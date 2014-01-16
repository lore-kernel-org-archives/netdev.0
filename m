From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH] e1000e: Fix compilation warning when !CONFIG_PM_SLEEP
Date: Thu, 16 Jan 2014 14:39:39 +0200
Message-ID: <1389875979-30340-1-git-send-email-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aaron Brown <aaron.f.brown@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	netdev@vger.kernel.org
To: Dave Ertman <davidx.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18838 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbaAPMjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 07:39:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7509963c703b (e1000e: Fix a compile flag mis-match for
suspend/resume) moved suspend and resume hooks to be available when
CONFIG_PM is set. However, it can be set even if CONFIG_PM_SLEEP is not=
 set
causing following warnings to be emitted:

drivers/net/ethernet/intel/e1000e/netdev.c:6178:12: warning:
  	=E2=80=98e1000_suspend=E2=80=99 defined but not used [-Wunused-funct=
ion]

drivers/net/ethernet/intel/e1000e/netdev.c:6185:12: warning:
	=E2=80=98e1000_resume=E2=80=99 defined but not used [-Wunused-function=
]

To fix this make the hooks to be available only when CONFIG_PM_SLEEP is=
 set
and remove CONFIG_PM wrapping from driver ops because this is already
handled by SET_SYSTEM_SLEEP_PM_OPS() and SET_RUNTIME_PM_OPS().

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Cc: Dave Ertman <davidx.m.ertman@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
index c30d41d6e426..6d14eea17918 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6174,7 +6174,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
=20
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int e1000_suspend(struct device *dev)
 {
 	struct pci_dev *pdev =3D to_pci_dev(dev);
@@ -6193,7 +6193,7 @@ static int e1000_resume(struct device *dev)
=20
 	return __e1000_resume(pdev);
 }
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
=20
 #ifdef CONFIG_PM_RUNTIME
 static int e1000_runtime_suspend(struct device *dev)
@@ -7015,13 +7015,11 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) =3D=
 {
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
=20
-#ifdef CONFIG_PM
 static const struct dev_pm_ops e1000_pm_ops =3D {
 	SET_SYSTEM_SLEEP_PM_OPS(e1000_suspend, e1000_resume)
 	SET_RUNTIME_PM_OPS(e1000_runtime_suspend, e1000_runtime_resume,
 			   e1000_idle)
 };
-#endif
=20
 /* PCI Device API Driver */
 static struct pci_driver e1000_driver =3D {
@@ -7029,11 +7027,9 @@ static struct pci_driver e1000_driver =3D {
 	.id_table =3D e1000_pci_tbl,
 	.probe    =3D e1000_probe,
 	.remove   =3D e1000_remove,
-#ifdef CONFIG_PM
 	.driver   =3D {
 		.pm =3D &e1000_pm_ops,
 	},
-#endif
 	.shutdown =3D e1000_shutdown,
 	.err_handler =3D &e1000_err_handler
 };
--=20
1.8.5.2
