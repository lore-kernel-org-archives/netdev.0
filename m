From: akpm@linux-foundation.org
Subject: [patch 3/4] mv643xx_eth: fix byte order when checksum offload is enabled
Date: Mon, 04 Feb 2008 23:47:15 -0800
Message-ID: <200802050746.m157kur6010404@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	byron.bbradley@gmail.com, dale@farnsworth.org,
	mlachwani@mvista.com, viro@zeniv.linux.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41427 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753644AbYBEHrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byron Bradley <byron.bbradley@gmail.com>

The Marvell Orion system on chips have an integrated mv643xx MAC.  On these
little endian ARM devices mv643xx will oops when checksum offload is
enabled.  Swapping the byte order of the protocol and checksum solves this
problem.

Signed-off-by: Byron Bradley <byron.bbradley@gmail.com>
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Manish Lachwani <mlachwani@mvista.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/mv643xx_eth.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff -puN drivers/net/mv643xx_eth.c~mv643xx_eth-fix-byte-order-when-checksum-offload-is-enabled drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c~mv643xx_eth-fix-byte-order-when-checksum-offload-is-enabled
+++ a/drivers/net/mv643xx_eth.c
@@ -1652,6 +1652,11 @@ static void eth_tx_fill_frag_descs(struc
 	}
 }
 
+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
+}
+
 /**
  * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
  *
@@ -1689,7 +1694,7 @@ static void eth_tx_submit_descs_for_skb(
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != ETH_P_IP);
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 			   ETH_GEN_IP_V_4_CHECKSUM  |
@@ -1698,10 +1703,10 @@ static void eth_tx_submit_descs_for_skb(
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = udp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
 			break;
 		case IPPROTO_TCP:
-			desc->l4i_chk = tcp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
 			break;
 		default:
 			BUG();
_
