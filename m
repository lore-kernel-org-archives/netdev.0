From: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 16:29:02 +0200
Message-ID: <8021096.gY5K1ti0Dn@garfield>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com> <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33009 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661AbbIVO3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 10:29:18 -0400
Received: by lamp12 with SMTP id p12so14271357lam.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 07:29:16 -0700 (PDT)
In-Reply-To: <CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thanks for this report!

Thank you for answering!

> When you say "CWND is reduced due to loss", are you talking about RTO
> or Fast Recovery? Do you have any traces you can share that illustrate
> this issue?

The problem is not related to loss recovery, but only occurs in congestion
avoidance state. This is because tcp_is_cwnd_limited(), called from the
congestion controls ".cong_avoid" hook, will only use tp->is_cwnd_limited when
in congestion avoidance.

I've made two traces to compare the effect with and without the patch:
http://heim.ifi.uio.no/bendiko/traces/CWV_PATCH/

To ensure that the results are comparable, the traces are produced with an extra
patch applied (shown below) such that both connections are in congestion
avoidance from the beginning.

> Have you verified that this patch fixes the issue you identified? I
> think the fix may be in the wrong place for that scenario, or at least
> incomplete.

Yes, we have tested this and verified that the patch solves the issue in the
test scenarios we've run.

As always (in networking) it can be difficult to reproduce the issue in a
consistent manner, so I will describe the setup we have used.

In our testbed we have a sender host, a bridge and a receiver. The bridge is
configured with 75 ms delay in each direction, giving an RTT of 150 ms.

On bridge:
tc qdisc add dev eth0 handle 1:0 root netem delay 75ms
tc qdisc add dev eth1 handle 1:0 root netem delay 75ms

We have used the tool streamzero (https://bitbucket.org/bendikro/streamzero) to
produce the thin stream traffic. An example where the sender opens a TCP
connection and performs write calls to the socket every 10 ms with 100 bytes per
call for 60 seconds:

On receiver host (10.0.0.22):
./streamzero_srv -p 5010 -A

On sender host:
./streamzero_client -s 10.0.0.22 -p 5010 -v3 -A4 -d 60 -I i:10,S:100

streamzero_client will by default disable Nagle (TCP_NODELAY=1).

Adding loss for a few seconds in netem causes the CWND and ssthresh to
eventually drop to a low value, e.g. 2.

On bridge:
tc qdisc del dev eth1 root && tc qdisc add dev eth1 handle 1:0 root netem delay
75ms loss 4%

Removing loss after a few seconds:
tc qdisc del dev eth1 root && tc qdisc add dev eth1 handle 1:0 root netem delay
75ms

>From this point and on the CWND will not grow any further, as shown by the print
statement when applying this patch:

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d0ad355..947eb57 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2135,6 +2135,8 @@ repair:
 			break;
 	}
 
+	printk("CWND: %d, SSTHRESH: %d, PKTS_OUT: %d\n", tp->snd_cwnd, tp->snd_ssthresh, tp->packets_out);
+
 	if (likely(sent_pkts)) {
 		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += sent_pkts;


The following patch avoids the need to induce loss by setting the connection in
congestion avoidance from the beginning:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a62e9c7..206b32f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5394,6 +5394,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 
 	tcp_init_metrics(sk);
 +
	tp->snd_cwnd = tp->snd_ssthresh = 2;
 	tcp_init_congestion_control(sk);
 
 	/* Prevent spurious tcp_cwnd_restart() on first data


The traces linked to above are run with this patch applied.

> In the scenario you describe, you say "all the buffered data in the
> output queue was sent within the current CWND", which means that there
> is no unsent data, so in tcp_write_xmit() the call to tcp_send_head()
> would return NULL, so we would not enter the while loop, and could not
> set is_cwnd_limited to true.

I'll describe two example scenarios in detail. In both scenarios we are in
congestion avoidance after experiencing loss. Nagle is disabled.

Scenario 1:
Current CWND is 2 and there is currently one packet in flight. The output queue
contains one SKB with unsent data (payload <= 1 * MSS).

In tcp_write_xmit(), tcp_send_head() will return the SKB with unsent data, and
tcp_cwnd_test() will set cwnd_quota to 1, which means that is_cwnd_limited will
remain false. After sending the packet, sent_pkts will be set to 1, and the
while will break because tcp_send_head() returns NULL. tcp_cwnd_validate() will
be called with is_cwnd_limited=false.

When a new data chunk is put on the output queue, and tcp_write_xmit is called,
tcp_send_head() will return the SKB with unsent data. tcp_cwnd_test() will now
set cwnd_quota to 0 because packets in flight == CWND. is_cwnd_limited will
correctly be set to true, however, since no packets were sent,
tcp_cwnd_validate() will never be called.
(Calling tcp_cwnd_validate() if sent_pkts == 0 will not solve the problem in
this scenario as it will not enter the first if test in tcp_cwnd_validate()
where tp->is_cwnd_limited is updated.)


Scenario 2:
CWND is 2 and there is currently one packet in flight. The output queue contains
two SKBs with unsent data.

In tcp_write_xmit(), tcp_send_head() will return the first SKB with unsent data,
and tcp_cwnd_test() will set cwnd_quota to 1, which means that is_cwnd_limited
will remain false. After sending the packet, sent_pkts will be set to 1, and the
while loop continues on to the next (and last) SKB with unsent data returned by
tcp_send_head(). tcp_cwnd_test() will set cwnd_quota to 0 and is_cwnd_limited
will be set to true (and the while breaks). As one packet was sent, and one
packet was held back, tcp_cwnd_validate() will be called with
is_cwnd_limited=true, and tp->is_cwnd_limited will be set to true (as it
should).


In scenario 1, "all the buffered data in the output queue was sent within the
current CWND", and the result is that the CWND does not grow even when the CWND
is fully utilized after the packet is sent. In scenario 2, some of the unsent
data buffered in the output queue was not sent because there was no room in the
CWND, and this results in the CWND growing because tp->is_cwnd_limited was set
to true.

Analysing the traces with the analyseTCP
(https://bitbucket.org/mpg_code/tstools_analysetcp) gives the following results:

# ./analyseTCP -s 10.0.0.15 -f test_net-next.pcap
Processing sent packets...
Using filter: 'tcp && src host 10.0.0.15'
Finished processing sent packets...
Processing acknowledgements...
Finished processing acknowledgements...
STATS FOR CONN: 10.0.0.15:15000 -> 10.0.0.22:5010
  Duration: 61 seconds (0.016944 hours)
  Total packets sent                            :        782
  Total data packets sent                       :        779
  Total pure acks (no payload)                  :          2
  SYN/FIN/RST packets sent                      :      1/1/0
  Number of retransmissions                     :          0
  Number of packets with bundled segments       :          0
  Number of packets with redundant data         :          0
  Number of received acks                       :        779
  Total bytes sent (payload)                    :     555600
  Number of unique bytes                        :     555600
  Number of retransmitted bytes                 :          0
  Redundant bytes (bytes already sent)          :          0 (0.00 %)
  Estimated loss rate based on retransmissions  :       0.00 %
---------------------------------------------------------------
Payload size stats:
  Minimum    payload                            :     100 bytes
  Average    payload                            :     713 bytes
  Maximum    payload                            :    1448 bytes
---------------------------------------------------------------
Latency stats:
  Minimum    latency                            :  150244 usec
  Average    latency                            :  150675 usec
  Maximum    latency                            :  302493 usec
---------------------------------------------------------------
ITT stats:
  Minimum        itt                            :      12 usec
  Average        itt                            :   78383 usec
  Maximum        itt                            :  302704 usec
===============================================================


General info for entire dump:
  10.0.0.15: -> :
  Filename: test_net-next.pcap
  Sent Packet Count     : 782
  Received Packet Count : 0
  ACK Count             : 779
  Sent Bytes Count      : 555600
  Max payload size      : 1448
#


# ./analyseTCP -s 10.0.0.15 -f test_cwv_fix.pcap
Processing sent packets...
Using filter: 'tcp && src host 10.0.0.15'
Finished processing sent packets...
Processing acknowledgements...
Finished processing acknowledgements...
STATS FOR CONN: 10.0.0.15:15000 -> 10.0.0.22:5010
  Duration: 60 seconds (0.016667 hours)
  Total packets sent                            :       4760
  Total data packets sent                       :       4756
  Total pure acks (no payload)                  :          2
  SYN/FIN/RST packets sent                      :      1/1/0
  Number of retransmissions                     :          0
  Number of packets with bundled segments       :          0
  Number of packets with redundant data         :          0
  Number of received acks                       :       4758
  Total bytes sent (payload)                    :     483300
  Number of unique bytes                        :     483300
  Number of retransmitted bytes                 :          0
  Redundant bytes (bytes already sent)          :          0 (0.00 %)
  Estimated loss rate based on retransmissions  :       0.00 %
---------------------------------------------------------------
Payload size stats:
  Minimum    payload                            :     100 bytes
  Average    payload                            :     102 bytes
  Maximum    payload                            :    1400 bytes
---------------------------------------------------------------
Latency stats:
  Minimum    latency                            :  150221 usec
  Average    latency                            :  150340 usec
  Maximum    latency                            :  302022 usec
---------------------------------------------------------------
ITT stats:
  Minimum        itt                            :    1469 usec
  Average        itt                            :   12761 usec
  Maximum        itt                            :  302287 usec
===============================================================


General info for entire dump:
  10.0.0.15: -> :
  Filename: test_cwv_fix.pcap
  Sent Packet Count     : 4760
  Received Packet Count : 0
  ACK Count             : 4758
  Sent Bytes Count      : 483300
  Max payload size      : 1400
#


The key results revealing the effect of the proposed patch:

test_net-next.pcap:
Packets with payload sent: 779
Average payload per packet: 713 bytes
Average time between each packet transmission: 78.3 ms

test_cwv_fix.pcap:
Packets with payload sent: 4756
Average payload per packet: 102 bytes
Average time between each packet transmission: 12.7 ms


> In the scenario you describe, I think we'd need to check for being
> cwnd-limited in tcp_xmit_retransmit_queue().
> 
> How about something like the following patch:
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index d0ad355..8e6a772 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2145,6 +2145,7 @@ repair:
>                 tcp_cwnd_validate(sk, is_cwnd_limited);
>                 return false;
>         }
> +       tp->is_cwnd_limited |= is_cwnd_limited;
>         return !tp->packets_out && tcp_send_head(sk);
>  }
> 
> @@ -2762,8 +2763,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
>                  * packet to be MSS sized and all the
>                  * packet counting works out.
>                  */
> -               if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
> +               if (tcp_packets_in_flight(tp) >= tp->snd_cwnd) {
> +                       tp->is_cwnd_limited = true;
>                         return;
> +               }
> 
>                 if (fwd_rexmitting) {
>  begin_fwd:
> 
> neal

This will not fix the problem, as that would only set tp->is_cwnd_limited=true
once after retransmitting. The main issue is that the CWND does not grow for
these types of streams while no loss occurs, even when the CWND is fully
utilized (but only after a loss _has_ occurred to put the connection in
congestion avoidance).

When setting the initial CWND and ssthresh to 10 instead of 2 (with the patch
above to start in congestion avoidance), and running the same test as in the
traces (where the application performs ~15 write calls per RTT), the CWND never
grows past 10. When applying the proposed patch to update tp->is_cwnd_limited
when no packets are transmitted, the CWND grows to 13-14, which produces minimal
sojourn time for the segments written by the application.

Let me know if you need more information or additional test traces.

Bendik
