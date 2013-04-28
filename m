From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2x: allow handling tunnel over udp
 offload
Date: Sun, 28 Apr 2013 21:16:02 +0300
Message-ID: <1367172962-17369-3-git-send-email-dmitry@broadcom.com>
References: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dmitry@broadcom.com
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4715 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756087Ab3D1SQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Apr 2013 14:16:24 -0400
In-Reply-To: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Pravin B Shelar <pshelar@nicira.com> 
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 5 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index fd20a4f..466b512 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3530,6 +3530,11 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 			ETH_TX_PARSE_2ND_BD_IP_HDR_LEN_OUTER_W_SHIFT) |
 		((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
 			ETH_TX_PARSE_2ND_BD_LLC_SNAP_EN_SHIFT);
+
+	if (ip_hdr(skb)->protocol == IPPROTO_UDP) {
+		SET_FLAG(*global_data, ETH_TX_PARSE_2ND_BD_TUNNEL_UDP_EXIST, 1);
+		pbd2->tunnel_udp_hdr_start_w = skb_transport_offset(skb) >> 1;
+	}
 }
 
 /* called with netif_tx_lock
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 927f83a..91a0434 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12043,11 +12043,11 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!CHIP_IS_E1x(bp)) {
-		dev->hw_features |= NETIF_F_GSO_GRE;
+		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 		dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
-			NETIF_F_GSO_GRE;
+			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 	}
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-- 
1.8.1.4
