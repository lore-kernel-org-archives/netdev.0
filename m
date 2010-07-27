From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000: use netif_<level> instead of
	netdev_<level>
Date: Mon, 26 Jul 2010 23:33:31 -0700
Message-ID: <20100727063129.24362.20955.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Joe Perches <joe@perches.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:50748
	"EHLO qmta02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752945Ab0G0Gd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 02:33:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch restores the ability to set msglvl through ethtool.
The issue was introduced by:
commit 675ad47375c76a7c3be4ace9554d92cd55518ced

CC: Joe Perches <joe@perches.com>

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |   18 ++++----
 drivers/net/e1000/e1000_ethtool.c |   27 ++++++------
 drivers/net/e1000/e1000_main.c    |   86 ++++++++++++++++++++-----------------
 3 files changed, 70 insertions(+), 61 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 65298a6..99288b9 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -324,18 +324,20 @@ enum e1000_state_t {
 extern struct net_device *e1000_get_hw_dev(struct e1000_hw *hw);
 #define e_dbg(format, arg...) \
 	netdev_dbg(e1000_get_hw_dev(hw), format, ## arg)
-#define e_err(format, arg...) \
-	netdev_err(adapter->netdev, format, ## arg)
-#define e_info(format, arg...) \
-	netdev_info(adapter->netdev, format, ## arg)
-#define e_warn(format, arg...) \
-	netdev_warn(adapter->netdev, format, ## arg)
-#define e_notice(format, arg...) \
-	netdev_notice(adapter->netdev, format, ## arg)
+#define e_err(msglvl, format, arg...) \
+	netif_err(adapter, msglvl, adapter->netdev, format, ## arg)
+#define e_info(msglvl, format, arg...) \
+	netif_info(adapter, msglvl, adapter->netdev, format, ## arg)
+#define e_warn(msglvl, format, arg...) \
+	netif_warn(adapter, msglvl, adapter->netdev, format, ## arg)
+#define e_notice(msglvl, format, arg...) \
+	netif_notice(adapter, msglvl, adapter->netdev, format, ## arg)
 #define e_dev_info(format, arg...) \
 	dev_info(&adapter->pdev->dev, format, ## arg)
 #define e_dev_warn(format, arg...) \
 	dev_warn(&adapter->pdev->dev, format, ## arg)
+#define e_dev_err(format, arg...) \
+	dev_err(&adapter->pdev->dev, format, ## arg)
 
 extern char e1000_driver_name[];
 extern const char e1000_driver_version[];
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index d5ff029..f4d0922 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -346,7 +346,7 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 
 	netdev->features &= ~NETIF_F_TSO6;
 
-	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
+	e_info(probe, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = true;
 	return 0;
 }
@@ -714,9 +714,9 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
 		writel(write & test[i], address);
 		read = readl(address);
 		if (read != (write & test[i] & mask)) {
-			e_info("pattern test reg %04X failed: "
-			       "got 0x%08X expected 0x%08X\n",
-			       reg, read, (write & test[i] & mask));
+			e_err(drv, "pattern test reg %04X failed: "
+			      "got 0x%08X expected 0x%08X\n",
+			      reg, read, (write & test[i] & mask));
 			*data = reg;
 			return true;
 		}
@@ -734,7 +734,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 	writel(write & mask, address);
 	read = readl(address);
 	if ((read & mask) != (write & mask)) {
-		e_err("set/check reg %04X test failed: "
+		e_err(drv, "set/check reg %04X test failed: "
 		      "got 0x%08X expected 0x%08X\n",
 		      reg, (read & mask), (write & mask));
 		*data = reg;
@@ -779,7 +779,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	ew32(STATUS, toggle);
 	after = er32(STATUS) & toggle;
 	if (value != after) {
-		e_err("failed STATUS register test got: "
+		e_err(drv, "failed STATUS register test got: "
 		      "0x%08X expected: 0x%08X\n", after, value);
 		*data = 1;
 		return 1;
@@ -894,7 +894,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		*data = 1;
 		return -1;
 	}
-	e_info("testing %s interrupt\n", (shared_int ? "shared" : "unshared"));
+	e_info(hw, "testing %s interrupt\n", (shared_int ?
+	       "shared" : "unshared"));
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
@@ -1561,7 +1562,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		u8 forced_speed_duplex = hw->forced_speed_duplex;
 		u8 autoneg = hw->autoneg;
 
-		e_info("offline testing starting\n");
+		e_info(hw, "offline testing starting\n");
 
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result */
@@ -1601,7 +1602,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		e_info("online testing starting\n");
+		e_info(hw, "online testing starting\n");
 		/* Online tests */
 		if (e1000_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1694,8 +1695,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->supported &= ~WAKE_UCAST;
 
 		if (adapter->wol & E1000_WUFC_EX)
-			e_err("Interface does not support "
-		        "directed (unicast) frame wake-up packets\n");
+			e_err(drv, "Interface does not support directed "
+			      "(unicast) frame wake-up packets\n");
 		break;
 	default:
 		break;
@@ -1726,8 +1727,8 @@ static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		if (wol->wolopts & WAKE_UCAST) {
-			e_err("Interface does not support "
-			      "directed (unicast) frame wake-up packets\n");
+			e_err(drv, "Interface does not support directed "
+			      "(unicast) frame wake-up packets\n");
 			return -EOPNOTSUPP;
 		}
 		break;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 68a8089..02833af 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -275,7 +275,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 	                  netdev);
 	if (err) {
-		e_err("Unable to allocate interrupt Error: %d\n", err);
+		e_err(probe, "Unable to allocate interrupt Error: %d\n", err);
 	}
 
 	return err;
@@ -657,7 +657,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 		ew32(WUC, 0);
 
 	if (e1000_init_hw(hw))
-		e_err("Hardware Error\n");
+		e_dev_err("Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
@@ -925,7 +925,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize eeprom parameters */
 	if (e1000_init_eeprom_params(hw)) {
-		e_err("EEPROM initialization failed\n");
+		e_err(probe, "EEPROM initialization failed\n");
 		goto err_eeprom;
 	}
 
@@ -936,7 +936,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* make sure the EEPROM is good */
 	if (e1000_validate_eeprom_checksum(hw) < 0) {
-		e_err("The EEPROM Checksum Is Not Valid\n");
+		e_err(probe, "The EEPROM Checksum Is Not Valid\n");
 		e1000_dump_eeprom(adapter);
 		/*
 		 * set MAC address to all zeroes to invalidate and temporary
@@ -950,14 +950,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	} else {
 		/* copy the MAC address out of the EEPROM */
 		if (e1000_read_mac_addr(hw))
-			e_err("EEPROM Read Error\n");
+			e_err(probe, "EEPROM Read Error\n");
 	}
 	/* don't block initalization here due to bad MAC address */
 	memcpy(netdev->dev_addr, hw->mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr))
-		e_err("Invalid MAC Address\n");
+		e_err(probe, "Invalid MAC Address\n");
 
 	e1000_get_bus_info(hw);
 
@@ -1047,7 +1047,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_register;
 
 	/* print bus type/speed/width info */
-	e_info("(PCI%s:%dMHz:%d-bit) %pM\n",
+	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
 	       ((hw->bus_type == e1000_bus_type_pcix) ? "-X" : ""),
 	       ((hw->bus_speed == e1000_bus_speed_133) ? 133 :
 		(hw->bus_speed == e1000_bus_speed_120) ? 120 :
@@ -1059,7 +1059,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	e_info("Intel(R) PRO/1000 Network Connection\n");
+	e_info(probe, "Intel(R) PRO/1000 Network Connection\n");
 
 	cards_found++;
 	return 0;
@@ -1159,7 +1159,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	/* identify the MAC */
 
 	if (e1000_set_mac_type(hw)) {
-		e_err("Unknown MAC Type\n");
+		e_err(probe, "Unknown MAC Type\n");
 		return -EIO;
 	}
 
@@ -1192,7 +1192,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	adapter->num_rx_queues = 1;
 
 	if (e1000_alloc_queues(adapter)) {
-		e_err("Unable to allocate memory for queues\n");
+		e_err(probe, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
 
@@ -1386,7 +1386,8 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if (!txdr->buffer_info) {
-		e_err("Unable to allocate memory for the Tx descriptor ring\n");
+		e_err(probe, "Unable to allocate memory for the Tx descriptor "
+		      "ring\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -1401,7 +1402,8 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
-		e_err("Unable to allocate memory for the Tx descriptor ring\n");
+		e_err(probe, "Unable to allocate memory for the Tx descriptor "
+		      "ring\n");
 		return -ENOMEM;
 	}
 
@@ -1409,7 +1411,7 @@ setup_tx_desc_die:
 	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 		void *olddesc = txdr->desc;
 		dma_addr_t olddma = txdr->dma;
-		e_err("txdr align check failed: %u bytes at %p\n",
+		e_err(tx_err, "txdr align check failed: %u bytes at %p\n",
 		      txdr->size, txdr->desc);
 		/* Try again, without freeing the previous */
 		txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size,
@@ -1427,7 +1429,7 @@ setup_tx_desc_die:
 					  txdr->dma);
 			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
 					  olddma);
-			e_err("Unable to allocate aligned memory "
+			e_err(probe, "Unable to allocate aligned memory "
 			      "for the transmit descriptor ring\n");
 			vfree(txdr->buffer_info);
 			return -ENOMEM;
@@ -1460,7 +1462,7 @@ int e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = e1000_setup_tx_resources(adapter, &adapter->tx_ring[i]);
 		if (err) {
-			e_err("Allocation for Tx Queue %u failed\n", i);
+			e_err(probe, "Allocation for Tx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_tx_resources(adapter,
 							&adapter->tx_ring[i]);
@@ -1580,7 +1582,8 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	size = sizeof(struct e1000_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if (!rxdr->buffer_info) {
-		e_err("Unable to allocate memory for the Rx descriptor ring\n");
+		e_err(probe, "Unable to allocate memory for the Rx descriptor "
+		      "ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -1596,7 +1599,8 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 					GFP_KERNEL);
 
 	if (!rxdr->desc) {
-		e_err("Unable to allocate memory for the Rx descriptor ring\n");
+		e_err(probe, "Unable to allocate memory for the Rx descriptor "
+		      "ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
@@ -1606,7 +1610,7 @@ setup_rx_desc_die:
 	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 		void *olddesc = rxdr->desc;
 		dma_addr_t olddma = rxdr->dma;
-		e_err("rxdr align check failed: %u bytes at %p\n",
+		e_err(rx_err, "rxdr align check failed: %u bytes at %p\n",
 		      rxdr->size, rxdr->desc);
 		/* Try again, without freeing the previous */
 		rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size,
@@ -1615,8 +1619,8 @@ setup_rx_desc_die:
 		if (!rxdr->desc) {
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			e_err("Unable to allocate memory for the Rx descriptor "
-			      "ring\n");
+			e_err(probe, "Unable to allocate memory for the Rx "
+			      "descriptor ring\n");
 			goto setup_rx_desc_die;
 		}
 
@@ -1626,8 +1630,8 @@ setup_rx_desc_die:
 					  rxdr->dma);
 			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
 					  olddma);
-			e_err("Unable to allocate aligned memory for the Rx "
-			      "descriptor ring\n");
+			e_err(probe, "Unable to allocate aligned memory for "
+			      "the Rx descriptor ring\n");
 			goto setup_rx_desc_die;
 		} else {
 			/* Free old allocation, new allocation was successful */
@@ -1659,7 +1663,7 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = e1000_setup_rx_resources(adapter, &adapter->rx_ring[i]);
 		if (err) {
-			e_err("Allocation for Rx Queue %u failed\n", i);
+			e_err(probe, "Allocation for Rx Queue %u failed\n", i);
 			for (i-- ; i >= 0; i--)
 				e1000_free_rx_resources(adapter,
 							&adapter->rx_ring[i]);
@@ -2110,7 +2114,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	u32 *mcarray = kcalloc(mta_reg_count, sizeof(u32), GFP_ATOMIC);
 
 	if (!mcarray) {
-		e_err("memory allocation failed\n");
+		e_err(probe, "memory allocation failed\n");
 		return;
 	}
 
@@ -2648,7 +2652,8 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 		break;
 	default:
 		if (unlikely(net_ratelimit()))
-			e_warn("checksum_partial proto=%x!\n", skb->protocol);
+			e_warn(drv, "checksum_partial proto=%x!\n",
+			       skb->protocol);
 		break;
 	}
 
@@ -2992,7 +2997,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				/* fall through */
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					e_err("__pskb_pull_tail failed.\n");
+					e_err(drv, "__pskb_pull_tail "
+					      "failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
 				}
@@ -3140,7 +3146,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		e_err("Invalid MTU setting\n");
+		e_err(probe, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -3148,7 +3154,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
 		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
-			e_err("Jumbo Frames not supported.\n");
+			e_err(probe, "Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 		break;
@@ -3500,7 +3506,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
-			e_err("Detected Tx Unit Hang\n"
+			e_err(drv, "Detected Tx Unit Hang\n"
 			      "  Tx Queue             <%lu>\n"
 			      "  TDH                  <%x>\n"
 			      "  TDT                  <%x>\n"
@@ -3749,7 +3755,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			e_err("pskb_may_pull failed.\n");
+			e_err(drv, "pskb_may_pull failed.\n");
 			dev_kfree_skb(skb);
 			goto next_desc;
 		}
@@ -3874,7 +3880,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (adapter->discarding) {
 			/* All receives must fit into a single buffer */
-			e_info("Receive packet consumed multiple buffers\n");
+			e_dbg("Receive packet consumed multiple buffers\n");
 			/* recycle */
 			buffer_info->skb = skb;
 			if (status & E1000_RXD_STAT_EOP)
@@ -3986,8 +3992,8 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			e_err("skb align check failed: %u bytes at %p\n",
-			      bufsz, skb->data);
+			e_err(rx_err, "skb align check failed: %u bytes at "
+			      "%p\n", bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
@@ -4095,8 +4101,8 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
 			struct sk_buff *oldskb = skb;
-			e_err("skb align check failed: %u bytes at %p\n",
-			      bufsz, skb->data);
+			e_err(rx_err, "skb align check failed: %u bytes at "
+			      "%p\n", bufsz, skb->data);
 			/* Try again, without freeing the previous */
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			/* Failed allocation, critical failure */
@@ -4141,8 +4147,8 @@ map_skb:
 		if (!e1000_check_64k_bound(adapter,
 					(void *)(unsigned long)buffer_info->dma,
 					adapter->rx_buffer_len)) {
-			e_err("dma align check failed: %u bytes at %p\n",
-			      adapter->rx_buffer_len,
+			e_err(rx_err, "dma align check failed: %u bytes at "
+			      "%p\n", adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
@@ -4355,7 +4361,7 @@ void e1000_pci_set_mwi(struct e1000_hw *hw)
 	int ret_val = pci_set_mwi(adapter->pdev);
 
 	if (ret_val)
-		e_err("Error in setting MWI\n");
+		e_err(probe, "Error in setting MWI\n");
 }
 
 void e1000_pci_clear_mwi(struct e1000_hw *hw)
@@ -4486,7 +4492,7 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((hw->media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		e_err("Unsupported Speed/Duplex configuration\n");
+		e_err(probe, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 
@@ -4509,7 +4515,7 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		e_err("Unsupported Speed/Duplex configuration\n");
+		e_err(probe, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;

