From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: test MSI interrupts
Date: Wed, 26 Mar 2008 11:36:34 -0700
Message-ID: <20080326183631.25114.90265.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Test the MSI interrupt physically once before assuming that it
actually works. Several platforms have already come across that
have non-functional MSI interrupts and this code will attempt
to detect those safely. Once the test succeeds MSI interrupts
will be enabled.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/e1000.h   |    1 
 drivers/net/e1000e/netdev.c  |  161 ++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 155 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index a4f511f..c3593f3 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -385,6 +385,7 @@
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_ICS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 
 /* Transmit Descriptor Control */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 4bf0c6c..556b258 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -305,6 +305,7 @@ struct e1000_info {
 #define FLAG_MSI_ENABLED                  (1 << 27)
 #define FLAG_RX_CSUM_ENABLED              (1 << 28)
 #define FLAG_TSO_FORCE                    (1 << 29)
+#define FLAG_MSI_TEST_FAILED              (1 << 30)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f501dd5..41d57da 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -932,25 +932,30 @@ static irqreturn_t e1000_intr(int irq, void *data)
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	irq_handler_t handler = e1000_intr;
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	if (!pci_enable_msi(adapter->pdev)) {
-		adapter->flags |= FLAG_MSI_ENABLED;
-		handler = e1000_intr_msi;
-		irq_flags = 0;
+	if (!(adapter->flags & FLAG_MSI_TEST_FAILED)) {
+		err = pci_enable_msi(adapter->pdev);
+		if (!err) {
+			adapter->flags |= FLAG_MSI_ENABLED;
+			irq_flags = 0;
+		}
 	}
 
-	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
-			  netdev);
+	err = request_irq(adapter->pdev->irq,
+			  (adapter->flags & FLAG_MSI_ENABLED) ?
+			  &e1000_intr_msi : &e1000_intr, irq_flags,
+			  netdev->name, netdev);
 	if (err) {
 		ndev_err(netdev,
 		       "Unable to allocate %s interrupt (return: %d)\n",
 			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
 			err);
-		if (adapter->flags & FLAG_MSI_ENABLED)
+		if (adapter->flags & FLAG_MSI_ENABLED) {
 			pci_disable_msi(adapter->pdev);
+			adapter->flags &= ~FLAG_MSI_ENABLED;
+		}
 	}
 
 	return err;
@@ -2234,6 +2239,135 @@ err:
 }
 
 /**
+ * e1000_intr_msi_test - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ **/
+static irqreturn_t e1000_intr_msi_test(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	u32 icr = er32(ICR);
+	ndev_dbg(netdev, "icr is %08X\n", icr);
+	if (icr & E1000_ICR_RXSEQ) {
+		adapter->flags &= ~FLAG_MSI_TEST_FAILED;
+		wmb();
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * e1000_test_msi_interrupt - Returns 0 for successful test
+ * @adapter: board private struct
+ *
+ * code flow taken from tg3.c
+ **/
+static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	int err;
+
+	/* poll_enable hasn't been called yet, so don't need disable */
+	/* clear any pending events */
+	er32(ICR);
+
+	/* free the real vector and request a test handler */
+	e1000_free_irq(adapter);
+
+	err = pci_enable_msi(adapter->pdev);
+	if (err)
+		goto msi_test_failed;
+
+	err = request_irq(adapter->pdev->irq, &e1000_intr_msi_test, 0,
+			  netdev->name, netdev);
+	if (err) {
+		pci_disable_msi(adapter->pdev);
+		goto msi_test_failed;
+	}
+
+	/* Assume that the test fails, if it succeeds then the test
+	 * MSI irq handler will unset this flag */
+	adapter->flags |= FLAG_MSI_TEST_FAILED;
+	wmb();
+
+	e1000_irq_enable(adapter);
+
+	/* fire an unusual interrupt on the test handler */
+	ew32(ICS, E1000_ICS_RXSEQ);
+	e1e_flush();
+	msleep(50);
+
+	e1000_irq_disable(adapter);
+
+	rmb();
+
+	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
+		err = -EIO;
+		ndev_dbg(netdev, "MSI interrupt test failed!\n");
+	}
+
+	free_irq(adapter->pdev->irq, netdev);
+	pci_disable_msi(adapter->pdev);
+
+	if (err == -EIO)
+		goto msi_test_failed;
+
+	/* okay so the test worked, restore settings */
+	ndev_dbg(netdev, "MSI interrupt test succeeded!\n");
+msi_test_failed:
+	/* restore the original vector, even if it failed */
+	e1000_request_irq(adapter);
+	return err;
+}
+
+/**
+ * e1000_test_msi - Returns 0 if MSI test succeeds or INTx mode is restored
+ * @adapter: board private struct
+ *
+ * code flow taken from tg3.c, called with e1000 interrupts disabled.
+ **/
+static int e1000_test_msi(struct e1000_adapter *adapter)
+{
+	int err;
+	u16 pci_cmd;
+
+	if (!(adapter->flags & FLAG_MSI_ENABLED))
+		return 0;
+
+	/* disable SERR in case the MSI write causes a master abort */
+	pci_read_config_word(adapter->pdev, PCI_COMMAND, &pci_cmd);
+	pci_write_config_word(adapter->pdev, PCI_COMMAND,
+			      pci_cmd & ~PCI_COMMAND_SERR);
+
+	err = e1000_test_msi_interrupt(adapter);
+
+	/* restore previous setting of command word */
+	pci_write_config_word(adapter->pdev, PCI_COMMAND, pci_cmd);
+
+	/* success ! */
+	if (!err)
+		return 0;
+
+	/* EIO means MSI test failed */
+	if (err != -EIO)
+		return err;
+
+	/* back to INTx mode */
+	ndev_warn(adapter->netdev, "MSI interrupt test failed, using legacy "
+		  "interrupt.\n");
+
+	e1000_free_irq(adapter);
+
+	err = e1000_request_irq(adapter);
+
+	return err;
+}
+
+/**
  * e1000_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2288,6 +2422,17 @@ static int e1000_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
+	/*
+	 * Work around PCIe errata with MSI interrupts causing some chipsets to
+	 * ignore e1000e MSI messages, which means we need to test our MSI
+	 * interrupt now
+	 */
+	err = e1000_test_msi(adapter);
+	if (err) {
+		ndev_err(netdev, "Interrupt allocation failed\n");
+		goto err_req_irq;
+	}
+
 	/* From here on the code is the same as e1000e_up() */
 	clear_bit(__E1000_DOWN, &adapter->state);
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
