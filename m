From: David Miller <davem@davemloft.net>
Subject: [PATCH 21/39]: net: Delete NETDEVICES_MULTIQUEUE kconfig option.
Date: Thu, 03 Jul 2008 00:04:22 -0700 (PDT)
Message-ID: <20080703.000422.51814646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50614
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757874AbYGCHEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Multiple TX queue support is a core networking feature.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/networking/multiqueue.txt |   79 +------------------------------
 drivers/net/Kconfig                     |    8 ---
 drivers/net/cpmac.c                     |   14 ------
 drivers/net/ixgbe/ixgbe_ethtool.c       |    6 --
 drivers/net/ixgbe/ixgbe_main.c          |   40 ----------------
 drivers/net/s2io.c                      |   47 +++---------------
 include/linux/netdevice.h               |   14 ------
 include/linux/skbuff.h                  |   10 ----
 net/mac80211/Kconfig                    |    3 -
 9 files changed, 9 insertions(+), 212 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
index ea5a42e..e6dc1ee 100644
--- a/Documentation/networking/multiqueue.txt
+++ b/Documentation/networking/multiqueue.txt
@@ -3,19 +3,11 @@
 		===========================================
 
 Section 1: Base driver requirements for implementing multiqueue support
-Section 2: Qdisc support for multiqueue devices
-Section 3: Brief howto using PRIO or RR for multiqueue devices
-
 
 Intro: Kernel support for multiqueue devices
 ---------------------------------------------------------
 
-Kernel support for multiqueue devices is only an API that is presented to the
-netdevice layer for base drivers to implement.  This feature is part of the
-core networking stack, and all network devices will be running on the
-multiqueue-aware stack.  If a base driver only has one queue, then these
-changes are transparent to that driver.
-
+Kernel support for multiqueue devices is always present.
 
 Section 1: Base driver requirements for implementing multiqueue support
 -----------------------------------------------------------------------
@@ -43,73 +35,4 @@ bitmap on device initialization.  Below is an example from e1000:
 		netdev->features |= NETIF_F_MULTI_QUEUE;
 #endif
 
-
-Section 2: Qdisc support for multiqueue devices
------------------------------------------------
-
-Currently two qdiscs support multiqueue devices.  A new round-robin qdisc,
-sch_rr, and sch_prio. The qdisc is responsible for classifying the skb's to
-bands and queues, and will store the queue mapping into skb->queue_mapping.
-Use this field in the base driver to determine which queue to send the skb
-to.
-
-sch_rr has been added for hardware that doesn't want scheduling policies from
-software, so it's a straight round-robin qdisc.  It uses the same syntax and
-classification priomap that sch_prio uses, so it should be intuitive to
-configure for people who've used sch_prio.
-
-In order to utilitize the multiqueue features of the qdiscs, the network
-device layer needs to enable multiple queue support.  This can be done by
-selecting NETDEVICES_MULTIQUEUE under Drivers.
-
-The PRIO qdisc naturally plugs into a multiqueue device.  If
-NETDEVICES_MULTIQUEUE is selected, then on qdisc load, the number of
-bands requested is compared to the number of queues on the hardware.  If they
-are equal, it sets a one-to-one mapping up between the queues and bands.  If
-they're not equal, it will not load the qdisc.  This is the same behavior
-for RR.  Once the association is made, any skb that is classified will have
-skb->queue_mapping set, which will allow the driver to properly queue skb's
-to multiple queues.
-
-
-Section 3: Brief howto using PRIO and RR for multiqueue devices
----------------------------------------------------------------
-
-The userspace command 'tc,' part of the iproute2 package, is used to configure
-qdiscs.  To add the PRIO qdisc to your network device, assuming the device is
-called eth0, run the following command:
-
-# tc qdisc add dev eth0 root handle 1: prio bands 4 multiqueue
-
-This will create 4 bands, 0 being highest priority, and associate those bands
-to the queues on your NIC.  Assuming eth0 has 4 Tx queues, the band mapping
-would look like:
-
-band 0 => queue 0
-band 1 => queue 1
-band 2 => queue 2
-band 3 => queue 3
-
-Traffic will begin flowing through each queue if your TOS values are assigning
-traffic across the various bands.  For example, ssh traffic will always try to
-go out band 0 based on TOS -> Linux priority conversion (realtime traffic),
-so it will be sent out queue 0.  ICMP traffic (pings) fall into the "normal"
-traffic classification, which is band 1.  Therefore pings will be send out
-queue 1 on the NIC.
-
-Note the use of the multiqueue keyword.  This is only in versions of iproute2
-that support multiqueue networking devices; if this is omitted when loading
-a qdisc onto a multiqueue device, the qdisc will load and operate the same
-if it were loaded onto a single-queue device (i.e. - sends all traffic to
-queue 0).
-
-Another alternative to multiqueue band allocation can be done by using the
-multiqueue option and specify 0 bands.  If this is the case, the qdisc will
-allocate the number of bands to equal the number of queues that the device
-reports, and bring the qdisc online.
-
-The behavior of tc filters remains the same, where it will override TOS priority
-classification.
-
-
 Author: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d85b9d0..220f1d9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -26,14 +26,6 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
 
-config NETDEVICES_MULTIQUEUE
-	bool "Netdevice multiple hardware queue support"
-	---help---
-	  Say Y here if you want to allow the network stack to use multiple
-	  hardware TX queues on an ethernet device.
-
-	  Most people will say N here.
-
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 7f3f62e..d630e2a 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -569,11 +569,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	len = max(skb->len, ETH_ZLEN);
 	queue = skb_get_queue_mapping(skb);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(dev, queue);
-#else
-	netif_stop_queue(dev);
-#endif
 
 	desc = &priv->desc_ring[queue];
 	if (unlikely(desc->dataflags & CPMAC_OWN)) {
@@ -626,24 +622,14 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 
 		dev_kfree_skb_irq(desc->skb);
 		desc->skb = NULL;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		if (netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
-#else
-		if (netif_queue_stopped(dev))
-			netif_wake_queue(dev);
-#endif
 	} else {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING
 			       "%s: end_xmit: spurious interrupt\n", dev->name);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		if (netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
-#else
-		if (netif_queue_stopped(dev))
-			netif_wake_queue(dev);
-#endif
 	}
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 12990b1..81b7690 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -252,21 +252,15 @@ static int ixgbe_set_tso(struct net_device *netdev, u32 data)
 		netdev->features |= NETIF_F_TSO;
 		netdev->features |= NETIF_F_TSO6;
 	} else {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		struct ixgbe_adapter *adapter = netdev_priv(netdev);
 		int i;
-#endif
 		netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			netif_stop_subqueue(netdev, i);
-#endif
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			netif_start_subqueue(netdev, i);
-#endif
 		netif_start_queue(netdev);
 	}
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b37d618..10a1c8c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -266,28 +266,16 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
 			adapter->restart_queue++;
 		}
-#else
-		if (netif_queue_stopped(netdev) &&
-		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
-			netif_wake_queue(netdev);
-			adapter->restart_queue++;
-		}
-#endif
 	}
 
 	if (adapter->detect_tx_hung)
 		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			netif_stop_subqueue(netdev, tx_ring->queue_index);
-#else
-			netif_stop_queue(netdev);
-#endif
 
 	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
@@ -2192,11 +2180,7 @@ static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 		case (IXGBE_FLAG_RSS_ENABLED):
 			rss_m = 0xF;
 			nrq = rss_i;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			ntq = rss_i;
-#else
-			ntq = 1;
-#endif
 			break;
 		case 0:
 		default:
@@ -2370,10 +2354,8 @@ try_msi:
 	}
 
 out:
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
 	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
-#endif
 
 	return err;
 }
@@ -2910,9 +2892,7 @@ static void ixgbe_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	bool link_up;
 	u32 link_speed = 0;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	int i;
-#endif
 
 	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
 
@@ -2934,10 +2914,8 @@ static void ixgbe_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			for (i = 0; i < adapter->num_tx_queues; i++)
 				netif_wake_subqueue(netdev, i);
-#endif
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -3264,11 +3242,7 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_stop_queue(netdev);
-#endif
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -3280,11 +3254,7 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_wake_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_wake_queue(netdev);
-#endif
 	++adapter->restart_queue;
 	return 0;
 }
@@ -3312,9 +3282,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int f;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
-#endif
 	tx_ring = &adapter->tx_ring[r_idx];
 
 
@@ -3502,11 +3470,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUEUES);
-#else
-	netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
-#endif
 	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
@@ -3598,9 +3562,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev->features |= NETIF_F_MULTI_QUEUE;
-#endif
 
 	/* make sure the EEPROM is good */
 	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
@@ -3668,10 +3630,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		netif_stop_subqueue(netdev, i);
-#endif
 
 	ixgbe_napi_add_all(adapter);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e7a3dbe..51a9115 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -546,13 +546,10 @@ static struct pci_driver s2io_driver = {
 static inline void s2io_stop_all_tx_queue(struct s2io_nic *sp)
 {
 	int i;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq) {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			netif_stop_subqueue(sp->dev, i);
-	} else
-#endif
-	{
+	} else {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_STOP;
 		netif_stop_queue(sp->dev);
@@ -561,12 +558,9 @@ static inline void s2io_stop_all_tx_queue(struct s2io_nic *sp)
 
 static inline void s2io_stop_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq)
 		netif_stop_subqueue(sp->dev, fifo_no);
-	else
-#endif
-	{
+	else {
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_STOP;
 		netif_stop_queue(sp->dev);
@@ -576,13 +570,10 @@ static inline void s2io_stop_tx_queue(struct s2io_nic *sp, int fifo_no)
 static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
 {
 	int i;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq) {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			netif_start_subqueue(sp->dev, i);
-	} else
-#endif
-	{
+	} else {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
 		netif_start_queue(sp->dev);
@@ -591,12 +582,9 @@ static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
 
 static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq)
 		netif_start_subqueue(sp->dev, fifo_no);
-	else
-#endif
-	{
+	else {
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_START;
 		netif_start_queue(sp->dev);
@@ -606,13 +594,10 @@ static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
 static inline void s2io_wake_all_tx_queue(struct s2io_nic *sp)
 {
 	int i;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq) {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			netif_wake_subqueue(sp->dev, i);
-	} else
-#endif
-	{
+	} else {
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
 		netif_wake_queue(sp->dev);
@@ -623,13 +608,10 @@ static inline void s2io_wake_tx_queue(
 	struct fifo_info *fifo, int cnt, u8 multiq)
 {
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (multiq) {
 		if (cnt && __netif_subqueue_stopped(fifo->dev, fifo->fifo_no))
 			netif_wake_subqueue(fifo->dev, fifo->fifo_no);
-	} else
-#endif
-	if (cnt && (fifo->queue_state == FIFO_QUEUE_STOP)) {
+	} else if (cnt && (fifo->queue_state == FIFO_QUEUE_STOP)) {
 		if (netif_queue_stopped(fifo->dev)) {
 			fifo->queue_state = FIFO_QUEUE_START;
 			netif_wake_queue(fifo->dev);
@@ -4189,15 +4171,12 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_LOCKED;
 	}
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq) {
 		if (__netif_subqueue_stopped(dev, fifo->fifo_no)) {
 			spin_unlock_irqrestore(&fifo->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
-	} else
-#endif
-	if (unlikely(fifo->queue_state == FIFO_QUEUE_STOP)) {
+	} else if (unlikely(fifo->queue_state == FIFO_QUEUE_STOP)) {
 		if (netif_queue_stopped(dev)) {
 			spin_unlock_irqrestore(&fifo->tx_lock, flags);
 			return NETDEV_TX_BUSY;
@@ -7633,12 +7612,6 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 		DBG_PRINT(ERR_DBG, "tx fifos\n");
 	}
 
-#ifndef CONFIG_NETDEVICES_MULTIQUEUE
-	if (multiq) {
-		DBG_PRINT(ERR_DBG, "s2io: Multiqueue support not enabled\n");
-		multiq = 0;
-	}
-#endif
 	if (multiq)
 		*dev_multiq = multiq;
 
@@ -7783,12 +7756,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		pci_disable_device(pdev);
 		return -ENODEV;
 	}
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (dev_multiq)
 		dev = alloc_etherdev_mq(sizeof(struct s2io_nic), tx_fifo_num);
 	else
-#endif
-	dev = alloc_etherdev(sizeof(struct s2io_nic));
+		dev = alloc_etherdev(sizeof(struct s2io_nic));
 	if (dev == NULL) {
 		DBG_PRINT(ERR_DBG, "Device allocation failed\n");
 		pci_disable_device(pdev);
@@ -7979,10 +7950,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
 	}
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (config->multiq)
 		dev->features |= NETIF_F_MULTI_QUEUE;
-#endif
 	dev->tx_timeout = &s2io_tx_watchdog;
 	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;
 	INIT_WORK(&sp->rst_timer_task, s2io_restart_nic);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f5f8bb6..d43bfc6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1041,9 +1041,7 @@ static inline int netif_running(const struct net_device *dev)
  */
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	clear_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
-#endif
 }
 
 /**
@@ -1055,13 +1053,11 @@ static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
  */
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
 #endif
 	set_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
-#endif
 }
 
 /**
@@ -1074,12 +1070,8 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 static inline int __netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	return test_bit(__LINK_STATE_XOFF,
 			&dev->egress_subqueue[queue_index].state);
-#else
-	return 0;
-#endif
 }
 
 static inline int netif_subqueue_stopped(const struct net_device *dev,
@@ -1097,7 +1089,6 @@ static inline int netif_subqueue_stopped(const struct net_device *dev,
  */
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
@@ -1105,7 +1096,6 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 	if (test_and_clear_bit(__LINK_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
 		__netif_schedule(&dev->tx_queue);
-#endif
 }
 
 /**
@@ -1117,11 +1107,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
  */
 static inline int netif_is_multiqueue(const struct net_device *dev)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	return (!!(NETIF_F_MULTI_QUEUE & dev->features));
-#else
-	return 0;
-#endif
 }
 
 /* Use this variant when it is known for sure that it
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2220b9e..8f10e3d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -305,9 +305,7 @@ struct sk_buff {
 #endif
 
 	int			iif;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	__u16			queue_mapping;
-#endif
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
@@ -1671,25 +1669,17 @@ static inline void skb_init_secmark(struct sk_buff *skb)
 
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	skb->queue_mapping = queue_mapping;
-#endif
 }
 
 static inline u16 skb_get_queue_mapping(struct sk_buff *skb)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	return skb->queue_mapping;
-#else
-	return 0;
-#endif
 }
 
 static inline void skb_copy_queue_mapping(struct sk_buff *to, const struct sk_buff *from)
 {
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	to->queue_mapping = from->queue_mapping;
-#endif
 }
 
 static inline int skb_is_gso(const struct sk_buff *skb)
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 0d3661d..4be8acc 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -15,14 +15,11 @@ config MAC80211_QOS
 	def_bool y
 	depends on MAC80211
 	depends on NET_SCHED
-	depends on NETDEVICES_MULTIQUEUE
 
 comment "QoS/HT support disabled"
 	depends on MAC80211 && !MAC80211_QOS
 comment "QoS/HT support needs CONFIG_NET_SCHED"
 	depends on MAC80211 && !NET_SCHED
-comment "QoS/HT support needs CONFIG_NETDEVICES_MULTIQUEUE"
-	depends on MAC80211 && !NETDEVICES_MULTIQUEUE
 
 menu "Rate control algorithm selection"
 	depends on MAC80211 != n
-- 
1.5.6

