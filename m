From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] ixgbe: add real-time traffic counters
Date: Fri, 01 Feb 2008 15:59:19 -0800
Message-ID: <20080201235919.31474.147.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

Just like our other drivers before we can switch ixgbe to
provide real-time packet/byte counters to the stack easily.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6e7d90e..ead49e5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -275,6 +275,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
 
+	adapter->net_stats.tx_bytes += total_tx_bytes;
+	adapter->net_stats.tx_packets += total_tx_packets;
 	cleaned = total_tx_packets ? true : false;
 	return cleaned;
 }
@@ -443,6 +445,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	u16 hdr_info, vlan_tag;
 	bool is_vlan, cleaned = false;
 	int cleaned_count = 0;
+	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
 	upper_len = 0;
@@ -522,6 +525,11 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		}
 
 		ixgbe_rx_checksum(adapter, staterr, skb);
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
 		skb->protocol = eth_type_trans(skb, netdev);
 		ixgbe_receive_skb(adapter, skb, is_vlan, vlan_tag);
 		netdev->last_rx = jiffies;
@@ -550,6 +558,9 @@ next_desc:
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
 
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+
 	return cleaned;
 }
 
@@ -2088,10 +2099,6 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.rx_packets = adapter->stats.gprc;
-	adapter->net_stats.tx_packets = adapter->stats.gptc;
-	adapter->net_stats.rx_bytes = adapter->stats.gorc;
-	adapter->net_stats.tx_bytes = adapter->stats.gotc;
 	adapter->net_stats.multicast = adapter->stats.mprc;
 
 	/* Rx Errors */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
