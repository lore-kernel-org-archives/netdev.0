From: ganesh.venkatesan@intel.com
Subject: [PATCH 9/12 2.4] e1000 - Add compiler hints (likely/unlikely), check
 return codes, related cleanup
Date: Thu, 29 Jul 2004 08:30:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290744400.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000.h linux-2.4/drivers/net/e1000.new/e1000.h
--- linux-2.4/drivers/net/e1000/e1000.h	2004-07-28 08:47:08.172582760 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000.h	2004-07-28 08:47:09.439390176 -0700
@@ -63,6 +63,7 @@
 #include <linux/udp.h>
 #include <net/pkt_sched.h>
 #include <linux/list.h>
+#include <linux/rtnetlink.h>
 #include <linux/reboot.h>
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
@@ -79,6 +79,8 @@
 #define PCI_DMA_64BIT	0xffffffffffffffffULL
 #define PCI_DMA_32BIT	0x00000000ffffffffULL
 
+#define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
+	PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
 
 struct e1000_adapter;
 
@@ -155,9 +158,9 @@ struct e1000_adapter;
 struct e1000_buffer {
 	struct sk_buff *skb;
 	uint64_t dma;
-	unsigned long length;
 	unsigned long time_stamp;
-	unsigned int next_to_watch;
+	uint16_t length;
+	uint16_t next_to_watch;
 };
 
 struct e1000_desc_ring {
diff -up linux-2.4/drivers/net/e1000/e1000_hw.c linux-2.4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.4/drivers/net/e1000/e1000_hw.c	2004-07-28 08:47:08.174582456 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.c	2004-07-28 08:47:09.499381056 -0700
@@ -251,6 +251,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
         break;
     case E1000_DEV_ID_82541ER:
     case E1000_DEV_ID_82541GI:
+    case E1000_DEV_ID_82541GI_LF:
     case E1000_DEV_ID_82541GI_MOBILE:
         hw->mac_type = e1000_82541_rev_2;
         break;
@@ -920,7 +921,8 @@ e1000_setup_copper_link(struct e1000_hw 
     if(ret_val)
         return ret_val;
 
-    if(hw->mac_type == e1000_82545_rev_3) {
+    if((hw->mac_type == e1000_82545_rev_3) ||
+       (hw->mac_type == e1000_82546_rev_3)) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
         phy_data |= 0x00000008;
         ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
@@ -3057,16 +3059,6 @@ e1000_init_eeprom_params(struct e1000_hw
         }
         break;
     default:
-        eeprom->type = e1000_eeprom_spi;
-        eeprom->opcode_bits = 8;
-        eeprom->delay_usec = 1;
-        if (eecd & E1000_EECD_ADDR_BITS) {
-            eeprom->page_size = 32;
-            eeprom->address_bits = 16;
-        } else {
-            eeprom->page_size = 8;
-            eeprom->address_bits = 8;
-        }
         break;
     }
 
diff -up linux-2.4/drivers/net/e1000/e1000_hw.h linux-2.4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.4/drivers/net/e1000/e1000_hw.h	2004-07-28 08:47:08.176582152 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_hw.h	2004-07-28 08:47:09.531376192 -0700
@@ -357,11 +357,11 @@ int32_t e1000_set_d3_lplu_state(struct e
 #define E1000_DEV_ID_82547GI             0x1075
 #define E1000_DEV_ID_82541GI             0x1076
 #define E1000_DEV_ID_82541GI_MOBILE      0x1077
+#define E1000_DEV_ID_82541GI_LF          0x107C
 #define E1000_DEV_ID_82546GB_COPPER      0x1079
 #define E1000_DEV_ID_82546GB_FIBER       0x107A
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
 #define E1000_DEV_ID_82547EI             0x1019
-
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
 
diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -27,73 +27,69 @@
 *******************************************************************************/
 
 #include "e1000.h"
-#include <linux/rtnetlink.h>
 
 /* Change Log
+ * 5.3.12	6/7/04
+ * - kcompat NETIF_MSG for older kernels (2.4.9) <sean.p.mcdermott@intel.com>
+ * - if_mii support and associated kcompat for older kernels
+ * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
+ * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
  *
- * 5.2.51   5/14/04
- *   o set default configuration to 'NAPI disabled'. NAPI enabled driver
- *     causes kernel panic when the interface is shutdown while data is being
- *     transferred.
- * 5.2.47   5/04/04
- *   o fixed ethtool -t implementation
- * 5.2.45   4/29/04
- *   o fixed ethtool -e implementation
- *   o Support for ethtool ops [Stephen Hemminger (shemminger@osdl.org)]
- * 5.2.42   4/26/04
- *   o Added support for the DPRINTK macro for enhanced error logging.  Some
- *     parts of the patch were supplied by Jon Mason.
- *   o Move the register_netdevice() donw in the probe routine due to a 
- *     loading/unloading test issue.
- *   o Added a long RX byte count the the extra ethtool data members for BER
- *     testing purposes.
- * 5.2.39	3/12/04
+ * 5.3.11	6/4/04
+ * - ethtool register dump reads MANC register conditionally.
+ *
+ * 5.3.10	6/1/04
  */
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.52-k3";
+#ifndef CONFIG_E1000_NAPI
+#define DRIVERNAPI
+#else
+#define DRIVERNAPI "-NAPI"
+#endif
+char e1000_driver_version[] = "5.3.19-k1"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
- * Wildcard entries (PCI_ANY_ID) should come last
  * Last entry must be all 0s
  *
- * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
- *   Class, Class Mask, private data (not used) }
+ * Macro expands to...
+ *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
 static struct pci_device_id e1000_pci_tbl[] = {
-	{0x8086, 0x1000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1001, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1004, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1008, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x100C, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x100D, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x100E, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x100F, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1012, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1013, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1015, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1016, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1017, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1018, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1019, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x101D, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x101E, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1026, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1027, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1028, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1075, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1076, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1077, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1078, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x1079, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x107A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x8086, 0x107B, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	INTEL_E1000_ETHERNET_DEVICE(0x1000),
+	INTEL_E1000_ETHERNET_DEVICE(0x1001),
+	INTEL_E1000_ETHERNET_DEVICE(0x1004),
+	INTEL_E1000_ETHERNET_DEVICE(0x1008),
+	INTEL_E1000_ETHERNET_DEVICE(0x1009),
+	INTEL_E1000_ETHERNET_DEVICE(0x100C),
+	INTEL_E1000_ETHERNET_DEVICE(0x100D),
+	INTEL_E1000_ETHERNET_DEVICE(0x100E),
+	INTEL_E1000_ETHERNET_DEVICE(0x100F),
+	INTEL_E1000_ETHERNET_DEVICE(0x1010),
+	INTEL_E1000_ETHERNET_DEVICE(0x1011),
+	INTEL_E1000_ETHERNET_DEVICE(0x1012),
+	INTEL_E1000_ETHERNET_DEVICE(0x1013),
+	INTEL_E1000_ETHERNET_DEVICE(0x1015),
+	INTEL_E1000_ETHERNET_DEVICE(0x1016),
+	INTEL_E1000_ETHERNET_DEVICE(0x1017),
+	INTEL_E1000_ETHERNET_DEVICE(0x1018),
+	INTEL_E1000_ETHERNET_DEVICE(0x1019),
+	INTEL_E1000_ETHERNET_DEVICE(0x101D),
+	INTEL_E1000_ETHERNET_DEVICE(0x101E),
+	INTEL_E1000_ETHERNET_DEVICE(0x1026),
+	INTEL_E1000_ETHERNET_DEVICE(0x1027),
+	INTEL_E1000_ETHERNET_DEVICE(0x1028),
+	INTEL_E1000_ETHERNET_DEVICE(0x1075),
+	INTEL_E1000_ETHERNET_DEVICE(0x1076),
+	INTEL_E1000_ETHERNET_DEVICE(0x1077),
+	INTEL_E1000_ETHERNET_DEVICE(0x1078),
+	INTEL_E1000_ETHERNET_DEVICE(0x1079),
+	INTEL_E1000_ETHERNET_DEVICE(0x107A),
+	INTEL_E1000_ETHERNET_DEVICE(0x107B),
+	INTEL_E1000_ETHERNET_DEVICE(0x107C),
 	/* required last entry */
 	{0,}
 };
@@ -202,7 +198,7 @@ MODULE_AUTHOR("Intel Corporation, <linux
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 
-static int debug = 3;
+static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
@@ -687,19 +683,19 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	e1000_init_eeprom_params(hw);
 
-	if((hw->mac_type == e1000_82541) ||
-	   (hw->mac_type == e1000_82547) ||
-	   (hw->mac_type == e1000_82541_rev_2) ||
-	   (hw->mac_type == e1000_82547_rev_2))
+	switch(hw->mac_type) {
+	default:
+		break;
+	case e1000_82541:
+	case e1000_82547:
+	case e1000_82541_rev_2:
+	case e1000_82547_rev_2:
 		hw->phy_init_script = 1;
+		break;
+	}
 
 	e1000_set_media_type(hw);
 
-	if(hw->mac_type < e1000_82543)
-		hw->report_tx_early = 0;
-	else
-		hw->report_tx_early = 1;
-
 	hw->wait_autoneg_complete = FALSE;
 	hw->tbi_compatibility_en = TRUE;
 	hw->adaptive_ifs = TRUE;
@@ -751,7 +747,7 @@ e1000_open(struct net_device *netdev)
 	if((err = e1000_up(adapter)))
 		goto err_up;
 
-	return 0;
+	return E1000_SUCCESS;
 
 err_up:
 	e1000_free_rx_resources(adapter);
@@ -893,10 +889,10 @@ e1000_configure_tx(struct e1000_adapter 
 	adapter->txd_cmd = E1000_TXD_CMD_IDE | E1000_TXD_CMD_EOP |
 		E1000_TXD_CMD_IFCS;
 
-	if(adapter->hw.report_tx_early == 1)
-		adapter->txd_cmd |= E1000_TXD_CMD_RS;
-	else
+	if(adapter->hw.mac_type < e1000_82543)
 		adapter->txd_cmd |= E1000_TXD_CMD_RPS;
+	else
+		adapter->txd_cmd |= E1000_TXD_CMD_RS;
 
 	/* Cache if we're 82544 running in PCI-X because we'll
 	 * need this to apply a workaround later in the send path. */
@@ -1547,7 +1538,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 	unsigned int i;
 	uint8_t css;
 
-	if(skb->ip_summed == CHECKSUM_HW) {
+	if(likely(skb->ip_summed == CHECKSUM_HW)) {
 		css = skb->h.raw - skb->data;
 
 		i = adapter->tx_ring.next_to_use;
@@ -1559,7 +1538,7 @@ 
 		context_desc->tcp_seg_setup.data = 0;
 		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);
 
-		if(++i == adapter->tx_ring.count) i = 0;
+		if(unlikely(++i == adapter->tx_ring.count)) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return TRUE;
@@ -1592,14 +1585,14 @@ e1000_tx_map(struct e1000_adapter *adapt
 #ifdef NETIF_F_TSO
 		/* Workaround for premature desc write-backs
 		 * in TSO mode.  Append 4-byte sentinel desc */
-		if(mss && !nr_frags && size == len && size > 8)
+		if(unlikely(mss && !nr_frags && size == len && size > 8))
 			size -= 4;
 #endif
 		/* Workaround for potential 82544 hang in PCI-X.  Avoid
 		 * terminating buffers within evenly-aligned dwords. */
-		if(adapter->pcix_82544 &&
+		if(unlikely(adapter->pcix_82544 &&
 		   !((unsigned long)(skb->data + offset + size - 1) & 4) &&
-		   size > 4)
+		   size > 4))
 			size -= 4;
 
 		buffer_info->length = size;
@@ -1613,7 +1606,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 		len -= size;
 		offset += size;
 		count++;
-		if(++i == tx_ring->count) i = 0;
+		if(unlikely(++i == tx_ring->count)) i = 0;
 	}
 
 	for(f = 0; f < nr_frags; f++) {
@@ -1629,15 +1622,15 @@ e1000_tx_map(struct e1000_adapter *adapt
 #ifdef NETIF_F_TSO
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if(mss && f == (nr_frags-1) && size == len && size > 8)
+			if(unlikely(mss && f == (nr_frags-1) && size == len && size > 8))
 				size -= 4;
 #endif
 			/* Workaround for potential 82544 hang in PCI-X.
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
-			if(adapter->pcix_82544 &&
+			if(unlikely(adapter->pcix_82544 &&
 			   !((unsigned long)(frag->page+offset+size-1) & 4) &&
-			   size > 4)
+			   size > 4))
 				size -= 4;
 
 			buffer_info->length = size;
@@ -1652,7 +1645,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 			len -= size;
 			offset += size;
 			count++;
-			if(++i == tx_ring->count) i = 0;
+			if(unlikely(++i == tx_ring->count)) i = 0;
 		}
 	}
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
@@ -1671,18 +1667,18 @@ e1000_tx_queue(struct e1000_adapter *ada
 	uint32_t txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
 	unsigned int i;
 
-	if(tx_flags & E1000_TX_FLAGS_TSO) {
+	if(likely(tx_flags & E1000_TX_FLAGS_TSO)) {
 		txd_lower |= E1000_TXD_CMD_DEXT | E1000_TXD_DTYP_D |
 		             E1000_TXD_CMD_TSE;
 		txd_upper |= (E1000_TXD_POPTS_IXSM | E1000_TXD_POPTS_TXSM) << 8;
 	}
 
-	if(tx_flags & E1000_TX_FLAGS_CSUM) {
+	if(likely(tx_flags & E1000_TX_FLAGS_CSUM)) {
 		txd_lower |= E1000_TXD_CMD_DEXT | E1000_TXD_DTYP_D;
 		txd_upper |= E1000_TXD_POPTS_TXSM << 8;
 	}
 
-	if(tx_flags & E1000_TX_FLAGS_VLAN) {
+	if(unlikely(tx_flags & E1000_TX_FLAGS_VLAN)) {
 		txd_lower |= E1000_TXD_CMD_VLE;
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
@@ -1696,7 +1692,7 @@ e1000_tx_queue(struct e1000_adapter *ada
 		tx_desc->lower.data =
 			cpu_to_le32(txd_lower | buffer_info->length);
 		tx_desc->upper.data = cpu_to_le32(txd_upper);
-		if(++i == tx_ring->count) i = 0;
+		if(unlikely(++i == tx_ring->count)) i = 0;
 	}
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
@@ -1765,7 +1751,8 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int f;
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	len -= skb->data_len;
-	if(skb->len <= 0) {
+
+	if(unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
@@ -1811,8 +1776,8 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	}
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
-	if(adapter->hw.mac_type == e1000_82547) {
-		if(e1000_82547_fifo_workaround(adapter, skb)) {
+	if(unlikely(adapter->hw.mac_type == e1000_82547)) {
+		if(unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
 			return 1;
@@ -1819,7 +1776,7 @@ 
 		}
 	}
 
-	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if(unlikely(adapter->vlgrp && vlan_tx_tag_present(skb))) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
 	}
@@ -1826,9 +1776,9 @@ 
 
 	first = adapter->tx_ring.next_to_use;
 	
-	if(e1000_tso(adapter, skb))
+	if(likely(e1000_tso(adapter, skb)))
 		tx_flags |= E1000_TX_FLAGS_TSO;
-	else if(e1000_tx_csum(adapter, skb))
+	else if(likely(e1000_tx_csum(adapter, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
 	e1000_tx_queue(adapter, 
@@ -2090,7 +2087,7 @@ e1000_irq_disable(struct e1000_adapter *
 static inline void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
-	if(atomic_dec_and_test(&adapter->irq_sem)) {
+	if(likely(atomic_dec_and_test(&adapter->irq_sem))) {
 		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
 		E1000_WRITE_FLUSH(&adapter->hw);
 	}
@@ -2109,21 +2106,21 @@ e1000_intr(int irq, void *data, struct p
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t icr = E1000_READ_REG(&adapter->hw, ICR);
+	uint32_t icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
 	unsigned int i;
 #endif
 
-	if(!icr)
+	if(unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
-	if(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+	if(unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
 		mod_timer(&adapter->watchdog_timer, jiffies);
 	}
 
 #ifdef CONFIG_E1000_NAPI
-	if(netif_rx_schedule_prep(netdev)) {
+	if(likely(netif_rx_schedule_prep(netdev))) {
 
 		/* Disable interrupts and register for poll. The flush 
 		  of the posted write is intentionally left out.
@@ -2135,8 +2132,8 @@ e1000_intr(int irq, void *data, struct p
 	}
 #else
 	for(i = 0; i < E1000_MAX_INTR; i++)
-		if(!e1000_clean_rx_irq(adapter) &
-		   !e1000_clean_tx_irq(adapter))
+		if(unlikely(!e1000_clean_rx_irq(adapter) &
+		   !e1000_clean_tx_irq(adapter)))
 			break;
 #endif
 
@@ -2202,8 +2184,8 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
-			if(buffer_info->dma) {
 
+			if(likely(buffer_info->dma)) {
 				pci_unmap_page(pdev,
 					       buffer_info->dma,
 					       buffer_info->length,
@@ -2224,7 +2221,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			tx_desc->upper.data = 0;
 
 			cleaned = (i == eop);
-			if(++i == tx_ring->count) i = 0;
+			if(unlikely(++i == tx_ring->count)) i = 0;
 		}
 		
 		eop = tx_ring->buffer_info[i].next_to_watch;
@@ -2235,7 +2232,8 @@ e1000_clean_tx_irq(struct e1000_adapter 
 
 	spin_lock(&adapter->tx_lock);
 
-	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
+	if(unlikely(cleaned && netif_queue_stopped(netdev) &&
+		    netif_carrier_ok(netdev)))
 		netif_wake_queue(netdev);
 
 	spin_unlock(&adapter->tx_lock);
@@ -2291,25 +2276,21 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rx_desc->length);
 
-		if(!(rx_desc->status & E1000_RXD_STAT_EOP)) {
 
+		if(unlikely(!(rx_desc->status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 
-			E1000_DBG("%s: Receive packet consumed multiple buffers\n",
-				netdev->name);
 
+			E1000_DBG("%s: Receive packet consumed multiple"
+				  " buffers\n", netdev->name);
 			dev_kfree_skb_irq(skb);
-			rx_desc->status = 0;
-			buffer_info->skb = NULL;
 
-			if(++i == rx_ring->count) i = 0;
 
-			rx_desc = E1000_RX_DESC(*rx_ring, i);
-			continue;
+			goto next_desc;
 		}
 
-		if(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK) {
 
+		if(unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
 			last_byte = *(skb->data + length - 1);
 
 			if(TBI_ACCEPT(&adapter->hw, rx_desc->status,
@@ -2327,13 +2276,9 @@ 
 			} else {
 
 				dev_kfree_skb_irq(skb);
-				rx_desc->status = 0;
-				buffer_info->skb = NULL;
 
-				if(++i == rx_ring->count) i = 0;
 
-				rx_desc = E1000_RX_DESC(*rx_ring, i);
-				continue;
+				goto next_desc;
 			}
 		}
 
@@ -2345,7 +2317,8 @@ e1000_clean_rx_irq(struct e1000_adapter 
 
 		skb->protocol = eth_type_trans(skb, netdev);
 #ifdef CONFIG_E1000_NAPI
-		if(adapter->vlgrp && (rx_desc->status & E1000_RXD_STAT_VP)) {
+		if(unlikely(adapter->vlgrp &&
+			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special &
 					E1000_RXD_SPC_VLAN_MASK));
@@ -2353,7 +2317,8 @@ 
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_E1000_NAPI */
-		if(adapter->vlgrp && (rx_desc->status & E1000_RXD_STAT_VP)) {
+		if(unlikely(adapter->vlgrp &&
+			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->special &
 					E1000_RXD_SPC_VLAN_MASK));
@@ -2363,10 +2335,10 @@ e1000_clean_rx_irq(struct e1000_adapter 
 #endif /* CONFIG_E1000_NAPI */
 		netdev->last_rx = jiffies;
 
+next_desc:
 		rx_desc->status = 0;
 		buffer_info->skb = NULL;
-
-		if(++i == rx_ring->count) i = 0;
+		if(unlikely(++i == rx_ring->count)) i = 0;
 
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 	}
@@ -2399,8 +2371,6 @@ e1000_alloc_rx_buffers(struct e1000_adap
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-		rx_desc = E1000_RX_DESC(*rx_ring, i);
-
 		skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
 
 		if(!skb) {
@@ -2424,9 +2390,10 @@ e1000_alloc_rx_buffers(struct e1000_adap
 			               adapter->rx_buffer_len,
 			               PCI_DMA_FROMDEVICE);
 
+		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
-		if((i & ~(E1000_RX_BUFFER_WRITE - 1)) == i) {
+		if(unlikely((i & ~(E1000_RX_BUFFER_WRITE - 1)) == i)) {
 			/* Force memory writes to complete before letting h/w
 			 * know there are new descriptors to fetch.  (Only
 			 * applicable for weak-ordered memory model archs,
@@ -2436,7 +2427,7 @@ e1000_alloc_rx_buffers(struct e1000_adap
 			E1000_WRITE_REG(&adapter->hw, RDT, i);
 		}
 
-		if(++i == rx_ring->count) i = 0;
+		if(unlikely(++i == rx_ring->count)) i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
@@ -2625,11 +2616,11 @@ e1000_rx_checksum(struct e1000_adapter *
                   struct sk_buff *skb)
 {
 	/* 82543 or newer only */
-	if((adapter->hw.mac_type < e1000_82543) ||
+	if(unlikely((adapter->hw.mac_type < e1000_82543) ||
 	/* Ignore Checksum bit is set */
 	(rx_desc->status & E1000_RXD_STAT_IXSM) ||
 	/* TCP Checksum has not been calculated */
-	(!(rx_desc->status & E1000_RXD_STAT_TCPCS))) {
+	(!(rx_desc->status & E1000_RXD_STAT_TCPCS)))) {
 		skb->ip_summed = CHECKSUM_NONE;
 		return;
 	}
@@ -2652,7 +2643,8 @@ e1000_pci_set_mwi(struct e1000_hw *hw)
 {
 	struct e1000_adapter *adapter = hw->back;
 
-	pci_set_mwi(adapter->pdev);
+	int ret;
+	ret = pci_set_mwi(adapter->pdev);
 }
 
 void
