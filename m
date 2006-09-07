From: Hayim Shaul <hayim@iportent.com>
Subject: [PATCH 2.6.18-rc1 2/2] dllink driver: porting v1.19 to linux
	2.6.18-rc1
Date: Thu, 07 Sep 2006 12:08:00 +0300
Message-ID: <1157620080.2904.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edward_peng@dlink.com.tw,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv1.iportent.com ([62.90.210.153]:15551 "EHLO iportent.com")
	by vger.kernel.org with ESMTP id S1751246AbWIGJCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2006 05:02:21 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- drivers/net/dl2k.h.orig	2006-09-07 10:33:05.000000000 +0300
+++ drivers/net/dl2k.h	2006-09-07 10:33:17.000000000 +0300
@@ -36,7 +36,7 @@
 #include <linux/spinlock.h>
 #include <linux/time.h>
 #define TX_RING_SIZE	256
-#define TX_QUEUE_LEN	(TX_RING_SIZE - 1) /* Limit ring entries actually used.*/
+#define TX_QUEUE_LEN	(TX_RING_SIZE - 10) /* Limit ring entries actually used.*/
 #define RX_RING_SIZE 	256
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct netdev_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct netdev_desc)
@@ -243,6 +243,7 @@
 	VLANTagInsert = 0x0000000010000000,
 	TFDDone = 0x80000000,
 	VIDShift = 32,
+	CFI = 0x0000100000000000,
 	UsePriorityShift = 48,
 };
 
@@ -512,7 +513,7 @@
 	u16 image;
 	struct {
 		u16 _bit_11_0:12;	// bit 11:0
-		u16 media_1000BT_HD:2;	// bit 12
+		u16 media_1000BT_HD:1;	// bit 12
 		u16 media_1000BT_FD:1;	// bit 13
 		u16 media_1000BX_HD:1;	// bit 14
 		u16 media_1000BX_FD:1;	// bit 15
@@ -655,6 +656,8 @@
 	struct net_device_stats stats;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
 	unsigned int speed;		/* Operating speed */
+	struct tasklet_struct tx_tasklet;
+	struct tasklet_struct rx_tasklet;
 	unsigned int vlan;		/* VLAN Id */
 	unsigned int chip_id;		/* PCI table chip id */
 	unsigned int rx_coalesce; 	/* Maximum frames each RxDMAComplete intr */
@@ -672,6 +675,9 @@
 	struct netdev_desc *last_tx;	/* Last Tx descriptor used. */
 	unsigned long cur_rx, old_rx;	/* Producer/consumer ring indices */
 	unsigned long cur_tx, old_tx;
+	unsigned long cur_task;
+	atomic_t tx_desc_lock;
+	int budget;
 	struct timer_list timer;
 	int wake_polarity;
 	char name[256];		/* net device description */
@@ -683,6 +689,11 @@
 };
 
 /* The station address location in the EEPROM. */
+#ifdef MEM_MAPPING
+#define PCI_IOTYPE (PCI_USES_MASTER | PCI_USES_MEM | PCI_ADDR1)
+#else
+#define PCI_IOTYPE (PCI_USES_MASTER | PCI_USES_IO  | PCI_ADDR0)
+#endif
 /* The struct pci_device_id consist of:
         vendor, device          Vendor and device ID to match (or PCI_ANY_ID)
         subvendor, subdevice    Subsystem vendor and device ID to match (or PCI_ANY_ID)
@@ -690,10 +701,9 @@
         class_mask              of the class are honored during the comparison.
         driver_data             Data private to the driver.
 */
-
-static const struct pci_device_id rio_pci_tbl[] = {
-	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
-	{ }
+static struct pci_device_id rio_pci_tbl[] __devinitdata = {
+	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0,}
 };
 MODULE_DEVICE_TABLE (pci, rio_pci_tbl);
 #define TX_TIMEOUT  (4*HZ)
@@ -704,4 +714,5 @@
 #define DEFAULT_RXT		750
 #define DEFAULT_TXC		1
 #define MAX_TXC			8
+#define RX_BUDGET		RX_RING_SIZE/2
 #endif				/* __DL2K_H__ */

