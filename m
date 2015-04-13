From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH RFC net-next] tcp: improve SACK RTT for CC
Date: Sun, 12 Apr 2015 21:24:20 -0700
Message-ID: <CAK6E8=chmgkJf1-4m+SjMLQm2na0AaP6-bdJebb1yMQ=wx01nQ@mail.gmail.com>
References: <1428861117-24064-1-git-send-email-kennetkl@ifi.uio.no> <1428863848.25985.359.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37548 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbDMEZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 00:25:01 -0400
Received: by igblo3 with SMTP id lo3so35425212igb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 21:25:00 -0700 (PDT)
In-Reply-To: <1428863848.25985.359.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2015 at 11:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2015-04-12 at 19:51 +0200, Kenneth Klette Jonassen wrote:
>> tcp_sacktag_one() always picks the earliest sequence SACKed for RTT.
>> This might not make sense for congestion control in cases where:
>>
>>   1. ACKs are lost, i.e. a SACK subsequent to a lost SACK covers both
>>      a new and an old segment at the receiver.
>>   2. The receiver disregards the RFC 5681 recommendation to immediately
>>      ACK out-of-order segments.
>>
>> Give congestion control a RTT for the latest segment SACKed, which is the
>> most accurate RTT estimate, but preserve the conservative RTT for RTO.
>>
>> Also remove the dependency on skb_mstamp_get() in tcp_sacktag_one() which
>> potentially contributes to variance between RTT signals.
>>
>> This is a request for comments. For full effect, a later patch would move
>> the call to pkts_acked() outside the scope of if (flag & FLAG_ACKED). As is,
>> this hook only gets called when sequentially acknowledging new data.
>> ---
>>  net/ipv4/tcp_input.c | 90 ++++++++++++++++++++++++++++++----------------------
>>  1 file changed, 52 insertions(+), 38 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index a7ef679..8f0bd3c 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -1130,7 +1130,16 @@ static bool tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
>>  struct tcp_sacktag_state {
>>       int     reord;
>>       int     fack_count;
>> -     long    rtt_us; /* RTT measured by SACKing never-retransmitted data */
>> +     /* Timestamp for earliest never-retransmitted segment that was
>> +      * SACKed and its usec delta to the corresponding latest segment.
>> +      * RTO needs the earliest RTT to be conservative against receivers
>> +      * that might delay SACKing (RFC 5681 does not require ACKing
>> +      * out-of-order segments immediately), but congestion control should
>> +      * still get an accurate delay signal. Even without delayed SACKing,
>> +      * this helps mitigate the effect of ACK loss on delay-based CC.
>> +      */
>> +     struct skb_mstamp first_ackt;
>> +     u32     last_ack_us_delta;
>>       int     flag;
>>  };
>>
>> @@ -1233,14 +1242,13 @@ static u8 tcp_sacktag_one(struct sock *sk,
>>                                                          state->reord);
>>                               if (!after(end_seq, tp->high_seq))
>>                                       state->flag |= FLAG_ORIG_SACK_ACKED;
>> -                             /* Pick the earliest sequence sacked for RTT */
>> -                             if (state->rtt_us < 0) {
>> -                                     struct skb_mstamp now;
>>
>> -                                     skb_mstamp_get(&now);
>> -                                     state->rtt_us = skb_mstamp_us_delta(&now,
>> -                                                             xmit_time);
>> -                             }
>> +                             if (state->first_ackt.v64 == 0)
>> +                                     state->first_ackt.v64 = xmit_time->v64;
state->first_ackt = *xmit_time?

>> +                             else
>> +                                     state->last_ack_us_delta =
>> +                                              skb_mstamp_us_delta(xmit_time,
>> +                                                                  &state->first_ackt);
>
> I do not think you need to perform this skb_mstamp_us_delta() at this
> point.
>
> Instead of storing a state->last_ack_us_delta, I would store
> state->last_ackt
>
> And later doing a single skb_mstamp_us_delta()
yes I agree with Eric that having last_ackt and first_act are better.
perhaps s/ackt/sackt too?
>
>
>
