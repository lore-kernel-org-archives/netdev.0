From: Ben Greear <greearb@candelatech.com>
Subject: Add ability to receive and transmit ethernet frames with bad CRC
 (e1000)
Date: Mon, 25 Oct 2004 14:43:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417D736A.6080207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have patched the e1000 driver to allow one to send frames with bad (ie, custom)
CRCs, as well as receive packets with bad CRCs and other errors.  The receive logic
should be very useful for packet sniffing, and the tx is useful for testing error
cases for ethernet equipment.

The rest of the patch to turn on/off these bits is tangled in with ethtool
changes and several other files, but I will dis-entangle them if it is agreed
that this feature is desired.  I also have driver support for the e100 driver.

Comments welcome, and let me know if it's worth my time to break out the
other components of this feature from my big patch.

Thanks,
Ben


--- linux-2.6.9/drivers/net/e1000/e1000_main.c	2004-10-18 14:53:50.000000000 -0700
+++ linux-2.6.9.p4s/drivers/net/e1000/e1000_main.c	2004-10-22 12:35:22.000000000 -0700
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/** -*-linux-c -*- ***************************************************************


    Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
@@ -120,7 +120,7 @@
  static void e1000_setup_rctl(struct e1000_adapter *adapter);
  static void e1000_clean_tx_ring(struct e1000_adapter *adapter);
  static void e1000_clean_rx_ring(struct e1000_adapter *adapter);
-static void e1000_set_multi(struct net_device *netdev);
+void e1000_set_multi(struct net_device *netdev);
  static void e1000_update_phy_info(unsigned long data);
  static void e1000_watchdog(unsigned long data);
  static void e1000_82547_tx_fifo_stall(unsigned long data);
@@ -499,6 +499,10 @@
  	if(pci_using_dac)
  		netdev->features |= NETIF_F_HIGHDMA;

+	/* Has ability to receive all frames (even bad CRCs and such) */
+	netdev->features |= NETIF_F_RX_ALL | NETIF_F_SAVE_CRC;
+
+	
   	/* hard_start_xmit is safe against parallel locking */
   	netdev->features |= NETIF_F_LLTX;

@@ -1269,7 +1273,7 @@
   * promiscuous mode, and all-multi behavior.
   **/

-static void
+void
  e1000_set_multi(struct net_device *netdev)
  {
  	struct e1000_adapter *adapter = netdev->priv;
@@ -1297,6 +1301,35 @@

  	E1000_WRITE_REG(hw, RCTL, rctl);

+
+	/* This is useful for using ethereal or tcpdump to sniff
+        * packets in promiscuous mode without stripping VLAN/priority
+        * information, and also letting bad packets through.
+        *
+        * THIS IS NOT PRODUCTION CODE - FOR INTERNAL USE ONLY!!!
+        *
+        */
+        if (netdev->priv_flags & IFF_ACCEPT_ALL_FRAMES) {
+		uint32_t ctrl;
+		/*printk("%s: Enabling acceptance of ALL frames (bad CRC too).\n",
+		  netdev->name); */
+		/* store bad packets, promisc/multicast all, no VLAN
+		 * filter */
+		rctl = E1000_READ_REG(hw, RCTL);
+		rctl |= (E1000_RCTL_SBP | E1000_RCTL_UPE | E1000_RCTL_MPE);
+		rctl &= ~(E1000_RCTL_VFE | E1000_RCTL_CFIEN);
+		E1000_WRITE_REG(hw, RCTL, rctl);
+		/* disable VLAN tagging/striping */
+		ctrl = E1000_READ_REG(hw, CTRL);
+		ctrl &= ~E1000_CTRL_VME;
+		E1000_WRITE_REG(hw, CTRL, ctrl);
+	}
+	else {
+		/* TODO:  Do we need a way to explicitly turn this off if it was
+		 * previously enabled, or will it magically go back to normal??? --Ben
+		 */
+	}
+	
  	/* 82542 2.0 needs to be in reset to write receive address registers */

  	if(hw->mac_type == e1000_82542_rev2_0)
@@ -1493,6 +1526,7 @@
  #define E1000_TX_FLAGS_CSUM		0x00000001
  #define E1000_TX_FLAGS_VLAN		0x00000002
  #define E1000_TX_FLAGS_TSO		0x00000004
+#define E1000_TX_FLAGS_NO_FCS		0x00000008
  #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
  #define E1000_TX_FLAGS_VLAN_SHIFT	16

@@ -1697,6 +1731,13 @@
  		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
  	}

+#ifdef CONFIG_SUPPORT_SEND_BAD_CRC
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS)) {
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+		/* printk("Disabling CRC in tx_queue, txd_lower: 0x%x\n", txd_lower); */
+	}
+#endif
+	
  	i = tx_ring->next_to_use;

  	while(count--) {
@@ -1711,6 +1752,14 @@

  	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);

+#ifdef CONFIG_SUPPORT_SEND_BAD_CRC
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS)) {
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+		/* printk("Disabling2 CRC in tx_queue, txd_lower: 0x%x\n", tx_desc->lower.data); */
+	}
+#endif
+	
  	/* Force memory writes to complete before letting h/w
  	 * know there are new descriptors to fetch.  (Only
  	 * applicable for weak-ordered memory model archs,
@@ -1849,6 +1898,12 @@
  	else if(likely(e1000_tx_csum(adapter, skb)))
  		tx_flags |= E1000_TX_FLAGS_CSUM;

+#ifdef CONFIG_SUPPORT_SEND_BAD_CRC
+	if (unlikely(skb->general_flags & DONT_DO_TX_CRC)) {
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+	}
+#endif	
+
  	e1000_tx_queue(adapter,
  		e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss),
  		tx_flags);
@@ -2307,7 +2362,11 @@
  			goto next_desc;
  		}

-		if(unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
+		/* If we are accepting all frames, then do not pay attention to the
+		 * framing errors.
+		 */
+ 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK) &&
+		    !(netdev->priv_flags & IFF_ACCEPT_ALL_FRAMES)) {
  			last_byte = *(skb->data + length - 1);
  			if(TBI_ACCEPT(&adapter->hw, rx_desc->status,
  			              rx_desc->errors, length, last_byte)) {
@@ -2325,7 +2384,12 @@
  		}

  		/* Good Receive */
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
+		if (netdev->priv_flags & IFF_SAVE_FCS) {
+			skb_put(skb, length);
+		}
+		else {
+			skb_put(skb, length - ETHERNET_FCS_SIZE);
+		}

  		/* Receive Checksum Offload */
  		e1000_rx_checksum(adapter, rx_desc, skb);
--- linux-2.6.9/drivers/net/e1000/e1000_ethtool.c	2004-10-18 14:54:07.000000000 -0700
+++ linux-2.6.9.p4s/drivers/net/e1000/e1000_ethtool.c	2004-10-22 12:14:24.000000000 -0700
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/*** -*-linux-c-*- **************************************************************


    Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
@@ -39,6 +39,7 @@
  extern void e1000_down(struct e1000_adapter *adapter);
  extern void e1000_reset(struct e1000_adapter *adapter);
  extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+extern void e1000_set_multi(struct net_device *netdev);
  extern int e1000_setup_rx_resources(struct e1000_adapter *adapter);
  extern int e1000_setup_tx_resources(struct e1000_adapter *adapter);
  extern void e1000_free_rx_resources(struct e1000_adapter *adapter);
@@ -1612,6 +1613,58 @@
  	}
  }

+static int e1000_ethtool_setrxall(struct net_device *netdev, uint32_t val) {
+	unsigned short old_flags = netdev->priv_flags;
+	if (val) {
+		netdev->priv_flags |= IFF_ACCEPT_ALL_FRAMES;
+	}
+	else {
+		netdev->priv_flags &= ~(IFF_ACCEPT_ALL_FRAMES);
+	}
+
+	/* printk("e1000_ethtool_setrxall (%s) val: %d\n",
+	   netdev->name, val); */
+	if (old_flags != netdev->priv_flags) {
+		spin_lock_bh(&netdev->xmit_lock);
+		if (netif_running(netdev)) {
+			/*printk("Kicking e1000 for setrxall..\n");*/
+			e1000_set_multi(netdev);
+		} else {
+			/* Value will be flushed into the hardware when the device is
+			 * brought up.
+			 */
+		}
+		spin_unlock_bh(&netdev->xmit_lock);
+	}
+	return 0;
+}
+
+static int e1000_ethtool_set_save_fcs(struct net_device *netdev, uint32_t val) {
+	spin_lock_bh(&netdev->xmit_lock);
+	if (val) {
+		netdev->priv_flags |= IFF_SAVE_FCS;
+	}
+	else {
+		netdev->priv_flags &= ~IFF_SAVE_FCS;
+	}
+	spin_unlock_bh(&netdev->xmit_lock);
+	return 0;
+}
+
+static int e1000_ethtool_get_save_fcs(struct net_device *netdev, uint32_t* val) {
+	*val = !!(netdev->priv_flags & IFF_SAVE_FCS);
+	/*printk("GETRXALL, data: %d  priv_flags: %hx\n",
+	  edata.data, netdev->priv_flags);*/
+	return 0;
+}
+
+static int e1000_ethtool_getrxall(struct net_device *netdev, uint32_t* val) {
+	*val = !!(netdev->priv_flags & IFF_ACCEPT_ALL_FRAMES);
+	/*printk("GETRXALL, data: %d  priv_flags: %hx\n",
+	  edata.data, netdev->priv_flags);*/
+	return 0;
+}		
+
  struct ethtool_ops e1000_ethtool_ops = {
  	.get_settings           = e1000_get_settings,
  	.set_settings           = e1000_set_settings,
@@ -1647,6 +1700,10 @@
  	.phys_id                = e1000_phys_id,
  	.get_stats_count        = e1000_get_stats_count,
  	.get_ethtool_stats      = e1000_get_ethtool_stats,
+	.get_rx_all             = e1000_ethtool_getrxall,
+	.set_rx_all             = e1000_ethtool_setrxall,
+	.set_save_fcs           = e1000_ethtool_set_save_fcs,
+	.get_save_fcs           = e1000_ethtool_get_save_fcs,
  };

  void set_ethtool_ops(struct net_device *netdev)

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
