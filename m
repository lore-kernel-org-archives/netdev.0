From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 16/21] orinoco_pci: disable device and free IRQ when suspending
Date: Fri, 07 Apr 2006 04:10:51 -0400
Message-ID: <20060407081051.16107.87289.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_pci.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/or=
inoco_pci.c
index 5362c21..e57e92b 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -304,7 +304,9 @@ static int orinoco_pci_suspend(struct pc
 =09
 	orinoco_unlock(priv, &flags);
=20
+	free_irq(pdev->irq, dev);
 	pci_save_state(pdev);
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
=20
 	return 0;
@@ -320,7 +322,16 @@ static int orinoco_pci_resume(struct pci
 	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
=20
 	pci_set_power_state(pdev, 0);
+	pci_enable_device(pdev);
 	pci_restore_state(pdev);
+
+	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: Cannot re-allocate IRQ\n", dev->name);
+		pci_disable_device(pdev);
+		return -EBUSY;
+	}
=20
 	err =3D orinoco_reinit_firmware(dev);
 	if (err) {



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
