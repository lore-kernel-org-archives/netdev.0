From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000e: Fix irq_synchronize in MSI-X case
Date: Mon, 02 Aug 2010 17:27:23 -0700
Message-ID: <20100803002721.4179.75916.stgit@localhost.localdomain>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jean Delvare <jdelvare@suse.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:33367 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751882Ab0HCA1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:27:47 -0400
In-Reply-To: <20100803002622.4179.31850.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original patch/work from Jean Delvare <jdelvare@suse.de>
Synchronize all IRQs when in MSI-X IRQ mode.

Jean's original patch hard coded the sync with the 3 possible vectors,
this patch incorporates more flexibility for the future and aligns
with how igb stores the number of vectors into the adapter structure.

CC: Jean Delvare <jdelvare@suse.de>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
---

 drivers/net/e1000e/e1000.h  |    1 +
 drivers/net/e1000e/netdev.c |   26 ++++++++++++++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 9ee133f..f9a31c8 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -348,6 +348,7 @@ struct e1000_adapter {
 	u32 test_icr;
 
 	u32 msg_enable;
+	unsigned int num_vectors;
 	struct msix_entry *msix_entries;
 	int int_mode;
 	u32 eiac_mask;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 464c9a2..9e9164a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1785,25 +1785,25 @@ void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter)
 void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 {
 	int err;
-	int numvecs, i;
-
+	int i;
 
 	switch (adapter->int_mode) {
 	case E1000E_INT_MODE_MSIX:
 		if (adapter->flags & FLAG_HAS_MSIX) {
-			numvecs = 3; /* RxQ0, TxQ0 and other */
-			adapter->msix_entries = kcalloc(numvecs,
+			adapter->num_vectors = 3; /* RxQ0, TxQ0 and other */
+			adapter->msix_entries = kcalloc(adapter->num_vectors,
 						      sizeof(struct msix_entry),
 						      GFP_KERNEL);
 			if (adapter->msix_entries) {
-				for (i = 0; i < numvecs; i++)
+				for (i = 0; i < adapter->num_vectors; i++)
 					adapter->msix_entries[i].entry = i;
 
 				err = pci_enable_msix(adapter->pdev,
 						      adapter->msix_entries,
-						      numvecs);
-				if (err == 0)
+						      adapter->num_vectors);
+				if (err == 0) {
 					return;
+				}
 			}
 			/* MSI-X failed, so fall through and try MSI */
 			e_err("Failed to initialize MSI-X interrupts.  "
@@ -1825,6 +1825,9 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
 		/* Don't do anything; this is the system default */
 		break;
 	}
+
+	/* store the number of vectors being used */
+	adapter->num_vectors = 1;
 }
 
 /**
@@ -1946,7 +1949,14 @@ static void e1000_irq_disable(struct e1000_adapter *adapter)
 	if (adapter->msix_entries)
 		ew32(EIAC_82574, 0);
 	e1e_flush();
-	synchronize_irq(adapter->pdev->irq);
+
+	if (adapter->msix_entries) {
+		int i;
+		for (i = 0; i < adapter->num_vectors; i++)
+			synchronize_irq(adapter->msix_entries[i].vector);
+	} else {
+		synchronize_irq(adapter->pdev->irq);
+	}
 }
 
 /**

