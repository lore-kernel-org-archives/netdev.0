From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH V2 1/6] net/ethernet/atl1c: Disable ASPM on various chipsets
Date: Fri, 11 Nov 2011 11:14:19 -0500
Message-ID: <1321028064-644-2-git-send-email-mjg@redhat.com>
References: <1321028064-644-1-git-send-email-mjg@redhat.com>
Cc: Matthew Garrett <mjg@redhat.com>, netdev@vger.kernel.org,
	jcliburn@gmail.com, chris.snook@gmail.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321028064-644-1-git-send-email-mjg@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Windows driver disables ASPM support for various chipsets supported
by atl1c. This adds the same set of logic to the Linux driver. ASPM is
disabled on l1c, l2c, l2cb and l2cb2 devices except for those in Toshiba
or Lenovo devices. Data taken from
http://www.atheros.cz/atheros-inf-file.php?inf=199&chipset=51&system=6

Signed-off-by: Matthew Garrett <mjg@redhat.com>
Cc: netdev@vger.kernel.org
Cc: jcliburn@gmail.com
Cc: chris.snook@gmail.com
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 02c7ed8..d91dabd 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -19,6 +19,7 @@
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
 
+#include <linux/pci-aspm.h>
 #include "atl1c.h"
 
 #define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
@@ -2652,6 +2653,20 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 
 	int err = 0;
 
+	switch (pdev->device) {
+	case PCI_DEVICE_ID_ATTANSIC_L1C:
+	case PCI_DEVICE_ID_ATTANSIC_L2C:
+	case PCI_DEVICE_ID_ATHEROS_L2C_B:
+	case PCI_DEVICE_ID_ATHEROS_L2C_B2:
+		if (pdev->subsystem_vendor == PCI_VENDOR_ID_TOSHIBA ||
+		    pdev->subsystem_vendor == PCI_VENDOR_ID_LENOVO)
+			break;
+		pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S |
+				       PCIE_LINK_STATE_L1 |
+				       PCIE_LINK_STATE_CLKPM);
+		break;
+	}
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	err = pci_enable_device_mem(pdev);
 	if (err) {
-- 
1.7.7.1
