From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 1/2] bnx2x: Allow vfs to disable txvlan offload
Date: Fri, 9 Jun 2017 17:17:01 +0300
Message-ID: <20170609141702.20688-2-Yuval.Mintz@cavium.com>
References: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mschmidt@redhat.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0046.outbound.protection.outlook.com ([104.47.40.46]:16288
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751572AbdFIORd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:17:33 -0400
In-Reply-To: <20170609141702.20688-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF clients are configured as enforced, meaning firmware is validating
the correctness of their ethertype/vid during transmission.
Once txvlan is disabled, VF would start getting SKBs for transmission
here vlan is on the payload - but it'll pass the packet's ethertype
instead of the vid, leading to firmware declaring it as malicious.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5f49334..f619c4c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3883,15 +3883,26 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* when transmitting in a vf, start bd must hold the ethertype
 		 * for fw to enforce it
 		 */
+		u16 vlan_tci = 0;
 #ifndef BNX2X_STOP_ON_ERROR
-		if (IS_VF(bp))
+		if (IS_VF(bp)) {
 #endif
-			tx_start_bd->vlan_or_ethertype =
-				cpu_to_le16(ntohs(eth->h_proto));
+			/* Still need to consider inband vlan for enforced */
+			if (__vlan_get_tag(skb, &vlan_tci)) {
+				tx_start_bd->vlan_or_ethertype =
+					cpu_to_le16(ntohs(eth->h_proto));
+			} else {
+				tx_start_bd->bd_flags.as_bitfield |=
+					(X_ETH_INBAND_VLAN <<
+					 ETH_TX_BD_FLAGS_VLAN_MODE_SHIFT);
+				tx_start_bd->vlan_or_ethertype =
+					cpu_to_le16(vlan_tci);
+			}
 #ifndef BNX2X_STOP_ON_ERROR
-		else
+		} else {
 			/* used by FW for packet accounting */
 			tx_start_bd->vlan_or_ethertype = cpu_to_le16(pkt_prod);
+		}
 #endif
 	}
 
-- 
2.9.4
