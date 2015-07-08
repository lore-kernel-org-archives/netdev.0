From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/1] sfc: Ensure down_write(&filter_sem) and up_write()
 are matched before calling efx_net_open()
Date: Wed, 8 Jul 2015 10:12:45 +0100
Message-ID: <559CE98D.1070703@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:58434 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933144AbbGHJMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 05:12:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch avoids the double up_write to filter_sem if
efx_net_open() fails.

Resolves: 2d432f20d27c1813a2746008e16dd6ce12a14dc1

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 6c9b6e4..1798e7e 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -640,21 +640,21 @@ int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i, u16 vlan,
 				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
 				  vf->vlan, &vf->vport_id);
 	if (rc)
-		goto reset_nic;
+		goto reset_nic_up_write;
 
 restore_mac:
 	if (!is_zero_ether_addr(vf->mac)) {
 		rc2 = efx_ef10_vport_add_mac(efx, vf->vport_id, vf->mac);
 		if (rc2) {
 			eth_zero_addr(vf->mac);
-			goto reset_nic;
+			goto reset_nic_up_write;
 		}
 	}
 
 restore_evb_port:
 	rc2 = efx_ef10_evb_port_assign(efx, vf->vport_id, vf_i);
 	if (rc2)
-		goto reset_nic;
+		goto reset_nic_up_write;
 	else
 		vf->vport_assigned = 1;
 
@@ -662,14 +662,16 @@ restore_vadaptor:
 	if (vf->efx) {
 		rc2 = efx_ef10_vadaptor_alloc(vf->efx, EVB_PORT_ID_ASSIGNED);
 		if (rc2)
-			goto reset_nic;
+			goto reset_nic_up_write;
 	}
 
 restore_filters:
 	if (vf->efx) {
 		rc2 = vf->efx->type->filter_table_probe(vf->efx);
 		if (rc2)
-			goto reset_nic;
+			goto reset_nic_up_write;
+
+		up_write(&vf->efx->filter_sem);
 
 		up_write(&vf->efx->filter_sem);
 
@@ -681,9 +683,12 @@ restore_filters:
 	}
 	return rc;
 
+reset_nic_up_write:
+	if (vf->efx)
+		up_write(&vf->efx->filter_sem);
+
 reset_nic:
 	if (vf->efx) {
-		up_write(&vf->efx->filter_sem);
 		netif_err(efx, drv, efx->net_dev,
 			  "Failed to restore VF - scheduling reset.\n");
 		efx_schedule_reset(vf->efx, RESET_TYPE_DATAPATH);
