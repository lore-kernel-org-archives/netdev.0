From: Anton Blanchard <anton@samba.org>
Subject: e1000 issues
Date: Sun, 28 Mar 2004 11:10:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040328011052.GQ27747@krispykreme>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Cc: cramerj@intel.com, john.ronciak@intel.com, Ganesh.Venkatesan@intel.com,
        jk@ozlabs.org, olof@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi,

Welcome to the new e1000 guys. Here is our current ppc64+2.6+e1000 hitlist
(apologies to those who have received this before):

- We can wrap around the tx ring and start overwriting valid entries. On
  ppc64 that means we leak IOMMU entries and eventually run out of them.
  Olof Johansson debugged this problem and provided the attached fix
  (e1000_tx_wraparound).

- TSO HW workaround doesnt seem to be working. In TSO mode, some e1000s
  report DMA complete too early. There is a workaround in the current
  driver:

#ifdef NETIF_F_TSO
                        /* Workaround for premature desc write-backs
                         * in TSO mode.  Append 4-byte sentinel desc */
                        if(mss && f == (nr_frags-1) && size == len &&
size > 8)
                                size -= 4;
#endif

  However we were still getting card lockups so Jeremy put together a
  patch based on our original workaround when we first found the bug
  (e1000_tso_hack). Basically it keeps a one entry cache of skbs and pci
  mappings and always frees the second to last one. Yes its a hack and
  it will leak skbs and IOMMU entries but with it applied we no longer
  see any problems.

  BTW I wonder if this is the problem Scott mentioned in his checkin
  comment to disable TSO by default on e1000 2.6.

- e1000 tx spinlock is extremely painful.

Heres a web benchmark run with 2.6 BK (numbers are in %):

9.7149  e1000_xmit_frame
4.2336  tcp_v4_rcv
3.9495  skb_release_data
3.8244  qdisc_restart
3.5437  iommu_free

Heres the profile after I backed the tx spinlock patch out (attached):

6.4075  pci_iommu_map_single
4.3752  tcp_v4_rcv
4.1046  skb_release_data
3.8190  iommu_free
3.7119  default_idle
3.6749  qdisc_restart
3.4538  iommu_alloc
2.0153  do_tcp_sendpages
1.8828  __d_lookup
1.7772  e1000_clean_tx_irq
1.7654  atomic_dec_and_lock
1.7354  e1000_xmit_frame

And performance improved. Olof had suggestions for how to work around
this problem without incurring the cost of a spinlock.

Anton

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=e1000_tx_wraparound


Fix from Olof Johansson to avoid overwriting valid tx ring entries.

diff -urN linux-2.5/drivers/net/e1000/e1000_main.c ameslab-2.5/drivers/net/e1000/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-03-09 14:32:14.000000000 +1100
+++ ameslab-2.5/drivers/net/e1000/e1000_main.c	2004-02-27 00:45:41.000000000 +1100
@@ -1582,7 +1582,7 @@
 
 	i = tx_ring->next_to_use;
 
-	while(len) {
+	while(len && count < E1000_DESC_UNUSED(&adapter->tx_ring)) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
 #ifdef NETIF_F_TSO
@@ -1619,7 +1619,7 @@
 		len = frag->size;
 		offset = frag->page_offset;
 
-		while(len) {
+		while(len && count < E1000_DESC_UNUSED(&adapter->tx_ring)) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
 #ifdef NETIF_F_TSO

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=e1000_tso_hack

diff -urN ppc64-linux-2.5.orig/drivers/net/e1000/e1000.h ppc64-linux-2.5/drivers/net/e1000/e1000.h
--- ppc64-linux-2.5.orig/drivers/net/e1000/e1000.h	2004-02-26 22:14:44.000000000 +1100
+++ ppc64-linux-2.5/drivers/net/e1000/e1000.h	2004-03-09 12:58:53.000000000 +1100
@@ -246,5 +246,9 @@
 
 
 	uint32_t pci_state[16];
+
+	/* TSO hack */
+	unsigned long tso_hack_dma, tso_hack_len;
+	struct sk_buff *tso_hack_skb;
 };
 #endif /* _E1000_H_ */
diff -urN ppc64-linux-2.5.orig/drivers/net/e1000/e1000_main.c ppc64-linux-2.5/drivers/net/e1000/e1000_main.c
--- ppc64-linux-2.5.orig/drivers/net/e1000/e1000_main.c	2004-02-26 22:14:44.000000000 +1100
+++ ppc64-linux-2.5/drivers/net/e1000/e1000_main.c	2004-03-09 13:01:06.000000000 +1100
@@ -2200,17 +2200,25 @@
 
 			if(buffer_info->dma) {
 
-				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
+				if (adapter->tso_hack_dma) {
+					pci_unmap_page(pdev, 
+					       adapter->tso_hack_dma,
+					       adapter->tso_hack_len,
 					       PCI_DMA_TODEVICE);
+				}
+				adapter->tso_hack_dma = buffer_info->dma;
+				adapter->tso_hack_len = buffer_info->length;
 
 				buffer_info->dma = 0;
 			}
 
 			if(buffer_info->skb) {
 
-				dev_kfree_skb_any(buffer_info->skb);
+				if (adapter->tso_hack_skb)
+					dev_kfree_skb_any(
+						adapter->tso_hack_skb);
+
+				adapter->tso_hack_skb = buffer_info->skb;
 
 				buffer_info->skb = NULL;
 			}

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=e1000_tx_spinlock

# ChangeSet
#   2004/02/04 03:05:56-05:00 scott.feldman@intel.com 
#   [netdrvr e1000] tx_lock
#   
#   * Fix race in Tx performance path with tx_lock.  Between checking
#     if we're out of resources and stopping the queue, we can get
#     a hard interrupt which will clean up all Tx work, and wake
#     the queue.  Coming out of hard interrupt context, we stop the
#     queue even though no work was queued, and all work completed
#     has been cleaned up.  Scenario requires ring to be completely
#     filled, which is more likely to happen with TSO, since each
#     TSO send consumes multiple ring entries.
# 
# drivers/net/e1000/e1000_main.c
#   2004/02/02 15:08:10-05:00 scott.feldman@intel.com +12 -0
#   tx_lock
# 
# drivers/net/e1000/e1000.h
#   2004/02/02 15:07:29-05:00 scott.feldman@intel.com +1 -0
#   tx_lock
# 
diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	Sat Feb 28 18:40:30 2004
+++ b/drivers/net/e1000/e1000.h	Sat Feb 28 18:40:30 2004
@@ -202,6 +202,7 @@
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
+	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
 	uint32_t tx_abs_int_delay;
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Sat Feb 28 18:40:30 2004
+++ b/drivers/net/e1000/e1000_main.c	Sat Feb 28 18:40:30 2004
@@ -678,6 +678,7 @@
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
+	spin_lock_init(&adapter->tx_lock);
 
 	return 0;
 }
@@ -1765,6 +1766,7 @@
 	struct e1000_adapter *adapter = netdev->priv;
 	unsigned int first;
 	unsigned int tx_flags = 0;
+	unsigned long flags;
 	int count;
 
 	if(skb->len <= 0) {
@@ -1772,10 +1774,13 @@
 		return 0;
 	}
 
+	spin_lock_irqsave(&adapter->tx_lock, flags);
+
 	if(adapter->hw.mac_type == e1000_82547) {
 		if(e1000_82547_fifo_workaround(adapter, skb)) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
+			spin_unlock_irqrestore(&adapter->tx_lock, flags);
 			return 1;
 		}
 	}
@@ -1796,11 +1801,14 @@
 		e1000_tx_queue(adapter, count, tx_flags);
 	else {
 		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
 
 	netdev->trans_start = jiffies;
 
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+	
 	return 0;
 }
 
@@ -2154,6 +2162,8 @@
 	unsigned int i, eop;
 	boolean_t cleaned = FALSE;
 
+	spin_lock(&adapter->tx_lock);
+
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
@@ -2197,6 +2207,8 @@
 
 	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
 		netif_wake_queue(netdev);
+
+	spin_unlock(&adapter->tx_lock);
 
 	return cleaned;
 }


--45Z9DzgjV8m4Oswq--
