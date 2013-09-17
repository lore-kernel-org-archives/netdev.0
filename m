From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Why we discard all rtt samples when only some of the acked skbs
 have been retransmited in processing ack?
Date: Tue, 17 Sep 2013 07:53:31 -0700
Message-ID: <CAK6E8=cY77JDkHE3Z_rZCO=FComk1YmkiKvqnBcMnf+wXY5xzg@mail.gmail.com>
References: <CAAA3+BpsxtyM2uAvX6B4ys73ZC6fX5K1ib3Acsk0fp5cQBNgWg@mail.gmail.com>
 <1379394682.29845.2.camel@edumazet-glaptop> <CADVnQykjm8nxVYzFu7=RfdcOH-cdARarSoRyBwj9Rp0m-+VKEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LovelyLich <lovelylich@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35182 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab3IQOxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 10:53:52 -0400
Received: by mail-ie0-f178.google.com with SMTP id to1so9987203ieb.23
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 07:53:51 -0700 (PDT)
In-Reply-To: <CADVnQykjm8nxVYzFu7=RfdcOH-cdARarSoRyBwj9Rp0m-+VKEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 6:31 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Tue, Sep 17, 2013 at 1:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2013-09-17 at 12:01 +0800, LovelyLich wrote:
>>> Hi Eric,
>>>
>>> In tcp_clean_rtx_queue(), we set the flag FLAG_RETRANS_DATA_ACKED when we
>>>
>>> encounter one ever retransmited skb A. But if there is one( or more) skb B
>>>
>>> after this retransmited skb, and we calculate the rtt for skb B. The question
>>>
>>> is because we have set the flag FLAG_RETRANS_DATA_ACKED, and we will just
>>>
>>> return in tcp_ack_no_tstamp() !
>>>
>>> Two questions:
>>>
>>> 1. if we will just ignore all packets in this ack, we do not need to calculate
>>>
>>> skb B's rtt sample.
>>>
>>> 2. what I want to know, even if A's rtt sample is not reliable, but B's rtt
>>>
>>> sample can be trusted. Why we discard it ?
>>>
>>>
>>>
>>> Thanks in advanced.
>>>
>>
>> Good point !
>>
>> Yuchung, what do you think of following patch ?
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 25a89ea..7f12b96 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -2971,7 +2971,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>>         struct sk_buff *skb;
>>         u32 now = tcp_time_stamp;
>>         int fully_acked = true;
>> -       int flag = 0;
>> +       int flag = FLAG_RETRANS_DATA_ACKED;
>>         u32 pkts_acked = 0;
>>         u32 reord = tp->packets_out;
>>         u32 prior_sacked = tp->sacked_out;
>> @@ -3002,7 +3002,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>>                 if (sacked & TCPCB_RETRANS) {
>>                         if (sacked & TCPCB_SACKED_RETRANS)
>>                                 tp->retrans_out -= acked_pcount;
>> -                       flag |= FLAG_RETRANS_DATA_ACKED;
>>                 } else {
>>                         ca_seq_rtt = now - scb->when;
>>                         last_ackt = skb->tstamp;
>> @@ -3013,6 +3012,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>>                                 reord = min(pkts_acked, reord);
>>                         if (!after(scb->end_seq, tp->high_seq))
>>                                 flag |= FLAG_ORIG_SACK_ACKED;
>> +                       flag &= ~FLAG_RETRANS_DATA_ACKED;
>>                 }
>>
>>                 if (sacked & TCPCB_SACKED_ACKED)
>
> I think the existing logic is better than the patch. If we get a
> cumulative ACK that covers a retransmitted packet, then any RTT sample
> we try to extract is suspect, and likely to be at least 2x too high.
>
> Consider the following common scenario:
>
> t=0: send pkts 1, 2, 3, 4
> t=1*RTT: receive dupack with SACK for pkts 2,3,4; fast retransmit  pkt 1
> t=2*RTT: receive cumulative ack for all pkts through 4
>
> With the existing logic, because the ACK we get at t=2*RTT covers the
> retransmitted pkt 1, we do not attempt to take an RTT sample.
>
> With that proposed patch, when we get the ACK at t=2*RTT we see that
> there are non-retransmitted pkts 2,3,4 being ACKed, so we clear the
> FLAG_RETRANS_DATA_ACKED bit and take an RTT sample of 2*RTT. But this
> is 2x too big, and will distort our RTT sample.

Yes I completely agree with Neal's analysis. In fact I've considered
the proposed change when I implement the patch quoted below, and later
realized it actually breaks Karn's algorithm: to properly take an RTT
sample w/o ambiguity, all, not just some, of the packets cumulatively
acked must not been retransmitted.

>
> Note that with Yuchung's recent patch to gather RTT samples from
> SACKed packets (59c9af4234b0c21a1ed05cf65bf014d0c1a67bfd "tcp: measure
> RTT from new SACK"), we will already be extracting essentially all the
> RTT samples that we possibly can out of such scenarios with
> retransmitted packets (for OSes that support SACK, which is basically
> everyone). In the example above, Yuchung's new SACK-based RTT scheme
> will correctly take RTT samples at t=1*RTT for the SACKed packets.
>
> neal
