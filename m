From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] forcedeth: make msi-x different name for rx-tx
Date: Thu, 05 Feb 2009 20:59:20 -0800
Message-ID: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:60937 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbZBFFBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 00:01:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Impact: make /proc/interrupts could show more info which irq is rx or other for msi-x

add three name fields for rx, tx, other

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/forcedeth.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -812,6 +812,11 @@ struct fe_priv {
 
 	/* power saved state */
 	u32 saved_config_space[NV_PCI_REGSZ_MAX/4];
+
+	/* for different msi-x irq type */
+	char name_rx[IFNAMSIZ + 3];       /* -rx    */
+	char name_tx[IFNAMSIZ + 3];       /* -tx    */
+	char name_other[IFNAMSIZ + 6];    /* -other */
 };
 
 /*
@@ -3918,21 +3923,27 @@ static int nv_request_irq(struct net_dev
 			np->msi_flags |= NV_MSI_X_ENABLED;
 			if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT && !intr_test) {
 				/* Request irq for rx handling */
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector, &nv_nic_irq_rx, IRQF_SHARED, dev->name, dev) != 0) {
+				sprintf(np->name_rx, "%s-rx", dev->name);
+				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
+						&nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for rx %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_err;
 				}
 				/* Request irq for tx handling */
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector, &nv_nic_irq_tx, IRQF_SHARED, dev->name, dev) != 0) {
+				sprintf(np->name_tx, "%s-tx", dev->name);
+				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
+						&nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for tx %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
 					goto out_free_rx;
 				}
 				/* Request irq for link and timer handling */
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector, &nv_nic_irq_other, IRQF_SHARED, dev->name, dev) != 0) {
+				sprintf(np->name_other, "%s-other", dev->name);
+				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
+						&nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for link %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
