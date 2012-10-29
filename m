From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 01/10] drivers: net: ethernet: cpsw: add multicast address to ALE table
Date: Mon, 29 Oct 2012 19:45:11 +0100
Message-ID: <b6ebb808853753126a45aeeb32f430f14b44b0ad.1351535538.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:37510 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760475Ab2J2Spf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:35 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1826941eaa.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:34 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>

Adding multicast address to ALE table via netdev ops to subscribe, transmit
or receive multicast frames to and from the network

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c     |   27 +++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.c |   31 ++++++++++++++++++++++++++++---
 drivers/net/ethernet/ti/cpsw_ale.h |    1 +
 3 files changed, 56 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index df55e24..63b046f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -70,6 +70,8 @@ do {								\
 		dev_notice(priv->dev, format, ## __VA_ARGS__);	\
 } while (0)
 
+#define ALE_ALL_PORTS		0x7
+
 #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
 #define CPSW_MINOR_VERSION(reg)		(reg & 0xff)
 #define CPSW_RTL_VERSION(reg)		((reg >> 11) & 0x1f)
@@ -228,6 +230,30 @@ struct cpsw_priv {
 			(func)((priv)->slaves + idx, ##arg);	\
 	} while (0)
 
+static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	if (ndev->flags & IFF_PROMISC) {
+		/* Enable promiscuous mode */
+		dev_err(priv->dev, "Ignoring Promiscuous mode\n");
+		return;
+	}
+
+	/* Clear all mcast from ALE */
+	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS << priv->host_port);
+
+	if (!netdev_mc_empty(ndev)) {
+		struct netdev_hw_addr *ha;
+
+		/* program multicast address list into ALE register */
+		netdev_for_each_mc_addr(ha, ndev) {
+			cpsw_ale_add_mcast(priv->ale, (u8 *)ha->addr,
+				ALE_ALL_PORTS << priv->host_port, 0, 0);
+		}
+	}
+}
+
 static void cpsw_intr_enable(struct cpsw_priv *priv)
 {
 	__raw_writel(0xFF, &priv->ss_regs->tx_en);
@@ -673,6 +699,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_get_stats		= cpsw_ndo_get_stats,
+	.ndo_set_rx_mode	= cpsw_ndo_set_rx_mode,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cpsw_ndo_poll_controller,
 #endif
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index ca0d48a..0e9ccc2 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -20,6 +20,7 @@
 #include <linux/io.h>
 #include <linux/stat.h>
 #include <linux/sysfs.h>
+#include <linux/etherdevice.h>
 
 #include "cpsw_ale.h"
 
@@ -211,10 +212,34 @@ static void cpsw_ale_flush_mcast(struct cpsw_ale *ale, u32 *ale_entry,
 	mask &= ~port_mask;
 
 	/* free if only remaining port is host port */
-	if (mask == BIT(ale->params.ale_ports))
-		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
-	else
+	if (mask)
 		cpsw_ale_set_port_mask(ale_entry, mask);
+	else
+		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
+}
+
+int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask)
+{
+	u32 ale_entry[ALE_ENTRY_WORDS];
+	int ret, idx;
+
+	for (idx = 0; idx < ale->params.ale_entries; idx++) {
+		cpsw_ale_read(ale, idx, ale_entry);
+		ret = cpsw_ale_get_entry_type(ale_entry);
+		if (ret != ALE_TYPE_ADDR && ret != ALE_TYPE_VLAN_ADDR)
+			continue;
+
+		if (cpsw_ale_get_mcast(ale_entry)) {
+			u8 addr[6];
+
+			cpsw_ale_get_addr(ale_entry, addr);
+			if (!is_broadcast_ether_addr(addr))
+				cpsw_ale_flush_mcast(ale, ale_entry, port_mask);
+		}
+
+		cpsw_ale_write(ale, idx, ale_entry);
+	}
+	return 0;
 }
 
 static void cpsw_ale_flush_ucast(struct cpsw_ale *ale, u32 *ale_entry,
diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
index a95b37b..2bd09cb 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.h
+++ b/drivers/net/ethernet/ti/cpsw_ale.h
@@ -80,6 +80,7 @@ void cpsw_ale_stop(struct cpsw_ale *ale);
 
 int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout);
 int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask);
+int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask);
 int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags);
 int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port);
 int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
-- 
1.7.2.5
