From: Florian Westphal <fw@strlen.de>
Subject: [PATCH V2 2/7] e1000: move tbi workaround code into
	helper function
Date: Tue,  2 Sep 2014 14:24:45 +0200
Message-ID: <1409660690-10391-3-git-send-email-fw@strlen.de>
References: <1409660690-10391-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1409660690-10391-1-git-send-email-fw@strlen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Its the same in both handlers.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 no changes since v1.
 drivers/net/ethernet/intel/e1000/e1000_main.c | 63 ++++++++++++++-------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index fe56fac..f79ba40 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4054,6 +4054,26 @@ static void e1000_tbi_adjust_stats(struct e1000_hw *hw,
 	}
 }
 
+static bool e1000_tbi_should_accept(struct e1000_adapter *adapter,
+				    u8 status, u8 errors,
+				    u32 length, const u8 *data)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u8 last_byte = *(data + length - 1);
+
+	if (TBI_ACCEPT(hw, status, errors, length, last_byte)) {
+		unsigned long irq_flags;
+
+		spin_lock_irqsave(&adapter->stats_lock, irq_flags);
+		e1000_tbi_adjust_stats(hw, &adapter->stats, length, data);
+		spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
+
+		return true;
+	}
+
+	return false;
+}
+
 /**
  * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -4068,12 +4088,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				     struct e1000_rx_ring *rx_ring,
 				     int *work_done, int work_to_do)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
-	unsigned long irq_flags;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4114,23 +4132,15 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
 		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
-			u8 *mapped;
-			u8 last_byte;
-
-			mapped = page_address(buffer_info->page);
-			last_byte = *(mapped + length - 1);
-			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
-				       last_byte)) {
-				spin_lock_irqsave(&adapter->stats_lock,
-						  irq_flags);
-				e1000_tbi_adjust_stats(hw, &adapter->stats,
-						       length, mapped);
-				spin_unlock_irqrestore(&adapter->stats_lock,
-						       irq_flags);
+			u8 *mapped = page_address(buffer_info->page);
+
+			if (e1000_tbi_should_accept(adapter, status,
+						    rx_desc->errors,
+						    length, mapped)) {
 				length--;
+			} else if (netdev->features & NETIF_F_RXALL) {
+				goto process_skb;
 			} else {
-				if (netdev->features & NETIF_F_RXALL)
-					goto process_skb;
 				/* recycle both page and skb */
 				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
@@ -4281,12 +4291,10 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
-	unsigned long flags;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4336,7 +4344,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
-			e_dbg("Receive packet consumed multiple buffers\n");
+			netdev_dbg(netdev, "Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			if (status & E1000_RXD_STAT_EOP)
@@ -4345,18 +4353,13 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
-			u8 last_byte = *(skb->data + length - 1);
-			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
-				       last_byte)) {
-				spin_lock_irqsave(&adapter->stats_lock, flags);
-				e1000_tbi_adjust_stats(hw, &adapter->stats,
-						       length, skb->data);
-				spin_unlock_irqrestore(&adapter->stats_lock,
-						       flags);
+			if (e1000_tbi_should_accept(adapter, status,
+						    rx_desc->errors,
+						    length, skb->data)) {
 				length--;
+			} else if (netdev->features & NETIF_F_RXALL) {
+				goto process_skb;
 			} else {
-				if (netdev->features & NETIF_F_RXALL)
-					goto process_skb;
 				/* recycle */
 				buffer_info->skb = skb;
 				goto next_desc;
-- 
1.8.1.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
