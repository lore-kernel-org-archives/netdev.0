From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 4/6] netdev: bfin_mac: deduce Ethernet FCS from hardware IP payload checksum
Date: Tue, 19 Jan 2010 06:08:25 -0500
Message-ID: <1263899307-10627-4-git-send-email-vapier@gentoo.org>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59088 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755906Ab0ASLIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 06:08:19 -0500
In-Reply-To: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

IP checksum is based on 16-bit one's complement algorithm.
To deduce a value from checksum is equal to add its complement.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index a907e33..112d13e 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -994,6 +994,10 @@ static void bfin_mac_rx(struct net_device *dev)
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
 	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	unsigned int i;
+	unsigned char fcs[ETH_FCS_LEN + 1];
+#endif
 
 	/* check if frame status word reports an error condition
 	 * we which case we simply drop the packet
@@ -1027,6 +1031,8 @@ static void bfin_mac_rx(struct net_device *dev)
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
+	/* Deduce Ethernet FCS length from Ethernet payload length */
+	len -= ETH_FCS_LEN;
 	skb_put(skb, len);
 
 	skb->protocol = eth_type_trans(skb, dev);
@@ -1035,6 +1041,23 @@ static void bfin_mac_rx(struct net_device *dev)
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
+	/*
+	 * Deduce Ethernet FCS from hardware generated IP payload checksum.
+	 * IP checksum is based on 16-bit one's complement algorithm.
+	 * To deduce a value from checksum is equal to add its inversion.
+	 * If the IP payload len is odd, the inversed FCS should also
+	 * begin from odd address and leave first byte zero.
+	 */
+	if (skb->len % 2) {
+		fcs[0] = 0;
+		for (i = 0; i < ETH_FCS_LEN; i++)
+			fcs[i + 1] = ~skb->data[skb->len + i];
+		skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
+	} else {
+		for (i = 0; i < ETH_FCS_LEN; i++)
+			fcs[i] = ~skb->data[skb->len + i];
+		skb->csum = csum_partial(fcs, ETH_FCS_LEN, skb->csum);
+	}
 	skb->ip_summed = CHECKSUM_COMPLETE;
 #endif
 
-- 
1.6.6

