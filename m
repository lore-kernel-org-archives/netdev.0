From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x e1000, ixgb fixes
Date: Fri, 25 Feb 2005 14:30:47 -0500
Message-ID: <421F7CE7.4060507@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050504090709060508080307"
Cc: Netdev <netdev@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050504090709060508080307
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

See attached.

--------------050504090709060508080307
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/e1000/e1000.h         |    3 
 drivers/net/e1000/e1000_ethtool.c |   11 -
 drivers/net/e1000/e1000_hw.c      |   86 ++++++-------
 drivers/net/e1000/e1000_hw.h      |   11 +
 drivers/net/e1000/e1000_main.c    |  249 ++++++++++++++++++++++++++++++++++----
 drivers/net/ixgb/ixgb.h           |    3 
 drivers/net/ixgb/ixgb_ee.c        |   16 +-
 drivers/net/ixgb/ixgb_ee.h        |    3 
 drivers/net/ixgb/ixgb_ethtool.c   |    5 
 drivers/net/ixgb/ixgb_hw.c        |    2 
 drivers/net/ixgb/ixgb_hw.h        |    2 
 drivers/net/ixgb/ixgb_ids.h       |    2 
 drivers/net/ixgb/ixgb_main.c      |   73 ++++++-----
 drivers/net/ixgb/ixgb_osdep.h     |    2 
 drivers/net/ixgb/ixgb_param.c     |    2 
 15 files changed, 354 insertions(+), 116 deletions(-)

through these ChangeSets:

<mallikarjuna.chilakala:intel.com>:
  o e1000: Driver version white space,
  o e1000: Fixes related to Cable length
  o e1000: Report failure code when loopback
  o e1000: Checks for desc ring/rx data
  o e1000: Patch from Peter Kjellstroem --
  o e1000: Fix WOL settings in 82544 based
  o e1000: Delay clean-up of last Tx buffer
  o e1000: Avoid race between e1000_watchdog
  o e1000: use netif_poll_{enable|disable}
  o e1000: Robert Olsson's fix and refinement
  o ixgb: Driver version, white space, other stuff
  o ixgb: Invalidate software cache, when EEPROM write occurs
  o ixgb: Robert Olsson's fix and refinement to poll
  o ixgb: Avoid race e1000_watchdog and ixgb_clean_tx_irq
  o ixgb: use netif_poll_{enable|disable}


--------------050504090709060508080307
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/e1000/e1000.h	2005-02-25 14:29:12 -05:00
@@ -138,6 +138,7 @@
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
 #define AUTO_ALL_MODES       0
+#define E1000_EEPROM_82544_APM 0x0004
 #define E1000_EEPROM_APME    0x0400
 
 #ifndef E1000_MASTER_SLAVE
@@ -209,6 +210,7 @@
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
+	struct e1000_buffer previous_buffer_info;
 	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
@@ -222,6 +224,7 @@
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
 	boolean_t pcix_82544;
+	boolean_t detect_tx_hung;
 
 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/e1000/e1000_ethtool.c	2005-02-25 14:29:12 -05:00
@@ -1310,7 +1310,7 @@
 	struct e1000_desc_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-	int i;
+	int i, ret_val;
 
 	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
 
@@ -1330,11 +1330,12 @@
 					    rxdr->buffer_info[i].length,
 					    PCI_DMA_FROMDEVICE);
 
-		if (!e1000_check_lbtest_frame(rxdr->buffer_info[i++].skb, 1024))
-			return 0;
-	} while (i < 64);
+		ret_val = e1000_check_lbtest_frame(rxdr->buffer_info[i].skb,
+						   1024);
+		i++;
+	} while (ret_val != 0 && i < 64);
 
-	return 13;
+	return ret_val;
 }
 
 static int
diff -Nru a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
--- a/drivers/net/e1000/e1000_hw.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/e1000/e1000_hw.c	2005-02-25 14:29:12 -05:00
@@ -1572,7 +1572,8 @@
             if(mii_status_reg & MII_SR_LINK_STATUS) break;
             msec_delay(100);
         }
-        if((i == 0) && (hw->phy_type == e1000_phy_m88)) {
+        if((i == 0) &&
+           (hw->phy_type == e1000_phy_m88)) {
             /* We didn't get link.  Reset the DSP and wait again for link. */
             ret_val = e1000_phy_reset_dsp(hw);
             if(ret_val) {
@@ -2503,7 +2504,7 @@
         }
     }
 
-    ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                     phy_data);
 
     return ret_val;
@@ -2609,7 +2610,7 @@
         }
     }
 
-    ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                      phy_data);
 
     return ret_val;
@@ -2955,8 +2956,7 @@
     /* Check polarity status */
     ret_val = e1000_check_polarity(hw, &polarity);
     if(ret_val)
-        return ret_val;
-
+        return ret_val; 
     phy_info->cable_polarity = polarity;
 
     ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
@@ -2966,9 +2966,9 @@
     phy_info->mdix_mode = (phy_data & M88E1000_PSSR_MDIX) >>
                           M88E1000_PSSR_MDIX_SHIFT;
 
-    if(phy_data & M88E1000_PSSR_1000MBS) {
-        /* Cable Length Estimation and Local/Remote Receiver Informatoion
-         * are only valid at 1000 Mbps
+    if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
+        /* Cable Length Estimation and Local/Remote Receiver Information
+         * are only valid at 1000 Mbps.
          */
         phy_info->cable_length = ((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
                                   M88E1000_PSSR_CABLE_LENGTH_SHIFT);
@@ -4639,41 +4639,44 @@
 {
     uint32_t status;
 
-    if(hw->mac_type < e1000_82543) {
+    switch (hw->mac_type) {
+    case e1000_82542_rev2_0:
+    case e1000_82542_rev2_1:
         hw->bus_type = e1000_bus_type_unknown;
         hw->bus_speed = e1000_bus_speed_unknown;
         hw->bus_width = e1000_bus_width_unknown;
-        return;
-    }
-
-    status = E1000_READ_REG(hw, STATUS);
-    hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
-                   e1000_bus_type_pcix : e1000_bus_type_pci;
+        break;
+    default:
+        status = E1000_READ_REG(hw, STATUS);
+        hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
+                       e1000_bus_type_pcix : e1000_bus_type_pci;
 
-    if(hw->device_id == E1000_DEV_ID_82546EB_QUAD_COPPER) {
-        hw->bus_speed = (hw->bus_type == e1000_bus_type_pci) ?
-                        e1000_bus_speed_66 : e1000_bus_speed_120;
-    } else if(hw->bus_type == e1000_bus_type_pci) {
-        hw->bus_speed = (status & E1000_STATUS_PCI66) ?
-                        e1000_bus_speed_66 : e1000_bus_speed_33;
-    } else {
-        switch (status & E1000_STATUS_PCIX_SPEED) {
-        case E1000_STATUS_PCIX_SPEED_66:
-            hw->bus_speed = e1000_bus_speed_66;
-            break;
-        case E1000_STATUS_PCIX_SPEED_100:
-            hw->bus_speed = e1000_bus_speed_100;
-            break;
-        case E1000_STATUS_PCIX_SPEED_133:
-            hw->bus_speed = e1000_bus_speed_133;
-            break;
-        default:
-            hw->bus_speed = e1000_bus_speed_reserved;
-            break;
+        if(hw->device_id == E1000_DEV_ID_82546EB_QUAD_COPPER) {
+            hw->bus_speed = (hw->bus_type == e1000_bus_type_pci) ?
+                            e1000_bus_speed_66 : e1000_bus_speed_120;
+        } else if(hw->bus_type == e1000_bus_type_pci) {
+            hw->bus_speed = (status & E1000_STATUS_PCI66) ?
+                            e1000_bus_speed_66 : e1000_bus_speed_33;
+        } else {
+            switch (status & E1000_STATUS_PCIX_SPEED) {
+            case E1000_STATUS_PCIX_SPEED_66:
+                hw->bus_speed = e1000_bus_speed_66;
+                break;
+            case E1000_STATUS_PCIX_SPEED_100:
+                hw->bus_speed = e1000_bus_speed_100;
+                break;
+            case E1000_STATUS_PCIX_SPEED_133:
+                hw->bus_speed = e1000_bus_speed_133;
+                break;
+            default:
+                hw->bus_speed = e1000_bus_speed_reserved;
+                break;
+            }
         }
+        hw->bus_width = (status & E1000_STATUS_BUS64) ?
+                        e1000_bus_width_64 : e1000_bus_width_32;
+        break;
     }
-    hw->bus_width = (status & E1000_STATUS_BUS64) ?
-                    e1000_bus_width_64 : e1000_bus_width_32;
 }
 /******************************************************************************
  * Reads a value from one of the devices registers using port I/O (as opposed
@@ -4738,6 +4741,7 @@
     uint16_t agc_value = 0;
     uint16_t cur_agc, min_agc = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
     uint16_t i, phy_data;
+    uint16_t cable_length;
 
     DEBUGFUNC("e1000_get_cable_length");
 
@@ -4749,10 +4753,11 @@
                                      &phy_data);
         if(ret_val)
             return ret_val;
+        cable_length = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
+                       M88E1000_PSSR_CABLE_LENGTH_SHIFT;
 
         /* Convert the enum value to ranged values */
-        switch((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
-               M88E1000_PSSR_CABLE_LENGTH_SHIFT) {
+        switch (cable_length) {
         case e1000_cable_length_50:
             *min_length = 0;
             *max_length = e1000_igp_cable_length_50;
@@ -4919,8 +4924,7 @@
             return ret_val;
 
         hw->speed_downgraded = (phy_data & IGP01E1000_PLHR_SS_DOWNGRADE) ? 1 : 0;
-    }
-    else if(hw->phy_type == e1000_phy_m88) {
+    } else if(hw->phy_type == e1000_phy_m88) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
                                      &phy_data);
         if(ret_val)
diff -Nru a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
--- a/drivers/net/e1000/e1000_hw.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/e1000/e1000_hw.h	2005-02-25 14:29:12 -05:00
@@ -369,6 +369,7 @@
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
 #define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
+
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
 
@@ -1734,6 +1735,9 @@
 #define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
 #define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
 
+#define MAX_PHY_REG_ADDRESS        0x1F  /* 5 bit address bus (0-0x1F) */
+#define MAX_PHY_MULTI_PAGE_REG     0xF   /* Registers equal on all pages */
+
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
 #define M88E1000_PHY_SPEC_STATUS   0x11  /* PHY Specific Status Register */
@@ -1794,8 +1798,7 @@
 
 #define IGP01E1000_ANALOG_REGS_PAGE  0x20C0
 
-#define MAX_PHY_REG_ADDRESS 0x1F        /* 5 bit address bus (0-0x1F) */
-#define MAX_PHY_MULTI_PAGE_REG  0xF     /*Registers that are equal on all pages*/
+
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
 #define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
@@ -2098,7 +2101,11 @@
 #define IGP01E1000_ANALOG_FUSE_FINE_1               0x0080
 #define IGP01E1000_ANALOG_FUSE_FINE_10              0x0500
 
+
 /* Bit definitions for valid PHY IDs. */
+/* I = Integrated
+ * E = External
+ */
 #define M88E1000_E_PHY_ID  0x01410C50
 #define M88E1000_I_PHY_ID  0x01410C30
 #define M88E1011_I_PHY_ID  0x01410C20
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/e1000/e1000_main.c	2005-02-25 14:29:12 -05:00
@@ -35,6 +35,14 @@
  * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
  * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
  *
+ * 5.7.1	12/16/04
+ * - Resurrect 82547EI/GI related fix in e1000_intr to avoid deadlocks. This
+ *   fix was removed as it caused system instability. The suspected cause of 
+ *   this is the called to e1000_irq_disable in e1000_intr. Inlined the 
+ *   required piece of e1000_irq_disable into e1000_intr - Anton Blanchard
+ * 5.7.0	12/10/04
+ * - include fix to the condition that determines when to quit NAPI - Robert Olsson
+ * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
  * 5.6.5 	11/01/04
  * - Enabling NETIF_F_SG without checksum offload is illegal - 
      John Mason <jdmason@us.ibm.com>
@@ -57,7 +65,7 @@
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.6.10.1-k2"DRIVERNAPI;
+char e1000_driver_version[] = "5.7.6-k2"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -81,6 +89,7 @@
 	INTEL_E1000_ETHERNET_DEVICE(0x1011),
 	INTEL_E1000_ETHERNET_DEVICE(0x1012),
 	INTEL_E1000_ETHERNET_DEVICE(0x1013),
+	INTEL_E1000_ETHERNET_DEVICE(0x1014),
 	INTEL_E1000_ETHERNET_DEVICE(0x1015),
 	INTEL_E1000_ETHERNET_DEVICE(0x1016),
 	INTEL_E1000_ETHERNET_DEVICE(0x1017),
@@ -308,6 +317,9 @@
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	e1000_irq_enable(adapter);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
 	return 0;
 }
 
@@ -321,6 +333,10 @@
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
+
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_disable(netdev);
+#endif
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
@@ -414,6 +430,7 @@
 	int i;
 	int err;
 	uint16_t eeprom_data;
+	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
 
 	if((err = pci_enable_device(pdev)))
 		return err;
@@ -510,9 +527,6 @@
 	}
 
 #ifdef NETIF_F_TSO
-	/* Disbaled for now until root-cause is found for
-	 * hangs reported against non-IA archs.  TSO can be
-	 * enabled using ethtool -K eth<x> tso on */
 	if((adapter->hw.mac_type >= e1000_82544) &&
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
@@ -584,6 +598,11 @@
 	case e1000_82542_rev2_1:
 	case e1000_82543:
 		break;
+	case e1000_82544:
+		e1000_read_eeprom(&adapter->hw,
+			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
+		eeprom_apme_mask = E1000_EEPROM_82544_APM;
+		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 		if((E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
@@ -598,7 +617,7 @@
 			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
-	if(eeprom_data & E1000_EEPROM_APME)
+	if(eeprom_data & eeprom_apme_mask)
 		adapter->wol |= E1000_WUFC_MAG;
 
 	/* reset the hardware with the new settings */
@@ -807,6 +826,31 @@
 }
 
 /**
+ * e1000_check_64k_bound - check that memory doesn't cross 64kB boundary
+ * @adapter: address of board private structure
+ * @begin: address of beginning of memory
+ * @end: address of end of memory
+ **/
+static inline boolean_t
+e1000_check_64k_bound(struct e1000_adapter *adapter,
+		      void *start, unsigned long len)
+{
+	unsigned long begin = (unsigned long) start;
+	unsigned long end = begin + len;
+
+	/* first rev 82545 and 82546 need to not allow any memory
+	 * write location to cross a 64k boundary due to errata 23 */
+	if (adapter->hw.mac_type == e1000_82545 ||
+	    adapter->hw.mac_type == e1000_82546 ) {
+
+		/* check buffer doesn't cross 64kB */
+		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
+	}
+
+	return TRUE;
+}
+
+/**
  * e1000_setup_tx_resources - allocate Tx resources (Descriptors)
  * @adapter: board private structure
  *
@@ -824,7 +868,7 @@
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
 		DPRINTK(PROBE, ERR, 
-		"Unble to Allocate Memory for the Transmit descriptor ring\n");
+		"Unable to Allocate Memory for the Transmit descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -836,11 +880,42 @@
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
+setup_tx_desc_die:
 		DPRINTK(PROBE, ERR, 
-		"Unble to Allocate Memory for the Transmit descriptor ring\n");
+		"Unable to Allocate Memory for the Transmit descriptor ring\n");
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
+
+	/* fix for errata 23, cant cross 64kB boundary */
+	if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
+		void *olddesc = txdr->desc;
+		dma_addr_t olddma = txdr->dma;
+		DPRINTK(TX_ERR,ERR,"txdr align check failed: %u bytes at %p\n",
+		        txdr->size, txdr->desc);
+		/* try again, without freeing the previous */
+		txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+		/* failed allocation, critial failure */
+		if(!txdr->desc) {
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			goto setup_tx_desc_die;
+		}
+
+		if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
+			/* give up */
+			pci_free_consistent(pdev, txdr->size,
+			     txdr->desc, txdr->dma);
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			DPRINTK(PROBE, ERR,
+			 "Unable to Allocate aligned Memory for the Transmit"
+		         " descriptor ring\n");
+			vfree(txdr->buffer_info);
+			return -ENOMEM;
+		} else {
+			/* free old, move on with the new one since its okay */
+			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+		}
+	}
 	memset(txdr->desc, 0, txdr->size);
 
 	txdr->next_to_use = 0;
@@ -945,7 +1020,7 @@
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
 		DPRINTK(PROBE, ERR, 
-		"Unble to Allocate Memory for the Recieve descriptor ring\n");
+		"Unable to Allocate Memory for the Recieve descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -958,11 +1033,43 @@
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if(!rxdr->desc) {
+setup_rx_desc_die:
 		DPRINTK(PROBE, ERR, 
 		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
+
+	/* fix for errata 23, cant cross 64kB boundary */
+	if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
+		void *olddesc = rxdr->desc;
+		dma_addr_t olddma = rxdr->dma;
+		DPRINTK(RX_ERR,ERR,
+			"rxdr align check failed: %u bytes at %p\n",
+			rxdr->size, rxdr->desc);
+		/* try again, without freeing the previous */
+		rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+		/* failed allocation, critial failure */
+		if(!rxdr->desc) {
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			goto setup_rx_desc_die;
+		}
+
+		if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
+			/* give up */
+			pci_free_consistent(pdev, rxdr->size,
+			     rxdr->desc, rxdr->dma);
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			DPRINTK(PROBE, ERR, 
+				"Unable to Allocate aligned Memory for the"
+				" Receive descriptor ring\n");
+			vfree(rxdr->buffer_info);
+			return -ENOMEM;
+		} else {
+			/* free old, move on with the new one since its okay */
+			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+		}
+	}
 	memset(rxdr->desc, 0, rxdr->size);
 
 	rxdr->next_to_clean = 0;
@@ -1096,6 +1203,7 @@
 			struct e1000_buffer *buffer_info)
 {
 	struct pci_dev *pdev = adapter->pdev;
+
 	if(buffer_info->dma) {
 		pci_unmap_page(pdev,
 			       buffer_info->dma,
@@ -1124,6 +1232,11 @@
 
 	/* Free all the Tx ring sk_buffs */
 
+	if (likely(adapter->previous_buffer_info.skb != NULL)) {
+		e1000_unmap_and_free_tx_resource(adapter, 
+				&adapter->previous_buffer_info);
+	}
+
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -1425,7 +1538,6 @@
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
-	unsigned int i;
 	uint32_t link;
 
 	e1000_check_for_link(&adapter->hw);
@@ -1505,12 +1617,8 @@
 	/* Cause software interrupt to ensure rx ring is cleaned */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
 
-	/* Early detection of hung controller */
-	i = txdr->next_to_clean;
-	if(txdr->buffer_info[i].dma &&
-	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
-		netif_stop_queue(netdev);
+	/* Force detection of hung controller every watchdog period*/
+	adapter->detect_tx_hung = TRUE;
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -2151,10 +2259,28 @@
 		__netif_rx_schedule(netdev);
 	}
 #else
+	/* Writing IMC and IMS is needed for 82547.
+	   Due to Hub Link bus being occupied, an interrupt
+	   de-assertion message is not able to be sent.
+	   When an interrupt assertion message is generated later,
+	   two messages are re-ordered and sent out.
+	   That causes APIC to think 82547 is in de-assertion
+	   state, while 82547 is in assertion state, resulting
+	   in dead lock. Writing IMC forces 82547 into
+	   de-assertion state.
+	*/
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2){
+		atomic_inc(&adapter->irq_sem);
+		E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+	}
+
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(unlikely(!e1000_clean_rx_irq(adapter) &
 		   !e1000_clean_tx_irq(adapter)))
 			break;
+
+	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+		e1000_irq_enable(adapter);
 #endif
 
 	return IRQ_HANDLED;
@@ -2174,24 +2300,21 @@
 	int tx_cleaned;
 	int work_done = 0;
 	
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
-
 	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) || 
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
 				!netif_running(netdev)) {
-quit_polling:	netif_rx_complete(netdev);
+		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 
 #endif
@@ -2215,11 +2338,34 @@
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
 	while(eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
+		/* pre-mature writeback of Tx descriptors     */
+		/* clear (free buffers and unmap pci_mapping) */
+		/* previous_buffer_info                       */
+		if (likely(adapter->previous_buffer_info.skb != NULL)) {
+			e1000_unmap_and_free_tx_resource(adapter, 
+					&adapter->previous_buffer_info);
+		}
+
 		for(cleaned = FALSE; !cleaned; ) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
+			cleaned = (i == eop);
+
+			/* pre-mature writeback of Tx descriptors */
+			/* save the cleaning of the this for the  */
+			/* next iteration                         */
+			if (cleaned) {
+				memcpy(&adapter->previous_buffer_info,
+					buffer_info,
+					sizeof(struct e1000_buffer));
+				memset(buffer_info,
+					0,
+					sizeof(struct e1000_buffer));
+			} else {
+				e1000_unmap_and_free_tx_resource(adapter, 
+							buffer_info);
+			}
 
-			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->buffer_addr = 0;
 			tx_desc->lower.data = 0;
 			tx_desc->upper.data = 0;
@@ -2241,6 +2387,16 @@
 		netif_wake_queue(netdev);
 
 	spin_unlock(&adapter->tx_lock);
+ 
+	if(adapter->detect_tx_hung) {
+		/* detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
+		adapter->detect_tx_hung = FALSE;
+		if(tx_ring->buffer_info[i].dma &&
+		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ) &&
+		   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
+			netif_stop_queue(netdev);
+	}
 
 	return cleaned;
 }
@@ -2407,19 +2563,43 @@
 	struct e1000_rx_desc *rx_desc;
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
-	unsigned int i;
+	unsigned int i, bufsz;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		bufsz = adapter->rx_buffer_len + NET_IP_ALIGN;
 
+		skb = dev_alloc_skb(bufsz);
 		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
 
+		/* fix for errata 23, cant cross 64kB boundary */
+		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+			struct sk_buff *oldskb = skb;
+			DPRINTK(RX_ERR,ERR,
+				"skb align check failed: %u bytes at %p\n",
+				bufsz, skb->data);
+			/* try again, without freeing the previous */
+			skb = dev_alloc_skb(bufsz);
+			if (!skb) {
+				dev_kfree_skb(oldskb);
+				break;
+			}
+			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+				/* give up */
+				dev_kfree_skb(skb);
+				dev_kfree_skb(oldskb);
+				break; /* while !buffer_info->skb */
+			} else {
+				/* move on with the new one */
+				dev_kfree_skb(oldskb);
+			}
+		}
+
 		/* Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
@@ -2434,6 +2614,25 @@
 						  skb->data,
 						  adapter->rx_buffer_len,
 						  PCI_DMA_FROMDEVICE);
+
+		/* fix for errata 23, cant cross 64kB boundary */
+		if(!e1000_check_64k_bound(adapter,
+			                       (void *)(unsigned long)buffer_info->dma,
+			                       adapter->rx_buffer_len)) {
+			DPRINTK(RX_ERR,ERR,
+				"dma align check failed: %u bytes at %ld\n",
+				adapter->rx_buffer_len, (unsigned long)buffer_info->dma);
+
+			dev_kfree_skb(skb);
+			buffer_info->skb = NULL;
+
+			pci_unmap_single(pdev,
+					 buffer_info->dma,
+					 adapter->rx_buffer_len,
+					 PCI_DMA_FROMDEVICE);
+
+			break; /* while !buffer_info->skb */
+		}
 
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
diff -Nru a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
--- a/drivers/net/ixgb/ixgb.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb.h	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -176,6 +176,7 @@
 	uint64_t hw_csum_tx_error;
 	uint32_t tx_int_delay;
 	boolean_t tx_int_delay_enable;
+	boolean_t detect_tx_hung;
 
 	/* RX */
 	struct ixgb_desc_ring rx_ring;
diff -Nru a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
--- a/drivers/net/ixgb/ixgb_ee.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ee.c	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -372,11 +372,11 @@
  *
  *****************************************************************************/
 void
-ixgb_write_eeprom(struct ixgb_hw *hw,
-		   uint16_t offset,
-		   uint16_t data)
+ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
 {
-	/*  Prepare the EEPROM for writing  */
+	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
+
+	/* Prepare the EEPROM for writing */
 	ixgb_setup_eeprom(hw);
 
 	/*  Send the 9-bit EWEN (write enable) command to the EEPROM (5-bit opcode
@@ -410,6 +410,9 @@
 	/*  Done with writing  */
 	ixgb_cleanup_eeprom(hw);
 
+	/* clear the init_ctrl_reg_1 to signify that the cache is invalidated */
+	ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
+
 	return;
 }
 
@@ -478,6 +481,9 @@
 
 	if (checksum != (uint16_t) EEPROM_SUM) {
 		DEBUGOUT("ixgb_ee: Checksum invalid.\n");
+		/* clear the init_ctrl_reg_1 to signify that the cache is
+		 * invalidated */
+		ee_map->init_ctrl_reg_1 = EEPROM_ICW1_SIGNATURE_CLEAR;
 		return (FALSE);
 	}
 
diff -Nru a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
--- a/drivers/net/ixgb/ixgb_ee.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ee.h	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -63,6 +63,7 @@
 
 #define EEPROM_ICW1_SIGNATURE_MASK  0xC000
 #define EEPROM_ICW1_SIGNATURE_VALID 0x4000
+#define EEPROM_ICW1_SIGNATURE_CLEAR 0x0000
 
 /* For checksumming, the sum of all words in the EEPROM should equal 0xBABA. */
 #define EEPROM_SUM 0xBABA
diff -Nru a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
--- a/drivers/net/ixgb/ixgb_ethtool.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ethtool.c	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -63,6 +63,7 @@
 	{"tx_dropped", IXGB_STAT(net_stats.tx_dropped)},
 	{"multicast", IXGB_STAT(net_stats.multicast)},
 	{"collisions", IXGB_STAT(net_stats.collisions)},
+
 /*	{ "rx_length_errors", IXGB_STAT(net_stats.rx_length_errors) },	*/
 	{"rx_over_errors", IXGB_STAT(net_stats.rx_over_errors)},
 	{"rx_crc_errors", IXGB_STAT(net_stats.rx_crc_errors)},
@@ -98,6 +99,7 @@
 ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
+
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->port = PORT_FIBRE;
@@ -119,6 +121,7 @@
 ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
+
 	if(ecmd->autoneg == AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
diff -Nru a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
--- a/drivers/net/ixgb/ixgb_hw.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_hw.c	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Nru a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
--- a/drivers/net/ixgb/ixgb_hw.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_hw.h	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Nru a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
--- a/drivers/net/ixgb/ixgb_ids.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_ids.h	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_main.c	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -29,6 +29,9 @@
 #include "ixgb.h"
 
 /* Change Log
+ * 1.0.88 01/05/05
+ * - include fix to the condition that determines when to quit NAPI - Robert Olsson
+ * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
  * 1.0.84 10/26/04
  * - reset buffer_info->dma in Tx resource cleanup logic
  * 1.0.83 10/12/04
@@ -38,13 +41,14 @@
 
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
+
 #ifndef CONFIG_IXGB_NAPI
 #define DRIVERNAPI
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char ixgb_driver_version[] = "1.0.87-k2"DRIVERNAPI;
-char ixgb_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
+char ixgb_driver_version[] = "1.0.90-k2"DRIVERNAPI;
+char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -292,6 +296,9 @@
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	ixgb_irq_enable(adapter);
 
+#ifdef CONFIG_IXGB_NAPI
+	netif_poll_enable(netdev);
+#endif
 	return 0;
 }
 
@@ -309,6 +316,9 @@
 #endif
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
+#ifdef CONFIG_IXGB_NAPI
+	netif_poll_disable(netdev);
+#endif
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
@@ -709,14 +719,8 @@
 	IXGB_WRITE_REG(hw, TDH, 0);
 	IXGB_WRITE_REG(hw, TDT, 0);
 
-	/* don't set up txdctl, it induces performance problems if
-	 * configured incorrectly
-	 txdctl  = TXDCTL_PTHRESH_DEFAULT; // prefetch txds below this threshold
-	 txdctl |= (TXDCTL_HTHRESH_DEFAULT // only prefetch if there are this many ready
-	 << IXGB_TXDCTL_HTHRESH_SHIFT);
-	 IXGB_WRITE_REG (hw, TXDCTL, txdctl);
-	 */
-
+	/* don't set up txdctl, it induces performance problems if configured
+	 * incorrectly */
 	/* Set the Tx Interrupt Delay register */
 
 	IXGB_WRITE_REG(hw, TIDV, adapter->tx_int_delay);
@@ -849,10 +853,17 @@
 	IXGB_WRITE_REG(hw, RDH, 0);
 	IXGB_WRITE_REG(hw, RDT, 0);
 
-						/* burst 16 or burst when RXT0*/
-	rxdctl =  RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT 
-			| RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT 
-			| RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
+	/* set up pre-fetching of receive buffers so we get some before we
+	 * run out (default hardware behavior is to run out before fetching
+	 * more).  This sets up to fetch if HTHRESH rx descriptors are avail
+	 * and the descriptors in hw cache are below PTHRESH.  This avoids
+	 * the hardware behavior of fetching <=512 descriptors in a single
+	 * burst that pre-empts all other activity, usually causing fifo
+	 * overflows. */
+	/* use WTHRESH to burst write 16 descriptors or burst when RXT0 */
+	rxdctl = RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT |
+	         RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT |
+	         RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
@@ -1094,7 +1105,6 @@
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
-	unsigned int i;
 
 	ixgb_check_for_link(&adapter->hw);
 
@@ -1137,12 +1147,8 @@
 		}
 	}
 
-	/* Early detection of hung controller */
-	i = txdr->next_to_clean;
-	if(txdr->buffer_info[i].dma &&
-	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	   !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
-		netif_stop_queue(netdev);
+	/* Force detection of hung controller every watchdog period */
+	adapter->detect_tx_hung = TRUE;
 
 	/* generate an interrupt to force clean up of any stragglers */
 	IXGB_WRITE_REG(&adapter->hw, ICS, IXGB_INT_TXDW);
@@ -1668,20 +1674,16 @@
 	int work_to_do = min(*budget, netdev->quota);
 	int tx_cleaned;
 	int work_done = 0;
-	
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
 
 	tx_cleaned = ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
-	
-	/* if no Tx cleanup and not enough Rx work done, exit the polling mode */
-	if((!tx_cleaned && (work_done < work_to_do)) || 
-				!netif_running(netdev)) {
-quit_polling:	netif_rx_complete(netdev);
+
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+		netif_rx_complete(netdev);
 		ixgb_irq_enable(adapter);
 		return 0;
 	}
@@ -1741,6 +1743,17 @@
 		netif_wake_queue(netdev);
 	}
 	spin_unlock(&adapter->tx_lock);
+
+	if(adapter->detect_tx_hung) {
+		/* detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
+		adapter->detect_tx_hung = FALSE;
+		if(tx_ring->buffer_info[i].dma &&
+		   time_after(jiffies, tx_ring->buffer_info[i].time_stamp + HZ)
+		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
+			IXGB_STATUS_TXOFF))
+			netif_stop_queue(netdev);
+	}
 
 	return cleaned;
 }
diff -Nru a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
--- a/drivers/net/ixgb/ixgb_osdep.h	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_osdep.h	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Nru a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
--- a/drivers/net/ixgb/ixgb_param.c	2005-02-25 14:29:12 -05:00
+++ b/drivers/net/ixgb/ixgb_param.c	2005-02-25 14:29:12 -05:00
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 

--------------050504090709060508080307--
