From: Johannes Naab <jn@stusta.de>
Subject: [PATCH] netem: fix delay calculation in rate extension
Date: Wed, 23 Jan 2013 22:36:51 +0100
Message-ID: <510057F3.80707@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stusta.mhn.de ([141.84.69.5]:52866 "EHLO
	mail.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab3AWVqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:46:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Naab <jn@stusta.de>

The delay calculation with the rate extension introduces in v3.3 does
not properly work, if other packets are still queued for transmission.
For the delay calculation to work, both delay types (latency and delay
introduces by rate limitation) have to be handled differently. The
latency delay for a packet can overlap with the delay of other packets.
The delay introduced by the rate however is separate, and can only
start, once all other rate-introduced delays finished.

Latency delay is from same distribution for each packet, rate delay
depends on the packet size.

.: latency delay
-: rate delay
x: additional delay we have to wait since another packet is currently
   transmitted

  .....----                    Packet 1
    .....xx------              Packet 2
               .....------     Packet 3
    ^^^^^
    latency stacks
         ^^
         rate delay doesn't stack
               ^^
               latency stacks
 
  -----> time

When a packet is enqueued, we first consider the latency delay. If other
packets are already queued, we can reduce the latency delay until the
last packet in the queue is send, however the latency delay cannot be
<0, since this would mean that the rate is overcommitted.  The new
reference point is the time at which the last packet will be send. To
find the time, when the packet should be send, the rate introduces delay
has to be added on top of that.

Signed-off-by: Johannes Naab <jn@stusta.de>
Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>
---

Consider the following setup:
node0 <---> node1

For both nodes, the ARP entries are fixed, so only our IP packets are
considered.

qdisc for node0 outgoing:
tc qdisc add dev eth1 root netem latency 1100ms rate 100Mbps

> $ ping -n -i 1.0 -c 5 10.0.1.1
> PING 10.0.1.1 (10.0.1.1) 56(84) bytes of data.
> 64 bytes from 10.0.1.1: icmp_req=1 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=2 ttl=64 time=1282 ms
> 64 bytes from 10.0.1.1: icmp_req=3 ttl=64 time=1660 ms
> 64 bytes from 10.0.1.1: icmp_req=4 ttl=64 time=2417 ms
> 
> --- 10.0.1.1 ping statistics ---
> 5 packets transmitted, 4 received, 20% packet loss, time 4012ms
> rtt min/avg/max/mdev = 1100.461/1615.107/2417.472/505.386 ms, pipe 2

The delay for each packet rises. (For me) the expected behavior would
be, that the delay does not increase with each additional packet.

This is the case if the interval between the pings is increased >1.1s

> $ ping -n -i 1.2 -c 5 10.0.1.1
> PING 10.0.1.1 (10.0.1.1) 56(84) bytes of data.
> 64 bytes from 10.0.1.1: icmp_req=1 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=2 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=3 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=4 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=5 ttl=64 time=1100 ms
> 
> --- 10.0.1.1 ping statistics ---
> 5 packets transmitted, 5 received, 0% packet loss, time 4803ms
> rtt min/avg/max/mdev = 1100.407/1100.551/1100.927/0.691 ms

or if the rate is not set
tc qdisc add dev eth1 root netem latency 1100ms

> $ ping -n -i 1.0 -c 5 10.0.1.1
> PING 10.0.1.1 (10.0.1.1) 56(84) bytes of data.
> 64 bytes from 10.0.1.1: icmp_req=1 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=2 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=3 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=4 ttl=64 time=1100 ms
> 64 bytes from 10.0.1.1: icmp_req=5 ttl=64 time=1100 ms
> 
> --- 10.0.1.1 ping statistics ---
> 5 packets transmitted, 5 received, 0% packet loss, time 4011ms
> rtt min/avg/max/mdev = 1100.416/1100.474/1100.553/0.939 ms, pipe 2


The following patch seems to fix the problem. However, since I have no
familiarity with the code, please review it carefully (both from a
logical as a technical point of view).

The following problems might come to mind:
- What happens when the latency or rate is changed?
- How does it play with reordered packets?
- skb_peek_tail(list) is accessed twice, is the lock held, the list
  private, or is it a bug waiting to happen?

I developed this patch while doing a student project at
http://www.nav.ei.tum.de/.


 net/sched/sch_netem.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 298c0dd..3d2acc7 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -438,18 +438,18 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->rate) {
 			struct sk_buff_head *list = &sch->q;
 
-			delay += packet_len_2_sched_time(skb->len, q);
-
 			if (!skb_queue_empty(list)) {
 				/*
-				 * Last packet in queue is reference point (now).
-				 * First packet in queue is already in flight,
-				 * calculate this time bonus and substract
+				 * Last packet in queue is reference point (now),
+				 * calculate this time bonus and subtract
 				 * from delay.
 				 */
-				delay -= now - netem_skb_cb(skb_peek(list))->time_to_send;
+				delay -= netem_skb_cb(skb_peek_tail(list))->time_to_send - now;
+				delay = max_t(psched_tdiff_t, 0, delay);
 				now = netem_skb_cb(skb_peek_tail(list))->time_to_send;
 			}
+
+			delay += packet_len_2_sched_time(skb->len, q);
 		}
 
 		cb->time_to_send = now + delay;
