From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netem: restart device after inserting packets
Date: Fri, 10 Dec 2004 04:33:21 +0100
Message-ID: <41B91901.3070304@trash.net>
References: <20041208123103.4cc6b005@dxpl.pdx.osdl.net> <20041208210031.63f0963f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050406000709040107090906"
Cc: Stephen Hemminger <shemminger@osdl.org>, netem@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041208210031.63f0963f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050406000709040107090906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David S. Miller wrote:

>On Wed, 8 Dec 2004 12:31:03 -0800
>Stephen Hemminger <shemminger@osdl.org> wrote:
>  
>
>>The version of netem in 2.6.10 moves packets from the delayed queue
>>to the qdisc in a timer interrupt. But it forgot to force the device to
>>pick them up.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>>
>
>Good spotting.  Applied, thanks Stephen.
>
The patch is incomplete, netem may dequeue multiple packets from
the delayed queue at once and feed them to the inner queue, but
qdisc_restart will only dequeue one packet from the inner queue.
This patch moves qdisc_run back to include/net/pkt_sched.h and
replaces qdisc_restart by qdisc_run in netem_watchdog.

Regards
Patrick


--------------050406000709040107090906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/10 04:24:22+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Keep netem queue running until inner qdisc is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_netem.c
#   2004/12/10 04:24:13+01:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Keep netem queue running until inner qdisc is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/core/dev.c
#   2004/12/10 04:24:13+01:00 kaber@coreworks.de +0 -7
#   [PKT_SCHED]: Keep netem queue running until inner qdisc is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/pkt_sched.h
#   2004/12/10 04:24:13+01:00 kaber@coreworks.de +6 -0
#   [PKT_SCHED]: Keep netem queue running until inner qdisc is empty
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-12-10 04:24:54 +01:00
+++ b/include/net/pkt_sched.h	2004-12-10 04:24:54 +01:00
@@ -228,6 +228,12 @@
 
 extern int qdisc_restart(struct net_device *dev);
 
+static inline void qdisc_run(struct net_device *dev)
+{
+	while (!netif_queue_stopped(dev) && qdisc_restart(dev) < 0)
+		/* NOTHING */;
+}
+
 extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct tcf_result *res);
 
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-12-10 04:24:54 +01:00
+++ b/net/core/dev.c	2004-12-10 04:24:54 +01:00
@@ -1202,13 +1202,6 @@
 	}						\
 }
 
-static inline void qdisc_run(struct net_device *dev)
-{
-	while (!netif_queue_stopped(dev) &&
-	       qdisc_restart(dev)<0)
-		/* NOTHING */;
-}
-
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-12-10 04:24:54 +01:00
+++ b/net/sched/sch_netem.c	2004-12-10 04:24:54 +01:00
@@ -287,7 +287,7 @@
 		else
 			sch->q.qlen++;
 	}
-	qdisc_restart(dev);
+	qdisc_run(dev);
 	spin_unlock_bh(&dev->queue_lock);
 }
 

--------------050406000709040107090906--
