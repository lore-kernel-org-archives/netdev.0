From: Vincent Sanders <vince@simtec.co.uk>
Subject: [PATCH] Fix IXP 2000 network driver building.
Date: Sun, 11 Oct 2009 16:55:46 +0100
Message-ID: <1255276546-31903-1-git-send-email-vince@simtec.co.uk>
Cc: Vincent Sanders <vince@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flounder.pepperfish.net ([87.237.62.181]:50679 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705AbZJLLkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 07:40:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IXP 2000 network driver was failing to build as it has its own
statistics gathering which was not compatible with the recent network
device operations changes. This patch fixes the driver in the obvious
way and has been compile tested. I have been unable to get the ixp2000
maintainer to comment or test this fix.

Signed-off-by: Vincent Sanders <vince@simtec.co.uk>
---
 drivers/net/ixp2000/enp2611.c |   18 +-----------------
 drivers/net/ixp2000/ixpdev.c  |   11 +++++++++++
 drivers/net/ixp2000/ixpdev.h  |    1 +
 3 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ixp2000/enp2611.c b/drivers/net/ixp2000/enp2611.c
index b02a981..34a6cfd 100644
--- a/drivers/net/ixp2000/enp2611.c
+++ b/drivers/net/ixp2000/enp2611.c
@@ -119,24 +119,9 @@ static struct ixp2400_msf_parameters enp2611_msf_parameters =
 	}
 };
 
-struct enp2611_ixpdev_priv
-{
-	struct ixpdev_priv		ixpdev_priv;
-	struct net_device_stats		stats;
-};
-
 static struct net_device *nds[3];
 static struct timer_list link_check_timer;
 
-static struct net_device_stats *enp2611_get_stats(struct net_device *dev)
-{
-	struct enp2611_ixpdev_priv *ip = netdev_priv(dev);
-
-	pm3386_get_stats(ip->ixpdev_priv.channel, &(ip->stats));
-
-	return &(ip->stats);
-}
-
 /* @@@ Poll the SFP moddef0 line too.  */
 /* @@@ Try to use the pm3386 DOOL interrupt as well.  */
 static void enp2611_check_link_status(unsigned long __dummy)
@@ -203,14 +188,13 @@ static int __init enp2611_init_module(void)
 
 	ports = pm3386_port_count();
 	for (i = 0; i < ports; i++) {
-		nds[i] = ixpdev_alloc(i, sizeof(struct enp2611_ixpdev_priv));
+		nds[i] = ixpdev_alloc(i, sizeof(struct ixpdev_priv));
 		if (nds[i] == NULL) {
 			while (--i >= 0)
 				free_netdev(nds[i]);
 			return -ENOMEM;
 		}
 
-		nds[i]->get_stats = enp2611_get_stats;
 		pm3386_init_port(i);
 		pm3386_get_mac(i, nds[i]->dev_addr);
 	}
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 1272434..79cb6fa 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -21,6 +21,7 @@
 #include "ixp2400_tx.ucode"
 #include "ixpdev_priv.h"
 #include "ixpdev.h"
+#include "pm3386.h"
 
 #define DRV_MODULE_VERSION	"0.2"
 
@@ -271,6 +272,15 @@ static int ixpdev_close(struct net_device *dev)
 	return 0;
 }
 
+static struct net_device_stats *ixpdev_get_stats(struct net_device *dev)
+{
+	struct ixpdev_priv *ip = netdev_priv(dev);
+
+	pm3386_get_stats(ip->channel, &(ip->stats));
+
+	return &(ip->stats);
+}
+
 static const struct net_device_ops ixpdev_netdev_ops = {
 	.ndo_open		= ixpdev_open,
 	.ndo_stop		= ixpdev_close,
@@ -278,6 +288,7 @@ static const struct net_device_ops ixpdev_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_get_stats		= ixpdev_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixpdev_poll_controller,
 #endif
diff --git a/drivers/net/ixp2000/ixpdev.h b/drivers/net/ixp2000/ixpdev.h
index 391ece6..bf235e9 100644
--- a/drivers/net/ixp2000/ixpdev.h
+++ b/drivers/net/ixp2000/ixpdev.h
@@ -18,6 +18,7 @@ struct ixpdev_priv
 	struct napi_struct napi;
 	int	channel;
 	int	tx_queue_entries;
+	struct net_device_stats		stats;
 };
 
 struct net_device *ixpdev_alloc(int channel, int sizeof_priv);
-- 
1.6.0.4

