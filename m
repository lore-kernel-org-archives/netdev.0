From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Fri, 18 Mar 2016 00:26:38 +0100
Message-ID: <56EB3D2E.7090303@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eXH1HEXEWiAnUTT65i9=M=j1W1v3MQFSxvk2xF_TNLZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:34995 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcCQX0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 19:26:43 -0400
Received: by mail-lb0-f196.google.com with SMTP id wn5so5847003lbb.2
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 16:26:42 -0700 (PDT)
In-Reply-To: <CAK6E8=eXH1HEXEWiAnUTT65i9=M=j1W1v3MQFSxvk2xF_TNLZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 6a92b15..8f3f3bf 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -716,6 +716,21 @@ tcp_thin_dpifl_itt_lower_bound - INTEGER
>>         calculated, which is used to classify whether a stream is thin.
>>         Default: 10000
>>
>> +tcp_rdb - BOOLEAN
>> +       Enable RDB for all new TCP connections.
>   Please describe RDB briefly, perhaps with a pointer to your paper.

Ah, yes, that description may have been a bit too brief...

What about pointing to tcp-thin.txt in the brief description, and
rewrite tcp-thin.txt with a more detailed description of RDB along
with a paper reference?

>    I suggest have three level of controls:
>    0: disable RDB completely
>    1: enable indiv. thin-stream conn. to use RDB via TCP_RDB socket
> options
>    2: enable RDB on all thin-stream conn. by default
>
>    currently it only provides mode 1 and 2. but there may be cases where
>    the administrator wants to disallow it (e.g., broken middle-boxes).

Good idea. Will change this.

>> +       Default: 0
>> +
>> +tcp_rdb_max_bytes - INTEGER
>> +       Enable restriction on how many bytes an RDB packet can contain.
>> +       This is the total amount of payload including the new unsent data.
>> +       Default: 0
>> +
>> +tcp_rdb_max_packets - INTEGER
>> +       Enable restriction on how many previous packets in the output queue
>> +       RDB may include data from. A value of 1 will restrict bundling to
>> +       only the data from the last packet that was sent.
>> +       Default: 1
>  why two metrics on redundancy?

We have primarily used the packet based limit in our tests. This is
also the most important knob as it directly controls how many lost
packets each RDB packet may recover.

We believe that the byte based limit can also be useful because it
allows more fine grained control on how much impact RDB can have on
the increased bandwidth requirements of the flows. If an application
writes 700 bytes per write call, the bandwidth increase can be quite
significant (even with a 1 packet bundling limit) if we consider a
scenario with thousands of RDB streams.

In some of our experiments with many simultaneous thin streams, where
we set up a bottleneck rate limited by a htb with pfifo queue, we
observed considerable difference in loss rates depending on how many
bytes (packets) were allowed to be bundled with each packet. This is
partly why we recommend a default bundling limit of 1 packet.

By limiting the total payload size of RDB packets to e.g. 100 bytes,
only the smallest segments will benefit from RDB, while the segments
that would increase the bandwidth requirements the most, will not.

While a very large number of RDB streams from one sender may be a
corner case, we still think this sysctl knob can be valuable for a
sysadmin that finds himself in such a situation.

> It also seems better to
> allow individual socket to select the redundancy level (e.g.,
> setsockopt TCP_RDB=3 means <=3 pkts per bundle) vs a global setting.
> This requires more bits in tcp_sock but 2-3 more is suffice.

Most certainly. We decided not to implement this for the patch to keep
it as simple as possible, however, we surely prefer to have this
functionality included if possible.

>> +static unsigned int rdb_detect_loss(struct sock *sk)
>> +{
...
>> +               tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
>> +                       if (before(TCP_SKB_CB(skb)->seq, scb->tx.rdb_start_seq))
>> +                               break;
>> +                       packets_lost++;
> since we only care if there is packet loss or not, we can return early here?

Yes, I considered that, and as long as the number of packets presumed
to be lost is not needed, that will suffice. However, could this not
be useful for statistical purposes?

This is also relevant to the comment from Eric on SNMP counters for
how many times losses could be repaired by RDB?

>> +               }
>> +               break;
>> +       }
>> +       return packets_lost;
>> +}
>> +
>> +/**
>> + * tcp_rdb_ack_event() - initiate RDB loss detection
>> + * @sk: socket
>> + * @flags: flags
>> + */
>> +void tcp_rdb_ack_event(struct sock *sk, u32 flags)
> flags are not used

Ah, yes, will remove that.

>> +int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_skb,
>> +                        unsigned int mss_now, gfp_t gfp_mask)
>> +{
>> +       struct sk_buff *rdb_skb = NULL;
>> +       struct sk_buff *first_to_bundle;
>> +       u32 bytes_in_rdb_skb = 0;
>> +
>> +       /* How we detect that RDB was used. When equal, no RDB data was sent */
>> +       TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq = TCP_SKB_CB(xmit_skb)->seq;
>
>> +
>> +       if (!tcp_stream_is_thin_dpifl(tcp_sk(sk)))
> During loss recovery tcp inflight fluctuates and would like to trigger
> this check even for non-thin-stream connections.

Good point.

> Since the loss
> already occurs, RDB can only take advantage from limited-transmit,
> which it likely does not have (b/c its a thin-stream). It might be
> checking if the state is open.

You mean to test for open state to avoid calling rdb_can_bundle_test()
unnecessarily if we (presume to) know it cannot bundle anyway? That
makes sense, however, I would like to do some tests on whether "state
!= open" is a good indicator on when bundling is not possible.

>> +               goto xmit_default;
>> +
>> +       /* No bundling if first in queue, or on FIN packet */
>> +       if (skb_queue_is_first(&sk->sk_write_queue, xmit_skb) ||
>> +           (TCP_SKB_CB(xmit_skb)->tcp_flags & TCPHDR_FIN))
> seems there are still benefit to bundle packets up to FIN?

I was close to removing the FIN test, but decided to not remove it
until I could verify that it will not cause any issues on some TCP
receivers. If/(Since?) you are certain it will not cause any issues, I
will remove it.

> since RDB will cause DSACKs, and we only blindly count DSACKs to
> perform CWND undo. How does RDB handle that false positives?

That is a very good question. The simple answer is that the
implementation does not handle any such false positives, which I
expect can result in incorrectly undoing CWND reduction in some cases.
This gets a bit complicated, so I'll have to do some more testing on
this to verify with certainty when it happens.

When there is no loss, and each RDB packet arriving at the receiver
contains both already received and new data, the receiver will respond
with an ACK that acknowledges new data (moves snd_una), with the SACK
field populated with the already received sequence range (DSACK).

The DSACKs in these incoming ACKs are not counted (tp->undo_retrans--)
unless tp->undo_marker has been set by tcp_init_undo(), which is
called by either tcp_enter_loss() or tcp_enter_recovery(). However,
whenever a loss is detected by rdb_detect_loss(), tcp_enter_cwr() is
called, which disables CWND undo. Therefore, I believe the incorrect
counting of DSACKs from ACKs on RDB packets will only be a problem
after the regular loss detection mechanisms (Fast Retransmit/RTO) have
been triggered (i.e. we are in either TCP_CA_Recovery or TCP_CA_Loss).

We have recorded the CWND values for both RDB and non-RDB streams in
our experiments, and have not found any obvious red flags when
analysing the results, so I presume (hope may be more precise) this is
not a major issue we have missed. Nevertheless, I will investigate
this in detail and get back to you.


Thank you for the detailed comments.

Bendik
