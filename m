From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.23 2/3]S2IO: Fixes in MSIX related code.
Date: Mon, 6 Aug 2007 05:36:28 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708060533510.4004-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:40111 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760752AbXHFJga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 05:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Calling store_xmsi_data to store the MSI-X datas during initialization
  in s2io-init_nic function
- Disabling NAPI when MSI-X is enabled
- Freeing sp->entries and sp->s2io_entries in s2io_rem_isr

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch1/drivers/net/s2io.c patch2/drivers/net/s2io.c
--- patch1/drivers/net/s2io.c	2007-07-31 11:04:50.000000000 +0530
+++ patch2/drivers/net/s2io.c	2007-08-02 16:51:57.000000000 +0530
@@ -3898,6 +3898,12 @@ static int s2io_open(struct net_device *
 		}
 	}
 
+	/* NAPI doesn't work well with MSI(X) */
+	 if (sp->intr_type != INTA) {
+		if(sp->config.napi)
+			sp->config.napi = 0;
+	}
+
 	/* Initialize H/W and enable interrupts */
 	err = s2io_card_up(sp);
 	if (err) {
@@ -6472,6 +6478,7 @@ static void s2io_rem_isr(struct s2io_nic
 {
 	int cnt = 0;
 	struct net_device *dev = sp->dev;
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	if (sp->intr_type == MSI_X) {
 		int i;
@@ -6484,6 +6491,16 @@ static void s2io_rem_isr(struct s2io_nic
 
 			free_irq(vector, arg);
 		}
+
+		kfree(sp->entries);
+		stats->mem_freed +=
+			(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+		kfree(sp->s2io_entries);
+		stats->mem_freed +=
+			(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+		sp->entries = NULL;
+		sp->s2io_entries = NULL;
+
 		pci_read_config_word(sp->pdev, 0x42, &msi_control);
 		msi_control &= 0xFFFE; /* Disable MSI */
 		pci_write_config_word(sp->pdev, 0x42, msi_control);
@@ -7379,6 +7396,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	dev->addr_len = ETH_ALEN;
 	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);
 
+	 /* Store the values of the MSIX table in the s2io_nic structure */
+	store_xmsi_data(sp);
 	/* reset Nic and bring it to known state */
 	s2io_reset(sp);
 
diff -urpN patch1/drivers/net/s2io.h patch2/drivers/net/s2io.h
--- patch1/drivers/net/s2io.h	2007-07-31 10:47:06.000000000 +0530
+++ patch2/drivers/net/s2io.h	2007-07-31 10:57:35.000000000 +0530
@@ -415,6 +415,7 @@ struct config_param {
 #define INTA	0
 #define MSI_X	2
 	u8 intr_type;
+	u8 napi;
 
 	/* Specifies if Tx Intr is UTILZ or PER_LIST type. */
 

