From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: [PATCH RFC] Changing burstiness of sch_tbf
Date: Thu, 10 Apr 2014 13:57:02 +0200
Message-ID: <87eh15mm7l.fsf@toke.dk>
Content-Type: text/plain
Cc: Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([144.76.141.112]:38703 "EHLO mail2.tohojo.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030368AbaDJMEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 08:04:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I'm trying to get the tbf qdisc to stop being bursty after an idle
period. The use case is using it to emulate a physical link accurately;
where initial bursts can have effects that make the emulated link behave
differently than a physical link would.

Currently, if tbf's burst parameter is set lower than the interface MTU,
(large) packets will be dropped entirely. Setting it to the MTU makes
full-size packets be spaced appropriately at the configured rate,
however several smaller packets can be sent back-to-back up to a total
of the MTU size after an idle period.

The patch below fixes this by not carrying over tokens to the next
dequeue after a packet is successfully dequeued. It works as intended to
correctly space small packets (see tcpdump output below), however it
also effectively disables the burst mechanism, making the 'burst'
parameter work as a max packet size instead.

I would therefore like to solicit feedback on (a) the best way to
implement this while still keeping the burst functionality (burst-free
parameter, setting burst=0, something else?) and (b) whether such a
change would be eligible for inclusion?

Thanks,
-Toke


tcpdump output before patch; first 11 packets are sent back-to-back,
subsequent ones are spaced out.

tbf is configured for rate 100kbit burst 1514 in both runs. Traffic is
ping -f.

$ sudo tcpdump -i eth2 dst testserv-01
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 65535 bytes
12:08:13.765076 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 1, length 108
12:08:13.765825 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 2, length 108
12:08:13.766498 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 3, length 108
12:08:13.767148 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 4, length 108
12:08:13.767793 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 5, length 108
12:08:13.768443 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 6, length 108
12:08:13.769092 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 7, length 108
12:08:13.769745 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 8, length 108
12:08:13.770389 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 9, length 108
12:08:13.771038 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 10, length 108
12:08:13.771687 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 11, length 108
12:08:13.780300 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 12, length 108
12:08:13.791639 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 13, length 108
12:08:13.802997 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 14, length 108
12:08:13.814357 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 15, length 108
12:08:13.825717 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 16, length 108
12:08:13.837077 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 17, length 108
12:08:13.848438 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 18, length 108
12:08:13.859798 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 19, length 108
12:08:13.871157 IP 10.60.1.1 > testserv-01: ICMP echo request, id 7992, seq 20, length 108


After the patch; all packets are spaced out:

$ sudo tcpdump -i eth2 dst testserv-01
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), capture size 65535 bytes
13:07:44.272109 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 1, length 108
13:07:44.283472 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 2, length 108
13:07:44.294835 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 3, length 108
13:07:44.306198 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 4, length 108
13:07:44.317560 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 5, length 108
13:07:44.328929 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 6, length 108
13:07:44.340298 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 7, length 108
13:07:44.351661 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 8, length 108
13:07:44.363024 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 9, length 108
13:07:44.374386 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 10, length 108
13:07:44.385749 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 11, length 108
13:07:44.397117 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 12, length 108
13:07:44.408483 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 13, length 108
13:07:44.419846 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 14, length 108
13:07:44.431209 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 15, length 108
13:07:44.442572 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 16, length 108
13:07:44.453934 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 17, length 108
13:07:44.465302 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 18, length 108
13:07:44.476671 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 19, length 108
13:07:44.488035 IP 10.60.1.1 > testserv-01: ICMP echo request, id 2983, seq 20, length 108



diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 4f505a0..2d9e168 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -252,14 +252,14 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		if ((toks|ptoks) >= 0) {
 			skb = qdisc_dequeue_peeked(q->qdisc);
 			if (unlikely(!skb))
 				return NULL;
 
 			q->t_c = now;
-			q->tokens = toks;
-			q->ptokens = ptoks;
+			q->tokens = toks > 0 ? 0 : toks;
+			q->ptokens = ptoks > 0 ? 0 : ptoks;
 			sch->q.qlen--;
 			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
 			return skb;
 		}
 
