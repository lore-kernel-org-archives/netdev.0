From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 14/14] sfc: Bind the sfc driver to any available
 VF's
Date: Wed, 6 May 2015 01:00:07 +0100
Message-ID: <55495987.1090106@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:23347 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932101AbbEFAAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 20:00:18 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the device ID of the VF to the PCI device ID table.

Added a boolean flag is_vf in efx_nic_type to differentiate
between a VF and PF at probe time. This flag is useful in later
patches while setting MAC address specially in the
PCI-passthrough case.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  2 ++
 drivers/net/ethernet/sfc/efx.c        |  6 +++++-
 drivers/net/ethernet/sfc/falcon.c     |  2 ++
 drivers/net/ethernet/sfc/mcdi.c       | 10 ----------
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/siena.c      |  1 +
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 7a67202..882117a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3810,6 +3810,7 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 }
 
 const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
+	.is_vf = true,
 	.mem_bar = EFX_MEM_VF_BAR,
 	.mem_map_size = efx_ef10_mem_map_size,
 	.probe = efx_ef10_probe_vf,
@@ -3907,6 +3908,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 };
 
 const struct efx_nic_type efx_hunt_a0_nic_type = {
+	.is_vf = false,
 	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = efx_ef10_mem_map_size,
 	.probe = efx_ef10_probe_pf,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 706b936..0f127a0 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1454,6 +1454,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	}
 #endif
 	efx->rss_spread = efx->n_rx_channels;
+
 	return 0;
 }
 
@@ -2676,6 +2677,8 @@ static const struct pci_device_id efx_pci_table[] = {
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0903),  /* SFC9120 PF */
 	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x1903),  /* SFC9120 VF */
+	 .driver_data = (unsigned long) &efx_hunt_a0_vf_nic_type},
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0923),  /* SFC9140 PF */
 	 .driver_data = (unsigned long) &efx_hunt_a0_nic_type},
 	{0}			/* end of list */
@@ -3031,7 +3034,8 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	netif_info(efx, probe, efx->net_dev,
 		   "Solarflare NIC detected\n");
 
-	efx_probe_vpd_strings(efx);
+	if (!efx->type->is_vf)
+		efx_probe_vpd_strings(efx);
 
 	/* Set up basic I/O (BAR mappings etc) */
 	rc = efx_init_io(efx);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 3bb1da8..80e69af 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2700,6 +2700,7 @@ static int falcon_set_wol(struct efx_nic *efx, u32 type)
  */
 
 const struct efx_nic_type falcon_a1_nic_type = {
+	.is_vf = false,
 	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = falcon_a1_mem_map_size,
 	.probe = falcon_probe_nic,
@@ -2797,6 +2798,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 };
 
 const struct efx_nic_type falcon_b0_nic_type = {
+	.is_vf = false,
 	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = falcon_b0_mem_map_size,
 	.probe = falcon_probe_nic,
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 1ffe289..b44ee31 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1186,16 +1186,6 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 	 * and are completely trusted by firmware.  Abort probing
 	 * if that's not true for this function.
 	 */
-	if (driver_operating &&
-	    (efx->mcdi->fn_flags &
-	     (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
-	      1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED)) !=
-	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
-	     1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED)) {
-		netif_err(efx, probe, efx->net_dev,
-			  "This driver version only supports one function per port\n");
-		return -ENODEV;
-	}
 
 	if (was_attached != NULL)
 		*was_attached = MCDI_DWORD(outbuf, DRV_ATTACH_OUT_OLD_STATE);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9498a42..031a338 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1224,6 +1224,7 @@ struct efx_mtd_partition {
  * @hwtstamp_filters: Mask of hardware timestamp filter types supported
  */
 struct efx_nic_type {
+	bool is_vf;
 	unsigned int mem_bar;
 	unsigned int (*mem_map_size)(struct efx_nic *efx);
 	int (*probe)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index a36ed1b..8b4130a 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -917,6 +917,7 @@ fail:
  */
 
 const struct efx_nic_type siena_a0_nic_type = {
+	.is_vf = false,
 	.mem_bar = EFX_MEM_BAR,
 	.mem_map_size = siena_mem_map_size,
 	.probe = siena_probe_nic,
