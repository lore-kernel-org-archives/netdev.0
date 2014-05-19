From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 6/9] net: mv643xx_eth: Avoid setting the initial TCP checksum
Date: Mon, 19 May 2014 13:59:57 -0300
Message-ID: <1400518800-6111-7-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53617 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964772AbaESRBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:01:13 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As specified in the datasheet, the driver can set the "L4Chk_Mode" flag
(bit 10) in the Tx descriptor command/status to specify that a frame is not
IP fragmented and that the controller is in charge of generating the TCP/IP
checksum. This must be used together with the "GL4chk" flag (bit 17).

These two flags allow to avoid setting the initial TCP checksum in the l4i_chk
field of the Tx descriptor, which is needed to support software TSO.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 14a0dbb..5ad19d2 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -250,6 +250,7 @@ struct tx_desc {
 #define GEN_TCP_UDP_CHECKSUM		0x00020000
 #define UDP_FRAME			0x00010000
 #define MAC_HDR_EXTRA_4_BYTES		0x00008000
+#define GEN_TCP_UDP_CHK_FULL		0x00000400
 #define MAC_HDR_EXTRA_8_BYTES		0x00000200
 
 #define TX_IHL_SHIFT			11
@@ -695,17 +696,19 @@ static int skb_tx_csum(struct mv643xx_eth_private *mp, struct sk_buff *skb,
 		if (tag_bytes & 8)
 			cmd |= MAC_HDR_EXTRA_8_BYTES;
 
-		cmd |= GEN_TCP_UDP_CHECKSUM |
+		cmd |= GEN_TCP_UDP_CHECKSUM | GEN_TCP_UDP_CHK_FULL |
 			   GEN_IP_V4_CHECKSUM   |
 			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
+		/* TODO: Revisit this. With the usage of GEN_TCP_UDP_CHK_FULL
+		 * it seems we don't need to pass the initial checksum. */
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd |= UDP_FRAME;
-			*l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
+			*l4i_chk = 0;
 			break;
 		case IPPROTO_TCP:
-			*l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
+			*l4i_chk = 0;
 			break;
 		default:
 			WARN(1, "protocol not supported");
-- 
1.9.1
