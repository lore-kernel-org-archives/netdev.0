From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 19/32] sfc: Add power-management and wake-on-LAN support
Date: Sat, 28 Nov 2009 03:50:10 +0000
Message-ID: <1259380210.2811.44.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42676 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbZK1DuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:50:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wake-on-LAN is a stub for Falcon, but will be implemented fully for
new NICs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   96 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/ethtool.c    |   17 +++++++
 drivers/net/sfc/falcon.c     |   27 ++++++++++++
 drivers/net/sfc/net_driver.h |    6 +++
 4 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d94ec07..75a2ce3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2243,11 +2243,107 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	return rc;
 }
 
+static int efx_pm_freeze(struct device *dev)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	efx->state = STATE_FINI;
+
+	netif_device_detach(efx->net_dev);
+
+	efx_stop_all(efx);
+	efx_fini_channels(efx);
+
+	return 0;
+}
+
+static int efx_pm_thaw(struct device *dev)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	efx->state = STATE_INIT;
+
+	efx_init_channels(efx);
+
+	mutex_lock(&efx->mac_lock);
+	efx->phy_op->reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	efx_start_all(efx);
+
+	netif_device_attach(efx->net_dev);
+
+	efx->state = STATE_RUNNING;
+
+	efx->type->resume_wol(efx);
+
+	return 0;
+}
+
+static int efx_pm_poweroff(struct device *dev)
+{
+	struct pci_dev *pci_dev = to_pci_dev(dev);
+	struct efx_nic *efx = pci_get_drvdata(pci_dev);
+
+	efx->type->fini(efx);
+
+	efx->reset_pending = RESET_TYPE_NONE;
+
+	pci_save_state(pci_dev);
+	return pci_set_power_state(pci_dev, PCI_D3hot);
+}
+
+/* Used for both resume and restore */
+static int efx_pm_resume(struct device *dev)
+{
+	struct pci_dev *pci_dev = to_pci_dev(dev);
+	struct efx_nic *efx = pci_get_drvdata(pci_dev);
+	int rc;
+
+	rc = pci_set_power_state(pci_dev, PCI_D0);
+	if (rc)
+		return rc;
+	pci_restore_state(pci_dev);
+	rc = pci_enable_device(pci_dev);
+	if (rc)
+		return rc;
+	pci_set_master(efx->pci_dev);
+	rc = efx->type->reset(efx, RESET_TYPE_ALL);
+	if (rc)
+		return rc;
+	rc = efx->type->init(efx);
+	if (rc)
+		return rc;
+	efx_pm_thaw(dev);
+	return 0;
+}
+
+static int efx_pm_suspend(struct device *dev)
+{
+	int rc;
+
+	efx_pm_freeze(dev);
+	rc = efx_pm_poweroff(dev);
+	if (rc)
+		efx_pm_resume(dev);
+	return rc;
+}
+
+static struct dev_pm_ops efx_pm_ops = {
+	.suspend	= efx_pm_suspend,
+	.resume		= efx_pm_resume,
+	.freeze		= efx_pm_freeze,
+	.thaw		= efx_pm_thaw,
+	.poweroff	= efx_pm_poweroff,
+	.restore	= efx_pm_resume,
+};
+
 static struct pci_driver efx_pci_driver = {
 	.name		= EFX_DRIVER_NAME,
 	.id_table	= efx_pci_table,
 	.probe		= efx_pci_probe,
 	.remove		= efx_pci_remove,
+	.driver.pm	= &efx_pm_ops,
 };
 
 /**************************************************************************
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 92c5d8d..901bad3 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -752,6 +752,21 @@ static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
 }
 

+static void efx_ethtool_get_wol(struct net_device *net_dev,
+				struct ethtool_wolinfo *wol)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	return efx->type->get_wol(efx, wol);
+}
+
+
+static int efx_ethtool_set_wol(struct net_device *net_dev,
+			       struct ethtool_wolinfo *wol)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	return efx->type->set_wol(efx, wol->wolopts);
+}
+
 const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
@@ -781,4 +796,6 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_strings		= efx_ethtool_get_strings,
 	.phys_id		= efx_ethtool_phys_id,
 	.get_ethtool_stats	= efx_ethtool_get_stats,
+	.get_wol                = efx_ethtool_get_wol,
+	.set_wol                = efx_ethtool_set_wol,
 };
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 85233c8..6b89607 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3245,6 +3245,27 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
 
 /**************************************************************************
  *
+ * Wake on LAN
+ *
+ **************************************************************************
+ */
+
+static void falcon_get_wol(struct efx_nic *efx, struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
+
+static int falcon_set_wol(struct efx_nic *efx, u32 type)
+{
+	if (type != 0)
+		return -EINVAL;
+	return 0;
+}
+
+/**************************************************************************
+ *
  * Revision-dependent attributes used by efx.c
  *
  **************************************************************************
@@ -3266,6 +3287,9 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
+	.get_wol = falcon_get_wol,
+	.set_wol = falcon_set_wol,
+	.resume_wol = efx_port_dummy_op_void,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_A1,
@@ -3300,6 +3324,9 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
+	.get_wol = falcon_get_wol,
+	.set_wol = falcon_set_wol,
+	.resume_wol = efx_port_dummy_op_void,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ecb24b9..9ce5a28 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -861,6 +861,9 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @push_irq_moderation: Apply interrupt moderation value
  * @push_multicast_hash: Apply multicast hash table
  * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
+ * @get_wol: Get WoL configuration from driver state
+ * @set_wol: Push WoL configuration to the NIC
+ * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
  * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -896,6 +899,9 @@ struct efx_nic_type {
 	void (*push_irq_moderation)(struct efx_channel *channel);
 	void (*push_multicast_hash)(struct efx_nic *efx);
 	int (*reconfigure_port)(struct efx_nic *efx);
+	void (*get_wol)(struct efx_nic *efx, struct ethtool_wolinfo *wol);
+	int (*set_wol)(struct efx_nic *efx, u32 type);
+	void (*resume_wol)(struct efx_nic *efx);
 	struct efx_mac_operations *default_mac_ops;
 
 	int revision;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

