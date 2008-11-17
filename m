From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ixgbe: fix compilation with gcc-3.4
Date: Mon, 17 Nov 2008 13:01:49 +0300
Message-ID: <20081117100149.GA10586@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:49753 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbYKQJ6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 04:58:15 -0500
Received: by ug-out-1314.google.com with SMTP id 39so355283ugf.37
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 01:58:13 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  drivers/net/ixgbe/ixgbe_main.o
drivers/net/ixgbe/ixgbe_main.c: In function `ixgbe_intr':
drivers/net/ixgbe/ixgbe_main.c:1290: sorry, unimplemented: inlining failed in call to 'ixgbe_irq_enable': function body not available
drivers/net/ixgbe/ixgbe_main.c:1312: sorry, unimplemented: called from here
make[4]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   58 +++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 30 deletions(-)

--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1287,7 +1287,34 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	return;
 }
 
-static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter);
+/**
+ * ixgbe_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
+{
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		int i;
+		for (i = 0; i < adapter->num_msix_vectors; i++)
+			synchronize_irq(adapter->msix_entries[i].vector);
+	} else {
+		synchronize_irq(adapter->pdev->irq);
+	}
+}
+
+/**
+ * ixgbe_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
+{
+	u32 mask;
+	mask = IXGBE_EIMS_ENABLE_MASK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+}
 
 /**
  * ixgbe_intr - legacy mode Interrupt Handler
@@ -1394,35 +1421,6 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- **/
-static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
-{
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-	IXGBE_WRITE_FLUSH(&adapter->hw);
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		int i;
-		for (i = 0; i < adapter->num_msix_vectors; i++)
-			synchronize_irq(adapter->msix_entries[i].vector);
-	} else {
-		synchronize_irq(adapter->pdev->irq);
-	}
-}
-
-/**
- * ixgbe_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- **/
-static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
-{
-	u32 mask;
-	mask = IXGBE_EIMS_ENABLE_MASK;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	IXGBE_WRITE_FLUSH(&adapter->hw);
-}
-
-/**
  * ixgbe_configure_msi_and_legacy - Initialize PIN (INTA...) and MSI interrupts
  *
  **/
