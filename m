From: Sonny Rao <sonnyrao@us.ibm.com>
Subject: [PATCH] Add missing read memory barrier to Intel
 Ethernet device drivers
Date: Wed, 21 Jul 2010 11:22:41 -0500
Message-ID: <20100721162241.GW21853@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Milton Miller <miltonm@bga.com>

The PowerPC architecture does not require loads to independent bytes to be
ordered without adding an explicit barrier.

In ixgbe_clean_rx_irq we load the status bit then load the packet data.
With packet split disabled if these loads go out of order we get a
stale packet, but we will notice the bad sequence numbers and drop it.

The problem occurs with packet split enabled where the TCP/IP header and data
are in different descriptors. If the reads go out of order we may have data
that doesn't match the TCP/IP header. Since we use hardware checksumming this
bad data is never verified and it makes it all the way to the application.

This bug was found during stress testing and adding this barrier has been shown
to fix it.  The bug can manifest as a data integrity issue (bad payload data)
or as a BUG in skb_pull().

This was a nasty bug to hunt down, if people agree with the fix I think
it's a candidate for stable.

Previously Submitted to e1000-devel only for ixgbe

http://marc.info/?l=e1000-devel&m=126593062701537&w=3

We've now seen this problem hit with other device drivers (e1000e mostly)
So I'm resubmitting with fixes for other Intel Device Drivers with
similar issues:  ixgb, e100, e1000, and e1000e 

Signed-off-by: Milton Miller <miltonm@bga.com>
Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Sonny Rao <sonnyrao@us.ibm.com>
cc: stable <stable@kernel.org>

---



Index: linux-2.6.35-rc5/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e1000/e1000_main.c	2010-07-21 11:19:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e1000/e1000_main.c	2010-07-21 11:19:58.000000000 -0500
@@ -3448,6 +3448,7 @@ static bool e1000_clean_tx_irq(struct e1
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+		rmb();	/* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
Index: linux-2.6.35-rc5/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e1000e/netdev.c	2010-07-21 11:19:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e1000e/netdev.c	2010-07-21 11:19:58.000000000 -0500
@@ -984,6 +984,7 @@ static bool e1000_clean_tx_irq(struct e1
 	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
 	       (count < tx_ring->count)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for (; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
Index: linux-2.6.35-rc5/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/ixgb/ixgb_main.c	2010-07-21 11:19:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/ixgb/ixgb_main.c	2010-07-21 11:19:58.000000000 -0500
@@ -1816,6 +1816,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 
 	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
+		rmb(); /* read buffer_info after eop_desc */
 		for (cleaned = false; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
Index: linux-2.6.35-rc5/drivers/net/e100.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/e100.c	2010-07-21 11:19:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/e100.c	2010-07-21 11:20:04.000000000 -0500
@@ -1779,6 +1779,7 @@ static int e100_tx_clean(struct nic *nic
 	for (cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
+		rmb(); /* read skb after status */
 		netif_printk(nic, tx_done, KERN_DEBUG, nic->netdev,
 			     "cb[%d]->status = 0x%04X\n",
 			     (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
Index: linux-2.6.35-rc5/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.35-rc5.orig/drivers/net/ixgbe/ixgbe_main.c	2010-07-21 11:19:47.000000000 -0500
+++ linux-2.6.35-rc5/drivers/net/ixgbe/ixgbe_main.c	2010-07-21 11:19:58.000000000 -0500
@@ -748,6 +748,7 @@ static bool ixgbe_clean_tx_irq(struct ix
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
 	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
+		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
