From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 08/10] chelsio: add MSI support
Date: Fri, 01 Dec 2006 16:36:20 -0800
Message-ID: <20061202003707.741158000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:48610 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162424AbWLBAjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:40 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-msi.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using MSI can avoid sharing IRQ and associated overhead.
Tested on PCI-X.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/common.h |    1 +
 drivers/net/chelsio/cxgb2.c  |   20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

--- chelsio.orig/drivers/net/chelsio/common.h
+++ chelsio/drivers/net/chelsio/common.h
@@ -228,6 +228,7 @@ struct adapter_params {
 	unsigned short chip_revision;
 	unsigned char  chip_version;
 	unsigned char  is_asic;
+	unsigned char  has_msi;
 };
 
 struct link_config {
--- chelsio.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio/drivers/net/chelsio/cxgb2.c
@@ -107,6 +107,10 @@ static int t1powersave = 1;	/* HW defaul
 module_param(t1powersave, int, 0);
 MODULE_PARM_DESC(t1powersave, "Enable/Disable T1 powersaving mode");
 
+static int disable_msi = 0;
+module_param(disable_msi, int, 0);
+MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
+
 static const char pci_speed[][4] = {
 	"33", "66", "100", "133"
 };
@@ -215,11 +219,19 @@ static int cxgb_up(struct adapter *adapt
 	}
 
 	t1_interrupts_clear(adapter);
-	if ((err = request_irq(adapter->pdev->irq,
-			       t1_select_intr_handler(adapter), IRQF_SHARED,
-			       adapter->name, adapter))) {
+
+	adapter->params.has_msi = !disable_msi && pci_enable_msi(adapter->pdev) == 0;
+	err = request_irq(adapter->pdev->irq,
+			  t1_select_intr_handler(adapter),
+			  adapter->params.has_msi ? 0 : IRQF_SHARED,
+			  adapter->name, adapter);
+	if (err) {
+		if (adapter->params.has_msi)
+			pci_disable_msi(adapter->pdev);
+
 		goto out_err;
 	}
+
 	t1_sge_start(adapter->sge);
 	t1_interrupts_enable(adapter);
  out_err:
@@ -234,6 +246,8 @@ static void cxgb_down(struct adapter *ad
 	t1_sge_stop(adapter->sge);
 	t1_interrupts_disable(adapter);
 	free_irq(adapter->pdev->irq, adapter);
+	if (adapter->params.has_msi)
+		pci_disable_msi(adapter->pdev);
 }
 
 static int cxgb_open(struct net_device *dev)

-- 

