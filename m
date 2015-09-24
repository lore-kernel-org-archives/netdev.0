From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [v3 4/8] dpaa_eth: add driver's Tx queue selection mechanism
Date: Thu, 24 Sep 2015 18:00:15 +0300
Message-ID: <1443106819-5549-5-git-send-email-madalin.bucur@freescale.com>
References: <1443106819-5549-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <scottwood@freescale.com>,
	<igal.liberman@freescale.com>, <roy.pledge@freescale.com>,
	<ppc@mindchasers.com>, <joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <f.fainelli@gmail.com>,
	<stsp@list.ru>, Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0148.outbound.protection.outlook.com ([207.46.100.148]:45632
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755508AbbIXPRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 11:17:53 -0400
In-Reply-To: <1443106819-5549-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the selection of the transmission queue based on the CPU id.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig           | 10 ++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c        |  3 +++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h        |  6 ++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c |  8 ++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h |  4 ++++
 5 files changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index 022d5aa..2577aac 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -11,6 +11,16 @@ menuconfig FSL_DPAA_ETH
 
 if FSL_DPAA_ETH
 
+config FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+	bool "Use driver's Tx queue selection mechanism"
+	default y
+	---help---
+	  The DPAA Ethernet driver defines a ndo_select_queue() callback for optimal selection
+	  of the egress FQ. That will override the XPS support for this netdevice.
+	  If for whatever reason you want to be in control of the egress FQ-to-CPU selection and mapping,
+	  or simply don't want to use the driver's ndo_select_queue() callback, then unselect this
+	  and use the standard XPS support instead.
+
 config FSL_DPAA_ETH_FRIENDLY_IF_NAME
 	bool "Use fmX-macY names for the DPAA interfaces"
 	default y
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 85e2bdf..a04c0aa 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -393,6 +393,9 @@ static const struct net_device_ops dpa_private_ops = {
 	.ndo_get_stats64 = dpa_get_stats64,
 	.ndo_set_mac_address = dpa_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+	.ndo_select_queue = dpa_select_queue,
+#endif
 	.ndo_change_mtu = dpa_change_mtu,
 	.ndo_set_rx_mode = dpa_set_rx_mode,
 	.ndo_init = dpa_ndo_init,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index 96553fd..349e052 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -419,9 +419,15 @@ static inline void _dpa_assign_wq(struct dpa_fq *fq)
 	}
 }
 
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+/* Use in lieu of skb_get_queue_mapping() */
+#define dpa_get_queue_mapping(skb) \
+	raw_smp_processor_id()
+#else
 /* Use the queue selected by XPS */
 #define dpa_get_queue_mapping(skb) \
 	skb_get_queue_mapping(skb)
+#endif
 
 static inline void _dpa_bp_free_pf(void *addr)
 {
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index b36cbca..89f3b1f 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -593,6 +593,14 @@ bool dpa_bpid2pool_use(int bpid)
 	return false;
 }
 
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+u16 dpa_select_queue(struct net_device *net_dev, struct sk_buff *skb,
+		     void *accel_priv, select_queue_fallback_t fallback)
+{
+	return dpa_get_queue_mapping(skb);
+}
+#endif
+
 struct dpa_fq *dpa_fq_alloc(struct device *dev,
 			    const struct fqid_cell *fqids,
 			    struct list_head *list,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
index 9df8f14..2e9471d 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
@@ -70,6 +70,10 @@ struct dpa_bp *dpa_bpid2pool(int bpid);
 void dpa_bpid2pool_map(int bpid, struct dpa_bp *dpa_bp);
 bool dpa_bpid2pool_use(int bpid);
 void dpa_bp_drain(struct dpa_bp *bp);
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+u16 dpa_select_queue(struct net_device *net_dev, struct sk_buff *skb,
+		     void *accel_priv, select_queue_fallback_t fallback);
+#endif
 struct dpa_fq *dpa_fq_alloc(struct device *dev,
 			    const struct fqid_cell *fqids,
 			    struct list_head *list,
-- 
1.7.11.7
