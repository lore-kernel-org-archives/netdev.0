From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: set config bit (ifup/ifdown) on netdev open/close
Date: Tue, 25 Jul 2017 00:51:08 -0700
Message-ID: <20170725075108.18537-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:37538 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdGYHv7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 03:51:59 -0400
Received: by mail-pg0-f49.google.com with SMTP id y129so67101752pgy.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 00:51:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk van der Merwe <dirk.vandermerwe@netronome.com>

When a netdev (PF netdev or representor) is opened or closed, set the
physical port config bit appropriately - which powers UP/DOWN the PHY
module for the physical interface.

The PHY is powered first in the HW/FW configuration step when opening
the netdev and again last in the HW/FW configuration step when closing
the netdev.

This is only applicable when there is a physical port associated with
the netdev and if the NSP support this. Otherwise we silently ignore
this step.

The 'nfp_eth_set_configured' can actually return positive values -
updated the function documentation appropriately.

Signed-off-by: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 10 +++++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  | 23 ++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.c      | 27 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  1 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 18 +++++++++++++--
 5 files changed, 74 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 18750ff0ede6..ea471604450e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2658,6 +2658,7 @@ static int nfp_net_netdev_close(struct net_device *netdev)
 	/* Step 2: Tell NFP
 	 */
 	nfp_net_clear_config_and_disable(nn);
+	nfp_port_configure(netdev, false);
 
 	/* Step 3: Free resources
 	 */
@@ -2775,16 +2776,21 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 		goto err_free_all;
 
 	/* Step 2: Configure the NFP
+	 * - Ifup the physical interface if it exists
 	 * - Enable rings from 0 to tx_rings/rx_rings - 1.
 	 * - Write MAC address (in case it changed)
 	 * - Set the MTU
 	 * - Set the Freelist buffer size
 	 * - Enable the FW
 	 */
-	err = nfp_net_set_config_and_enable(nn);
+	err = nfp_port_configure(netdev, true);
 	if (err)
 		goto err_free_all;
 
+	err = nfp_net_set_config_and_enable(nn);
+	if (err)
+		goto err_port_disable;
+
 	/* Step 3: Enable for kernel
 	 * - put some freelist descriptors on each RX ring
 	 * - enable NAPI on each ring
@@ -2795,6 +2801,8 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
 	return 0;
 
+err_port_disable:
+	nfp_port_configure(netdev, false);
 err_free_all:
 	nfp_net_close_free_all(nn);
 	return err;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 8ec5474f4b18..47daad30756c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -239,15 +239,34 @@ static netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev)
 static int nfp_repr_stop(struct net_device *netdev)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
+	int err;
+
+	err = nfp_app_repr_stop(repr->app, repr);
+	if (err)
+		return err;
 
-	return nfp_app_repr_stop(repr->app, repr);
+	nfp_port_configure(netdev, false);
+	return 0;
 }
 
 static int nfp_repr_open(struct net_device *netdev)
 {
 	struct nfp_repr *repr = netdev_priv(netdev);
+	int err;
+
+	err = nfp_port_configure(netdev, true);
+	if (err)
+		return err;
+
+	err = nfp_app_repr_open(repr->app, repr);
+	if (err)
+		goto err_port_disable;
 
-	return nfp_app_repr_open(repr->app, repr);
+	return 0;
+
+err_port_disable:
+	nfp_port_configure(netdev, false);
+	return err;
 }
 
 const struct net_device_ops nfp_repr_netdev_ops = {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index e42644dbb865..d16a7b78ba9b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -181,6 +181,33 @@ nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len)
 	return 0;
 }
 
+/**
+ * nfp_port_configure() - helper to set the interface configured bit
+ * @netdev:	net_device instance
+ * @configed:	Desired state
+ *
+ * Helper to set the ifup/ifdown state on the PHY only if there is a physical
+ * interface associated with the netdev.
+ *
+ * Return:
+ * 0 - configuration successful (or no change);
+ * -ERRNO - configuration failed.
+ */
+int nfp_port_configure(struct net_device *netdev, bool configed)
+{
+	struct nfp_eth_table_port *eth_port;
+	struct nfp_port *port;
+	int err;
+
+	port = nfp_port_from_netdev(netdev);
+	eth_port = __nfp_port_get_eth_port(port);
+	if (!eth_port)
+		return 0;
+
+	err = nfp_eth_set_configured(port->app->cpp, eth_port->index, configed);
+	return err < 0 && err != -EOPNOTSUPP ? err : 0;
+}
+
 int nfp_port_init_phy_port(struct nfp_pf *pf, struct nfp_app *app,
 			   struct nfp_port *port, unsigned int id)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index a33d22e18f94..56c76926c82a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -120,6 +120,7 @@ struct nfp_eth_table_port *nfp_port_get_eth_port(struct nfp_port *port);
 
 int
 nfp_port_get_phys_port_name(struct net_device *netdev, char *name, size_t len);
+int nfp_port_configure(struct net_device *netdev, bool configed);
 
 struct nfp_port *
 nfp_port_alloc(struct nfp_app *app, enum nfp_port_type type,
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index c2bc36e8649f..f6f7c085f8e0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -391,7 +391,10 @@ int nfp_eth_config_commit_end(struct nfp_nsp *nsp)
  * Enable or disable PHY module (this usually means setting the TX lanes
  * disable bits).
  *
- * Return: 0 or -ERRNO.
+ * Return:
+ * 0 - configuration successful;
+ * 1 - no changes were needed;
+ * -ERRNO - configuration failed.
  */
 int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
 {
@@ -427,7 +430,10 @@ int nfp_eth_set_mod_enable(struct nfp_cpp *cpp, unsigned int idx, bool enable)
  *
  * Set the ifup/ifdown state on the PHY.
  *
- * Return: 0 or -ERRNO.
+ * Return:
+ * 0 - configuration successful;
+ * 1 - no changes were needed;
+ * -ERRNO - configuration failed.
  */
 int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx, bool configed)
 {
@@ -439,6 +445,14 @@ int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx, bool configed)
 	if (IS_ERR(nsp))
 		return PTR_ERR(nsp);
 
+	/* Older ABI versions did support this feature, however this has only
+	 * been reliable since ABI 20.
+	 */
+	if (nfp_nsp_get_abi_ver_minor(nsp) < 20) {
+		nfp_eth_config_cleanup_end(nsp);
+		return -EOPNOTSUPP;
+	}
+
 	entries = nfp_nsp_config_entries(nsp);
 
 	/* Check if we are already in requested state */
-- 
2.11.0
