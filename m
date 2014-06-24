From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 3/6] amd-xgbe: VLAN Rx tag stripping fix
Date: Tue, 24 Jun 2014 16:19:18 -0500
Message-ID: <20140624211918.20681.26540.stgit@tlendack-t1.amdoffice.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.207] ([207.46.163.207]:22904 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752809AbaFXVUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:20:03 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving a VLAN packet check to be sure that VLAN
RX CTAG stripping is enabled before indicating that the
tag has been stripped in the packet information data
structure.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index b239b21..d0f4379 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1113,6 +1113,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	struct xgbe_ring_data *rdata;
 	struct xgbe_ring_desc *rdesc;
 	struct xgbe_packet_data *packet = &ring->packet_data;
+	struct net_device *netdev = channel->pdata->netdev;
 	unsigned int err, etlt;
 
 	DBGPR("-->xgbe_dev_read: cur = %d\n", ring->cur);
@@ -1153,7 +1154,8 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	DBGPR("  err=%u, etlt=%#x\n", err, etlt);
 
 	if (!err || (err && !etlt)) {
-		if (etlt == 0x09) {
+		if ((etlt == 0x09) &&
+		    (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
 			XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
 				       VLAN_CTAG, 1);
 			packet->vlan_ctag = XGMAC_GET_BITS_LE(rdesc->desc0,
