From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: don't try and read ef10 data on non-ef10 NIC
Date: Tue, 15 Aug 2017 14:55:32 +0100
Message-ID: <45a53c3b-b578-56ed-ef41-09bef5b5519c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
        "Stefano Brivio" <sbrivio@redhat.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:54448 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750936AbdHONzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:55:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAC stats command takes a port ID, which doesn't exist on
pre-ef10 NICs (5000- and 6000- series). This is extracted from the
NIC specific data; we misinterpret this as the ef10 data structure,
causing us to read potentially unallocated data. With a KASAN kernel
this can cause errors with:
   BUG: KASAN: slab-out-of-bounds in efx_mcdi_mac_stats

Fixes: 0a2ab4d988d7 ("sfc: set the port-id when calling MC_CMD_MAC_STATS")
Reported-by: Stefano Brivio <sbrivio@redhat.com>
Tested-by: Stefano Brivio <sbrivio@redhat.com>
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_port.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index c905971c5f3a..990a63d7fcb7 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -938,7 +938,6 @@ enum efx_stats_action {
 static int efx_mcdi_mac_stats(struct efx_nic *efx,
 			      enum efx_stats_action action, int clear)
 {
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
 	int rc;
 	int change = action == EFX_STATS_PULL ? 0 : 1;
@@ -960,7 +959,12 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx,
 			      MAC_STATS_IN_PERIODIC_NOEVENT, 1,
 			      MAC_STATS_IN_PERIOD_MS, period);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
-	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, nic_data->vport_id);
+
+	if (efx_nic_rev(efx) >= EFX_REV_HUNT_A0) {
+		struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+		MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, nic_data->vport_id);
+	}
 
 	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
 				NULL, 0, NULL);
-- 
2.7.5
