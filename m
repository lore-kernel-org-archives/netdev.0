From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Mon, 21 May 2007 13:58:53 -0500
Message-ID: <20070521185853.GD5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47620 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755627AbXEUS65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 14:58:57 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4LHurGI032143
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 13:56:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4LIws9W554816
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 14:58:54 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4LIwrjE009845
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 14:58:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds PCI error recovery support to the 
s2io 10-Gigabit ethernet device driver. Fourth revision,
blocks MSI interrupts, and statistics gathering, as well.

Tested, seems to work well.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Acked-by: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Wen Xiong <wenxiong@us.ibm.com>

----
Please apply. This has been submitted for 2.6.19, 2.6.20 and 2.6.21
with no major criticisms made, although with minor polish & fixups.
I think its ready.

Linas.

 drivers/net/s2io.c |  127 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/s2io.h |    5 ++
 2 files changed, 127 insertions(+), 5 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/s2io.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-21 11:52:40.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-21 13:35:18.000000000 -0500
@@ -480,11 +480,18 @@ static struct pci_device_id s2io_tbl[] _
 
 MODULE_DEVICE_TABLE(pci, s2io_tbl);
 
+static struct pci_error_handlers s2io_err_handler = {
+	.error_detected = s2io_io_error_detected,
+	.slot_reset = s2io_io_slot_reset,
+	.resume = s2io_io_resume,
+};
+
 static struct pci_driver s2io_driver = {
       .name = "S2IO",
       .id_table = s2io_tbl,
       .probe = s2io_init_nic,
       .remove = __devexit_p(s2io_rem_nic),
+      .err_handler = &s2io_err_handler,
 };
 
 /* A simplifier macro used both by init and free shared_mem Fns(). */
@@ -2700,6 +2707,9 @@ static void s2io_netpoll(struct net_devi
 	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
 
+	if (pci_channel_offline(nic->pdev))
+		return;
+
 	disable_irq(dev->irq);
 
 	atomic_inc(&nic->isr_cnt);
@@ -3223,6 +3233,8 @@ static void alarm_intr_handler(struct s2
 	register u64 val64 = 0, err_reg = 0;
 	u64 cnt;
 	int i;
+	if (pci_channel_offline(nic->pdev))
+		return;
 	if (atomic_read(&nic->card_state) == CARD_DOWN)
 		return;
 	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
@@ -4191,6 +4203,9 @@ static irqreturn_t s2io_msi_handle(int i
 	struct mac_info *mac_control;
 	struct config_param *config;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -4221,6 +4236,9 @@ static irqreturn_t s2io_msix_ring_handle
 	struct ring_info *ring = (struct ring_info *)dev_id;
 	struct s2io_nic *sp = ring->nic;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 
 	rx_intr_handler(ring);
@@ -4235,6 +4253,9 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct fifo_info *fifo = (struct fifo_info *)dev_id;
 	struct s2io_nic *sp = fifo->nic;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	tx_intr_handler(fifo);
 	atomic_dec(&sp->isr_cnt);
@@ -4324,6 +4345,10 @@ static irqreturn_t s2io_isr(int irq, voi
 	struct mac_info *mac_control;
 	struct config_param *config;
 
+	/* Pretend we handled any irq's from a disconnected card */
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -4413,6 +4438,9 @@ static void s2io_updt_stats(struct s2io_
 	u64 val64;
 	int cnt = 0;
 
+	if (pci_channel_offline(sp->pdev))
+		return;
+
 	if (atomic_read(&sp->card_state) == CARD_UP) {
 		/* Apprx 30us on a 133 MHz bus */
 		val64 = SET_UPDT_CLICKS(10) |
@@ -6579,7 +6607,7 @@ static void s2io_rem_isr(struct s2io_nic
 	} while(cnt < 5);
 }
 
-static void s2io_card_down(struct s2io_nic * sp)
+static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 {
 	int cnt = 0;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
@@ -6594,7 +6622,8 @@ static void s2io_card_down(struct s2io_n
 	atomic_set(&sp->card_state, CARD_DOWN);
 
 	/* disable Tx and Rx traffic on the NIC */
-	stop_nic(sp);
+	if (do_io)
+		stop_nic(sp);
 
 	s2io_rem_isr(sp);
 
@@ -6602,7 +6631,7 @@ static void s2io_card_down(struct s2io_n
 	tasklet_kill(&sp->task);
 
 	/* Check if the device is Quiescent and then Reset the NIC */
-	do {
+	while(do_io) {
 		/* As per the HW requirement we need to replenish the
 		 * receive buffer to avoid the ring bump. Since there is
 		 * no intention of processing the Rx frame at this pointwe are
@@ -6627,8 +6656,9 @@ static void s2io_card_down(struct s2io_n
 				  (unsigned long long) val64);
 			break;
 		}
-	} while (1);
-	s2io_reset(sp);
+	}
+	if (do_io)
+		s2io_reset(sp);
 
 	spin_lock_irqsave(&sp->tx_lock, flags);
 	/* Free all Tx buffers */
@@ -6643,6 +6673,11 @@ static void s2io_card_down(struct s2io_n
 	clear_bit(0, &(sp->link_state));
 }
 
+static void s2io_card_down(struct s2io_nic * sp)
+{
+	do_s2io_card_down(sp, 1);
+}
+
 static int s2io_card_up(struct s2io_nic * sp)
 {
 	int i, ret = 0;
@@ -8020,3 +8055,85 @@ static void lro_append_pkt(struct s2io_n
 	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
 	return;
 }
+
+/**
+ * s2io_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci conneection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
+                                               pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct s2io_nic *sp = netdev->priv;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		/* Bring down the card, while avoiding PCI I/O */
+		do_s2io_card_down(sp, 0);
+		sp->device_close_flag = TRUE;	/* Device is shut down. */
+	}
+	pci_disable_device(pdev);
+
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * s2io_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ * At this point, the card has exprienced a hard reset,
+ * followed by fixups by BIOS, and has its config space
+ * set up identically to what it was at cold boot.
+ */
+static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct s2io_nic *sp = netdev->priv;
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR "s2io: "
+		       "Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	s2io_reset(sp);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * s2io_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells
+ * us that its OK to resume normal operation.
+ */
+static void s2io_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct s2io_nic *sp = netdev->priv;
+
+	if (netif_running(netdev)) {
+		if (s2io_card_up(sp)) {
+			printk(KERN_ERR "s2io: "
+			       "Can't bring device back up after reset.\n");
+			return;
+		}
+
+		if (s2io_set_mac_addr(netdev, netdev->dev_addr) == FAILURE) {
+			s2io_card_down(sp);
+			printk(KERN_ERR "s2io: "
+			       "Can't resetore mac addr after reset.\n");
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+}
Index: linux-2.6.22-rc1/drivers/net/s2io.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.h	2007-05-21 11:52:40.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.h	2007-05-21 13:34:55.000000000 -0500
@@ -1052,6 +1052,11 @@ static void lro_append_pkt(struct s2io_n
 			   struct sk_buff *skb, u32 tcp_len);
 static int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring);
 
+static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
+			                      pci_channel_state_t state);
+static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev);
+static void s2io_io_resume(struct pci_dev *pdev);
+
 #define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size
 #define s2io_udp_mss(skb) skb_shinfo(skb)->gso_size
 #define s2io_offload_type(skb) skb_shinfo(skb)->gso_type
