From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 03/11] dpaa_eth: add PM ops
Date: Tue, 17 Mar 2015 20:58:21 +0200
Message-ID: <1426618709-19004-3-git-send-email-madalin.bucur@freescale.com>
References: <1426618709-19004-1-git-send-email-madalin.bucur@freescale.com>
 <1426618709-19004-2-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0136.outbound.protection.outlook.com ([157.56.111.136]:39098
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753230AbbCQS6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 14:58:40 -0400
In-Reply-To: <1426618709-19004-2-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend and resume functionality.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 109 +++++++++++++++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h |   9 ++
 2 files changed, 118 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 96a7cee..76b05c1 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -87,6 +87,110 @@ MODULE_PARM_DESC(tx_timeout, "The Tx timeout in ms");
 
 static u8 dpa_priv_common_bpid;
 
+#ifdef CONFIG_PM
+
+static int dpaa_suspend(struct device *dev)
+{
+	struct net_device	*net_dev;
+	struct dpa_priv_s	*priv;
+	struct mac_device	*mac_dev;
+	int			err = 0;
+
+	net_dev = dev_get_drvdata(dev);
+
+	if (net_dev->flags & IFF_UP) {
+		priv = netdev_priv(net_dev);
+		mac_dev = priv->mac_dev;
+
+		if (priv->wol & DPAA_WOL_MAGIC) {
+			err = priv->mac_dev->set_wol(
+				priv->mac_dev->get_mac_handle(mac_dev), true);
+			if (err) {
+				netdev_err(net_dev, "set_wol() = %d\n", err);
+				goto set_wol_failed;
+			}
+		}
+
+		err = fm_port_suspend(mac_dev->port_dev[RX]);
+		if (err) {
+			netdev_err(net_dev, "fm_port_suspend(RX) = %d\n", err);
+			goto rx_port_suspend_failed;
+		}
+
+		err = fm_port_suspend(mac_dev->port_dev[TX]);
+		if (err) {
+			netdev_err(net_dev, "fm_port_suspend(TX) = %d\n", err);
+			goto tx_port_suspend_failed;
+		}
+	}
+
+	return 0;
+
+tx_port_suspend_failed:
+	fm_port_resume(mac_dev->port_dev[RX]);
+rx_port_suspend_failed:
+	if (priv->wol & DPAA_WOL_MAGIC) {
+		priv->mac_dev->set_wol(priv->mac_dev->get_mac_handle(mac_dev),
+				       false);
+	}
+set_wol_failed:
+	return err;
+}
+
+static int dpaa_resume(struct device *dev)
+{
+	struct net_device	*net_dev;
+	struct dpa_priv_s	*priv;
+	struct mac_device	*mac_dev;
+	int			err = 0;
+
+	net_dev = dev_get_drvdata(dev);
+
+	if (net_dev->flags & IFF_UP) {
+		priv = netdev_priv(net_dev);
+		mac_dev = priv->mac_dev;
+
+		err = fm_port_resume(mac_dev->port_dev[TX]);
+		if (err) {
+			netdev_err(net_dev, "fm_port_resume(TX) = %d\n", err);
+			goto resume_failed;
+		}
+
+		err = fm_port_resume(mac_dev->port_dev[RX]);
+		if (err) {
+			netdev_err(net_dev, "fm_port_resume(RX) = %d\n", err);
+			goto resume_failed;
+		}
+
+		if (priv->wol & DPAA_WOL_MAGIC) {
+			err = priv->mac_dev->set_wol(
+				priv->mac_dev->get_mac_handle(mac_dev), false);
+			if (err) {
+				netdev_err(net_dev, "set_wol() = %d\n", err);
+				goto resume_failed;
+			}
+		}
+	}
+
+	return 0;
+
+resume_failed:
+	return err;
+}
+
+static const struct dev_pm_ops dpaa_pm_ops = {
+	.suspend = dpaa_suspend,
+	.resume = dpaa_resume,
+};
+
+#define DPAA_PM_OPS (&dpaa_pm_ops)
+
+#else /* CONFIG_PM */
+
+#define DPAA_PM_OPS NULL
+
+#endif /* CONFIG_PM */
+
 static void _dpa_rx_error(struct net_device *net_dev,
 			  const struct dpa_priv_s	*priv,
 			  struct dpa_percpu_priv_s *percpu_priv,
@@ -744,6 +848,10 @@ dpaa_eth_priv_probe(struct platform_device *pdev)
 	if (err < 0)
 		goto netdev_init_failed;
 
+#ifdef CONFIG_PM
+	device_set_wakeup_capable(dev, true);
+#endif
+
 	pr_info("Probed interface %s\n", net_dev->name);
 
 	return 0;
@@ -789,6 +897,7 @@ static struct platform_driver dpa_driver = {
 	.driver = {
 		.name		= KBUILD_MODNAME,
 		.owner		= THIS_MODULE,
+		.pm		= DPAA_PM_OPS,
 	},
 	.id_table	= dpa_devtype,
 	.probe		= dpaa_eth_priv_probe,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index 793491f..9b70c5a 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -128,6 +128,11 @@ struct dpa_buffer_layout_s {
 #define FSL_DPAA_ETH_MAX_BUF_COUNT	128
 #define FSL_DPAA_ETH_REFILL_THRESHOLD	80
 
+#ifdef CONFIG_PM
+/* Magic Packet wakeup */
+#define DPAA_WOL_MAGIC		0x00000001
+#endif
+
 /* More detailed FQ types - used for fine-grained WQ assignments */
 enum dpa_fq_type {
 	FQ_TYPE_RX_DEFAULT = 1, /* Rx Default FQs */
@@ -244,6 +249,10 @@ struct dpa_priv_s {
 
 	struct dpa_buffer_layout_s *buf_layout;
 	u16 rx_headroom;
+
+#ifdef CONFIG_PM
+	u32 wol;
+#endif
 };
 
 struct fm_port_fqs {
-- 
1.7.11.7
