From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 4/4] misc
Date: Thu, 25 Sep 2003 22:53:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309252251360.6939-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* removed unused var, ASSERT macro
* missed a free_netdev() in probe cleanup undo.

------------

diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_hw.h net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.h
--- net-drivers-2.5/drivers/net/e1000/e1000_hw.h	2003-09-24 21:26:38.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_hw.h	2003-09-24 21:27:11.000000000 -0700
@@ -995,7 +995,6 @@ struct e1000_hw {
     uint32_t ledctl_mode1;
     uint32_t ledctl_mode2;
     uint16_t phy_spd_default;
-    uint16_t dsp_reset_counter;
     uint16_t autoneg_advertised;
     uint16_t pci_cmd_word;
     uint16_t fc_high_water;
@@ -2109,5 +2108,4 @@ struct e1000_hw {
 #define AUTONEG_ADVERTISE_10_100_ALL    0x000F /* All 10/100 speeds*/
 #define AUTONEG_ADVERTISE_10_ALL        0x0003 /* 10Mbps Full & Half speeds*/
 
-
 #endif /* _E1000_HW_H_ */
diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_main.c net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5/drivers/net/e1000/e1000_main.c	2003-09-24 21:26:38.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c	2003-09-24 21:28:06.000000000 -0700
@@ -30,6 +30,16 @@
 
 /* Change Log
  *
+ * 5.2.18	9/13/03
+ *   o Bug fix: SERDES devices might be connected to a back-plane
+ *     switch that doesn't support auto-neg, so add the capability
+ *     to force 1000/Full.
+ *   o Bug fix: Flow control settings for hi/lo watermark didn't
+ *     consider changes in the Rx FIFO size, which could occur with
+ *     Jumbo Frames or with the reduced FIFO in 82547.
+ *   o Better propagation of error codes. [Janice Girouard 
+ *     (janiceg@us.ibm.com)].
+ *
  * 5.2.16	8/8/03
  *   o Added support for new controllers: 82545GM, 82546GB, 82541/7_B1
  *   o Bug fix: reset h/w before first EEPROM read because we don't know
@@ -47,19 +57,11 @@
  *   o Feature: Increase default Tx Descriptor count to 1024 for >= 82544.
  *   
  * 5.1.13	5/28/03
- *   o Bug fix: request_irq() failure resulted in freeing resources twice!
- *     [Don Fry (brazilnut@us.ibm.com)]
- *   o Bug fix: fix VLAN support on ppc64 [Mark Rakes (mrakes@vivato.net)]
- *   o Bug fix: missing Tx cleanup opportunities during interrupt handling.
- *   o Bug fix: alloc_etherdev failure didn't cleanup regions in probe.
- *   o Cleanup: s/int/unsigned int/ for descriptor ring indexes.
- *   
- * 5.1.11	5/6/03
  */
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.16-k1";
+char e1000_driver_version[] = "5.2.19-k1";
 char e1000_copyright[] = "Copyright (c) 1999-2003 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -552,7 +554,7 @@ err_sw_init:
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
-	kfree(netdev);
+	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
 	return err;
@@ -1560,7 +1562,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
-	if (mss)
+	if(mss)
 		max_per_txd = min(mss << 2, max_per_txd);
 #endif
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -2333,7 +2335,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
 
 /**
  * e1000_alloc_rx_buffers - Replace used receive buffers
- * @data: address of board private structure
+ * @adapter: address of board private structure
  **/
 
 static void
diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_osdep.h net-drivers-2.5/drivers/net/e1000.mod/e1000_osdep.h
--- net-drivers-2.5/drivers/net/e1000/e1000_osdep.h	2003-09-24 21:26:38.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_osdep.h	2003-09-24 21:28:12.000000000 -0700
@@ -61,8 +61,6 @@ typedef enum {
     TRUE = 1
 } boolean_t;
 
-#undef ASSERT
-#define ASSERT(x)	if(!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
 #if DBG
