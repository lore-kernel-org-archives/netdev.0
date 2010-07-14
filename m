From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [5/5] Respect the interrupt
 type in VM configuration
Date: Tue, 13 Jul 2010 17:51:39 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007131750060.32055@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain> <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain> <alpine.LRH.2.00.1007070232300.5939@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:44934 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753209Ab0GNAvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 20:51:39 -0400
In-Reply-To: <alpine.LRH.2.00.1007070232300.5939@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Do not ignore interrupt type in VM configuration

When interrupt type is not auto, do not ignore the interrupt type set from
VM configuration.
Driver may not always respect the interrupt type in configuration but it 
will certainly try to. Eg: if MSIx is configured and enabling MSIx fails 
in driver, it fall back on MSI and then on INTx.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

 drivers/net/vmxnet3/vmxnet3_drv.c     |   13 ++++++++++---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    2 +-
 drivers/net/vmxnet3/vmxnet3_int.h     |    6 +++---
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ffd6a9b..74fe3f0 100644
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
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index de1ba14..52128c7 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -291,7 +291,7 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
 
 		/* update harware LRO capability accordingly */
 		if (lro_requested)
-			adapter->shared->devRead.misc.uptFeatures &= UPT1_F_LRO;
+			adapter->shared->devRead.misc.uptFeatures |= UPT1_F_LRO;
 		else
 			adapter->shared->devRead.misc.uptFeatures &=
 								~UPT1_F_LRO;
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index bbed330..d17fae6 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.5.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.13.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000500
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000B00
 
 
 /*
@@ -150,7 +150,7 @@ vmxnet3_cmd_ring_desc_avail(struct vmxnet3_cmd_ring *ring)
 }
 
 static inline bool
-vmxnet3_cmd_ring_desc_empty(struct vmxnet3_cmd_ring *ring)
+vmxnet3_cmd_ring_desc_empty(const struct vmxnet3_cmd_ring *ring)
 {
 	return (ring->next2comp == ring->next2fill);
 }

