From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/2] net: qcom/emac: add software control for pause frame mode
Date: Tue,  1 Aug 2017 16:37:40 -0500
Message-ID: <1501623460-3575-3-git-send-email-timur@codeaurora.org>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40476 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752366AbdHAVhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 17:37:48 -0400
In-Reply-To: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC has the option of sending only a single pause frame when
flow control is enabled and the RX queue is full.  Although sending
only one pause frame has little value, this would allow admins to
enable automatic flow control without having to worry about the EMAC
flooding nearby switches with pause frames if the kernel hangs.

The option is enabled by using the single-pause-mode private flag.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c | 30 +++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.c     | 22 +++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.c         |  3 +++
 drivers/net/ethernet/qualcomm/emac/emac.h         |  3 +++
 4 files changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
index bbe24639aa5a..c8c6231b87f3 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
@@ -88,6 +88,8 @@ static void emac_set_msglevel(struct net_device *netdev, u32 data)
 static int emac_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
+	case ETH_SS_PRIV_FLAGS:
+		return 1;
 	case ETH_SS_STATS:
 		return EMAC_STATS_LEN;
 	default:
@@ -100,6 +102,10 @@ static void emac_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	unsigned int i;
 
 	switch (stringset) {
+	case ETH_SS_PRIV_FLAGS:
+		strcpy(data, "single-pause-mode");
+		break;
+
 	case ETH_SS_STATS:
 		for (i = 0; i < EMAC_STATS_LEN; i++) {
 			strlcpy(data, emac_ethtool_stat_strings[i],
@@ -230,6 +236,27 @@ static int emac_get_regs_len(struct net_device *netdev)
 	return EMAC_MAX_REG_SIZE * sizeof(u32);
 }
 
+#define EMAC_PRIV_ENABLE_SINGLE_PAUSE	BIT(0)
+
+static int emac_set_priv_flags(struct net_device *netdev, u32 flags)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	adpt->single_pause_mode = !!(flags & EMAC_PRIV_ENABLE_SINGLE_PAUSE);
+
+	if (netif_running(netdev))
+		return emac_reinit_locked(adpt);
+
+	return 0;
+}
+
+static u32 emac_get_priv_flags(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	return adpt->single_pause_mode ? EMAC_PRIV_ENABLE_SINGLE_PAUSE : 0;
+}
+
 static const struct ethtool_ops emac_ethtool_ops = {
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
@@ -253,6 +280,9 @@ static int emac_get_regs_len(struct net_device *netdev)
 
 	.get_regs_len    = emac_get_regs_len,
 	.get_regs        = emac_get_regs,
+
+	.set_priv_flags = emac_set_priv_flags,
+	.get_priv_flags = emac_get_priv_flags,
 };
 
 void emac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index bcd4708b3745..0ea3ca09c689 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -551,6 +551,28 @@ static void emac_mac_start(struct emac_adapter *adpt)
 	mac &= ~(HUGEN | VLAN_STRIP | TPAUSE | SIMR | HUGE | MULTI_ALL |
 		 DEBUG_MODE | SINGLE_PAUSE_MODE);
 
+	/* Enable single-pause-frame mode if requested.
+	 *
+	 * If enabled, the EMAC will send a single pause frame when the RX
+	 * queue is full.  This normally leads to packet loss because
+	 * the pause frame disables the remote MAC only for 33ms (the quanta),
+	 * and then the remote MAC continues sending packets even though
+	 * the RX queue is still full.
+	 *
+	 * If disabled, the EMAC sends a pause frame every 31ms until the RX
+	 * queue is no longer full.  Normally, this is the preferred
+	 * method of operation.  However, when the system is hung (e.g.
+	 * cores are halted), the EMAC interrupt handler is never called
+	 * and so the RX queue fills up quickly and stays full.  The resuling
+	 * non-stop "flood" of pause frames sometimes has the effect of
+	 * disabling nearby switches.  In some cases, other nearby switches
+	 * are also affected, shutting down the entire network.
+	 *
+	 * The user can enable or disable single-pause-frame mode
+	 * via ethtool.
+	 */
+	mac |= adpt->single_pause_mode ? SINGLE_PAUSE_MODE : 0;
+
 	writel_relaxed(csr1, adpt->csr + EMAC_EMAC_WRAPPER_CSR1);
 
 	writel_relaxed(mac, adpt->base + EMAC_MAC_CTRL);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 475c0ea29235..6f5e858ffbf3 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -448,6 +448,9 @@ static void emac_init_adapter(struct emac_adapter *adpt)
 	adpt->automatic = false;
 	adpt->tx_flow_control = false;
 	adpt->rx_flow_control = true;
+
+	/* Disable single-pause-frame mode by default */
+	adpt->single_pause_mode = false;
 }
 
 /* Get the clock */
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
index 8ee4ec6aef2e..d7c9f44209d4 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -363,6 +363,9 @@ struct emac_adapter {
 	bool				tx_flow_control;
 	bool				rx_flow_control;
 
+	/* True == use single-pause-frame mode. */
+	bool				single_pause_mode;
+
 	/* Ring parameter */
 	u8				tpd_burst;
 	u8				rfd_burst;
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
