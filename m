From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 1/5] cxgb4vf: Virtual Interfaces are always up ...
Date: Fri, 11 Feb 2011 17:00:19 -0800
Message-ID: <1297472423-15672-2-git-send-email-leedom@chelsio.com>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14825 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882Ab1BLBA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 20:00:27 -0500
In-Reply-To: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement new default mode of always reporting the Virtual Interface link as
being "up".  This allows different Virtual Interfaces on the same port to
continue to communicate with each other even when the physical port link is
down.  This new behavior is controlled via the module parameter
force_link_up (default 1).  The old behavior can be achieved by setting
force_link_up=0.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 56166ae..08c2b29 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -96,6 +96,18 @@ module_param(msi, int, 0644);
 MODULE_PARM_DESC(msi, "whether to use MSI-X or MSI");
 
 /*
+ * The Virtual Interfaces are connected to an internal switch on the chip
+ * which allows VIs attached to the same port to talk to each other even when
+ * the port link is down.  As a result, we generally want to always report a
+ * VI's link as being "up".
+ */
+static int force_link_up = 1;
+
+module_param(force_link_up, int, 0644);
+MODULE_PARM_DESC(force_link_up, "always report link up");
+
+
+/*
  * Fundamental constants.
  * ======================
  */
@@ -151,7 +163,8 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 		return;
 
 	/*
-	 * Tell the OS that the link status has changed and print a short
+	 * Tell the OS that the link status has changed (if we're not
+	 * operating in the forced link "up" mode) and print a short
 	 * informative message on the console about the event.
 	 */
 	if (link_ok) {
@@ -159,7 +172,8 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 		const char *fc;
 		const struct port_info *pi = netdev_priv(dev);
 
-		netif_carrier_on(dev);
+		if (!force_link_up)
+			netif_carrier_on(dev);
 
 		switch (pi->link_cfg.speed) {
 		case SPEED_10000:
@@ -200,7 +214,9 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 		printk(KERN_INFO "%s: link up, %s, full-duplex, %s PAUSE\n",
 		       dev->name, s, fc);
 	} else {
-		netif_carrier_off(dev);
+		if (!force_link_up)
+			netif_carrier_off(dev);
+
 		printk(KERN_INFO "%s: link down\n", dev->name);
 	}
 }
@@ -254,6 +270,14 @@ static int link_start(struct net_device *dev)
 	 */
 	if (ret == 0)
 		ret = t4vf_enable_vi(pi->adapter, pi->viid, true, true);
+
+	/*
+	 * If we didn't experience any error and we're always reporting the
+	 * link as being "up", tell the OS that the link is up.
+	 */
+	if (ret == 0 && force_link_up)
+		netif_carrier_on(dev);
+
 	return ret;
 }
 
-- 
1.7.0.4

