From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Thu, 10 Jan 2008 00:30:56 +0100
Message-ID: <20080109233056.GA5673@electric-eye.fr.zoreil.com>
References: <20080108213640.GC4450@electric-eye.fr.zoreil.com> <20080109003840.22917.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58264 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754855AbYAIXrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:47:11 -0500
Content-Disposition: inline
In-Reply-To: <20080109003840.22917.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux@horizon.com <linux@horizon.com> :
[...]
> That doesn't seem to do it.  Not entirely, at least.  After downloading
> and partially re-uploading an 800M file, slabtop reports:

Ok, enjoy this one. It is definitely better wrt the current problem.

More work tomorrow.

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..42f300d 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -860,18 +860,18 @@ static void ipg_nic_txfree(struct net_device *dev)
 	void __iomem *ioaddr = sp->ioaddr;
 	unsigned int curr;
 	u64 txd_map;
-	unsigned int released, pending;
+	unsigned int released, pending, dirty;
 
 	txd_map = (u64)sp->txd_map;
 	curr = ipg_r32(TFD_LIST_PTR_0) -
 		do_div(txd_map, sizeof(struct ipg_tx)) - 1;
 
 	IPG_DEBUG_MSG("_nic_txfree\n");
 
 	pending = sp->tx_current - sp->tx_dirty;
+	dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 
 	for (released = 0; released < pending; released++) {
-		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 		struct sk_buff *skb = sp->TxBuff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
@@ -882,8 +884,11 @@ static void ipg_nic_txfree(struct net_device *dev)
 		 * If the TFDDone bit is set, free the associated
 		 * buffer.
 		 */
-		if (dirty == curr)
+		if (!(txfd->tfc & cpu_to_le64(IPG_TFC_TFDDONE))) {
+			printk(KERN_INFO "%s: released = %d pending = %d\n",
+				dev->name, released, pending);
 			break;
+		}
 
 		/* Setup TFDDONE for compatible issue. */
 		txfd->tfc |= cpu_to_le64(IPG_TFC_TFDDONE);
@@ -898,6 +903,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 
 			sp->TxBuff[dirty] = NULL;
 		}
+		dirty = (dirty + 1) % IPG_TFDLIST_LENGTH;
 	}
 
 	sp->tx_dirty += released;
@@ -1943,10 +1948,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -2003,7 +2005,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ipg_w32(IPG_DC_TX_DMA_POLL_NOW, DMA_CTRL);
 
 	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
-		netif_wake_queue(dev);
+		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&sp->lock, flags);
 
-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
