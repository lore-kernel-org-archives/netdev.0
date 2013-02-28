From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 18:16:54 +0100
Message-ID: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:40417 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759406Ab3B1RRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 12:17:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not include the frame check sequence when adding the skb to
netif_receive_skb(). This causes problems when this interface was
bridged to a wifi ap and a big package should be forwarded from this
Ethernet driver through a bride to the wifi client.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index bf985c0..bce30e7 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -301,12 +301,16 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
 				  ring->start);
 		} else {
+			/* Omit CRC. */
+			len -= ETH_FCS_LEN;
+
 			new_skb = netdev_alloc_skb_ip_align(bgmac->net_dev, len);
 			if (new_skb) {
 				skb_put(new_skb, len);
 				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
 								 new_skb->data,
 								 len);
+				skb_checksum_none_assert(skb);
 				new_skb->protocol =
 					eth_type_trans(new_skb, bgmac->net_dev);
 				netif_receive_skb(new_skb);
-- 
1.7.10.4
