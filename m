From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/11][TG3]: Fix TSO bugs.
Date: Fri, 04 May 2007 17:51:48 -0700
Message-ID: <1178326308.4859.17.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3833 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767921AbXEEAEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:04:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix TSO bugs.

1. Remove the check for skb->len greater than MTU when doing TSO.
When the destination has a smaller MSS than the source, a TSO packet
may be smaller than the MTU and we still need to process it as a TSO
packet.

2. On 5705A3 devices with TSO enabled, the DMA engine can hang due to a
hardware bug.  This patch avoids the hanging condition by reducing the
DMA burst size.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9488f49..b8141be 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3895,8 +3895,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	entry = tp->tx_prod;
 	base_flags = 0;
 	mss = 0;
-	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
-	    (mss = skb_shinfo(skb)->gso_size) != 0) {
+	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
 
 		if (skb_header_cloned(skb) &&
@@ -4053,8 +4052,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 	mss = 0;
-	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
-	    (mss = skb_shinfo(skb)->gso_size) != 0) {
+	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		struct iphdr *iph;
 		int tcp_opt_len, ip_tcp_len, hdr_len;
 
@@ -6346,8 +6344,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750)) {
 		if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE &&
-		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
-		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
 			rdmac_mode |= RDMAC_MODE_FIFO_SIZE_128;
 		} else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
 			   !(tp->tg3_flags2 & TG3_FLG2_IS_5788)) {


