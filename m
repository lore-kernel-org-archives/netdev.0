From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 9/12]bnx2x: Add PCIE EEH support
Date: Tue, 27 May 2008 10:17:38 -0400
Message-ID: <1211897859.6967.82.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>,
	"Wendy Xiong" <wendyx@us.ibm.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1084 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756235AbYE0OR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Add PCIE EEH support
=EF=BB=BF
=EF=BB=BF=EF=BB=BFSigned-off-by: =EF=BB=BFWendy Xiong <wendyx@us.ibm.co=
m>
=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   96 ++++++++++++++++++++++++++++++++++++++=
+++++---
 1 files changed, 90 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5e824a3..5ab6013 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9988,13 +9988,97 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	return 0;
 }
=20
+/**
+ * bnx2x_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnx2x_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	rtnl_lock();
+	netif_device_detach(dev);
+
+	if (netif_running(dev))
+		bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+
+	pci_disable_device(pdev);
+	rtnl_unlock();
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnx2x_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	rtnl_lock();
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		rtnl_unlock();
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	if (netif_running(dev))
+		bnx2x_set_power_state(bp, PCI_D0);
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+	rtnl_unlock();
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnx2x_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us tha=
t
+ * its OK to resume normal operation.
+ */
+static void bnx2x_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct bnx2x *bp =3D netdev_priv(dev);
+
+	rtnl_lock();
+
+	if (netif_running(dev))
+		bnx2x_nic_load(bp, LOAD_OPEN);
+	netif_device_attach(dev);
+
+	rtnl_unlock();
+}
+
+static struct pci_error_handlers bnx2x_err_handler =3D {
+	.error_detected =3D bnx2x_io_error_detected,
+	.slot_reset =3D bnx2x_io_slot_reset,
+	.resume =3D bnx2x_io_resume,
+};
+
 static struct pci_driver bnx2x_pci_driver =3D {
-	.name       =3D DRV_MODULE_NAME,
-	.id_table   =3D bnx2x_pci_tbl,
-	.probe      =3D bnx2x_init_one,
-	.remove     =3D __devexit_p(bnx2x_remove_one),
-	.suspend    =3D bnx2x_suspend,
-	.resume     =3D bnx2x_resume,
+	.name        =3D DRV_MODULE_NAME,
+	.id_table    =3D bnx2x_pci_tbl,
+	.probe       =3D bnx2x_init_one,
+	.remove      =3D __devexit_p(bnx2x_remove_one),
+	.suspend     =3D bnx2x_suspend,
+	.resume      =3D bnx2x_resume,
+	.err_handler =3D &bnx2x_err_handler,
 };
=20
 static int __init bnx2x_init(void)
--=20
1.5.5




