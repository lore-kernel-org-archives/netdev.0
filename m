From: Ferry Huberts <mailings@hupie.com>
Subject: [PATCH v2 2/2] net: netem: always adjust now/delay when not reordering
Date: Wed, 21 Aug 2013 07:59:45 +0200
Message-ID: <1377064785-12629-1-git-send-email-mailings@hupie.com>
References: <1377030800.4226.89.camel@edumazet-glaptop>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:48133 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012Ab3HUF7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 01:59:47 -0400
Received: from stinkpad.internal.hupie.com.internal.hupie.com (s529dac66.adsl.online.nl [82.157.172.102])
	by hupie.dyndns.org (Postfix) with ESMTP id 533DF485E18
	for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 07:59:46 +0200 (CEST)
In-Reply-To: <1377030800.4226.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ferry Huberts <ferry.huberts@pelagic.nl>

Not doing this (current behaviour) introduces reordering.

The packet_len_2_sched_time call is the only thing that logically
depends on q->rate, so move the now/delay adjustment out of the if.

How to test:
------------
- Create a script to ping the default gateway using a queueing discipline:
cat > ./netemreordering << "EOF"
fields=( $(route -n | grep -E '^0.0.0.0\b' | awk '{ print $2 " " $NF; }') )
tc qdisc del dev "${fields[1]}" root
tc qdisc add dev "${fields[1]}" handle 1 root netem delay 10ms 500ms
ping -c 10 -i 0.1 -W 18 "${fields[0]}"
tc qdisc del dev "${fields[1]}" root
EOF
chmod 755 ./netemreordering
- Run the script:
sudo ./netemreordering


Current Behaviour:
------------------
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=111 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=311 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=201 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=412 ms
64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=58.1 ms
64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=168 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=379 ms
64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=171 ms
64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=62.0 ms
64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=491 ms

--- 10.0.0.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 961ms
rtt min/avg/max/mdev = 58.105/236.707/491.683/144.911 ms, pipe 5


Fixed Behaviour:
----------------
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=244 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=135 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=188 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=87.7 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=207 ms
64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=107 ms
64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=199 ms
64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=98.4 ms
64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=61.0 ms
64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=295 ms

--- 10.0.0.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 912ms
rtt min/avg/max/mdev = 61.002/162.580/295.638/72.336 ms, pipe 3


v2:
- fix checkpatch 'braces' warning
- add more comments on how to test

Reported-by: Teco Boot <teco@inf-net.nl>
Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
---
 net/sched/sch_netem.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index abe5fa6..64e0653 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -457,6 +457,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->gap == 0 || q->reorder == 0 || /* not doing reordering */
 	    q->counter < q->gap - 1 ||	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
+		struct sk_buff *last;
+
 		psched_time_t now;
 		psched_tdiff_t delay;
 
@@ -465,26 +467,23 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		now = psched_get_time();
 
-		if (q->rate) {
-			struct sk_buff *last;
-
-			if (!skb_queue_empty(&sch->q))
-				last = skb_peek_tail(&sch->q);
-			else
-				last = netem_rb_to_skb(rb_last(&q->t_root));
-			if (last) {
-				/*
-				 * Last packet in queue is reference point (now),
-				 * calculate this time bonus and subtract
-				 * from delay.
-				 */
-				delay -= netem_skb_cb(last)->time_to_send - now;
-				delay = max_t(psched_tdiff_t, 0, delay);
-				now = netem_skb_cb(last)->time_to_send;
-			}
+		if (!skb_queue_empty(&sch->q))
+			last = skb_peek_tail(&sch->q);
+		else
+			last = netem_rb_to_skb(rb_last(&q->t_root));
+		if (last) {
+			/*
+			 * Last packet in queue is reference point (now),
+			 * calculate this time bonus and subtract
+			 * from delay.
+			 */
+			delay -= netem_skb_cb(last)->time_to_send - now;
+			delay = max_t(psched_tdiff_t, 0, delay);
+			now = netem_skb_cb(last)->time_to_send;
+		}
 
+		if (q->rate)
 			delay += packet_len_2_sched_time(skb->len, q);
-		}
 
 		cb->time_to_send = now + delay;
 		cb->tstamp_save = skb->tstamp;
-- 
1.8.3.1
