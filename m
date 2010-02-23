From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/7] drivers/net/myri10ge: Use pr_<level> and netdev_<level>
Date: Mon, 22 Feb 2010 18:56:58 -0800
Message-ID: <0a98bb59c8ba36ea37bac53137e2b594bbc984d8.1266893507.git.joe@perches.com>
References: <cover.1266893507.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266893507.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt)
Convert logging messages to pr_<level> and netdev_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/myri10ge/myri10ge.c |  183 ++++++++++++++-------------------------
 1 files changed, 67 insertions(+), 116 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c0884a9..1d14a8b 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -38,6 +38,8 @@
  *   Myricom, Inc., 325N Santa Anita Avenue, Arcadia, CA 91006
  *************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/tcp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
@@ -819,9 +821,7 @@ static int myri10ge_change_pause(struct myri10ge_priv *mgp, int pause)
 	status = myri10ge_send_cmd(mgp, ctl, &cmd, 0);
 
 	if (status) {
-		printk(KERN_ERR
-		       "myri10ge: %s: Failed to set flow control mode\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "Failed to set flow control mode\n");
 		return status;
 	}
 	mgp->pause = pause;
@@ -837,8 +837,7 @@ myri10ge_change_promisc(struct myri10ge_priv *mgp, int promisc, int atomic)
 	ctl = promisc ? MXGEFW_ENABLE_PROMISC : MXGEFW_DISABLE_PROMISC;
 	status = myri10ge_send_cmd(mgp, ctl, &cmd, atomic);
 	if (status)
-		printk(KERN_ERR "myri10ge: %s: Failed to set promisc mode\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "Failed to set promisc mode\n");
 }
 
 static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
@@ -1482,19 +1481,15 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 
 			if (mgp->link_state == MXGEFW_LINK_UP) {
 				if (netif_msg_link(mgp))
-					printk(KERN_INFO
-					       "myri10ge: %s: link up\n",
-					       mgp->dev->name);
+					netdev_info(mgp->dev, "link up\n");
 				netif_carrier_on(mgp->dev);
 				mgp->link_changes++;
 			} else {
 				if (netif_msg_link(mgp))
-					printk(KERN_INFO
-					       "myri10ge: %s: link %s\n",
-					       mgp->dev->name,
-					       (link_up == MXGEFW_LINK_MYRINET ?
-						"mismatch (Myrinet detected)" :
-						"down"));
+					netdev_info(mgp->dev, "link %s\n",
+					    link_up == MXGEFW_LINK_MYRINET ?
+					    "mismatch (Myrinet detected)" :
+					    "down");
 				netif_carrier_off(mgp->dev);
 				mgp->link_changes++;
 			}
@@ -1503,9 +1498,8 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 		    ntohl(stats->rdma_tags_available)) {
 			mgp->rdma_tags_available =
 			    ntohl(stats->rdma_tags_available);
-			printk(KERN_WARNING "myri10ge: %s: RDMA timed out! "
-			       "%d tags left\n", mgp->dev->name,
-			       mgp->rdma_tags_available);
+			netdev_warn(mgp->dev, "RDMA timed out! %d tags left\n",
+				    mgp->rdma_tags_available);
 		}
 		mgp->down_cnt += stats->link_down;
 		if (stats->link_down)
@@ -1576,8 +1570,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		if (send_done_count != tx->pkt_done)
 			myri10ge_tx_done(ss, (int)send_done_count);
 		if (unlikely(i > myri10ge_max_irq_loops)) {
-			printk(KERN_WARNING "myri10ge: %s: irq stuck?\n",
-			       mgp->dev->name);
+			netdev_err(mgp->dev, "irq stuck?\n");
 			stats->valid = 0;
 			schedule_work(&mgp->watchdog_work);
 		}
@@ -1614,16 +1607,14 @@ myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	 */
 	ptr = mgp->product_code_string;
 	if (ptr == NULL) {
-		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
-		       netdev->name);
+		netdev_err(netdev, "Missing product code\n");
 		return 0;
 	}
 	for (i = 0; i < 3; i++, ptr++) {
 		ptr = strchr(ptr, '-');
 		if (ptr == NULL) {
-			printk(KERN_ERR "myri10ge: %s: Invalid product "
-			       "code %s\n", netdev->name,
-			       mgp->product_code_string);
+			netdev_err(netdev, "Invalid product code %s\n",
+				   mgp->product_code_string);
 			return 0;
 		}
 	}
@@ -2009,17 +2000,15 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 				mgp->small_bytes + MXGEFW_PAD, 0);
 
 	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
-		printk(KERN_ERR
-		       "myri10ge: %s:slice-%d: alloced only %d small bufs\n",
-		       dev->name, slice, ss->rx_small.fill_cnt);
+		netdev_err(dev, "slice-%d: alloced only %d small bufs\n",
+			   slice, ss->rx_small.fill_cnt);
 		goto abort_with_rx_small_ring;
 	}
 
 	myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
 	if (ss->rx_big.fill_cnt < ss->rx_big.mask + 1) {
-		printk(KERN_ERR
-		       "myri10ge: %s:slice-%d: alloced only %d big bufs\n",
-		       dev->name, slice, ss->rx_big.fill_cnt);
+		netdev_err(dev, "slice-%d: alloced only %d big bufs\n",
+			   slice, ss->rx_big.fill_cnt);
 		goto abort_with_rx_big_ring;
 	}
 
@@ -2358,7 +2347,7 @@ static int myri10ge_open(struct net_device *dev)
 	mgp->running = MYRI10GE_ETH_STARTING;
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
-		printk(KERN_ERR "myri10ge: %s: failed reset\n", dev->name);
+		netdev_err(dev, "failed reset\n");
 		goto abort_with_nothing;
 	}
 
@@ -2370,9 +2359,7 @@ static int myri10ge_open(struct net_device *dev)
 		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
 					   &cmd, 0);
 		if (status != 0) {
-			printk(KERN_ERR
-			       "myri10ge: %s: failed to set number of slices\n",
-			       dev->name);
+			netdev_err(dev, "failed to set number of slices\n");
 			goto abort_with_nothing;
 		}
 		/* setup the indirection table */
@@ -2384,9 +2371,7 @@ static int myri10ge_open(struct net_device *dev)
 					    MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
 					    &cmd, 0);
 		if (status != 0) {
-			printk(KERN_ERR
-			       "myri10ge: %s: failed to setup rss tables\n",
-			       dev->name);
+			netdev_err(dev, "failed to setup rss tables\n");
 			goto abort_with_nothing;
 		}
 
@@ -2400,9 +2385,7 @@ static int myri10ge_open(struct net_device *dev)
 		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_ENABLE,
 					   &cmd, 0);
 		if (status != 0) {
-			printk(KERN_ERR
-			       "myri10ge: %s: failed to enable slices\n",
-			       dev->name);
+			netdev_err(dev, "failed to enable slices\n");
 			goto abort_with_nothing;
 		}
 	}
@@ -2450,9 +2433,7 @@ static int myri10ge_open(struct net_device *dev)
 
 		status = myri10ge_get_txrx(mgp, slice);
 		if (status != 0) {
-			printk(KERN_ERR
-			       "myri10ge: %s: failed to get ring sizes or locations\n",
-			       dev->name);
+			netdev_err(dev, "failed to get ring sizes or locations\n");
 			goto abort_with_rings;
 		}
 		status = myri10ge_allocate_rings(ss);
@@ -2465,9 +2446,7 @@ static int myri10ge_open(struct net_device *dev)
 		if (slice == 0 || mgp->dev->real_num_tx_queues > 1)
 			status = myri10ge_set_stats(mgp, slice);
 		if (status) {
-			printk(KERN_ERR
-			       "myri10ge: %s: Couldn't set stats DMA\n",
-			       dev->name);
+			netdev_err(dev, "Couldn't set stats DMA\n");
 			goto abort_with_rings;
 		}
 
@@ -2498,8 +2477,7 @@ static int myri10ge_open(struct net_device *dev)
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_BIG_BUFFER_SIZE, &cmd, 0);
 	if (status) {
-		printk(KERN_ERR "myri10ge: %s: Couldn't set buffer sizes\n",
-		       dev->name);
+		netdev_err(dev, "Couldn't set buffer sizes\n");
 		goto abort_with_rings;
 	}
 
@@ -2511,8 +2489,7 @@ static int myri10ge_open(struct net_device *dev)
 	cmd.data0 = 0;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_TSO_MODE, &cmd, 0);
 	if (status && status != -ENOSYS) {
-		printk(KERN_ERR "myri10ge: %s: Couldn't set TSO mode\n",
-		       dev->name);
+		netdev_err(dev, "Couldn't set TSO mode\n");
 		goto abort_with_rings;
 	}
 
@@ -2521,8 +2498,7 @@ static int myri10ge_open(struct net_device *dev)
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
-		printk(KERN_ERR "myri10ge: %s: Couldn't bring up link\n",
-		       dev->name);
+		netdev_err(dev, "Couldn't bring up link\n");
 		goto abort_with_rings;
 	}
 
@@ -2575,15 +2551,12 @@ static int myri10ge_close(struct net_device *dev)
 		status =
 		    myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_DOWN, &cmd, 0);
 		if (status)
-			printk(KERN_ERR
-			       "myri10ge: %s: Couldn't bring down link\n",
-			       dev->name);
+			netdev_err(dev, "Couldn't bring down link\n");
 
 		wait_event_timeout(mgp->down_wq, old_down_cnt != mgp->down_cnt,
 				   HZ);
 		if (old_down_cnt == mgp->down_cnt)
-			printk(KERN_ERR "myri10ge: %s never got down irq\n",
-			       dev->name);
+			netdev_err(dev, "never got down irq\n");
 	}
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
@@ -2944,9 +2917,7 @@ abort_linearize:
 		idx = (idx + 1) & tx->mask;
 	} while (idx != last_idx);
 	if (skb_is_gso(skb)) {
-		printk(KERN_ERR
-		       "myri10ge: %s: TSO but wanted to linearize?!?!?\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "TSO but wanted to linearize?!?!?\n");
 		goto drop;
 	}
 
@@ -3043,8 +3014,8 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 
 	err = myri10ge_send_cmd(mgp, MXGEFW_ENABLE_ALLMULTI, &cmd, 1);
 	if (err != 0) {
-		printk(KERN_ERR "myri10ge: %s: Failed MXGEFW_ENABLE_ALLMULTI,"
-		       " error status: %d\n", dev->name, err);
+		netdev_err(dev, "Failed MXGEFW_ENABLE_ALLMULTI, error status: %d\n",
+			   err);
 		goto abort;
 	}
 
@@ -3058,9 +3029,8 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 	err = myri10ge_send_cmd(mgp, MXGEFW_LEAVE_ALL_MULTICAST_GROUPS,
 				&cmd, 1);
 	if (err != 0) {
-		printk(KERN_ERR
-		       "myri10ge: %s: Failed MXGEFW_LEAVE_ALL_MULTICAST_GROUPS"
-		       ", error status: %d\n", dev->name, err);
+		netdev_err(dev, "Failed MXGEFW_LEAVE_ALL_MULTICAST_GROUPS, error status: %d\n",
+			   err);
 		goto abort;
 	}
 
@@ -3073,18 +3043,16 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 					&cmd, 1);
 
 		if (err != 0) {
-			printk(KERN_ERR "myri10ge: %s: Failed "
-			       "MXGEFW_JOIN_MULTICAST_GROUP, error status:"
-			       "%d\t", dev->name, err);
-			printk(KERN_ERR "MAC %pM\n", mc_list->dmi_addr);
+			netdev_err(dev, "Failed MXGEFW_JOIN_MULTICAST_GROUP, error status:%d %pM\n",
+				   err, mc_list->dmi_addr);
 			goto abort;
 		}
 	}
 	/* Enable multicast filtering */
 	err = myri10ge_send_cmd(mgp, MXGEFW_DISABLE_ALLMULTI, &cmd, 1);
 	if (err != 0) {
-		printk(KERN_ERR "myri10ge: %s: Failed MXGEFW_DISABLE_ALLMULTI,"
-		       "error status: %d\n", dev->name, err);
+		netdev_err(dev, "Failed MXGEFW_DISABLE_ALLMULTI, error status: %d\n",
+			   err);
 		goto abort;
 	}
 
@@ -3105,9 +3073,8 @@ static int myri10ge_set_mac_address(struct net_device *dev, void *addr)
 
 	status = myri10ge_update_mac_address(mgp, sa->sa_data);
 	if (status != 0) {
-		printk(KERN_ERR
-		       "myri10ge: %s: changing mac address failed with %d\n",
-		       dev->name, status);
+		netdev_err(dev, "changing mac address failed with %d\n",
+			   status);
 		return status;
 	}
 
@@ -3122,12 +3089,10 @@ static int myri10ge_change_mtu(struct net_device *dev, int new_mtu)
 	int error = 0;
 
 	if ((new_mtu < 68) || (ETH_HLEN + new_mtu > MYRI10GE_MAX_ETHER_MTU)) {
-		printk(KERN_ERR "myri10ge: %s: new mtu (%d) is not valid\n",
-		       dev->name, new_mtu);
+		netdev_err(dev, "new mtu (%d) is not valid\n", new_mtu);
 		return -EINVAL;
 	}
-	printk(KERN_INFO "%s: changing mtu from %d to %d\n",
-	       dev->name, dev->mtu, new_mtu);
+	netdev_info(dev, "changing mtu from %d to %d\n", dev->mtu, new_mtu);
 	if (mgp->running) {
 		/* if we change the mtu on an active device, we must
 		 * reset the device so the firmware sees the change */
@@ -3356,7 +3321,7 @@ static int myri10ge_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netif_device_detach(netdev);
 	if (netif_running(netdev)) {
-		printk(KERN_INFO "myri10ge: closing %s\n", netdev->name);
+		netdev_info(netdev, "closing\n");
 		rtnl_lock();
 		myri10ge_close(netdev);
 		rtnl_unlock();
@@ -3383,8 +3348,7 @@ static int myri10ge_resume(struct pci_dev *pdev)
 	msleep(5);		/* give card time to respond */
 	pci_read_config_word(mgp->pdev, PCI_VENDOR_ID, &vendor);
 	if (vendor == 0xffff) {
-		printk(KERN_ERR "myri10ge: %s: device disappeared!\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "device disappeared!\n");
 		return -EIO;
 	}
 
@@ -3463,10 +3427,9 @@ static void myri10ge_watchdog(struct work_struct *work)
 		 * if the card rebooted due to a parity error
 		 * For now, just report it */
 		reboot = myri10ge_read_reboot(mgp);
-		printk(KERN_ERR
-		       "myri10ge: %s: NIC rebooted (0x%x),%s resetting\n",
-		       mgp->dev->name, reboot,
-		       myri10ge_reset_recover ? " " : " not");
+		netdev_err(mgp->dev, "NIC rebooted (0x%x),%s resetting\n",
+			   reboot,
+			   myri10ge_reset_recover ? "" : " not");
 		if (myri10ge_reset_recover == 0)
 			return;
 		rtnl_lock();
@@ -3494,31 +3457,26 @@ static void myri10ge_watchdog(struct work_struct *work)
 		if (cmd == 0xffff) {
 			pci_read_config_word(mgp->pdev, PCI_VENDOR_ID, &vendor);
 			if (vendor == 0xffff) {
-				printk(KERN_ERR
-				       "myri10ge: %s: device disappeared!\n",
-				       mgp->dev->name);
+				netdev_err(mgp->dev, "device disappeared!\n");
 				return;
 			}
 		}
 		/* Perhaps it is a software error.  Try to reset */
 
-		printk(KERN_ERR "myri10ge: %s: device timeout, resetting\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "device timeout, resetting\n");
 		for (i = 0; i < mgp->num_slices; i++) {
 			tx = &mgp->ss[i].tx;
-			printk(KERN_INFO
-			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
-			       mgp->dev->name, i, tx->queue_active, tx->req,
-			       tx->done, tx->pkt_start, tx->pkt_done,
-			       (int)ntohl(mgp->ss[i].fw_stats->
-					  send_done_count));
+			netdev_err(mgp->dev, "(%d): %d %d %d %d %d %d\n",
+				   i, tx->queue_active, tx->req,
+				   tx->done, tx->pkt_start, tx->pkt_done,
+				   (int)ntohl(mgp->ss[i].fw_stats->
+					      send_done_count));
 			msleep(2000);
-			printk(KERN_INFO
-			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
-			       mgp->dev->name, i, tx->queue_active, tx->req,
-			       tx->done, tx->pkt_start, tx->pkt_done,
-			       (int)ntohl(mgp->ss[i].fw_stats->
-					  send_done_count));
+			netdev_info(mgp->dev, "(%d): %d %d %d %d %d %d\n",
+				    i, tx->queue_active, tx->req,
+				    tx->done, tx->pkt_start, tx->pkt_done,
+				    (int)ntohl(mgp->ss[i].fw_stats->
+					       send_done_count));
 		}
 	}
 
@@ -3528,8 +3486,7 @@ static void myri10ge_watchdog(struct work_struct *work)
 	}
 	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0)
-		printk(KERN_ERR "myri10ge: %s: failed to load firmware\n",
-		       mgp->dev->name);
+		netdev_err(mgp->dev, "failed to load firmware\n");
 	else
 		myri10ge_open(mgp->dev);
 	rtnl_unlock();
@@ -3580,14 +3537,10 @@ static void myri10ge_watchdog_timer(unsigned long arg)
 			/* nic seems like it might be stuck.. */
 			if (rx_pause_cnt != mgp->watchdog_pause) {
 				if (net_ratelimit())
-					printk(KERN_WARNING
-					       "myri10ge %s slice %d:"
-					       "TX paused, check link partner\n",
-					       mgp->dev->name, i);
+					netdev_err(mgp->dev, "slice %d: TX paused, check link partner\n",
+						   i);
 			} else {
-				printk(KERN_WARNING
-				       "myri10ge %s slice %d stuck:",
-				       mgp->dev->name, i);
+				netdev_warn(mgp->dev, "slice %d stuck:", i);
 				reset_needed = 1;
 			}
 		}
@@ -4127,13 +4080,11 @@ static struct notifier_block myri10ge_dca_notifier = {
 
 static __init int myri10ge_init_module(void)
 {
-	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
-	       MYRI10GE_VERSION_STR);
+	pr_info("Version %s\n", MYRI10GE_VERSION_STR);
 
 	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_MAX) {
-		printk(KERN_ERR
-		       "%s: Illegal rssh hash type %d, defaulting to source port\n",
-		       myri10ge_driver.name, myri10ge_rss_hash);
+		pr_err("Illegal rssh hash type %d, defaulting to source port\n",
+		       myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
 #ifdef CONFIG_MYRI10GE_DCA
-- 
1.7.0.14.g7e948
