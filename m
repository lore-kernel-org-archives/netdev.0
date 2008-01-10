From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/4] ipg: plug Tx completion leak
Date: Fri, 11 Jan 2008 00:37:07 +0100
Message-ID: <20080110233707.GC13315@electric-eye.fr.zoreil.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, jeff@garzik.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38178 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755979AbYAJXuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:50:52 -0500
Content-Disposition: inline
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tx skb release could not free more than one skb per call.
Add it to the fact that the xmit handler does not check for
a queue full condition and you have a recipe to leak quickly.

Let's release every pending Tx descriptor which has been given
back to the host CPU by the network controller. The xmit handler
suggests that it is done through the IPG_TFC_TFDDONE bit.

Remove the former "curr" computing: it does not produce anything
usable in its current form.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ipg.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index cd1650e..9752902 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -857,21 +857,14 @@ static void init_tfdlist(struct net_device *dev)
 static void ipg_nic_txfree(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
-	void __iomem *ioaddr = sp->ioaddr;
-	unsigned int curr;
-	u64 txd_map;
-	unsigned int released, pending;
-
-	txd_map = (u64)sp->txd_map;
-	curr = ipg_r32(TFD_LIST_PTR_0) -
-		do_div(txd_map, sizeof(struct ipg_tx)) - 1;
+	unsigned int released, pending, dirty;
 
 	IPG_DEBUG_MSG("_nic_txfree\n");
 
 	pending = sp->tx_current - sp->tx_dirty;
+	dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 
 	for (released = 0; released < pending; released++) {
-		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 		struct sk_buff *skb = sp->TxBuff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
@@ -882,11 +875,8 @@ static void ipg_nic_txfree(struct net_device *dev)
 		 * If the TFDDone bit is set, free the associated
 		 * buffer.
 		 */
-		if (dirty == curr)
-			break;
-
-		/* Setup TFDDONE for compatible issue. */
-		txfd->tfc |= cpu_to_le64(IPG_TFC_TFDDONE);
+		if (!(txfd->tfc & cpu_to_le64(IPG_TFC_TFDDONE)))
+                        break;
 
 		/* Free the transmit buffer. */
 		if (skb) {
@@ -898,6 +888,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 
 			sp->TxBuff[dirty] = NULL;
 		}
+		dirty = (dirty + 1) % IPG_TFDLIST_LENGTH;
 	}
 
 	sp->tx_dirty += released;
-- 
1.5.3.3

