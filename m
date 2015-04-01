From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 05/10] dpaa_eth: add driver's Tx queue selection mechanism
Date: Wed, 1 Apr 2015 19:19:51 +0300
Message-ID: <1427905196-27778-4-git-send-email-madalin.bucur@freescale.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
 <1427905196-27778-2-git-send-email-madalin.bucur@freescale.com>
 <1427905196-27778-3-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905196-27778-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the selection of the transmission queue based on the CPU id.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig           | 11 +++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c        |  3 +++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h        |  6 ++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c |  9 +++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h |  4 ++++
 5 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index 9db7d25..a124639 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -11,6 +11,17 @@ menuconfig FSL_DPAA_ETH
 
 if FSL_DPAA_ETH
 
+config FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+	bool "Use driver's Tx queue selection mechanism"
+	default y
+	depends on FSL_DPAA_ETH
+	---help---
+	  The DPAA-Ethernet driver defines a ndo_select_queue() callback for optimal selection
+	  of the egress FQ. That will override the XPS support for this netdevice.
+	  If for whatever reason you want to be in control of the egress FQ-to-CPU selection and mapping,
+	  or simply don't want to use the driver's ndo_select_queue() callback, then unselect this
+	  and use the standard XPS support instead.
+
 config FSL_DPAA_ETH_MAX_BUF_COUNT
 	int "Maximum nuber of buffers in private bpool"
 	depends on FSL_DPAA_ETH
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 036e272..6ca637d 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -388,6 +388,9 @@ static const struct net_device_ops dpa_private_ops = {
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
index 5f3157d..da2fd6b 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -431,9 +431,15 @@ static inline void _dpa_assign_wq(struct dpa_fq *fq)
 	}
 }
 
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+/* Use in lieu of skb_get_queue_mapping() */
+#define dpa_get_queue_mapping(skb) \
+	smp_processor_id()
+#else
 /* Use the queue selected by XPS */
 #define dpa_get_queue_mapping(skb) \
 	skb_get_queue_mapping(skb)
+#endif
 
 static inline void _dpa_bp_free_pf(void *addr)
 {
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index 1fdb35d..eb7a4a0 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -615,6 +615,15 @@ bool dpa_bpid2pool_use(int bpid)
 	return false;
 }
 
+#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
+u16 dpa_select_queue(struct net_device *net_dev, struct sk_buff *skb,
+		     void *accel_priv, select_queue_fallback_t fallback)
+{
+	return dpa_get_queue_mapping(skb);
+}
+EXPORT_SYMBOL(dpa_select_queue);
+#endif
+
 struct dpa_fq *dpa_fq_alloc(struct device *dev,
 			    const struct fqid_cell *fqids,
 			    struct list_head *list,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
index 9b1774e..de5b68e 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
@@ -89,6 +89,10 @@ struct dpa_bp *dpa_bpid2pool(int bpid);
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
