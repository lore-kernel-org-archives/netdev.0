From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [NET] [BUG-FIX] [Patch 1/1]: Revert use of skb_padto
Date: Fri, 16 May 2008 18:17:02 +0100
Message-ID: <20080516171702.GA1615@gerrit.erg.abdn.ac.uk>
References: <20080502202940.GA5116@gerrit.erg.abdn.ac.uk> <20080502144503.4ef2a430@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47172 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758741AbYEPRRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 13:17:23 -0400
Content-Disposition: inline
In-Reply-To: <20080502144503.4ef2a430@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[SC92031]: Using padto turned driver into an IPv6-only interface

IPv4 would work with this driver only with static arp table entries,
the patch  reverts a padto introduced in

 commit 26a17b7bbb36a8552d531bc1ad08472fb5aa3007
 sc92031: start transmit return value bugfix

The padto does not work because the driver code evaluates `len' later on and
there are cases where skb->len is not updated accordingly.

This was observed with ARP frames (skb->len = 42 bytes, !skb_cloned(), 
skb_tailroom = 84 bytes). Then in skb_pad(), the first condition is true, where
skb->len is not updated. As a consequence, the driver uses 42 bytes instead of
the 60 bytes, and the ARP frame never makes it onto the wire.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 drivers/net/sc92031.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -953,9 +953,6 @@ static int sc92031_start_xmit(struct sk_
 	unsigned entry;
 	u32 tx_status;
 
-	if (skb_padto(skb, ETH_ZLEN))
-		return NETDEV_TX_OK;
-
 	if (unlikely(skb->len > TX_BUF_SIZE)) {
 		dev->stats.tx_dropped++;
 		goto out;
@@ -975,6 +972,11 @@ static int sc92031_start_xmit(struct sk_
 	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
 
 	len = skb->len;
+	if (unlikely(len < ETH_ZLEN)) {
+		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
+				0, ETH_ZLEN - len);
+		len = ETH_ZLEN;
+	}
 
 	wmb();
 
