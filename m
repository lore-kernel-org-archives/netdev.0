From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 1/2] s2io: add PCI error recovery support
Date: Fri, 18 May 2007 03:06:53 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77019D47CC@nekter>
References: <20070514233730.GA4511@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-pci@atrey.karlin.mff.cuni.cz>, <netdev@vger.kernel.org>,
	<James.Bottomley@SteelEye.com>, <linux-kernel@vger.kernel.org>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
To: "Linas Vepstas" <linas@austin.ibm.com>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759142AbXERHVW@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070514233730.GA4511@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Fix looks good. I have couple of comments,

1) Return from s2io_updt_stats function if the PCI bus is offline
(pci_channel_offline). 
         if (pci_channel_offline(pdev))
                return;

2) No Need to call netif_wake_queue() in s2io_io_resume as
netif_device_attach() will take care of calling it.

3) We need to return from s2io_msix_ring_handle(),
s2io_msix_fifo_handle(), s2io_msi_handle() if the PCI channel is
offline. Some thing similary to the below condition that is added in the
s2io_isr()

 -4117,6 +4129,10 @@ static irqreturn_t s2io_isr(int irq, voi
        struct mac_info *mac_control;
        struct config_param *config;

+       /* Pretend we handled any irq's from a disconnected card */
+       if (pci_channel_offline(sp->pdev))
+               return IRQ_NONE;

Thanks,
~Siva

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Linas Vepstas
Sent: Tuesday, May 15, 2007 5:08 AM
To: Jeff Garzik
Cc: linux-pci@atrey.karlin.mff.cuni.cz; netdev@vger.kernel.org;
James.Bottomley@SteelEye.com; linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] s2io: add PCI error recovery support


This patch adds PCI error recovery support to the s2io 10-Gigabit
ethernet device driver. Third revision, blocks interrupts and the
watchdog.

Tested, seems to work well.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Acked-by: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Cc: Raghavendra Koushik <raghavendra.koushik@neterion.com>
Cc: Wen Xiong <wenxiong@us.ibm.com>

----

Jeff, please apply for 2.6.22

--linas


 drivers/net/s2io.c |  116
++++++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/s2io.h |    5 ++
 2 files changed, 116 insertions(+), 5 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/s2io.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-14
17:05:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-14 17:23:45.000000000
-0500
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
@@ -3225,6 +3235,8 @@ static void alarm_intr_handler(struct s2
 	int i;
 	if (atomic_read(&nic->card_state) == CARD_DOWN)
 		return;
+	if (pci_channel_offline(nic->pdev))
+		return;
 	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
 	/* Handling the XPAK counters update */
 	if(nic->mac_control.stats_info->xpak_stat.xpak_timer_count <
72000) { @@ -4324,6 +4336,10 @@ static irqreturn_t s2io_isr(int irq, voi
 	struct mac_info *mac_control;
 	struct config_param *config;
 
+	/* Pretend we handled any irq's from a disconnected card */
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -6579,7 +6595,7 @@ static void s2io_rem_isr(struct s2io_nic
 	} while(cnt < 5);
 }
 
-static void s2io_card_down(struct s2io_nic * sp)
+static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 {
 	int cnt = 0;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0; @@ -6594,7
+6610,8 @@ static void s2io_card_down(struct s2io_n
 	atomic_set(&sp->card_state, CARD_DOWN);
 
 	/* disable Tx and Rx traffic on the NIC */
-	stop_nic(sp);
+	if (do_io)
+		stop_nic(sp);
 
 	s2io_rem_isr(sp);
 
@@ -6602,7 +6619,7 @@ static void s2io_card_down(struct s2io_n
 	tasklet_kill(&sp->task);
 
 	/* Check if the device is Quiescent and then Reset the NIC */
-	do {
+	while(do_io) {
 		/* As per the HW requirement we need to replenish the
 		 * receive buffer to avoid the ring bump. Since there is
 		 * no intention of processing the Rx frame at this
pointwe are @@ -6627,8 +6644,9 @@ static void s2io_card_down(struct
s2io_n
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
@@ -6643,6 +6661,11 @@ static void s2io_card_down(struct s2io_n
 	clear_bit(0, &(sp->link_state));
 }
 
+static void s2io_card_down(struct s2io_nic * sp) {
+	do_s2io_card_down(sp, 1);
+}
+
 static int s2io_card_up(struct s2io_nic * sp)  {
 	int i, ret = 0;
@@ -8020,3 +8043,86 @@ static void lro_append_pkt(struct s2io_n
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
+                                               pci_channel_state_t 
+state) {
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct s2io_nic *sp = netdev->priv;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		/* Bring down the card, while avoiding PCI I/O */
+		do_s2io_card_down(sp, 0);
+		sp->device_close_flag = TRUE;	/* Device is shut down.
*/
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
+static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev) {
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
+static void s2io_io_resume(struct pci_dev *pdev) {
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct s2io_nic *sp = netdev->priv;
+
+	if (netif_running(netdev)) {
+		if (s2io_card_up(sp)) {
+			printk(KERN_ERR "s2io: "
+			       "Can't bring device back up after
reset.\n");
+			return;
+		}
+
+		if (s2io_set_mac_addr(netdev, netdev->dev_addr) ==
FAILURE) {
+			s2io_card_down(sp);
+			printk(KERN_ERR "s2io: "
+			       "Can't resetore mac addr after
reset.\n");
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+	netif_wake_queue(netdev);
+}
Index: linux-2.6.22-rc1/drivers/net/s2io.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/s2io.h	2007-05-14
17:05:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/s2io.h	2007-05-14 17:23:45.000000000
-0500
@@ -1052,6 +1052,11 @@ static void lro_append_pkt(struct s2io_n
 			   struct sk_buff *skb, u32 tcp_len);  static
int rts_ds_steer(struct s2io_nic *nic, u8 ds_codepoint, u8 ring);
 
+static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
+			                      pci_channel_state_t
state); static 
+pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev); static void 
+s2io_io_resume(struct pci_dev *pdev);
+
 #define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size  #define
s2io_udp_mss(skb) skb_shinfo(skb)->gso_size  #define
s2io_offload_type(skb) skb_shinfo(skb)->gso_type
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
