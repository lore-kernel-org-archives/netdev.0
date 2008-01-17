From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'ipg-fixes' branch (try #2)
Date: Thu, 17 Jan 2008 23:36:51 +0100
Message-ID: <20080117223651.GA7782@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux@horizon.com,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Sorbica@icplus.com.tw, Jesse@icplus.com.tw,
	craig_rich@sundanceti.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41307 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760392AbYAQWwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 17:52:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'ipg-fixes' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git ipg-fixes

to get the changes below.

Distance from 'master' (d8c89eb3a12f0da96d049bd515c7fa3702e511c5)
-----------------------------------------------------------------

47cccd7d7cc1f2b6f34aadc9041fb991c6293cdd
dafdec746f8c468bebf6b99f32a392ee6c8d0212
0da1b995aee447656c0eb77e4e32468e37f868a3
227bc24d675d80de1cfb3ab72891cc932dadbc3b

Diffstat
--------

 drivers/net/ipg.c |   36 ++++++++++++------------------------
 1 files changed, 12 insertions(+), 24 deletions(-)

Shortlog
--------

Francois Romieu (4):
      ipg: balance locking in irq handler
      ipg: plug Tx completion leak
      ipg: fix queue stop condition in the xmit handler
      ipg: fix Tx completion irq request

Patch
-----

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..50f0c17 100644
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
@@ -1630,6 +1621,8 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 #ifdef JUMBO_FRAME
 	ipg_nic_rxrestore(dev);
 #endif
+	spin_lock(&sp->lock);
+
 	/* Get interrupt source information, and acknowledge
 	 * some (i.e. TxDMAComplete, RxDMAComplete, RxEarly,
 	 * IntRequested, MacControlFrame, LinkEvent) interrupts
@@ -1647,9 +1640,7 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 	handled = 1;
 
 	if (unlikely(!netif_running(dev)))
-		goto out;
-
-	spin_lock(&sp->lock);
+		goto out_unlock;
 
 	/* If RFDListEnd interrupt, restore all used RFDs. */
 	if (status & IPG_IS_RFD_LIST_END) {
@@ -1733,9 +1724,9 @@ out_enable:
 	ipg_w16(IPG_IE_TX_DMA_COMPLETE | IPG_IE_RX_DMA_COMPLETE |
 		IPG_IE_HOST_ERROR | IPG_IE_INT_REQUESTED | IPG_IE_TX_COMPLETE |
 		IPG_IE_LINK_EVENT | IPG_IE_UPDATE_STATS, INT_ENABLE);
-
+out_unlock:
 	spin_unlock(&sp->lock);
-out:
+
 	return IRQ_RETVAL(handled);
 }
 
@@ -1943,10 +1934,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (sp->tenmbpsmode)
 		txfd->tfc |= cpu_to_le64(IPG_TFC_TXINDICATE);
-	else if (!((sp->tx_current - sp->tx_dirty + 1) >
-	    IPG_FRAMESBETWEENTXDMACOMPLETES)) {
-		txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
-	}
+	txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
 	/* Based on compilation option, determine if FCS is to be
 	 * appended to transmit frame by IPG.
 	 */
@@ -2003,7 +1991,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ipg_w32(IPG_DC_TX_DMA_POLL_NOW, DMA_CTRL);
 
 	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
-		netif_wake_queue(dev);
+		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&sp->lock, flags);
 
-- 
Ueimor
