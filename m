From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] ixgbe: fix select_queue management
Date: Thu, 19 Mar 2009 23:36:10 -0700
Message-ID: <20090319233610.51fe4ee1@nehalam>
References: <20090319233404.6697768b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, David Miller
	<davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090319233404.6697768b@nehalam>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert ixgbe to use net_device_ops properly.
Rather than changing the select_queue function pointer
just check the flag.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    8 --------
 drivers/net/ixgbe/ixgbe_main.c   |   11 +++++++++++
 2 files changed, 11 insertions(+), 8 deletions(-)

--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-19 22:57:01.053842791 -0700
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c	2009-03-19 23:07:36.372656027 -0700
@@ -102,12 +102,6 @@ static u8 ixgbe_dcbnl_get_state(struct n
 	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
 }
 
-static u16 ixgbe_dcb_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	/* All traffic should default to class 0 */
-	return 0;
-}
-
 static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 {
 	u8 err = 0;
@@ -135,7 +129,6 @@ static u8 ixgbe_dcbnl_set_state(struct n
 		kfree(adapter->rx_ring);
 		adapter->tx_ring = NULL;
 		adapter->rx_ring = NULL;
-		netdev->select_queue = &ixgbe_dcb_select_queue;
 
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
@@ -154,7 +147,6 @@ static u8 ixgbe_dcbnl_set_state(struct n
 			kfree(adapter->rx_ring);
 			adapter->tx_ring = NULL;
 			adapter->rx_ring = NULL;
-			netdev->select_queue = NULL;
 
 			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
--- a/drivers/net/ixgbe/ixgbe_main.c	2009-03-19 23:05:56.954718897 -0700
+++ b/drivers/net/ixgbe/ixgbe_main.c	2009-03-19 23:07:33.611651593 -0700
@@ -4272,6 +4272,16 @@ static int ixgbe_maybe_stop_tx(struct ne
 	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
 }
 
+static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+		return 0;  /* All traffic should default to class 0 */
+
+	return skb_tx_hash(dev, skb);
+}
+
 static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -4401,6 +4411,7 @@ static const struct net_device_ops ixgbe
 	.ndo_open 		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
+	.ndo_select_queue	= ixgbe_select_queue,
 	.ndo_get_stats		= ixgbe_get_stats,
 	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
 	.ndo_set_multicast_list	= ixgbe_set_rx_mode,

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
