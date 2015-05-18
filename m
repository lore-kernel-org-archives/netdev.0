From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 16/16] sfc: set the MAC address using MC_CMD_VADAPTOR_SET_MAC
Date: Mon, 18 May 2015 16:31:51 +0100
Message-ID: <555A05E7.5080708@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:60403 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753123AbbERPcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:32:13 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a set_mac_address() NIC-type function for EF10 only, and
use this to set the MAC address on the vadaptor. For Siena and
earlier, the MAC address continues to be set by MC_CMD_SET_MAC;
this is still called on EF10, and including a MAC address in
this command has no effect.

The sriov_mac_address_changed() NIC-type function is no longer
needed on EF10, but it is needed for Siena where it is used to
update the peer address of the PF for VFDI.  Change this to use
the new set_mac_address function pointer.

efx_ef10_sriov_mac_address_changed() is no longer called, as VFs
will try to change the MAC address on their vadaptor rather than
trying to change to the context of the PF to alter the vport.

When a VF is running in direct passthrough mode with MAC spoofing
enabled, it will be able to change the MAC address on its vadaptor.
In this case, there is a link to the PF, so find the correct VF in
its ef10_vf array and update the MAC address.

ndo_set_mac_address() can be called during driver unload while
bonding, and in this case the device has already been stopped, so
don't call efx_net_open() to restart it after reconfiguration.

efx->port_enabled is set to false in efx_stop_port(), so it is
indicator of whether the device needs to be restarted.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 75 ++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_sriov.h |  4 --
 drivers/net/ethernet/sfc/efx.c        |  4 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h  | 42 ++++++++++++++++++++
 drivers/net/ethernet/sfc/mcdi_port.c  |  1 +
 drivers/net/ethernet/sfc/net_driver.h |  3 +-
 drivers/net/ethernet/sfc/siena.c      |  2 +-
 7 files changed, 122 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e624ddd..a547ceb 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3596,6 +3596,78 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	WARN_ON(remove_failed);
 }
 
+static int efx_ef10_set_mac_address(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_SET_MAC_IN_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	bool was_enabled = efx->port_enabled;
+	int rc;
+
+	efx_device_detach_sync(efx);
+	efx_net_stop(efx->net_dev);
+	down_write(&efx->filter_sem);
+	efx_ef10_filter_table_remove(efx);
+
+	ether_addr_copy(MCDI_PTR(inbuf, VADAPTOR_SET_MAC_IN_MACADDR),
+			efx->net_dev->dev_addr);
+	MCDI_SET_DWORD(inbuf, VADAPTOR_SET_MAC_IN_UPSTREAM_PORT_ID,
+		       nic_data->vport_id);
+	rc = efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_SET_MAC, inbuf,
+			  sizeof(inbuf), NULL, 0, NULL);
+
+	efx_ef10_filter_table_probe(efx);
+	up_write(&efx->filter_sem);
+	if (was_enabled)
+		efx_net_open(efx->net_dev);
+	netif_device_attach(efx->net_dev);
+
+#if !defined(CONFIG_SFC_SRIOV)
+	if (rc == -EPERM)
+		netif_err(efx, drv, efx->net_dev,
+			  "Cannot change MAC address; use sfboot to enable mac-spoofing"
+			  " on this interface\n");
+#else
+	if (rc == -EPERM) {
+		struct pci_dev *pci_dev_pf = efx->pci_dev->physfn;
+
+		/* Switch to PF and change MAC address on vport */
+		if (efx->pci_dev->is_virtfn && pci_dev_pf) {
+			struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
+
+			if (!efx_ef10_sriov_set_vf_mac(efx_pf,
+						       nic_data->vf_index,
+						       efx->net_dev->dev_addr))
+				return 0;
+		}
+		netif_err(efx, drv, efx->net_dev,
+			  "Cannot change MAC address; use sfboot to enable mac-spoofing"
+			  " on this interface\n");
+	} else if (efx->pci_dev->is_virtfn) {
+		/* Successfully changed by VF (with MAC spoofing), so update the
+		 * parent PF if possible.
+		 */
+		struct pci_dev *pci_dev_pf = efx->pci_dev->physfn;
+
+		if (pci_dev_pf) {
+			struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
+			struct efx_ef10_nic_data *nic_data = efx_pf->nic_data;
+			unsigned int i;
+
+			for (i = 0; i < efx_pf->vf_count; ++i) {
+				struct ef10_vf *vf = nic_data->vf + i;
+
+				if (vf->efx == efx) {
+					ether_addr_copy(vf->mac,
+							efx->net_dev->dev_addr);
+					return 0;
+				}
+			}
+		}
+	}
+#endif
+	return rc;
+}
+
 static int efx_ef10_mac_reconfigure(struct efx_nic *efx)
 {
 	efx_ef10_filter_sync_rx_mode(efx);
@@ -4021,6 +4093,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.vswitching_remove = efx_ef10_vswitching_remove_vf,
 #endif
 	.get_mac_address = efx_ef10_get_mac_address_vf,
+	.set_mac_address = efx_ef10_set_mac_address,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
@@ -4127,7 +4200,6 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.sriov_configure = efx_ef10_sriov_configure,
 	.sriov_init = efx_ef10_sriov_init,
 	.sriov_fini = efx_ef10_sriov_fini,
-	.sriov_mac_address_changed = efx_ef10_sriov_mac_address_changed,
 	.sriov_wanted = efx_ef10_sriov_wanted,
 	.sriov_reset = efx_ef10_sriov_reset,
 	.sriov_flr = efx_ef10_sriov_flr,
@@ -4141,6 +4213,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.vswitching_remove = efx_ef10_vswitching_remove_pf,
 #endif
 	.get_mac_address = efx_ef10_get_mac_address_pf,
+	.set_mac_address = efx_ef10_set_mac_address,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 7171029..b985576 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -36,10 +36,6 @@ static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
 
 int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs);
 int efx_ef10_sriov_init(struct efx_nic *efx);
-static inline int efx_ef10_sriov_mac_address_changed(struct efx_nic *efx)
-{
-	return -EOPNOTSUPP;
-}
 static inline void efx_ef10_sriov_reset(struct efx_nic *efx) {}
 void efx_ef10_sriov_fini(struct efx_nic *efx);
 static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8cacb96..9eafa39 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2227,8 +2227,8 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	/* save old address */
 	ether_addr_copy(old_addr, net_dev->dev_addr);
 	ether_addr_copy(net_dev->dev_addr, new_addr);
-	if (efx->type->sriov_mac_address_changed) {
-		rc = efx->type->sriov_mac_address_changed(efx);
+	if (efx->type->set_mac_address) {
+		rc = efx->type->set_mac_address(efx);
 		if (rc) {
 			ether_addr_copy(net_dev->dev_addr, old_addr);
 			return rc;
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index ada610a..5affe67 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -6057,6 +6057,48 @@
 
 
 /***********************************/
+/* MC_CMD_VADAPTOR_SET_MAC
+ * assign a new MAC address to a v-adaptor.
+ */
+#define MC_CMD_VADAPTOR_SET_MAC 0x5d
+#undef MC_CMD_0x5d_PRIVILEGE_CTG
+
+#define MC_CMD_0x5d_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_VADAPTOR_SET_MAC_IN msgrequest */
+#define    MC_CMD_VADAPTOR_SET_MAC_IN_LEN 10
+/* The port to which the v-adaptor is connected. */
+#define       MC_CMD_VADAPTOR_SET_MAC_IN_UPSTREAM_PORT_ID_OFST 0
+/* The new MAC address to assign to this v-adaptor */
+#define       MC_CMD_VADAPTOR_SET_MAC_IN_MACADDR_OFST 4
+#define       MC_CMD_VADAPTOR_SET_MAC_IN_MACADDR_LEN 6
+
+/* MC_CMD_VADAPTOR_SET_MAC_OUT msgresponse */
+#define    MC_CMD_VADAPTOR_SET_MAC_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_VADAPTOR_GET_MAC
+ * read the MAC address assigned to a v-adaptor.
+ */
+#define MC_CMD_VADAPTOR_GET_MAC 0x5e
+#undef MC_CMD_0x5e_PRIVILEGE_CTG
+
+#define MC_CMD_0x5e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_VADAPTOR_GET_MAC_IN msgrequest */
+#define    MC_CMD_VADAPTOR_GET_MAC_IN_LEN 4
+/* The port to which the v-adaptor is connected. */
+#define       MC_CMD_VADAPTOR_GET_MAC_IN_UPSTREAM_PORT_ID_OFST 0
+
+/* MC_CMD_VADAPTOR_GET_MAC_OUT msgresponse */
+#define    MC_CMD_VADAPTOR_GET_MAC_OUT_LEN 6
+/* The MAC address assigned to this v-adaptor */
+#define       MC_CMD_VADAPTOR_GET_MAC_OUT_MACADDR_OFST 0
+#define       MC_CMD_VADAPTOR_GET_MAC_OUT_MACADDR_LEN 6
+
+
+/***********************************/
 /* MC_CMD_EVB_PORT_ASSIGN
  * assign a port to a PCI function.
  */
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index fb19b70..9bf04cb 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -865,6 +865,7 @@ int efx_mcdi_set_mac(struct efx_nic *efx)
 
 	BUILD_BUG_ON(MC_CMD_SET_MAC_OUT_LEN != 0);
 
+	/* This has no effect on EF10 */
 	ether_addr_copy(MCDI_PTR(cmdbytes, SET_MAC_IN_ADDR),
 			efx->net_dev->dev_addr);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c2eabd9..a468a22 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1205,6 +1205,7 @@ struct efx_mtd_partition {
  * @ptp_set_ts_config: Set hardware timestamp configuration.  The flags
  *	and tx_type will already have been validated but this operation
  *	must validate and update rx_filter.
+ * @set_mac_address: Set the MAC address of the device
  * @revision: Hardware architecture revision
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -1337,7 +1338,6 @@ struct efx_nic_type {
 	int (*sriov_configure)(struct efx_nic *efx, int num_vfs);
 	int (*sriov_init)(struct efx_nic *efx);
 	void (*sriov_fini)(struct efx_nic *efx);
-	int (*sriov_mac_address_changed)(struct efx_nic *efx);
 	bool (*sriov_wanted)(struct efx_nic *efx);
 	void (*sriov_reset)(struct efx_nic *efx);
 	void (*sriov_flr)(struct efx_nic *efx, unsigned vf_i);
@@ -1354,6 +1354,7 @@ struct efx_nic_type {
 	int (*vswitching_restore)(struct efx_nic *efx);
 	void (*vswitching_remove)(struct efx_nic *efx);
 	int (*get_mac_address)(struct efx_nic *efx, unsigned char *perm_addr);
+	int (*set_mac_address)(struct efx_nic *efx);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 8b4130a..b323b91 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1010,7 +1010,6 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.sriov_configure = efx_siena_sriov_configure,
 	.sriov_init = efx_siena_sriov_init,
 	.sriov_fini = efx_siena_sriov_fini,
-	.sriov_mac_address_changed = efx_siena_sriov_mac_address_changed,
 	.sriov_wanted = efx_siena_sriov_wanted,
 	.sriov_reset = efx_siena_sriov_reset,
 	.sriov_flr = efx_siena_sriov_flr,
@@ -1021,6 +1020,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.vswitching_probe = efx_port_dummy_op_int,
 	.vswitching_restore = efx_port_dummy_op_int,
 	.vswitching_remove = efx_port_dummy_op_void,
+	.set_mac_address = efx_siena_sriov_mac_address_changed,
 #endif
 
 	.revision = EFX_REV_SIENA_A0,
