From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.4.x net driver updates
Date: Thu, 03 Mar 2005 19:33:49 -0500
Message-ID: <4227ACED.4090006@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020202080705050805050400"
Cc: Netdev <netdev@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020202080705050805050400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020202080705050805050400
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.4

This will update the following files:

 drivers/net/e1000/e1000.h         |    3 
 drivers/net/e1000/e1000_ethtool.c |   11 -
 drivers/net/e1000/e1000_hw.c      |   86 ++++++-------
 drivers/net/e1000/e1000_hw.h      |   12 +
 drivers/net/e1000/e1000_main.c    |  251 ++++++++++++++++++++++++++++++++++----
 drivers/net/tulip/21142.c         |    2 
 drivers/net/tulip/eeprom.c        |    1 
 drivers/net/tulip/interrupt.c     |    2 
 drivers/net/tulip/media.c         |    1 
 drivers/net/tulip/pnic.c          |    1 
 drivers/net/tulip/pnic2.c         |    2 
 drivers/net/tulip/timer.c         |    1 
 drivers/net/tulip/tulip.h         |   15 ++
 drivers/net/tulip/tulip_core.c    |    2 
 14 files changed, 312 insertions(+), 78 deletions(-)

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
  o e1000: 2 use netif_poll_{enable|disable}
  o e1000: 1 Robert Olsson's fix and

John W. Linville:
  o tulip: make tulip_stop_rxtx() wait for DMA to fully stop


--------------020202080705050805050400
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/e1000/e1000.h	2005-03-03 19:33:21 -05:00
@@ -140,6 +140,7 @@
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
 #define AUTO_ALL_MODES       0
+#define E1000_EEPROM_82544_APM 0x0004
 #define E1000_EEPROM_APME    0x0400
 
 #ifndef E1000_MASTER_SLAVE
@@ -211,6 +212,7 @@
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
+	struct e1000_buffer previous_buffer_info;
 	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
@@ -224,6 +226,7 @@
 	uint32_t tx_fifo_size;
 	atomic_t tx_fifo_stall;
 	boolean_t pcix_82544;
+	boolean_t detect_tx_hung;
 
 	/* RX */
 	struct e1000_desc_ring rx_ring;
diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/e1000/e1000_ethtool.c	2005-03-03 19:33:21 -05:00
@@ -1309,7 +1309,7 @@
 	struct e1000_desc_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-	int i;
+	int i, ret_val;
 
 	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
 
@@ -1329,11 +1329,12 @@
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
--- a/drivers/net/e1000/e1000_hw.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/e1000/e1000_hw.c	2005-03-03 19:33:21 -05:00
@@ -1573,7 +1573,8 @@
             if(mii_status_reg & MII_SR_LINK_STATUS) break;
             msec_delay(100);
         }
-        if((i == 0) && (hw->phy_type == e1000_phy_m88)) {
+        if((i == 0) &&
+           (hw->phy_type == e1000_phy_m88)) {
             /* We didn't get link.  Reset the DSP and wait again for link. */
             ret_val = e1000_phy_reset_dsp(hw);
             if(ret_val) {
@@ -2504,7 +2505,7 @@
         }
     }
 
-    ret_val = e1000_read_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                     phy_data);
 
     return ret_val;
@@ -2610,7 +2611,7 @@
         }
     }
 
-    ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT & reg_addr,
+    ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                      phy_data);
 
     return ret_val;
@@ -2956,8 +2957,7 @@
     /* Check polarity status */
     ret_val = e1000_check_polarity(hw, &polarity);
     if(ret_val)
-        return ret_val;
-
+        return ret_val; 
     phy_info->cable_polarity = polarity;
 
     ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
@@ -2967,9 +2967,9 @@
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
@@ -4641,41 +4641,44 @@
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
@@ -4740,6 +4743,7 @@
     uint16_t agc_value = 0;
     uint16_t cur_agc, min_agc = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
     uint16_t i, phy_data;
+    uint16_t cable_length;
 
     DEBUGFUNC("e1000_get_cable_length");
 
@@ -4751,10 +4755,11 @@
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
@@ -4921,8 +4926,7 @@
             return ret_val;
 
         hw->speed_downgraded = (phy_data & IGP01E1000_PLHR_SS_DOWNGRADE) ? 1 : 0;
-    }
-    else if(hw->phy_type == e1000_phy_m88) {
+    } else if(hw->phy_type == e1000_phy_m88) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
                                      &phy_data);
         if(ret_val)
diff -Nru a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
--- a/drivers/net/e1000/e1000_hw.h	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/e1000/e1000_hw.h	2005-03-03 19:33:21 -05:00
@@ -36,7 +36,6 @@
 #include "e1000_osdep.h"
 
 
-
 /* Forward declarations of structures used by the shared code */
 struct e1000_hw;
 struct e1000_hw_stats;
@@ -370,6 +369,7 @@
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
 #define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
+
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
 
@@ -1735,6 +1735,9 @@
 #define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
 #define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
 
+#define MAX_PHY_REG_ADDRESS        0x1F  /* 5 bit address bus (0-0x1F) */
+#define MAX_PHY_MULTI_PAGE_REG     0xF   /* Registers equal on all pages */
+
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
 #define M88E1000_PHY_SPEC_STATUS   0x11  /* PHY Specific Status Register */
@@ -1795,8 +1798,7 @@
 
 #define IGP01E1000_ANALOG_REGS_PAGE  0x20C0
 
-#define MAX_PHY_REG_ADDRESS 0x1F        /* 5 bit address bus (0-0x1F) */
-#define MAX_PHY_MULTI_PAGE_REG  0xF     /*Registers that are equal on all pages*/
+
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
 #define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
@@ -2099,7 +2101,11 @@
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
--- a/drivers/net/e1000/e1000_main.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/e1000/e1000_main.c	2005-03-03 19:33:21 -05:00
@@ -34,6 +34,14 @@
  * - if_mii support and associated kcompat for older kernels
  * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
  * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
+ * 5.7.1	12/16/04
+ * - Resurrect 82547EI/GI related fix in e1000_intr to avoid deadlocks. This
+ *   fix was removed as it caused system instability. The suspected cause of 
+ *   this is the called to e1000_irq_disable in e1000_intr. Inlined the 
+ *   required piece of e1000_irq_disable into e1000_intr.
+ * 5.7.0	12/10/04
+ * - include fix to the condition that determines when to quit NAPI - Robert Olsson
+ * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
  * 5.6.5 	11/01/04
  * - Enabling NETIF_F_SG without checksum offload is illegal - 
      John Mason <jdmason@us.ibm.com>
@@ -41,8 +49,13 @@
  * - Remove redundant initialization - Jamal Hadi
  * - Reset buffer_info->dma in tx resource cleanup logic
  * 5.6.2	10/12/04
+ * - Avoid filling tx_ring completely - shemminger@osdl.org
+ * - Replace schedule_timeout() with msleep()/msleep_interruptible() -
+ *   nacc@us.ibm.com
  * - Sparse cleanup - shemminger@osdl.org
  * - Fix tx resource cleanup logic
+ * - LLTX support - ak@suse.de and hadi@cyberus.ca
+ * - {set, get}_wol is now symmetric for 82545EM adapters
  */
 
 char e1000_driver_name[] = "e1000";
@@ -52,7 +65,7 @@
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.6.10.1-k1"DRIVERNAPI;
+char e1000_driver_version[] = "5.7.6-k1"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -76,6 +89,7 @@
 	INTEL_E1000_ETHERNET_DEVICE(0x1011),
 	INTEL_E1000_ETHERNET_DEVICE(0x1012),
 	INTEL_E1000_ETHERNET_DEVICE(0x1013),
+	INTEL_E1000_ETHERNET_DEVICE(0x1014),
 	INTEL_E1000_ETHERNET_DEVICE(0x1015),
 	INTEL_E1000_ETHERNET_DEVICE(0x1016),
 	INTEL_E1000_ETHERNET_DEVICE(0x1017),
@@ -303,6 +317,9 @@
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	e1000_irq_enable(adapter);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
 	return 0;
 }
 
@@ -316,6 +333,10 @@
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
@@ -409,6 +430,7 @@
 	int i;
 	int err;
 	uint16_t eeprom_data;
+	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
 
 	if((err = pci_enable_device(pdev)))
 		return err;
@@ -505,9 +527,6 @@
 	}
 
 #ifdef NETIF_F_TSO
-	/* Disbaled for now until root-cause is found for
-	 * hangs reported against non-IA archs.  TSO can be
-	 * enabled using ethtool -K eth<x> tso on */
 	if((adapter->hw.mac_type >= e1000_82544) &&
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
@@ -576,6 +595,11 @@
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
@@ -590,7 +614,7 @@
 			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
-	if(eeprom_data & E1000_EEPROM_APME)
+	if(eeprom_data & eeprom_apme_mask)
 		adapter->wol |= E1000_WUFC_MAG;
 
 	/* reset the hardware with the new settings */
@@ -797,6 +821,31 @@
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
@@ -826,11 +875,42 @@
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
+setup_tx_desc_die:
 		DPRINTK(PROBE, ERR, 
 		"Unable to Allocate Memory for the Transmit descriptor ring\n");
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
@@ -948,11 +1028,43 @@
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
 	if(!rxdr->desc) {
+setup_rx_desc_die:
 		DPRINTK(PROBE, ERR, 
-		"Unable to Allocate Memory for the Recieve descriptor ring\n");
+		"Unble to Allocate Memory for the Recieve descriptor ring\n");
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
@@ -1086,6 +1198,7 @@
 			struct e1000_buffer *buffer_info)
 {
 	struct pci_dev *pdev = adapter->pdev;
+
 	if(buffer_info->dma) {
 		pci_unmap_page(pdev,
 			       buffer_info->dma,
@@ -1114,6 +1227,11 @@
 
 	/* Free all the Tx ring sk_buffs */
 
+	if (likely(adapter->previous_buffer_info.skb != NULL)) {
+		e1000_unmap_and_free_tx_resource(adapter, 
+				&adapter->previous_buffer_info);
+	}
+
 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -1415,7 +1533,6 @@
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
-	unsigned int i;
 	uint32_t link;
 
 	e1000_check_for_link(&adapter->hw);
@@ -1495,12 +1612,8 @@
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
@@ -2132,10 +2245,28 @@
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
@@ -2155,24 +2286,21 @@
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
@@ -2196,11 +2324,34 @@
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
@@ -2222,6 +2373,16 @@
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
@@ -2389,20 +2550,43 @@
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
 	int reserve_len = 2;
-	unsigned int i;
+	unsigned int i, bufsz;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while(!buffer_info->skb) {
+		bufsz = adapter->rx_buffer_len + reserve_len;
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
-
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
@@ -2417,6 +2601,25 @@
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
diff -Nru a/drivers/net/tulip/21142.c b/drivers/net/tulip/21142.c
--- a/drivers/net/tulip/21142.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/21142.c	2005-03-03 19:33:21 -05:00
@@ -14,8 +14,8 @@
 
 */
 
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/delay.h>
 
 
diff -Nru a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
--- a/drivers/net/tulip/eeprom.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/eeprom.c	2005-03-03 19:33:21 -05:00
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/init.h>
 #include <asm/unaligned.h>
diff -Nru a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
--- a/drivers/net/tulip/interrupt.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/interrupt.c	2005-03-03 19:33:21 -05:00
@@ -14,10 +14,10 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/config.h>
 #include <linux/etherdevice.h>
-#include <linux/pci.h>
 
 
 int tulip_rx_copybreak;
diff -Nru a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/media.c	2005-03-03 19:33:21 -05:00
@@ -18,6 +18,7 @@
 #include <linux/mii.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
--- a/drivers/net/tulip/pnic.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/pnic.c	2005-03-03 19:33:21 -05:00
@@ -15,6 +15,7 @@
 */
 
 #include <linux/kernel.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/pnic2.c b/drivers/net/tulip/pnic2.c
--- a/drivers/net/tulip/pnic2.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/pnic2.c	2005-03-03 19:33:21 -05:00
@@ -76,8 +76,8 @@
 
 
 
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/delay.h>
 
 
diff -Nru a/drivers/net/tulip/timer.c b/drivers/net/tulip/timer.c
--- a/drivers/net/tulip/timer.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/timer.c	2005-03-03 19:33:21 -05:00
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -Nru a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
--- a/drivers/net/tulip/tulip.h	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/tulip.h	2005-03-03 19:33:21 -05:00
@@ -146,6 +146,9 @@
 	TxIntr = 0x01,
 };
 
+/* bit mask for CSR5 TX/RX process state */
+#define CSR5_TS	0x00700000
+#define CSR5_RS	0x000e0000
 
 enum tulip_mode_bits {
 	TxThreshold		= (1 << 22),
@@ -484,9 +487,19 @@
 	u32 csr6 = inl(ioaddr + CSR6);
 
 	if (csr6 & RxTx) {
+		unsigned i=1300/10;
 		outl(csr6 & ~RxTx, ioaddr + CSR6);
 		barrier();
-		(void) inl(ioaddr + CSR6); /* mmio sync */
+		/* wait until in-flight frame completes.
+		 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+		 * Typically expect this loop to end in < 50us on 100BT.
+		 */
+		while (--i && (inl(ioaddr + CSR5) & (CSR5_TS|CSR5_RS))) 
+			udelay(10);
+
+		if (!i)
+			printk (KERN_DEBUG "%s: tulip_stop_rxtx() failed\n",
+					tp->pdev->slot_name);
 	}
 }
 
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	2005-03-03 19:33:21 -05:00
+++ b/drivers/net/tulip/tulip_core.c	2005-03-03 19:33:21 -05:00
@@ -20,8 +20,8 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/init.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>

--------------020202080705050805050400--
