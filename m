From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 4/9 v2] netdev: bfin_mac: deduce Ethernet FCS from hardware IP payload checksum
Date: Mon, 10 May 2010 11:39:09 -0400
Message-ID: <1273505954-32588-4-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jon Kowal <jon.kowal@dspecialists.de>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43484 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049Ab0EJPgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:23 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

IP checksum is based on 16-bit one's complement algorithm, so to deduce a
value from checksum is equal to add its complement.

Unfortunately, the Blackfin on-chip MAC checksum logic only works when the
IP packet has a header length of 20 bytes.  This is true for most IPv4
packets, but not for IPv6 packets or IPv4 packets which use header options.
So only use the hardware checksum when appropriate.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Jon Kowal <jon.kowal@dspecialists.de>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
v2
	- folded the ipv4 checks into this patch

 drivers/net/bfin_mac.c |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index f9ba598..b57b5ac 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -986,6 +986,7 @@ out:
 	return NETDEV_TX_OK;
 }
 
+#define IP_HEADER_OFF  0
 #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
 	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
 
@@ -994,6 +995,10 @@ static void bfin_mac_rx(struct net_device *dev)
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
 	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	unsigned int i;
+	unsigned char fcs[ETH_FCS_LEN + 1];
+#endif
 
 	/* check if frame status word reports an error condition
 	 * we which case we simply drop the packet
@@ -1027,6 +1032,8 @@ static void bfin_mac_rx(struct net_device *dev)
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
+	/* Deduce Ethernet FCS length from Ethernet payload length */
+	len -= ETH_FCS_LEN;
 	skb_put(skb, len);
 
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1034,8 +1041,32 @@ static void bfin_mac_rx(struct net_device *dev)
 	bfin_rx_hwtstamp(dev, skb);
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
-	skb->csum = current_rx_ptr->status.ip_payload_csum;
-	skb->ip_summed = CHECKSUM_COMPLETE;
+	/* Checksum offloading only works for IPv4 packets with the standard IP header
+	 * length of 20 bytes, because the blackfin MAC checksum calculation is
+	 * based on that assumption. We must NOT use the calculated checksum if our
+	 * IP version or header break that assumption.
+	 */
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
+	}
 #endif
 
 	netif_rx(skb);
-- 
1.7.1

