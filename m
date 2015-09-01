From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 20/21] net: rbridge: replace net_port rx_handler
Date: Tue,  1 Sep 2015 17:43:15 +0200
Message-ID: <1441122196-11662-21-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:39558 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752327AbbIAPxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:40 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace classic rx_handler in bridge by the new rbr_handle_frame in
order to provide trill support

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_if.c      |  7 ++++++-
 net/bridge/br_private.h |  1 +
 net/bridge/rbr.c        | 20 ++++++++++++++++----
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a538cb1..3b39f69 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -483,7 +483,12 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err3;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+#ifdef CONFIG_TRILL
+	if (br->trill_enabled == BR_TRILL)
+		err = netdev_rx_handler_register(dev, rbr_handle_frame, p);
+	else
+#endif
+		err = netdev_rx_handler_register(dev, br_handle_frame, p);
 	if (err)
 		goto err4;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5e622e1..27d5cd8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -852,6 +852,7 @@ ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 /* rbr.c */
 #ifdef CONFIG_TRILL
 void br_trill_set_enabled(struct net_bridge *br, unsigned long val);
+rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb);
 #endif
 
 /* br_stp_bpdu.c */
diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index 23f3e1d..2fb9b81 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -38,21 +38,28 @@ static struct rbr *add_rbr(struct net_bridge *br)
 
 static void br_trill_start(struct net_bridge *br)
 {
+	struct net_bridge_port *p;
 	/* Disable STP if it is already enabled */
 
 	if (br->stp_enabled != BR_NO_STP)
 		br_stp_set_enabled(br, false);
 	br->rbr = add_rbr(br);
-	if (br->rbr)
+	if (br->rbr) {
+		list_for_each_entry(p, &br->port_list, list) {
+			struct net_device *dev = p->dev;
+
+			rcu_assign_pointer(dev->rx_handler, rbr_handle_frame);
+		}
 		br->trill_enabled = BR_TRILL;
-	else
-		pr_warn("RBridge allocation for bridge '%s' failed\n",
-			br->dev->name);
+		return;
+	}
+	pr_warn("RBridge allocation for bridge '%s' failed\n", br->dev->name);
 }
 
 static void br_trill_stop(struct net_bridge *br)
 {
 	struct rbr *old;
+	struct net_bridge_port *p;
 
 	spin_lock_bh(&br->lock);
 	br->trill_enabled = BR_NO_TRILL;
@@ -60,6 +67,11 @@ static void br_trill_stop(struct net_bridge *br)
 	old = br->rbr;
 	br->rbr = NULL;
 	if (likely(old)) {
+		list_for_each_entry(p, &br->port_list, list) {
+			struct net_device *dev = p->dev;
+
+			rcu_assign_pointer(dev->rx_handler, br_handle_frame);
+		}
 		rbr_del_all(old);
 		kfree(old);
 	}
-- 
2.1.4
