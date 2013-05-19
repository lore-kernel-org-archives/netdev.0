From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Fix GSO for 57710/57711 chips
Date: Sun, 19 May 2013 17:41:01 +0300
Message-ID: <1368974461-5308-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4249 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811Ab3ESOjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 May 2013 10:39:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with commit 91226790bbe2dbfbba48dd79d49f2b38ef10eb97
`bnx2x: use FW 7.8.17', the bnx2x driver no longer requests the FW to perform
IP checksums for IPv4 packets.

This behaviour needs to be revised for 57710/57711 chips -
when using GSO, if the driver will not set the IP checksum flag then packets
will be transmitted by the chip without a valid IP checksum, resulting in
a drop of all such packets on the receiver-side.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index b8fbe26..be59ec4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3313,6 +3313,7 @@ static void bnx2x_set_pbd_gso_e2(struct sk_buff *skb, u32 *parsing_data,
  */
 static void bnx2x_set_pbd_gso(struct sk_buff *skb,
 			      struct eth_tx_parse_bd_e1x *pbd,
+			      struct eth_tx_start_bd *tx_start_bd,
 			      u32 xmit_type)
 {
 	pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
@@ -3326,11 +3327,14 @@ static void bnx2x_set_pbd_gso(struct sk_buff *skb,
 						   ip_hdr(skb)->daddr,
 						   0, IPPROTO_TCP, 0));
 
-	} else
+		/* GSO on 57710/57711 needs FW to calculate IP checksum */
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IP_CSUM;
+	} else {
 		pbd->tcp_pseudo_csum =
 			bswab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 						 &ipv6_hdr(skb)->daddr,
 						 0, IPPROTO_TCP, 0));
+	}
 
 	pbd->global_data |=
 		cpu_to_le16(ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN);
@@ -3814,7 +3818,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			bnx2x_set_pbd_gso_e2(skb, &pbd_e2_parsing_data,
 					     xmit_type);
 		else
-			bnx2x_set_pbd_gso(skb, pbd_e1x, xmit_type);
+			bnx2x_set_pbd_gso(skb, pbd_e1x, tx_start_bd,
+					  xmit_type);
 	}
 
 	/* Set the PBD's parsing_data field if not zero
-- 
1.8.1.227.g44fe835
