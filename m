From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/8] e1000e: convert ndev_ printks to
	something smaller
Date: Fri, 28 Mar 2008 09:15:31 -0700
Message-ID: <20080328161531.6562.8515.stgit@localhost.localdomain>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080328161503.6562.44329.stgit@localhost.localdomain>
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

From: Bruce Allan <bruce.w.allan@intel.com>

The ndev_* printk's are too lenghty and we don't need to specify
the adapter/netdev struct at all, making this a lot more readable.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h   |   27 ++++----
 drivers/net/e1000e/ethtool.c |   38 +++++------
 drivers/net/e1000e/netdev.c  |  148 +++++++++++++++++++-----------------------
 drivers/net/e1000e/param.c   |   31 +++------
 4 files changed, 108 insertions(+), 136 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index b941a6b..e48e353 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -41,24 +41,25 @@
 
 struct e1000_info;
 
-#define ndev_printk(level, netdev, format, arg...) \
-	printk(level "%s: " format, (netdev)->name, ## arg)
+#define e_printk(level, adapter, format, arg...) \
+	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
+	       adapter->netdev->name, ## arg)
 
 #ifdef DEBUG
-#define ndev_dbg(netdev, format, arg...) \
-	ndev_printk(KERN_DEBUG , netdev, format, ## arg)
+#define e_dbg(format, arg...) \
+	e_printk(KERN_DEBUG , adapter, format, ## arg)
 #else
-#define ndev_dbg(netdev, format, arg...) do { (void)(netdev); } while (0)
+#define e_dbg(format, arg...) do { (void)(adapter); } while (0)
 #endif
 
-#define ndev_err(netdev, format, arg...) \
-	ndev_printk(KERN_ERR , netdev, format, ## arg)
-#define ndev_info(netdev, format, arg...) \
-	ndev_printk(KERN_INFO , netdev, format, ## arg)
-#define ndev_warn(netdev, format, arg...) \
-	ndev_printk(KERN_WARNING , netdev, format, ## arg)
-#define ndev_notice(netdev, format, arg...) \
-	ndev_printk(KERN_NOTICE , netdev, format, ## arg)
+#define e_err(format, arg...) \
+	e_printk(KERN_ERR, adapter, format, ## arg)
+#define e_info(format, arg...) \
+	e_printk(KERN_INFO, adapter, format, ## arg)
+#define e_warn(format, arg...) \
+	e_printk(KERN_WARNING, adapter, format, ## arg)
+#define e_notice(format, arg...) \
+	e_printk(KERN_NOTICE, adapter, format, ## arg)
 
 
 /* Tx/Rx descriptor defines */
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 4ae0056..8398dbc 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -189,8 +189,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		ndev_err(adapter->netdev, "Unsupported Speed/Duplex "
-			 "configuration\n");
+		e_err("Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 
@@ -213,8 +212,7 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		ndev_err(adapter->netdev, "Unsupported Speed/Duplex "
-			 "configuration\n");
+		e_err("Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -231,8 +229,8 @@ static int e1000_set_settings(struct net_device *netdev,
 	 * cannot be changed
 	 */
 	if (e1000_check_reset_block(hw)) {
-		ndev_err(netdev, "Cannot change link "
-			 "characteristics when SoL/IDER is active.\n");
+		e_err("Cannot change link characteristics when SoL/IDER"
+		      " is active.\n");
 		return -EINVAL;
 	}
 
@@ -380,8 +378,7 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 		netdev->features &= ~NETIF_F_TSO6;
 	}
 
-	ndev_info(netdev, "TSO is %s\n",
-		  data ? "Enabled" : "Disabled");
+	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->flags |= FLAG_TSO_FORCE;
 	return 0;
 }
@@ -712,8 +709,8 @@ static bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
 				      (test[i] & write));
 		read = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
 		if (read != (test[i] & write & mask)) {
-			ndev_err(adapter->netdev, "pattern test reg %04X "
-				 "failed: got 0x%08X expected 0x%08X\n",
+			e_err("pattern test reg %04X failed: got "
+			      "0x%08X expected 0x%08X\n",
 				 reg + offset,
 				 read, (test[i] & write & mask));
 			*data = reg;
@@ -730,8 +727,8 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 	__ew32(&adapter->hw, reg, write & mask);
 	read = __er32(&adapter->hw, reg);
 	if ((write & mask) != (read & mask)) {
-		ndev_err(adapter->netdev, "set/check reg %04X test failed: "
-			 "got 0x%08X expected 0x%08X\n", reg, (read & mask),
+		e_err("set/check reg %04X test failed: got 0x%08X"
+		      "expected 0x%08X\n", reg, (read & mask),
 			 (write & mask));
 		*data = reg;
 		return true;
@@ -761,7 +758,6 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
-	struct net_device *netdev = adapter->netdev;
 	u32 value;
 	u32 before;
 	u32 after;
@@ -794,7 +790,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	ew32(STATUS, toggle);
 	after = er32(STATUS) & toggle;
 	if (value != after) {
-		ndev_err(netdev, "failed STATUS register test got: "
+		e_err("failed STATUS register test got: "
 			 "0x%08X expected: 0x%08X\n", after, value);
 		*data = 1;
 		return 1;
@@ -901,8 +897,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		*data = 1;
 		return -1;
 	}
-	ndev_info(netdev, "testing %s interrupt\n",
-		  (shared_int ? "shared" : "unshared"));
+	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1502,8 +1497,7 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	 * sessions are active
 	 */
 	if (e1000_check_reset_block(&adapter->hw)) {
-		ndev_err(adapter->netdev, "Cannot do PHY loopback test "
-			 "when SoL/IDER is active.\n");
+		e_err("Cannot do PHY loopback test when SoL/IDER is active.\n");
 		*data = 0;
 		goto out;
 	}
@@ -1588,7 +1582,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		forced_speed_duplex = adapter->hw.mac.forced_speed_duplex;
 		autoneg = adapter->hw.mac.autoneg;
 
-		ndev_info(netdev, "offline testing starting\n");
+		e_info("offline testing starting\n");
 
 		/*
 		 * Link test performed before hardware reset so autoneg doesn't
@@ -1634,7 +1628,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		ndev_info(netdev, "online testing starting\n");
+		e_info("online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1670,8 +1664,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->supported &= ~WAKE_UCAST;
 
 		if (adapter->wol & E1000_WUFC_EX)
-			ndev_err(netdev, "Interface does not support "
-				 "directed (unicast) frame wake-up packets\n");
+			e_err("Interface does not support directed (unicast)"
+			      " frame wake-up packets\n");
 	}
 
 	if (adapter->wol & E1000_WUFC_EX)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b8bb4fe..7ea7234 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -401,8 +401,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		 * packet, also make sure the frame isn't just CRC only */
 		if (!(status & E1000_RXD_STAT_EOP) || (length <= 4)) {
 			/* All receives must fit into a single buffer */
-			ndev_dbg(netdev, "%s: Receive packet consumed "
-				 "multiple buffers\n", netdev->name);
+			e_dbg("Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			goto next_desc;
@@ -493,28 +492,26 @@ static void e1000_print_tx_hang(struct e1000_adapter *adapter)
 	unsigned int i = tx_ring->next_to_clean;
 	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
 	struct e1000_tx_desc *eop_desc = E1000_TX_DESC(*tx_ring, eop);
-	struct net_device *netdev = adapter->netdev;
 
 	/* detected Tx unit hang */
-	ndev_err(netdev,
-		 "Detected Tx Unit Hang:\n"
-		 "  TDH                  <%x>\n"
-		 "  TDT                  <%x>\n"
-		 "  next_to_use          <%x>\n"
-		 "  next_to_clean        <%x>\n"
-		 "buffer_info[next_to_clean]:\n"
-		 "  time_stamp           <%lx>\n"
-		 "  next_to_watch        <%x>\n"
-		 "  jiffies              <%lx>\n"
-		 "  next_to_watch.status <%x>\n",
-		 readl(adapter->hw.hw_addr + tx_ring->head),
-		 readl(adapter->hw.hw_addr + tx_ring->tail),
-		 tx_ring->next_to_use,
-		 tx_ring->next_to_clean,
-		 tx_ring->buffer_info[eop].time_stamp,
-		 eop,
-		 jiffies,
-		 eop_desc->upper.fields.status);
+	e_err("Detected Tx Unit Hang:\n"
+	      "  TDH                  <%x>\n"
+	      "  TDT                  <%x>\n"
+	      "  next_to_use          <%x>\n"
+	      "  next_to_clean        <%x>\n"
+	      "buffer_info[next_to_clean]:\n"
+	      "  time_stamp           <%lx>\n"
+	      "  next_to_watch        <%x>\n"
+	      "  jiffies              <%lx>\n"
+	      "  next_to_watch.status <%x>\n",
+	      readl(adapter->hw.hw_addr + tx_ring->head),
+	      readl(adapter->hw.hw_addr + tx_ring->tail),
+	      tx_ring->next_to_use,
+	      tx_ring->next_to_clean,
+	      tx_ring->buffer_info[eop].time_stamp,
+	      eop,
+	      jiffies,
+	      eop_desc->upper.fields.status);
 }
 
 /**
@@ -664,8 +661,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		buffer_info->dma = 0;
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
-			ndev_dbg(netdev, "%s: Packet Split buffers didn't pick "
-				 "up the full packet\n", netdev->name);
+			e_dbg("Packet Split buffers didn't pick up the full"
+			      " packet\n");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -678,8 +675,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		length = le16_to_cpu(rx_desc->wb.middle.length0);
 
 		if (!length) {
-			ndev_dbg(netdev, "%s: Last part of the packet spanning"
-				 " multiple descriptors\n", netdev->name);
+			e_dbg("Last part of the packet spanning multiple"
+			      " descriptors\n");
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -979,12 +976,11 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
 	if (err) {
-		ndev_err(netdev,
-		       "Unable to allocate %s interrupt (return: %d)\n",
-			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
-			err);
-		if (adapter->flags & FLAG_MSI_ENABLED)
+		if (adapter->flags & FLAG_MSI_ENABLED) {
 			pci_disable_msi(adapter->pdev);
+			adapter->flags &= ~FLAG_MSI_ENABLED;
+		}
+		e_err("Unable to allocate interrupt, Error: %d\n", err);
 	}
 
 	return err;
@@ -1123,8 +1119,7 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	return 0;
 err:
 	vfree(tx_ring->buffer_info);
-	ndev_err(adapter->netdev,
-	"Unable to allocate memory for the transmit descriptor ring\n");
+	e_err("Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
 }
 
@@ -1178,8 +1173,7 @@ err_pages:
 	}
 err:
 	vfree(rx_ring->buffer_info);
-	ndev_err(adapter->netdev,
-	"Unable to allocate memory for the transmit descriptor ring\n");
+	e_err("Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
 }
 
@@ -2158,7 +2152,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	ew32(WUC, 0);
 
 	if (mac->ops.init_hw(hw))
-		ndev_err(adapter->netdev, "Hardware Error\n");
+		e_err("Hardware Error\n");
 
 	e1000_update_mng_vlan(adapter);
 
@@ -2292,7 +2286,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	return 0;
 
 err:
-	ndev_err(netdev, "Unable to allocate memory for queues\n");
+	e_err("Unable to allocate memory for queues\n");
 	kfree(adapter->rx_ring);
 	kfree(adapter->tx_ring);
 	return -ENOMEM;
@@ -2636,18 +2630,16 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 static void e1000_print_link_info(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
 	u32 ctrl = er32(CTRL);
 
-	ndev_info(netdev,
-		"Link is Up %d Mbps %s, Flow Control: %s\n",
-		adapter->link_speed,
-		(adapter->link_duplex == FULL_DUPLEX) ?
+	e_info("Link is Up %d Mbps %s, Flow Control: %s\n",
+	       adapter->link_speed,
+	       (adapter->link_duplex == FULL_DUPLEX) ?
 				"Full Duplex" : "Half Duplex",
-		((ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE)) ?
+	       ((ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE)) ?
 				"RX/TX" :
-		((ctrl & E1000_CTRL_RFCE) ? "RX" :
-		((ctrl & E1000_CTRL_TFCE) ? "TX" : "None" )));
+	       ((ctrl & E1000_CTRL_RFCE) ? "RX" :
+	       ((ctrl & E1000_CTRL_TFCE) ? "TX" : "None")));
 }
 
 static bool e1000_has_link(struct e1000_adapter *adapter)
@@ -2687,8 +2679,7 @@ static bool e1000_has_link(struct e1000_adapter *adapter)
 	if ((ret_val == E1000_ERR_PHY) && (hw->phy.type == e1000_phy_igp_3) &&
 	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
-		ndev_info(adapter->netdev,
-			  "Gigabit has been disabled, downgrading speed\n");
+		e_info("Gigabit has been disabled, downgrading speed\n");
 	}
 
 	return link_active;
@@ -2788,8 +2779,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 				switch (adapter->link_speed) {
 				case SPEED_10:
 				case SPEED_100:
-					ndev_info(netdev,
-					"10/100 speed: disabling TSO\n");
+					e_info("10/100 speed: disabling TSO\n");
 					netdev->features &= ~NETIF_F_TSO;
 					netdev->features &= ~NETIF_F_TSO6;
 					break;
@@ -2822,7 +2812,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			ndev_info(netdev, "Link is Down\n");
+			e_info("Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->state))
@@ -3295,8 +3285,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 			pull_size = min((unsigned int)4, skb->data_len);
 			if (!__pskb_pull_tail(skb, pull_size)) {
-				ndev_err(netdev,
-					 "__pskb_pull_tail failed.\n");
+				e_err("__pskb_pull_tail failed.\n");
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
@@ -3428,25 +3417,25 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		ndev_err(netdev, "Invalid MTU setting\n");
+		e_err("Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
 	/* Jumbo frame size limits */
 	if (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) {
 		if (!(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-			ndev_err(netdev, "Jumbo Frames not supported.\n");
+			e_err("Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 		if (adapter->hw.phy.type == e1000_phy_ife) {
-			ndev_err(netdev, "Jumbo Frames not supported.\n");
+			e_err("Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 	}
 
 #define MAX_STD_JUMBO_FRAME_SIZE 9234
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		ndev_err(netdev, "MTU > 9216 not supported.\n");
+		e_err("MTU > 9216 not supported.\n");
 		return -EINVAL;
 	}
 
@@ -3481,8 +3470,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
 					 + ETH_FCS_LEN;
 
-	ndev_info(netdev, "changing MTU from %d to %d\n",
-		netdev->mtu, new_mtu);
+	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 
 	if (netif_running(netdev))
@@ -3827,22 +3815,20 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	u32 part_num;
 
 	/* print bus type/speed/width info */
-	ndev_info(netdev, "(PCI Express:2.5GB/s:%s) "
-		  "%02x:%02x:%02x:%02x:%02x:%02x\n",
-		  /* bus width */
-		 ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
-		  "Width x1"),
-		  /* MAC address */
-		  netdev->dev_addr[0], netdev->dev_addr[1],
-		  netdev->dev_addr[2], netdev->dev_addr[3],
-		  netdev->dev_addr[4], netdev->dev_addr[5]);
-	ndev_info(netdev, "Intel(R) PRO/%s Network Connection\n",
-		  (hw->phy.type == e1000_phy_ife)
-		   ? "10/100" : "1000");
+	e_info("(PCI Express:2.5GB/s:%s) %02x:%02x:%02x:%02x:%02x:%02x\n",
+	       /* bus width */
+	      ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
+	       "Width x1"),
+	       /* MAC address */
+	       netdev->dev_addr[0], netdev->dev_addr[1],
+	       netdev->dev_addr[2], netdev->dev_addr[3],
+	       netdev->dev_addr[4], netdev->dev_addr[5]);
+	e_info("Intel(R) PRO/%s Network Connection\n",
+	       (hw->phy.type == e1000_phy_ife) ? "10/100" : "1000");
 	e1000e_read_part_num(hw, &part_num);
-	ndev_info(netdev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
-		  hw->mac.type, hw->phy.type,
-		  (part_num >> 8), (part_num & 0xff));
+	e_info("MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
+	       hw->mac.type, hw->phy.type,
+	       (part_num >> 8), (part_num & 0xff));
 }
 
 /**
@@ -3990,8 +3976,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	if (e1000_check_reset_block(&adapter->hw))
-		ndev_info(netdev,
-			  "PHY reset is blocked due to SOL/IDER session.\n");
+		e_info("PHY reset is blocked due to SOL/IDER session.\n");
 
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_HW_CSUM |
@@ -4030,7 +4015,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		if (e1000_validate_nvm_checksum(&adapter->hw) >= 0)
 			break;
 		if (i == 2) {
-			ndev_err(netdev, "The NVM Checksum Is Not Valid\n");
+			e_err("The NVM Checksum Is Not Valid\n");
 			err = -EIO;
 			goto err_eeprom;
 		}
@@ -4038,17 +4023,16 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* copy the MAC address out of the NVM */
 	if (e1000e_read_mac_addr(&adapter->hw))
-		ndev_err(netdev, "NVM Read Error while reading MAC address\n");
+		e_err("NVM Read Error while reading MAC address\n");
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		ndev_err(netdev, "Invalid MAC Address: "
-			 "%02x:%02x:%02x:%02x:%02x:%02x\n",
-			 netdev->perm_addr[0], netdev->perm_addr[1],
-			 netdev->perm_addr[2], netdev->perm_addr[3],
-			 netdev->perm_addr[4], netdev->perm_addr[5]);
+		e_err("Invalid MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+		      netdev->dev_addr[0], netdev->dev_addr[1],
+		      netdev->dev_addr[2], netdev->dev_addr[3],
+		      netdev->dev_addr[4], netdev->dev_addr[5]);
 		err = -EIO;
 		goto err_eeprom;
 	}
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index a66b92e..8effc31 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -27,6 +27,7 @@
 *******************************************************************************/
 
 #include <linux/netdevice.h>
+#include <linux/pci.h>
 
 #include "e1000.h"
 
@@ -162,17 +163,16 @@ static int __devinit e1000_validate_option(unsigned int *value,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			ndev_info(adapter->netdev, "%s Enabled\n", opt->name);
+			e_info("%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			ndev_info(adapter->netdev, "%s Disabled\n", opt->name);
+			e_info("%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			ndev_info(adapter->netdev,
-					"%s set to %i\n", opt->name, *value);
+			e_info("%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
@@ -184,8 +184,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')
-					ndev_info(adapter->netdev, "%s\n",
-						  ent->str);
+					e_info("%s\n", ent->str);
 				return 0;
 			}
 		}
@@ -195,8 +194,8 @@ static int __devinit e1000_validate_option(unsigned int *value,
 		BUG();
 	}
 
-	ndev_info(adapter->netdev, "Invalid %s value specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+	e_info("Invalid %s value specified (%i) %s\n", opt->name, *value,
+	       opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -213,13 +212,11 @@ static int __devinit e1000_validate_option(unsigned int *value,
 void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
 	int bd = adapter->bd_number;
 
 	if (bd >= E1000_MAX_NIC) {
-		ndev_notice(netdev,
-		       "Warning: no configuration for board #%i\n", bd);
-		ndev_notice(netdev, "Using defaults for all values\n");
+		e_notice("Warning: no configuration for board #%i\n", bd);
+		e_notice("Using defaults for all values\n");
 	}
 
 	{ /* Transmit Interrupt Delay */
@@ -313,19 +310,15 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->itr = InterruptThrottleRate[bd];
 			switch (adapter->itr) {
 			case 0:
-				ndev_info(netdev, "%s turned off\n",
-					opt.name);
+				e_info("%s turned off\n", opt.name);
 				break;
 			case 1:
-				ndev_info(netdev,
-					  "%s set to dynamic mode\n",
-					  opt.name);
+				e_info("%s set to dynamic mode\n", opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;
 				break;
 			case 3:
-				ndev_info(netdev,
-					"%s set to dynamic conservative mode\n",
+				e_info("%s set to dynamic conservative mode\n",
 					opt.name);
 				adapter->itr_setting = adapter->itr;
 				adapter->itr = 20000;


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
