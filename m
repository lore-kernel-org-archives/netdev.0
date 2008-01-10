From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/4] Pull request for 'ipg-fixes' branch
Date: Fri, 11 Jan 2008 00:35:08 +0100
Message-ID: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Cc: linux@horizon.com, jeff@garzik.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38173 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754219AbYAJXul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:50:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Please pull from branch 'ipg-fixes' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git ipg-fixes

to get the changes below.

I have tested the driver with a PIV HT based motherboard. The network
controller is connected to a fast ethernet switch (yeah, I'm cheap).
A second host is performing two loop of scp in both direction for a
400Mb file. The files are sha1sumed after each scp. I have added a
'ping -q -f -l16' from the computer under test after some time.

After 35 copies from the computer under test and 28 copies to it
(the ping eats a bit):
             total       used       free     shared    buffers     cached
Mem:       1019040    1003860      15180          0      20556     936792
-/+ buffers/cache:      46512     972528
Swap:      2031608          0    2031608

Before:
             total       used       free     shared    buffers     cached
Mem:       1019040     572036     447004          0      14988     525924
-/+ buffers/cache:      31124     987916
Swap:      2031608          0    2031608

/proc/slabinfo before and after the test are attached.

The driver is still a POMS but it seems better now.

I will not be available to work further on this issue before sunday.
I'd appreciate being Cced though.

Distance from 'net-2.6/master' (27d1cba21fcc50c37eef5042c6be9fa7135e88fc)
-------------------------------------------------------------------------

286c83ce6e8263a5c4c55a57b4c1040800de0171
d42f3afc953f9c99ffe84667a3ecf0d3b69f3d64
358bf4b8e8cbde5d6411b219e93a61728c892685
a58cceed4464ba8ae94294184c15f43e92a5de89

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

--UugvWAfsgieZRqgk
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="slab.tgz"
Content-Transfer-Encoding: base64

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
rW1ta1tq+wfitsumABgBAA==

--UugvWAfsgieZRqgk--
