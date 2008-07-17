From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 3/31]: netdev: Kill NETIF_F_MULTI_QUEUE.
Date: Thu, 17 Jul 2008 05:15:50 -0700 (PDT)
Message-ID: <20080717.051550.125083717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


There is no need for a feature bit for something that
can be tested by simply checking the TX queue count.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 Documentation/networking/multiqueue.txt |   11 -----------
 drivers/net/cpmac.c                     |    1 -
 drivers/net/igb/igb_main.c              |    2 --
 drivers/net/ixgbe/ixgbe_main.c          |    2 --
 drivers/net/s2io.c                      |    2 --
 include/linux/netdevice.h               |    4 +---
 net/mac80211/main.c                     |    3 ---
 7 files changed, 1 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
index e6dc1ee..d391ea6 100644
--- a/Documentation/networking/multiqueue.txt
+++ b/Documentation/networking/multiqueue.txt
@@ -24,15 +24,4 @@ netif_{start|stop|wake}_subqueue() functions to manage each queue while the
 device is still operational.  netdev->queue_lock is still used when the device
 comes online or when it's completely shut down (unregister_netdev(), etc.).
 
-Finally, the base driver should indicate that it is a multiqueue device.  The
-feature flag NETIF_F_MULTI_QUEUE should be added to the netdev->features
-bitmap on device initialization.  Below is an example from e1000:
-
-#ifdef CONFIG_E1000_MQ
-	if ( (adapter->hw.mac.type == e1000_82571) ||
-	     (adapter->hw.mac.type == e1000_82572) ||
-	     (adapter->hw.mac.type == e1000_80003es2lan))
-		netdev->features |= NETIF_F_MULTI_QUEUE;
-#endif
-
 Author: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index d630e2a..7c7b54e 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1165,7 +1165,6 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	dev->set_multicast_list = cpmac_set_multicast_list;
 	dev->tx_timeout         = cpmac_tx_timeout;
 	dev->ethtool_ops        = &cpmac_ethtool_ops;
-	dev->features |= NETIF_F_MULTI_QUEUE;
 
 	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 64a150a..471c194 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1155,8 +1155,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_MULTI_QUEUE;
-
 	netdev->features |= NETIF_F_LLTX;
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(&adapter->hw);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7d8bf94..e6df923 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3566,8 +3566,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_MULTI_QUEUE;
-
 	/* make sure the EEPROM is good */
 	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
 		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 517425d..5f0fcb0 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7966,8 +7966,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
 	}
-	if (config->multiq)
-		dev->features |= NETIF_F_MULTI_QUEUE;
 	dev->tx_timeout = &s2io_tx_watchdog;
 	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;
 	INIT_WORK(&sp->rst_timer_task, s2io_restart_nic);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f25d4f5..c02227b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -533,7 +533,6 @@ struct net_device
 #define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
 					/* do not use LLTX in new drivers */
 #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
-#define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 #define NETIF_F_LRO		32768	/* large receive offload */
 
 	/* Segmentation offload features */
@@ -1163,11 +1162,10 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
  *	@dev: network device
  *
  * Check if device has multiple transmit queues
- * Always falls if NETDEVICE_MULTIQUEUE is not configured
  */
 static inline int netif_is_multiqueue(const struct net_device *dev)
 {
-	return (!!(NETIF_F_MULTI_QUEUE & dev->features));
+	return (dev->num_tx_queues > 1);
 }
 
 /* Use this variant when it is known for sure that it
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b486e63..c74607e 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1678,9 +1678,6 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	if (!mdev)
 		goto fail_mdev_alloc;
 
-	if (ieee80211_num_queues(hw) > 1)
-		mdev->features |= NETIF_F_MULTI_QUEUE;
