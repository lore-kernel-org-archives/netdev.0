From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] net-tcp: fix cwnd reduction for non-sack recovery
Date: Thu, 23 Aug 2012 13:25:50 -0400
Message-ID: <CADVnQykjK=7cL9pu1EqU+HyiVX_ujSbJ-T1Ohb+M41w4rm1wuA@mail.gmail.com>
References: <1345741517-30504-1-git-send-email-ycheng@google.com>
	<CAB_+Fg6QhPDPo7o-QUMuOkkAuLWXPZwUoH2uG4q=jmph9Yv9ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
	mattmathis@google.com, netdev@vger.kernel.org
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43614 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964790Ab2HWRZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:25:52 -0400
Received: by obbuo13 with SMTP id uo13so2257076obb.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 10:25:51 -0700 (PDT)
In-Reply-To: <CAB_+Fg6QhPDPo7o-QUMuOkkAuLWXPZwUoH2uG4q=jmph9Yv9ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 1:21 PM, Nandita Dukkipati <nanditad@google.com> wrote:
> On Thu, Aug 23, 2012 at 10:05 AM, Yuchung Cheng <ycheng@google.com> wrote:
>> The cwnd reduction in fast recovery is based on the number of packets
>> newly delivered per ACK. For non-sack connections every DUPACK
>> signifies a packet has been delivered, but the sender mistakenly
>> skips counting them for cwnd reduction.
>>
>> The fix is to compute newly_acked_sacked after DUPACKs are accounted
>> in sacked_out for non-sack connections.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_input.c |   15 +++++++--------
>>  1 files changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index bcfccc5..ce4ffe9 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -2930,13 +2930,14 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
>>   * tcp_xmit_retransmit_queue().
>>   */
>>  static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
>> -                                 int newly_acked_sacked, bool is_dupack,
>> +                                 int prior_sacked, bool is_dupack,
>>                                   int flag)
>>  {
>>         struct inet_connection_sock *icsk = inet_csk(sk);
>>         struct tcp_sock *tp = tcp_sk(sk);
>>         int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
>>                                     (tcp_fackets_out(tp) > tp->reordering));
>> +       int newly_acked_sacked = 0;
>>         int fast_rexmit = 0;
>>
>>         if (WARN_ON(!tp->packets_out && tp->sacked_out))
>> @@ -2996,6 +2997,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
>>                                 tcp_add_reno_sack(sk);
>>                 } else
>>                         do_lost = tcp_try_undo_partial(sk, pkts_acked);
>> +               newly_acked_sacked = pkts_acked + tp->sacked_out - prior_sacked;
>>                 break;
>>         case TCP_CA_Loss:
>>                 if (flag & FLAG_DATA_ACKED)
>> @@ -3017,6 +3019,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
>>                         if (is_dupack)
>>                                 tcp_add_reno_sack(sk);
>>                 }
>> +               newly_acked_sacked = pkts_acked + tp->sacked_out - prior_sacked;
>>
>>                 if (icsk->icsk_ca_state <= TCP_CA_Disorder)
>>                         tcp_try_undo_dsack(sk);
>> @@ -3594,7 +3597,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>         int prior_packets;
>>         int prior_sacked = tp->sacked_out;
>>         int pkts_acked = 0;
>> -       int newly_acked_sacked = 0;
>>         bool frto_cwnd = false;
>>
>>         /* If the ack is older than previous acks
>> @@ -3670,8 +3672,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>         flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
>>
>>         pkts_acked = prior_packets - tp->packets_out;
>> -       newly_acked_sacked = (prior_packets - prior_sacked) -
>> -                            (tp->packets_out - tp->sacked_out);
>>
>>         if (tp->frto_counter)
>>                 frto_cwnd = tcp_process_frto(sk, flag);
>> @@ -3685,7 +3685,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>                     tcp_may_raise_cwnd(sk, flag))
>>                         tcp_cong_avoid(sk, ack, prior_in_flight);
>>                 is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
>> -               tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
>> +               tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
>>                                       is_dupack, flag);
>>         } else {
>>                 if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
>> @@ -3702,7 +3702,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>  no_queue:
>>         /* If data was DSACKed, see if we can undo a cwnd reduction. */
>>         if (flag & FLAG_DSACKING_ACK)
>> -               tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
>> +               tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
>>                                       is_dupack, flag);
>>         /* If this ack opens up a zero window, clear backoff.  It was
>>          * being used to time the probes, and is probably far higher than
>> @@ -3722,8 +3722,7 @@ old_ack:
>>          */
>>         if (TCP_SKB_CB(skb)->sacked) {
>>                 flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
>> -               newly_acked_sacked = tp->sacked_out - prior_sacked;
>> -               tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
>> +               tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
>>                                       is_dupack, flag);
>>         }
>>
>> --
>> 1.7.7.3
>>
> Acked-by: Nandita Dukkipati <nanditad@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
