From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH 2.6.35-rc1] net: vmxnet3 fixes [5/5] Respect the interrupt
 type in VM configuration
Date: Wed, 7 Jul 2010 02:34:37 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007070232300.5939@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain> <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Respect the interrupt type set in VM configuration.
   
When interrupt type is not auto, do not ignore the interrupt type set from
VM configuration.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 01a5bb7..c6d756f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2355,9 +2355,13 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 	adapter->intr.mask_mode = (cfg >> 2) & 0x3;
 
 	if (adapter->intr.type == VMXNET3_IT_AUTO) {
-		int err;
+		adapter->intr.type = VMXNET3_IT_MSIX;
+	}
 
 #ifdef CONFIG_PCI_MSI
+	if (adapter->intr.type == VMXNET3_IT_MSIX) {
+		int err;
+
 		adapter->intr.msix_entries[0].entry = 0;
 		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
 				      VMXNET3_LINUX_MAX_MSIX_VECT);
@@ -2366,15 +2370,18 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 			adapter->intr.type = VMXNET3_IT_MSIX;
 			return;
 		}
-#endif
+		adapter->intr.type = VMXNET3_IT_MSI;
+	}
 
+	if (adapter->intr.type == VMXNET3_IT_MSI) {
+		int err;
 		err = pci_enable_msi(adapter->pdev);
 		if (!err) {
 			adapter->intr.num_intrs = 1;
-			adapter->intr.type = VMXNET3_IT_MSI;
 			return;
 		}
 	}
+#endif /* CONFIG_PCI_MSI */
 
 	adapter->intr.type = VMXNET3_IT_INTX;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 8e1f704..6bab6ff 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.11.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.12.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000B00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000C00
 
 
 /*
