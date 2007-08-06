From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.23 1/3]S2IO: Making MSIX as default intr_type
Date: Mon, 6 Aug 2007 05:33:40 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708060525530.4004-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:40090 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760099AbXHFJdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 05:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Making MSIX as default intr_type
- Driver will test MSI-X by issuing test MSI-X vector and if fails it will
  fallback to INTA

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- org/drivers/net/s2io.c	2007-07-31 10:50:04.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-07-31 11:04:50.000000000 +0530
@@ -37,7 +37,7 @@
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
- *     2(MSI_X). Default value is '0(INTA)'
+ *     2(MSI_X). Default value is '2(MSI_X)'
  * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
@@ -428,7 +428,7 @@ S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
-S2IO_PARM_INT(intr_type, 0);
+S2IO_PARM_INT(intr_type, 2);
 /* Large receive offload feature */
 S2IO_PARM_INT(lro, 0);
 /* Max pkts to be aggregated by LRO at one time. If not specified,
@@ -3781,6 +3781,59 @@ static int s2io_enable_msi_x(struct s2io
 	return 0;
 }
 
+/* Handle software interrupt used during MSI(X) test */
+static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
+{
+	struct s2io_nic *sp = dev_id;
+
+	sp->msi_detected = 1;
+	wake_up(&sp->msi_wait);
+
+	return IRQ_HANDLED;
+}
+
+/* Test interrupt path by forcing a a software IRQ */
+static int __devinit s2io_test_msi(struct s2io_nic *sp)
+{
+	struct pci_dev *pdev = sp->pdev;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+	int err;
+	u64 val64, saved64;
+
+	err = request_irq(sp->entries[1].vector, s2io_test_intr, 0,
+			sp->name, sp);
+	if (err) {
+		DBG_PRINT(ERR_DBG, "%s: PCI %s: cannot assign irq %d\n",
+		       sp->dev->name, pci_name(pdev), pdev->irq);
+		return err;
+	}
+
+	init_waitqueue_head (&sp->msi_wait);
+	sp->msi_detected = 0;
+
+	saved64 = val64 = readq(&bar0->scheduled_int_ctrl);
+	val64 |= SCHED_INT_CTRL_ONE_SHOT;
+	val64 |= SCHED_INT_CTRL_TIMER_EN;
+	val64 |= SCHED_INT_CTRL_INT2MSI(1);
+	writeq(val64, &bar0->scheduled_int_ctrl);
+
+	wait_event_timeout(sp->msi_wait, sp->msi_detected, HZ/10);
+
+	if (!sp->msi_detected) {
+		/* MSI(X) test failed, go back to INTx mode */
+		DBG_PRINT(ERR_DBG, "%s: PCI %s: No interrupt was generated"
+			"using MSI(X) during test\n", sp->dev->name,
+			pci_name(pdev));
+
+		err = -EOPNOTSUPP;
+	}
+
+	free_irq(sp->entries[1].vector, sp);
+
+	writeq(saved64, &bar0->scheduled_int_ctrl);
+
+	return err;
+}
 /* ********************************************************* *
  * Functions defined below concern the OS part of the driver *
  * ********************************************************* */
@@ -3809,6 +3862,42 @@ static int s2io_open(struct net_device *
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
+	if (sp->intr_type == MSI_X) {
+		int ret = s2io_enable_msi_x(sp);
+
+		if (!ret) {
+			u16 msi_control;
+
+			ret = s2io_test_msi(sp);
+
+			/* rollback MSI-X, will re-enable during add_isr() */
+			kfree(sp->entries);
+			sp->mac_control.stats_info->sw_stat.mem_freed +=
+				(MAX_REQUESTED_MSI_X *
+				sizeof(struct msix_entry));
+			kfree(sp->s2io_entries);
+			sp->mac_control.stats_info->sw_stat.mem_freed +=
+				(MAX_REQUESTED_MSI_X *
+				sizeof(struct s2io_msix_entry));
+			sp->entries = NULL;
+			sp->s2io_entries = NULL;
+
+			pci_read_config_word(sp->pdev, 0x42, &msi_control);
+			msi_control &= 0xFFFE; /* Disable MSI */
+			pci_write_config_word(sp->pdev, 0x42, msi_control);
+
+			pci_disable_msix(sp->pdev);
+
+		}
+		if (ret) {
+
+			DBG_PRINT(ERR_DBG,
+			  "%s: MSI-X requested but failed to enable\n",
+			  dev->name);
+			sp->intr_type = INTA;
+		}
+	}
+
 	/* Initialize H/W and enable interrupts */
 	err = s2io_card_up(sp);
 	if (err) {
diff -urpN org/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- org/drivers/net/s2io.h	2007-07-31 10:50:04.000000000 +0530
+++ patch1/drivers/net/s2io.h	2007-07-31 10:47:06.000000000 +0530
@@ -412,6 +412,10 @@ struct config_param {
 	struct tx_fifo_config tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
 	u32 max_txds;		/*Max no. of Tx buffer descriptor per TxDL */
 	u64 tx_intr_type;
+#define INTA	0
+#define MSI_X	2
+	u8 intr_type;
+
 	/* Specifies if Tx Intr is UTILZ or PER_LIST type. */
 
 /* Rx Side */
@@ -861,6 +865,8 @@ struct s2io_nic {
 	struct vlan_group *vlgrp;
 #define MSIX_FLG                0xA5
 	struct msix_entry *entries;
+	int msi_detected;
+	wait_queue_head_t msi_wait;
 	struct s2io_msix_entry *s2io_entries;
 	char desc[MAX_REQUESTED_MSI_X][25];
 
diff -urpN org/drivers/net/s2io-regs.h patch1/drivers/net/s2io-regs.h
--- org/drivers/net/s2io-regs.h	2007-07-31 10:50:04.000000000 +0530
+++ patch1/drivers/net/s2io-regs.h	2007-07-31 10:47:32.000000000 +0530
@@ -220,7 +220,7 @@ struct XENA_dev_config {
 	u64 scheduled_int_ctrl;
 #define SCHED_INT_CTRL_TIMER_EN                BIT(0)
 #define SCHED_INT_CTRL_ONE_SHOT                BIT(1)
-#define SCHED_INT_CTRL_INT2MSI                 TBD
+#define SCHED_INT_CTRL_INT2MSI(val)		vBIT(val,10,6)
 #define SCHED_INT_PERIOD                       TBD
 
 	u64 txreqtimeout;

