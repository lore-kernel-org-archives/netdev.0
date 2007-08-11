From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 13/13] cxgb3 - test MSI capabilities
Date: Fri, 10 Aug 2007 23:30:36 -0700
Message-ID: <20070811063036.8239.27320.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6163 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbXHKGal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:30:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Check that the HW in really in MSI/MSI-X mode
when it was succesfully enabled.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   42 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/regs.h       |    4 ++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index eaebd7f..1449692 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2318,6 +2318,46 @@ void t3_fatal_err(struct adapter *adapter)
 
 }
 
+/*
+ * Interrupt handler used to check if MSI/MSI-X works on this platform.
+ */
+static irqreturn_t check_intr_handler(int irq, void *cookie)
+{
+	struct adapter *adap = cookie;
+
+	t3_set_reg_field(adap, A_PL_INT_ENABLE0, F_MI1, 0);
+	return IRQ_HANDLED;
+}
+
+static void __devinit check_msi(struct adapter *adap)
+{
+	int vec, mi1;
+
+	if (!(t3_read_reg(adap, A_PL_INT_CAUSE0) & F_MI1))
+		return;
+
+	vec = (adap->flags & USING_MSI) ? adap->pdev->irq :
+					  adap->msix_info[0].vec;
+
+	if (request_irq(vec, check_intr_handler, 0, adap->name, adap))
+		return;
+
+	t3_set_reg_field(adap, A_PL_INT_ENABLE0, 0, F_MI1);
+	msleep(10);
+	mi1 = t3_read_reg(adap, A_PL_INT_ENABLE0) & F_MI1;
+	if (mi1)
+		t3_set_reg_field(adap, A_PL_INT_ENABLE0, F_MI1, 0);
+	free_irq(vec, adap);
+
+	if (mi1) {
+		cxgb_disable_msi(adap);
+		dev_info(&adap->pdev->dev,
+			 "the kernel believes that MSI is available on this "
+			 "platform\nbut the driver's MSI test has failed.  "
+			 "Proceeding with INTx interrupts.\n");
+	}
+}
+
 static int __devinit cxgb_enable_msix(struct adapter *adap)
 {
 	struct msix_entry entries[SGE_QSETS + 1];
@@ -2554,6 +2594,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		adapter->flags |= USING_MSIX;
 	else if (msi > 0 && pci_enable_msi(pdev) == 0)
 		adapter->flags |= USING_MSI;
+	if (adapter->flags & (USING_MSIX | USING_MSI))
+		check_msi(adapter);
 
 	err = sysfs_create_group(&adapter->port[0]->dev.kobj,
 				 &cxgb3_attr_group);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 5e1bc0d..f97f8ab 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1639,6 +1639,10 @@
 #define V_MC5A(x) ((x) << S_MC5A)
 #define F_MC5A    V_MC5A(1U)
 
+#define S_MI1    13
+#define V_MI1(x) ((x) << S_MI1)
+#define F_MI1    V_MI1(1U)
+
 #define S_CPL_SWITCH    12
 #define V_CPL_SWITCH(x) ((x) << S_CPL_SWITCH)
 #define F_CPL_SWITCH    V_CPL_SWITCH(1U)
