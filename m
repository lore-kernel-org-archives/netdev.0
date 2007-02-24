From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 1/6] S2IO: Fixes for MSI and MSIX
Date: Sat, 24 Feb 2007 01:51:50 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240132020.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vep@neterion.com, rastapur.santosh@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45716 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbXBXGvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 01:51:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added debug statements to print a debug message if the MSI/MSI-X vector (or)
  data is zero.

- This patch removes the code that will enable NAPI for the case of single 
  ring and MSI-X / MSI case. There are some issue in the enabling NAPI with
  MSI/MSI-X.  So we are turning off NAPI in the case of MSI/MSI-X. 

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-02-21 12:15:42.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-02-21 12:28:59.000000000 +0530
@@ -6112,7 +6112,7 @@ static int s2io_add_isr(struct s2io_nic 
 		}
 	}
 	if (sp->intr_type == MSI_X) {
-		int i;
+		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
 		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
 			if (sp->s2io_entries[i].type == MSIX_FIFO_TYPE) {
@@ -6121,16 +6121,36 @@ static int s2io_add_isr(struct s2io_nic 
 				err = request_irq(sp->entries[i].vector,
 					  s2io_msix_fifo_handle, 0, sp->desc[i],
 						  sp->s2io_entries[i].arg);
-				DBG_PRINT(ERR_DBG, "%s @ 0x%llx\n", sp->desc[i],
-				(unsigned long long)sp->msix_info[i].addr);
+				/* If either data or addr is zero print it */
+				if(!(sp->msix_info[i].addr &&
+					sp->msix_info[i].data)) {
+					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx"
+						"Data:0x%lx\n",sp->desc[i],
+						(unsigned long long)
+						sp->msix_info[i].addr,
+						(unsigned long)
+						ntohl(sp->msix_info[i].data));
+				} else {
+					msix_tx_cnt++;
+				}
 			} else {
 				sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
 					dev->name, i);
 				err = request_irq(sp->entries[i].vector,
 					  s2io_msix_ring_handle, 0, sp->desc[i],
 						  sp->s2io_entries[i].arg);
-				DBG_PRINT(ERR_DBG, "%s @ 0x%llx\n", sp->desc[i],
-				(unsigned long long)sp->msix_info[i].addr);
+				/* If either data or addr is zero print it */
+				if(!(sp->msix_info[i].addr &&
+					sp->msix_info[i].data)) {
+					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx"
+						"Data:0x%lx\n",sp->desc[i],
+						(unsigned long long)
+						sp->msix_info[i].addr,
+						(unsigned long)
+						ntohl(sp->msix_info[i].data));
+				} else {
+					msix_rx_cnt++;
+				}
 			}
 			if (err) {
 				DBG_PRINT(ERR_DBG,"%s:MSI-X-%d registration "
@@ -6140,6 +6160,8 @@ static int s2io_add_isr(struct s2io_nic 
 			}
 			sp->s2io_entries[i].in_use = MSIX_REGISTERED_SUCCESS;
 		}
+		printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
+		printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
 	}
 	if (sp->intr_type == INTA) {
 		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
@@ -6704,8 +6726,7 @@ static int s2io_verify_parm(struct pci_d
 					"Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
-	if ( (rx_ring_num > 1) && (*dev_intr_type != INTA) )
-		napi = 0;
+
 	if (rx_ring_mode > 3) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
 		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 3-buffer mode\n");

