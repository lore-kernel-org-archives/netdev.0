From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] ixgbe: fix compilation with gcc-3.4
Date: Mon, 17 Nov 2008 17:04:17 -0800
Message-ID: <20081118010417.7521.37340.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:58080
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751700AbYKRBEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 20:04:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

CC [M]  drivers/net/ixgbe/ixgbe_main.o
drivers/net/ixgbe/ixgbe_main.c: In function `ixgbe_intr':
drivers/net/ixgbe/ixgbe_main.c:1290: sorry, unimplemented: inlining failed in call to 'ixgbe_irq_enable': function body not available
drivers/net/ixgbe/ixgbe_main.c:1312: sorry, unimplemented: called from here
make[4]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   62 +++++++++++++++++++---------------------
 1 files changed, 30 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a2fe0f8..4840f78 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1307,7 +1307,36 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
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
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
+		mask |= IXGBE_EIMS_GPI_SDP1;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+}
 
 /**
  * ixgbe_intr - legacy mode Interrupt Handler
@@ -1416,37 +1445,6 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
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
-	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
-		mask |= IXGBE_EIMS_GPI_SDP1;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	IXGBE_WRITE_FLUSH(&adapter->hw);
-}
-
-/**
  * ixgbe_configure_msi_and_legacy - Initialize PIN (INTA...) and MSI interrupts
  *
  **/

