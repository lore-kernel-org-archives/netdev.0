From: Ben Greear <greearb@candelatech.com>
Subject: Re: Problems with e1000 in 2.4.23
Date: Sun, 30 Nov 2003 18:51:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FCAACAD.7090609@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD05@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD05@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>Attached is an oops that did not hang the machine.
> 
> 
> Re: e1000_dump.txt: I'm 99% sure this shows dev_close being called
> without a matching dev_open, or a dev_close after failed dev_open.
> e1000 doesn't guard against that (and shouldn't), so we need to figure
> out how you're getting here and fix that.  What's above e1000?  Are you
> using bonding or pktgen or ?

It's possible I had a mac-vlan interface on it, but I don't think
I did.  I definately was not running bonding or pktgen.

I was running with the patch below, and this crash was shortly
after or during I configured the NIC to receive all (or, maybe
configured it from rx-all to not-rx-all.)

Could the problem happen because I do the set-multi even if the NIC
is down?  Is there enough locking in the e1000_ethtool additions?

Also, I am seeing bogus things on this machine regardless of which
kernel and which e1000 driver I use, so it's quite possible that either
the NIC hardware or the MB/RAM/CPU/Whatever is just plain not quite
right.

I'm ordering pieces for a nice new dual Xeon now....so hopefully I'll
have a more stable test environment soon....

Thanks,
Ben


--- linux-2.4.23/drivers/net/e1000/e1000_main.c	2003-11-28 10:26:20.000000000 -0800
+++ linux-2.4.23.p4s/drivers/net/e1000/e1000_main.c	2003-11-28 14:25:12.000000000 -0800
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/** -*-linux-c -*- ***************************************************************


    Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
@@ -462,6 +462,9 @@
  		netdev->features |= NETIF_F_TSO;
  #endif

+	/* Has ability to receive all frames (even bad CRCs and such) */
+	netdev->features |= NETIF_F_RX_ALL | NETIF_F_SAVE_CRC;
+	
  	if(pci_using_dac)
  		netdev->features |= NETIF_F_HIGHDMA;

@@ -1218,7 +1221,7 @@
   * promiscuous mode, and all-multi behavior.
   **/

-static void
+void
  e1000_set_multi(struct net_device *netdev)
  {
  	struct e1000_adapter *adapter = netdev->priv;
@@ -1243,6 +1246,34 @@

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
+		printk("Enabling acceptance of ALL frames (bad CRC too).\n");
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
@@ -1455,6 +1486,7 @@
  #define E1000_TX_FLAGS_CSUM		0x00000001
  #define E1000_TX_FLAGS_VLAN		0x00000002
  #define E1000_TX_FLAGS_TSO		0x00000004
+#define E1000_TX_FLAGS_NO_FCS		0x00000008
  #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
  #define E1000_TX_FLAGS_VLAN_SHIFT	16

@@ -1714,6 +1746,13 @@
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
@@ -1728,6 +1767,14 @@

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
@@ -1809,6 +1856,12 @@
  	else if(e1000_tx_csum(adapter, skb))
  		tx_flags |= E1000_TX_FLAGS_CSUM;

+#ifdef CONFIG_SUPPORT_SEND_BAD_CRC
+	if (unlikely(skb->general_flags & DONT_DO_TX_CRC)) {
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+	}
+#endif
+	
  	if((count = e1000_tx_map(adapter, skb, first)))
  		e1000_tx_queue(adapter, count, tx_flags);
  	else {
@@ -2281,7 +2334,11 @@
  			continue;
  		}

-		if(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK) {
+		/* If we are accepting all frames, then do not pay attention to the
+		 * framing errors.
+		 */
+		if (!(netdev->priv_flags & IFF_ACCEPT_ALL_FRAMES) &&
+		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {

  			last_byte = *(skb->data + length - 1);

@@ -2311,7 +2368,12 @@
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
--- linux-2.4.23/drivers/net/e1000/e1000_ethtool.c	2003-11-28 10:26:20.000000000 -0800
+++ linux-2.4.23.p4s/drivers/net/e1000/e1000_ethtool.c	2003-11-28 14:25:12.000000000 -0800
@@ -1,4 +1,4 @@
-/*******************************************************************************
+/*** -*-linux-c-*- **************************************************************


    Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
@@ -39,6 +39,7 @@
  extern void e1000_down(struct e1000_adapter *adapter);
  extern void e1000_reset(struct e1000_adapter *adapter);
  extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+extern void e1000_set_multi(struct net_device *netdev);

  struct e1000_stats {
  	char stat_string[ETH_GSTRING_LEN];
@@ -1335,6 +1336,28 @@
  	return 0;
  }

+/* Hold xmit lock before calling this */
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
+		/*  Kick the driver to flush the values...
+		 * TODO:  Needs review of driver folks to make sure locking is sane, etc
+		 */
+		/*printk("Kicking e1000_set_multi..\n");*/
+		e1000_set_multi(netdev);
+	}
+	return 0;
+}
+
  int
  e1000_ethtool_ioctl(struct net_device *netdev, struct ifreq *ifr)
  {
@@ -1624,6 +1647,47 @@

  		return 0;
  	}
+	case ETHTOOL_SETRXALL: {
+		struct ethtool_value id;
+		if (copy_from_user(&id, addr, sizeof(id)))
+			return -EFAULT;
+		spin_lock_bh(&netdev->xmit_lock);
+		e1000_ethtool_setrxall(netdev, id.data);
+		spin_unlock_bh(&netdev->xmit_lock);
+		return 0;
+	}
+	case ETHTOOL_GETRXALL: {
+		struct ethtool_value edata = { ETHTOOL_GSG };
+		edata.data = !!(netdev->priv_flags & IFF_ACCEPT_ALL_FRAMES);
+		/*printk("GETRXALL, data: %d  priv_flags: %hx\n",
+		  edata.data, netdev->priv_flags);*/
+		if (copy_to_user(addr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
+	case ETHTOOL_SETRXFCS: {
+		struct ethtool_value id;
+		if (copy_from_user(&id, addr, sizeof(id)))
+			return -EFAULT;
+		spin_lock_bh(&netdev->xmit_lock);
+		if (id.data) {
+			netdev->priv_flags |= IFF_SAVE_FCS;
+		}
+		else {
+			netdev->priv_flags &= ~IFF_SAVE_FCS;
+		}
+		spin_unlock_bh(&netdev->xmit_lock);
+		return 0;
+	}
+	case ETHTOOL_GETRXFCS: {
+		struct ethtool_value edata = { ETHTOOL_GSG };
+		edata.data = !!(netdev->priv_flags & IFF_SAVE_FCS);
+		/*printk("GETRXALL, data: %d  priv_flags: %hx\n",
+		  edata.data, netdev->priv_flags);*/
+		if (copy_to_user(addr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
  #ifdef NETIF_F_TSO
  	case ETHTOOL_GTSO: {
  		struct ethtool_value edata = { ETHTOOL_GTSO };


> 
> -scott
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
