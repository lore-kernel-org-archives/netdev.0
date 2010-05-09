From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 09/11] netdev: bfin_mac: only use hardware checksum in normal IPv4 mode
Date: Sun,  9 May 2010 06:18:55 -0400
Message-ID: <1273400337-26501-9-git-send-email-vapier@gentoo.org>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Jon Kowal <jon.kowal@dspecialists.de>,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53271 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842Ab0EIKQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 06:16:15 -0400
In-Reply-To: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Kowal <jon.kowal@dspecialists.de>

The Blackfin on-chip MAC checksum logic only works when the IP packet has
a header length of 20 bytes.  This is true for most IPv4 packets, but not
for IPv6 packets or IPv4 packets which use header options.  So only use
the hardware checksum when appropriate.

Signed-off-by: Jon Kowal <jon.kowal@dspecialists.de>
Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   42 +++++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 04cda8f..00d0f25 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1044,6 +1044,7 @@ out:
 	return NETDEV_TX_OK;
 }
 
+#define IP_HEADER_OFF  0
 #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
 	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
 
@@ -1098,25 +1099,32 @@ static void bfin_mac_rx(struct net_device *dev)
 	bfin_rx_hwtstamp(dev, skb);
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
-	skb->csum = current_rx_ptr->status.ip_payload_csum;
-	/*
-	 * Deduce Ethernet FCS from hardware generated IP payload checksum.
-	 * IP checksum is based on 16-bit one's complement algorithm.
-	 * To deduce a value from checksum is equal to add its inversion.
-	 * If the IP payload len is odd, the inversed FCS should also
-	 * begin from odd address and leave first byte zero.
+	/* Checksum offloading only works for IPv4 packets with the standard IP header
+	 * length of 20 bytes, because the blackfin MAC checksum calculation is
+	 * based on that assumption. We must NOT use the calculated checksum if our
+	 * IP version or header break that assumption.
 	 */
-	if (skb->len % 2) {
-		fcs[0] = 0;
-		for (i = 0; i < ETH_FCS_LEN; i++)
-			fcs[i + 1] = ~skb->data[skb->len + i];
-		skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
-	} else {
-		for (i = 0; i < ETH_FCS_LEN; i++)
-			fcs[i] = ~skb->data[skb->len + i];
-		skb->csum = csum_partial(fcs, ETH_FCS_LEN, skb->csum);
+	if (skb->data[IP_HEADER_OFF] == 0x45) {
+		skb->csum = current_rx_ptr->status.ip_payload_csum;
+		/*
+		 * Deduce Ethernet FCS from hardware generated IP payload checksum.
+		 * IP checksum is based on 16-bit one's complement algorithm.
+		 * To deduce a value from checksum is equal to add its inversion.
+		 * If the IP payload len is odd, the inversed FCS should also
+		 * begin from odd address and leave first byte zero.
+		 */
+		if (skb->len % 2) {
+			fcs[0] = 0;
+			for (i = 0; i < ETH_FCS_LEN; i++)
+				fcs[i + 1] = ~skb->data[skb->len + i];
+			skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
+		} else {
+			for (i = 0; i < ETH_FCS_LEN; i++)
+				fcs[i] = ~skb->data[skb->len + i];
+			skb->csum = csum_partial(fcs, ETH_FCS_LEN, skb->csum);
+		}
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
-	skb->ip_summed = CHECKSUM_COMPLETE;
 #endif
 
 	netif_rx(skb);
-- 
1.7.1

