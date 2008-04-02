From: Yinghai Lu <yhlu.kernel.send@gmail.com>
Subject: [PATCH] ixgb/e: fix IRQx nobody cared for shared irq with INTx
Date: Tue, 1 Apr 2008 17:20:03 -0700
Message-ID: <200804011720.03569.yhlu.kernel@gmail.com>
References: <200803291403.23479.yhlu.kernel@gmail.com> <200803311458.56119.yhlu.kernel@gmail.com>
Reply-To: yhlu.kernel@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758165AbYDBAS7@vger.kernel.org>
In-Reply-To: <200803311458.56119.yhlu.kernel@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] ixgb/e: fix IRQx nobody cared for shared irq with INTx

solve
	ixgb on pci-x and mptsas on pci-x. sometime mptsas get confused.

same to
	[PATCH] e1000: fix IRQx nobody cared for shared irq with INTx
	http://lkml.org/lkml/2008/3/29/103

Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>

Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
+++ linux-2.6/drivers/net/ixgb/ixgb_main.c
@@ -290,6 +290,11 @@ ixgb_up(struct ixgb_adapter *adapter)
 #endif
 	ixgb_irq_enable(adapter);
 
+	if (!adapter->have_msi) {
+		/* enable INTx if not using MSI */
+		pci_intx(adapter->pdev, 1);
+	}
+
 	return 0;
 }
 
@@ -368,6 +373,8 @@ ixgb_probe(struct pci_dev *pdev,
 	int i;
 	int err;
 
+	/* disable INTx at first */
+	pci_intx(pdev, 0);
 	if((err = pci_enable_device(pdev)))
 		return err;
 
Index: linux-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -1988,6 +1988,12 @@ try_intr_reinit:
 	if (err)
 		goto err_up;
 
+	if (!(adapter->flags &
+	      (IXGBE_FLAG_MSI_ENABLED | IXGBE_FLAG_MSIX_ENABLED))) {
+		/* enable INTx if not using MSI/MSIX */
+		pci_intx(adapter->pdev, 1);
+	}
+
 	return 0;
 
 err_up:
@@ -2627,6 +2633,8 @@ static int __devinit ixgbe_probe(struct 
 	u16 link_status, link_speed, link_width;
 	u32 part_num;
 
+	/* disable INTx at first */
+	pci_intx(pdev, 0);
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
