From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH v4.9 -stable] sfc: provide dummy definitions of vswitch
 functions
Date: Fri, 16 Jun 2017 09:45:08 +0100
Message-ID: <80b3b988-0ab0-d56f-5ad7-0d28d5d1e1fb@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:47730 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752067AbdFPIpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 04:45:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_probe_all() calls efx->type->vswitching_probe during probe. For
SFC4000 (Falcon) NICs this function is not defined, leading to a BUG
with the top of the call stack similar to:
  ? efx_pci_probe_main+0x29a/0x830
  efx_pci_probe+0x7d3/0xe70

vswitching_restore and vswitching_remove also need to be defined.

Fixed in mainline by:
commit 5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")

Fixes: 6d8aaaf6f798 ("sfc: create VEB vswitch and vport above default firmware setup")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 1a7092602aec..1bfb21465ace 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2801,6 +2801,11 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.timer_period_max =  1 << FRF_AB_TC_TIMER_VAL_WIDTH,
 	.offload_features = NETIF_F_IP_CSUM,
 	.mcdi_max_ver = -1,
+#ifdef CONFIG_SFC_SRIOV
+	.vswitching_probe = efx_port_dummy_op_int,
+	.vswitching_restore = efx_port_dummy_op_int,
+	.vswitching_remove = efx_port_dummy_op_void,
+#endif
 };
 
 const struct efx_nic_type falcon_b0_nic_type = {
@@ -2902,4 +2907,9 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
 	.mcdi_max_ver = -1,
 	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
+#ifdef CONFIG_SFC_SRIOV
+	.vswitching_probe = efx_port_dummy_op_int,
+	.vswitching_restore = efx_port_dummy_op_int,
+	.vswitching_remove = efx_port_dummy_op_void,
+#endif
 };
-- 
2.7.5
