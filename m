From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 08/16] sfc: Enable a VF to get its own MAC address
Date: Wed, 20 May 2015 11:10:20 +0100
Message-ID: <555C5D8C.2030604@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29078 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753361AbbETKK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:10:26 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

A VF's MAC address is set by its parent PF and added to its vport.
To get this MAC address, the VF must use MC_CMD_ VPORT_GET_MAC_ADDRESSES.
In the current scheme, a VF's vport should only have one MAC address,
so warn if this is not the case.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 35 +++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9e2e8e1..4058626 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -198,7 +198,7 @@ static int efx_ef10_get_sysclk_freq(struct efx_nic *efx)
 	return rc > 0 ? rc : -ERANGE;
 }
 
-static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
+static int efx_ef10_get_mac_address_pf(struct efx_nic *efx, u8 *mac_address)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_MAC_ADDRESSES_OUT_LEN);
 	size_t outlen;
@@ -218,6 +218,34 @@ static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
 	return 0;
 }
 
+static int efx_ef10_get_mac_address_vf(struct efx_nic *efx, u8 *mac_address)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_GET_MAC_ADDRESSES_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_VPORT_GET_MAC_ADDRESSES_OUT_LENMAX);
+	size_t outlen;
+	int num_addrs, rc;
+
+	MCDI_SET_DWORD(inbuf, VPORT_GET_MAC_ADDRESSES_IN_VPORT_ID,
+		       EVB_PORT_ID_ASSIGNED);
+	rc = efx_mcdi_rpc(efx, MC_CMD_VPORT_GET_MAC_ADDRESSES, inbuf,
+			  sizeof(inbuf), outbuf, sizeof(outbuf), &outlen);
+
+	if (rc)
+		return rc;
+	if (outlen < MC_CMD_VPORT_GET_MAC_ADDRESSES_OUT_LENMIN)
+		return -EIO;
+
+	num_addrs = MCDI_DWORD(outbuf,
+			       VPORT_GET_MAC_ADDRESSES_OUT_MACADDR_COUNT);
+
+	WARN_ON(num_addrs != 1);
+
+	ether_addr_copy(mac_address,
+			MCDI_PTR(outbuf, VPORT_GET_MAC_ADDRESSES_OUT_MACADDR));
+
+	return 0;
+}
+
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
@@ -299,7 +327,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		goto fail3;
 	efx->port_num = rc;
 
-	rc = efx_ef10_get_mac_address(efx, efx->net_dev->perm_addr);
+	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
 		goto fail3;
 
@@ -3982,6 +4010,8 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.vswitching_restore = efx_ef10_vswitching_restore_vf,
 	.vswitching_remove = efx_ef10_vswitching_remove_vf,
 #endif
+	.get_mac_address = efx_ef10_get_mac_address_vf,
+
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
 	.rx_prefix_size = ES_DZ_RX_PREFIX_SIZE,
@@ -4099,6 +4129,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.vswitching_restore = efx_ef10_vswitching_restore_pf,
 	.vswitching_remove = efx_ef10_vswitching_remove_pf,
 #endif
+	.get_mac_address = efx_ef10_get_mac_address_pf,
 
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f6c4832..364217b 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1351,6 +1351,7 @@ struct efx_nic_type {
 	int (*vswitching_probe)(struct efx_nic *efx);
 	int (*vswitching_restore)(struct efx_nic *efx);
 	void (*vswitching_remove)(struct efx_nic *efx);
+	int (*get_mac_address)(struct efx_nic *efx, unsigned char *perm_addr);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
