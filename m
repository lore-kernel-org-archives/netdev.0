From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 16/19] intel: convert drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:55 -0700
Message-ID: <20090901055130.042455994@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57486 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbZIAF7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:59:04 -0400
Content-Disposition: inline; filename=intel.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of some bogus return wrapping as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/e100.c             |    3 ++-
 drivers/net/e1000/e1000_main.c |    6 ++++--
 drivers/net/e1000e/netdev.c    |    3 ++-
 drivers/net/igb/igb_main.c     |   19 +++++++++++--------
 drivers/net/igbvf/netdev.c     |   14 ++++++--------
 drivers/net/ixgb/ixgb_main.c   |    5 +++--
 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 7 files changed, 30 insertions(+), 23 deletions(-)

--- a/drivers/net/e100.c	2009-08-31 16:17:52.421107750 -0700
+++ b/drivers/net/e100.c	2009-08-31 16:30:52.554352111 -0700
@@ -1690,7 +1690,8 @@ static void e100_xmit_prepare(struct nic
 	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
 }
 
-static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
+				   struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
 	int err;
--- a/drivers/net/e1000/e1000_main.c	2009-08-31 16:17:52.441081727 -0700
+++ b/drivers/net/e1000/e1000_main.c	2009-08-31 16:31:06.101316042 -0700
@@ -125,7 +125,8 @@ static void e1000_set_rx_mode(struct net
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
-static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
@@ -3249,7 +3250,8 @@ static int e1000_maybe_stop_tx(struct ne
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
--- a/drivers/net/e1000e/netdev.c	2009-08-31 16:17:52.421107750 -0700
+++ b/drivers/net/e1000e/netdev.c	2009-08-31 16:31:18.442354494 -0700
@@ -4097,7 +4097,8 @@ static int e1000_maybe_stop_tx(struct ne
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_ring *tx_ring = adapter->tx_ring;
--- a/drivers/net/igb/igb_main.c	2009-08-31 16:17:52.451108421 -0700
+++ b/drivers/net/igb/igb_main.c	2009-08-31 16:31:36.466352379 -0700
@@ -98,9 +98,11 @@ static void igb_set_multi(struct net_dev
 static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
-static int igb_xmit_frame_ring_adv(struct sk_buff *, struct net_device *,
-				  struct igb_ring *);
-static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *);
+static netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *,
+					   struct net_device *,
+					   struct igb_ring *);
+static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
+				      struct net_device *);
 static struct net_device_stats *igb_get_stats(struct net_device *);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
@@ -3295,9 +3297,9 @@ static int igb_maybe_stop_tx(struct net_
 	return __igb_maybe_stop_tx(netdev, tx_ring, size);
 }
 
-static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
-				   struct net_device *netdev,
-				   struct igb_ring *tx_ring)
+static netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
+					   struct net_device *netdev,
+					   struct igb_ring *tx_ring)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	unsigned int first;
@@ -3385,7 +3387,8 @@ static int igb_xmit_frame_ring_adv(struc
 	return NETDEV_TX_OK;
 }
 
-static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb,
+				      struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *tx_ring;
@@ -3398,7 +3401,7 @@ static int igb_xmit_frame_adv(struct sk_
 	 * to a flow.  Right now, performance is impacted slightly negatively
 	 * if using multiple tx queues.  If the stack breaks away from a
 	 * single qdisc implementation, we can look at this again. */
-	return (igb_xmit_frame_ring_adv(skb, netdev, tx_ring));
+	return igb_xmit_frame_ring_adv(skb, netdev, tx_ring);
 }
 
 /**
--- a/drivers/net/igbvf/netdev.c	2009-08-31 16:17:52.431080456 -0700
+++ b/drivers/net/igbvf/netdev.c	2009-08-31 16:31:47.458359112 -0700
@@ -2204,9 +2204,9 @@ static inline void igbvf_tx_queue_adv(st
 	mmiowb();
 }
 
-static int igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
-                                   struct net_device *netdev,
-                                   struct igbvf_ring *tx_ring)
+static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
+					     struct net_device *netdev,
+					     struct igbvf_ring *tx_ring)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	unsigned int first, tx_flags = 0;
@@ -2279,11 +2279,11 @@ static int igbvf_xmit_frame_ring_adv(str
 	return NETDEV_TX_OK;
 }
 
-static int igbvf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t igbvf_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct igbvf_ring *tx_ring;
-	int retval;
 
 	if (test_bit(__IGBVF_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -2292,9 +2292,7 @@ static int igbvf_xmit_frame(struct sk_bu
 
 	tx_ring = &adapter->tx_ring[0];
 
-	retval = igbvf_xmit_frame_ring_adv(skb, netdev, tx_ring);
-
-	return retval;
+	return igbvf_xmit_frame_ring_adv(skb, netdev, tx_ring);
 }
 
 /**
--- a/drivers/net/ixgb/ixgb_main.c	2009-08-31 16:17:52.431080456 -0700
+++ b/drivers/net/ixgb/ixgb_main.c	2009-08-31 16:31:58.474359401 -0700
@@ -81,7 +81,8 @@ static void ixgb_clean_tx_ring(struct ix
 static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter);
 static void ixgb_set_multi(struct net_device *netdev);
 static void ixgb_watchdog(unsigned long data);
-static int ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+static netdev_tx_t ixgb_xmit_frame(struct sk_buff *skb,
+				   struct net_device *netdev);
 static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
@@ -1442,7 +1443,7 @@ static int ixgb_maybe_stop_tx(struct net
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1 /* for context */ \
 	+ 1 /* one more needed for sentinel TSO workaround */
 
-static int
+static netdev_tx_t
 ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
--- a/drivers/net/ixgbe/ixgbe_main.c	2009-08-31 16:17:52.441081727 -0700
+++ b/drivers/net/ixgbe/ixgbe_main.c	2009-08-31 16:32:07.281106978 -0700
@@ -5107,7 +5107,8 @@ static u16 ixgbe_select_queue(struct net
 	return skb_tx_hash(dev, skb);
 }
 
-static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;

-- 

