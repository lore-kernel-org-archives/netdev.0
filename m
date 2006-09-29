From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 6/8][ATM]: [lec] use work queue instead of timer for lec arp expiry
Date: Fri, 29 Sep 2006 12:44:35 -0400
Message-ID: <200609291644.k8TGiZ5g025624@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:2525 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S932353AbWI2Qoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:44:55 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] use work queue instead of timer for lec arp expiry

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 0152dcfb9d42e203ff26d1619158c9664cfbf2d9
tree 24d0a36e52e7d4e86dd7bf1422ae9948011a194d
parent 693b186c2a764f62e017db4b7ed39298831d99e8
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 07:22:57 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Mon, 25 Sep 2006 07:22:57 -0400

 net/atm/lec.c |   17 +++++++----------
 net/atm/lec.h |    2 +-
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 87fb0c2..8a9f9ab 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1442,7 +1442,7 @@ #define DEBUG_ARP_TABLE 0
 
 #define LEC_ARP_REFRESH_INTERVAL (3*HZ)
 
-static void lec_arp_check_expire(unsigned long data);
+static void lec_arp_check_expire(void *data);
 static void lec_arp_expire_arp(unsigned long data);
 
 /* 
@@ -1465,11 +1465,8 @@ static void lec_arp_init(struct lec_priv
         INIT_HLIST_HEAD(&priv->lec_no_forward);
         INIT_HLIST_HEAD(&priv->mcast_fwds);
 	spin_lock_init(&priv->lec_arp_lock);
-	init_timer(&priv->lec_arp_timer);
-	priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
-	priv->lec_arp_timer.data = (unsigned long)priv;
-	priv->lec_arp_timer.function = lec_arp_check_expire;
-	add_timer(&priv->lec_arp_timer);
+	INIT_WORK(&priv->lec_arp_work, lec_arp_check_expire, priv);
+	schedule_delayed_work(&priv->lec_arp_work, LEC_ARP_REFRESH_INTERVAL);
 }
 
 static void lec_arp_clear_vccs(struct lec_arp_table *entry)
@@ -1719,7 +1716,7 @@ static void lec_arp_destroy(struct lec_p
 	struct lec_arp_table *entry;
 	int i;
 
-	del_timer_sync(&priv->lec_arp_timer);
+	cancel_rearming_delayed_work(&priv->lec_arp_work);
 
 	/*
 	 * Remove all entries
@@ -1865,10 +1862,10 @@ static void lec_arp_expire_vcc(unsigned 
  *       to ESI_FORWARD_DIRECT. This causes the flush period to end
  *       regardless of the progress of the flush protocol.
  */
-static void lec_arp_check_expire(unsigned long data)
+static void lec_arp_check_expire(void *data)
 {
 	unsigned long flags;
-	struct lec_priv *priv = (struct lec_priv *)data;
+	struct lec_priv *priv = data;
 	struct hlist_node *node, *next;
 	struct lec_arp_table *entry;
 	unsigned long now;
@@ -1930,7 +1927,7 @@ static void lec_arp_check_expire(unsigne
 	}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
-	mod_timer(&priv->lec_arp_timer, jiffies + LEC_ARP_REFRESH_INTERVAL);
+	schedule_delayed_work(&priv->lec_arp_work, LEC_ARP_REFRESH_INTERVAL);
 }
 
 /*
diff --git a/net/atm/lec.h b/net/atm/lec.h
index 8a6cb64..5bf3544 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -93,7 +93,7 @@ struct lec_priv {
 	spinlock_t lec_arp_lock;
 	struct atm_vcc *mcast_vcc;		/* Default Multicast Send VCC */
 	struct atm_vcc *lecd;
-	struct timer_list lec_arp_timer;	/* C10 */
+	struct work_struct lec_arp_work;	/* C10 */
 	unsigned int maximum_unknown_frame_count;
 						/*
 						 * Within the period of time defined by this variable, the client will send 
