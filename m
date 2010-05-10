From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/9] netdev: bfin_mac: handler RX status errors
Date: Mon, 10 May 2010 11:39:07 -0400
Message-ID: <1273505954-32588-2-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Peter Meerwald <pmeerw@pmeerw.net>,
	Graf Yang <graf.yang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43471 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab0EJPgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:20 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Meerwald <pmeerw@pmeerw.net>

Signed-off-by: Peter Meerwald <pmeerw@pmeerw.net>
Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 6a9519f..c888465 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -981,12 +981,25 @@ out:
 	return NETDEV_TX_OK;
 }
 
+#define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
+	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
+
 static void bfin_mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
 	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
 
+	/* check if frame status word reports an error condition
+	 * we which case we simply drop the packet
+	 */
+	if (current_rx_ptr->status.status_word & RX_ERROR_MASK) {
+		printk(KERN_NOTICE DRV_NAME
+		       ": rx: receive error - packet dropped\n");
+		dev->stats.rx_dropped++;
+		goto out;
+	}
+
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
 
@@ -1025,11 +1038,9 @@ static void bfin_mac_rx(struct net_device *dev)
 	netif_rx(skb);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
+out:
 	current_rx_ptr->status.status_word = 0x00000000;
 	current_rx_ptr = current_rx_ptr->next;
-
-out:
-	return;
 }
 
 /* interrupt routine to handle rx and error signal */
-- 
1.7.1

