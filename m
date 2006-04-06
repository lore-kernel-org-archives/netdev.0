From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] PCI Error Recovery: e100 network device driver
Date: Thu, 6 Apr 2006 17:24:00 -0500
Message-ID: <20060406222359.GA30037@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


Please apply and forward upstream.

--linas

[PATCH] PCI Error Recovery: e100 network device driver

Various PCI bus errors can be signaled by newer PCI controllers.  This
patch adds the PCI error recovery callbacks to the intel ethernet e100
device driver. The patch has been tested, and appears to work well.

Signed-off-by: Linas Vepstas <linas@linas.org>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

----

 drivers/net/e100.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+)

Index: linux-2.6.17-rc1/drivers/net/e100.c
===================================================================
--- linux-2.6.17-rc1.orig/drivers/net/e100.c	2006-04-05 09:56:06.000000000 -0500
+++ linux-2.6.17-rc1/drivers/net/e100.c	2006-04-06 15:17:29.000000000 -0500
@@ -2781,6 +2781,70 @@ static void e100_shutdown(struct pci_dev
 }
 
 
+/* ------------------ PCI Error Recovery infrastructure  -------------- */
+/** e100_io_error_detected() is called when PCI error is detected */
+static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+
+	/* Same as calling e100_down(netdev_priv(netdev)), but generic */
+	netdev->stop(netdev);
+
+	/* Detach; put netif into state similar to hotplug unplug */
+	netif_poll_enable(netdev);
+	netif_device_detach(netdev);
+
+	/* Request a slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/** e100_io_slot_reset is called after the pci bus has been reset.
+ *  Restart the card from scratch. */
+static pci_ers_result_t e100_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	if(pci_enable_device(pdev)) {
+		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+
+	/* Only one device per card can do a reset */
+	if (0 != PCI_FUNC (pdev->devfn))
+		return PCI_ERS_RESULT_RECOVERED;
+	e100_hw_reset(nic);
+	e100_phy_init(nic);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/** e100_io_resume is called when the error recovery driver
+ *  tells us that its OK to resume normal operation.
+ */
+static void e100_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	/* ack any pending wake events, disable PME */
+	pci_enable_wake(pdev, 0, 0);
+
+	netif_device_attach(netdev);
+	if(netif_running(netdev)) {
+		e100_open (netdev);
+		mod_timer(&nic->watchdog, jiffies);
+	}
+}
+
+static struct pci_error_handlers e100_err_handler = {
+	.error_detected = e100_io_error_detected,
+	.slot_reset = e100_io_slot_reset,
+	.resume = e100_io_resume,
+};
+
+
 static struct pci_driver e100_driver = {
 	.name =         DRV_NAME,
 	.id_table =     e100_id_table,
@@ -2791,6 +2855,7 @@ static struct pci_driver e100_driver = {
 	.resume =       e100_resume,
 #endif
 	.shutdown =     e100_shutdown,
+	.err_handler = &e100_err_handler,
 };
 
 static int __init e100_init_module(void)
