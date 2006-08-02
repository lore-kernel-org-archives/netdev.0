From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/6] htb: remove lock macro
Date: Wed, 2 Aug 2006 12:58:50 -0700
Message-ID: <20060802125850.748fb0aa@dxpl.pdx.osdl.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48077 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932269AbWHBWMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:10 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of the macro's being used to obscure the locking.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_htb.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 73094e7..c0b80b7 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -72,8 +72,6 @@ #define HTB_HSIZE 16	/* classid hash siz
 #define HTB_EWMAC 2	/* rate average over HTB_EWMAC*HTB_HSIZE sec */
 #define HTB_RATECM 1    /* whether to use rate computer */
 #define HTB_HYSTERESIS 1/* whether to use mode hysteresis for speedup */
-#define HTB_QLOCK(S) spin_lock_bh(&(S)->dev->queue_lock)
-#define HTB_QUNLOCK(S) spin_unlock_bh(&(S)->dev->queue_lock)
 #define HTB_VER 0x30011	/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
@@ -667,7 +665,7 @@ static void htb_rate_timer(unsigned long
 	struct list_head *p;
 
 	/* lock queue so that we can muck with it */
-	HTB_QLOCK(sch);
+	spin_lock_bh(&sch->dev->queue_lock);
 
 	q->rttim.expires = jiffies + HZ;
 	add_timer(&q->rttim);
@@ -681,7 +679,7 @@ static void htb_rate_timer(unsigned long
 		RT_GEN (cl->sum_bytes,cl->rate_bytes);
 		RT_GEN (cl->sum_packets,cl->rate_packets);
 	}
-	HTB_QUNLOCK(sch);
+	spin_unlock_bh(&sch->dev->queue_lock);
 }
 #endif
 
@@ -1089,7 +1087,7 @@ static int htb_dump(struct Qdisc *sch, s
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
 	struct tc_htb_glob gopt;
-	HTB_QLOCK(sch);
+	spin_lock_bh(&sch->dev->queue_lock);
 	gopt.direct_pkts = q->direct_pkts;
 
 	gopt.version = HTB_VER;
@@ -1100,10 +1098,10 @@ static int htb_dump(struct Qdisc *sch, s
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	rta->rta_len = skb->tail - b;
-	HTB_QUNLOCK(sch);
+	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
 rtattr_failure:
-	HTB_QUNLOCK(sch);
+	spin_unlock_bh(&sch->dev->queue_lock);
 	skb_trim(skb, skb->tail - skb->data);
 	return -1;
 }
@@ -1116,7 +1114,7 @@ static int htb_dump_class(struct Qdisc *
 	struct rtattr *rta;
 	struct tc_htb_opt opt;
 
-	HTB_QLOCK(sch);
+	spin_lock_bh(&sch->dev->queue_lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
 	if (!cl->level && cl->un.leaf.q)
@@ -1133,10 +1131,10 @@ static int htb_dump_class(struct Qdisc *
 	opt.level = cl->level; 
 	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 	rta->rta_len = skb->tail - b;
-	HTB_QUNLOCK(sch);
+	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
 rtattr_failure:
-	HTB_QUNLOCK(sch);
+	spin_unlock_bh(&sch->dev->queue_lock);
 	skb_trim(skb, b - skb->data);
 	return -1;
 }
-- 
1.4.0

