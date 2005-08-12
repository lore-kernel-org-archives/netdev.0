From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.13-rc6] S2io: Hardware fixes for Xframe II adapter
Date: Fri, 12 Aug 2005 10:15:59 -0700 (PDT)
Message-ID: <20050812171559.F0C03983D0@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com,
        ananda.raju@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Patch Description:
This patch incorporates the following hardware fixes required
for Xframe II adapter.
1. New values to program the dtx_control register.
2. Disable memory controller interrupts(MC_INTR) since these
   are now monitored thru' a poll routine.
3. Don't reset an XframeII card on an ECC double-bit error(It
   can recover).
4. Save/restore PCI config space before/after a reset irrespective
   of Xframe I or II card.
5. Bumped up the driver version no. to 2.0.3.1

Please review the patch and apply the same if it looks ok.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -urN old/drivers/net/s2io.c new/drivers/net/s2io.c
--- old/drivers/net/s2io.c	2005-08-12 01:29:56.000000000 -0700
+++ new/drivers/net/s2io.c	2005-08-12 01:30:12.000000000 -0700
@@ -67,7 +67,7 @@
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
-static char s2io_driver_version[] = "Version 2.0.2.1";
+static char s2io_driver_version[] = "Version 2.0.3.1";
 
 static inline int RXD_IS_UP2DT(RxD_t *rxdp)
 {
@@ -210,14 +210,18 @@
 
 static u64 herc_act_dtx_cfg[] = {
 	/* Set address */
-	0x80000515BA750000ULL, 0x80000515BA7500E0ULL,
+	0x8000051536750000ULL, 0x80000515367500E0ULL,
 	/* Write data */
-	0x80000515BA750004ULL, 0x80000515BA7500E4ULL,
+	0x8000051536750004ULL, 0x80000515367500E4ULL,
 	/* Set address */
 	0x80010515003F0000ULL, 0x80010515003F00E0ULL,
 	/* Write data */
 	0x80010515003F0004ULL, 0x80010515003F00E4ULL,
 	/* Set address */
+	0x801205150D440000ULL, 0x801205150D4400E0ULL,
+	/* Write data */
+	0x801205150D440004ULL, 0x801205150D4400E4ULL,
+	/* Set address */
 	0x80020515F2100000ULL, 0x80020515F21000E0ULL,
 	/* Write data */
 	0x80020515F2100004ULL, 0x80020515F21000E4ULL,
@@ -1903,7 +1907,7 @@
 	}
 
 	/*  Enable select interrupts */
-	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | MC_INTR;
+	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
 	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
 
@@ -2030,7 +2034,7 @@
 	config = &nic->config;
 
 	/*  Disable all interrupts */
-	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | MC_INTR;
+	interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 	interruptible |= TX_PIC_INTR | RX_PIC_INTR;
 	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
@@ -2688,8 +2692,10 @@
 			DBG_PRINT(ERR_DBG, "%s: Device indicates ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "double ECC error!!\n");
-			netif_stop_queue(dev);
-			schedule_work(&nic->rst_timer_task);
+			if (nic->device_type != XFRAME_II_DEVICE) {
+				netif_stop_queue(dev);
+				schedule_work(&nic->rst_timer_task);
+			}
 		} else {
 			nic->mac_control.stats_info->sw_stat.
 				single_ecc_errs++;
@@ -2772,8 +2778,7 @@
 	u16 subid, pci_cmd;
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
-	if (sp->device_type == XFRAME_I_DEVICE)
-		pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
 
 	val64 = SW_RESET_ALL;
 	writeq(val64, &bar0->sw_reset);
@@ -2792,14 +2797,10 @@
 	 */
 	msleep(250);
 
-	if (!(sp->device_type & XFRAME_II_DEVICE)) {
-		/* Restore the PCI state saved during initializarion. */
-		pci_restore_state(sp->pdev);
-		pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
+	/* Restore the PCI state saved during initialization. */
+	pci_restore_state(sp->pdev);
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,
 				     pci_cmd);
-	} else {
-		pci_set_master(sp->pdev);
-	}
 	s2io_init_pci(sp);
 
 	msleep(250);
@@ -5426,9 +5427,7 @@
 	INIT_WORK(&sp->set_link_task,
 		  (void (*)(void *)) s2io_set_link, sp);
 
-	if (!(sp->device_type & XFRAME_II_DEVICE)) {
-		pci_save_state(sp->pdev);
-	}
+	pci_save_state(sp->pdev);
 
 	/* Setting swapper control on the NIC, for proper reset operation */
 	if (s2io_set_swapper(sp)) {
