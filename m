From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem --
Date: Tue, 13 Jul 2004 15:19:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713151959.2470a211@dell_ss3.pdx.osdl.net>
References: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The netem scheduler needs to limit its delayed packet queue to prevent
a application burst from chewing up too much memory.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-07-13 13:02:58 -07:00
+++ b/net/sched/sch_netem.c	2004-07-13 13:02:58 -07:00
@@ -643,11 +643,17 @@
 	PSCHED_TADD2(now, delay, cb->time_to_send);
 	
 	/* Always queue at tail to keep packets in order */
-	__skb_queue_tail(&q->delayed, skb);
-	sch->q.qlen++;
-	sch->stats.bytes += skb->len;
-	sch->stats.packets++;
-	return 0;
+	if (likely(q->delayed.qlen < q->limit)) {
+		__skb_queue_tail(&q->delayed, skb);
+		sch->q.qlen++;
+		sch->stats.bytes += skb->len;
+		sch->stats.packets++;
+		return 0;
+	}
+
+	sch->stats.drops++;
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
 }
 
 /* Requeue packets but don't change time stamp */
