From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Add missing bit in default Tx switching
Date: Thu, 27 Feb 2014 15:42:26 +0200
Message-ID: <1393508546-8489-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34589 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbaB0Nma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 08:42:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c14db2025 "bnx2x: Correct default Tx switching behaviour" supposedly
changed the default Tx switching behaviour, but was missing the fastpath change
required for FW to pass packets from PFs to VFs.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9d7419e..9e97eeb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3875,7 +3875,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						     xmit_type);
 		}
 
-		/* Add the macs to the parsing BD this is a vf */
+		/* Add the macs to the parsing BD if this is a vf or if
+		 * Tx Switching is enabled.
+		 */
 		if (IS_VF(bp)) {
 			/* override GRE parameters in BD */
 			bnx2x_set_fw_mac_addr(&pbd_e2->data.mac_addr.src_hi,
@@ -3887,6 +3889,11 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					      &pbd_e2->data.mac_addr.dst_mid,
 					      &pbd_e2->data.mac_addr.dst_lo,
 					      eth->h_dest);
+		} else if (bp->flags & TX_SWITCHING) {
+			bnx2x_set_fw_mac_addr(&pbd_e2->data.mac_addr.dst_hi,
+					      &pbd_e2->data.mac_addr.dst_mid,
+					      &pbd_e2->data.mac_addr.dst_lo,
+					      eth->h_dest);
 		}
 
 		SET_FLAG(pbd_e2_parsing_data,
-- 
1.8.1.227.g44fe835
