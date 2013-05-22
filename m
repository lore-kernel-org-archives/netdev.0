From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: bug fix in proportional rate reduction.
Date: Tue, 21 May 2013 18:12:40 -0700
Message-ID: <CAB_+Fg6Up-XzydZEewt-nt-Bp9+OLEVX29ccaG4m9pkps+1ADg@mail.gmail.com>
References: <1369095724-17745-1-git-send-email-nanditad@google.com>
	<CAK6E8=fcaXtnw0=9Btyboike3OQS81UiGGTc0rAsb5=f+Xf6-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:48986 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab3EVBMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 21:12:40 -0400
Received: by mail-ob0-f176.google.com with SMTP id wp18so1567257obc.21
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 18:12:40 -0700 (PDT)
In-Reply-To: <CAK6E8=fcaXtnw0=9Btyboike3OQS81UiGGTc0rAsb5=f+Xf6-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 8:18 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Mon, May 20, 2013 at 5:22 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> This patch is a fix for a bug triggering newly_acked_sacked < 0
>> in tcp_ack(.).
>>
>> The bug is triggered by sacked_out decreasing relative to prior_sacked,
>> but packets_out remaining the same as pior_packets. This is because the
>> snapshot of prior_packets is taken after tcp_sacktag_write_queue() while
>> prior_sacked is captured before tcp_sacktag_write_queue(). The problem
>> is: tcp_sacktag_write_queue (tcp_match_skb_to_sack() -> tcp_fragment)
>> adjusts the pcount for packets_out and sacked_out (MSS change or other
>> reason). As a result, this delta in pcount is reflected in
>> (prior_sacked - sacked_out) but not in (prior_packets - packets_out).
> I don't think this patch fixes the problem you described because
> it does not change how newly_acked_sacked is computed.
>
> you probably should use prior_packets for newly_acked_sacked and use
>  previous_packets_out for pkts_acked

Good catch, you are absolutely right. Sent a v2.

>
>>
>> This patch does the following:
>> 1) initializes prior_packets at the start of tcp_ack() so as to
>> capture the delta in packets_out created by tcp_fragment.
>> 2) introduces a new "previous_packets_out" variable that snapshots
>> packets_out right before tcp_clean_rtx_queue, so pkts_acked can be
>> correctly computed as before.
>>
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
>> ---
>>  net/ipv4/tcp_input.c | 7 ++++---
>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index d7d3694..2986e10 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -3265,9 +3265,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>         bool is_dupack = false;
>>         u32 prior_in_flight;
>>         u32 prior_fackets;
>> -       int prior_packets;
>> +       int prior_packets = tp->packets_out;
>>         int prior_sacked = tp->sacked_out;
>>         int pkts_acked = 0;
>> +       int previous_packets_out = 0;
>>
>>         /* If the ack is older than previous acks
>>          * then we can probably ignore it.
>> @@ -3338,14 +3339,14 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>>         sk->sk_err_soft = 0;
>>         icsk->icsk_probes_out = 0;
>>         tp->rcv_tstamp = tcp_time_stamp;
>> -       prior_packets = tp->packets_out;
>>         if (!prior_packets)
>>                 goto no_queue;
>>
>>         /* See if we can take anything off of the retransmit queue. */
>> +       previous_packets_out = tp->packets_out;
>>         flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
>>
>> -       pkts_acked = prior_packets - tp->packets_out;
>> +       pkts_acked = previous_packets_out - tp->packets_out;
>>
>>         if (tcp_ack_is_dubious(sk, flag)) {
>>                 /* Advance CWND, if state allows this. */
>> --
>> 1.8.2.1
>>
