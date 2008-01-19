From: Byron Bradley <byron.bbradley@gmail.com>
Subject: [PATCH] mv643xx: fix byte order when checksum offload is enabled
Date: Sat, 19 Jan 2008 19:27:38 +0000
Message-ID: <1200770858-11456-1-git-send-email-byron.bbradley@gmail.com>
Cc: hvr@gnu.org, akpm@linux-foundation.org,
	Byron Bradley <byron.bbradley@gmail.com>,
	Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>,
	Tzachi Perelstein <tzachi@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.blueyonder.co.uk ([195.188.213.5]:49898 "EHLO
	smtp-out2.blueyonder.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbYASTfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 14:35:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell Orion system on chips have an integrated mv643xx MAC.
On these little endian ARM devices mv643xx will oops when checksum
offload is enabled. Swapping the byte order of the protocol and
checksum solves this problem.

Signed-off-by: Byron Bradley <byron.bbradley@gmail.com>
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Manish Lachwani <mlachwani@mvista.com>
Cc: Tzachi Perelstein <tzachi@marvell.com>
---

This patch has only been tested on two Marvell Orion based boards so it
should be considered only very lightly tested. It applies against
2.6.24-rc8-mm1.

 drivers/net/mv643xx_eth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 651c269..5d16a5d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1689,7 +1689,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != ETH_P_IP);
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 			   ETH_GEN_IP_V_4_CHECKSUM  |
@@ -1698,10 +1698,10 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = udp_hdr(skb)->check;
+			desc->l4i_chk = htons(udp_hdr(skb)->check);
 			break;
 		case IPPROTO_TCP:
-			desc->l4i_chk = tcp_hdr(skb)->check;
+			desc->l4i_chk = htons(tcp_hdr(skb)->check);
 			break;
 		default:
 			BUG();
-- 
1.5.4.rc2.38.gd6da3


