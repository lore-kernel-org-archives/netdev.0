From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 18/21] orinoco: support PCI suspend/resume for Nortel, PLX and TMD adaptors
Date: Fri, 07 Apr 2006 04:10:55 -0400
Message-ID: <20060407081055.16107.7233.stgit@dv.roinet.com>
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

Copy PCI suspend/resume functions from orinoco_pci.c.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_nortel.c |   87 +++++++++++++++++++++++++++=
++++--
 drivers/net/wireless/orinoco_plx.c    |   79 +++++++++++++++++++++++++++=
+++
 drivers/net/wireless/orinoco_tmd.c    |   79 +++++++++++++++++++++++++++=
+++
 3 files changed, 241 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless=
/orinoco_nortel.c
index d1a670b..3fff013 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -263,6 +263,83 @@ static void __devexit nortel_pci_remove_
 	pci_disable_device(pdev);
 }
=20
+static int orinoco_nortel_suspend(struct pci_dev *pdev, pm_message_t sta=
te)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	err =3D orinoco_lock(priv, &flags);
+	if (err) {
+		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
+		       dev->name);
+		return err;
+	}
+
+	err =3D __orinoco_down(dev);
+	if (err)
+		printk(KERN_WARNING "%s: error %d bringing interface down "
+		       "for suspend\n", dev->name, err);
+=09
+	netif_device_detach(dev);
+
+	priv->hw_unavailable++;
+=09
+	orinoco_unlock(priv, &flags);
+
+	free_irq(pdev->irq, dev);
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int orinoco_nortel_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	pci_set_power_state(pdev, 0);
+	pci_enable_device(pdev);
+	pci_restore_state(pdev);
+
+	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
+		       dev->name);
+		pci_disable_device(pdev);
+		return -EBUSY;
+	}
+
+	err =3D orinoco_reinit_firmware(dev);
+	if (err) {
+		printk(KERN_ERR "%s: error %d re-initializing firmware "
+		       "on resume\n", dev->name, err);
+		return err;
+	}
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	netif_device_attach(dev);
+
+	priv->hw_unavailable--;
+
+	if (priv->open && (! priv->hw_unavailable)) {
+		err =3D __orinoco_up(dev);
+		if (err)
+			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
+			       dev->name, err);
+	}
+=09
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
=20
 static struct pci_device_id nortel_pci_id_table[] =3D {
 	/* Nortel emobility PCI */
@@ -275,10 +352,12 @@ static struct pci_device_id nortel_pci_i
 MODULE_DEVICE_TABLE(pci, nortel_pci_id_table);
=20
 static struct pci_driver nortel_pci_driver =3D {
-	.name =3D DRIVER_NAME,
-	.id_table =3D nortel_pci_id_table,
-	.probe =3D nortel_pci_init_one,
-	.remove =3D __devexit_p(nortel_pci_remove_one),
+	.name		=3D DRIVER_NAME,
+	.id_table	=3D nortel_pci_id_table,
+	.probe		=3D nortel_pci_init_one,
+	.remove		=3D __devexit_p(nortel_pci_remove_one),
+	.suspend	=3D orinoco_nortel_suspend,
+	.resume		=3D orinoco_nortel_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/or=
inoco_plx.c
index 210e737..3fe7a2f 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -343,6 +343,83 @@ static void __devexit orinoco_plx_remove
 	pci_disable_device(pdev);
 }
=20
+static int orinoco_plx_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	err =3D orinoco_lock(priv, &flags);
+	if (err) {
+		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
+		       dev->name);
+		return err;
+	}
+
+	err =3D __orinoco_down(dev);
+	if (err)
+		printk(KERN_WARNING "%s: error %d bringing interface down "
+		       "for suspend\n", dev->name, err);
+=09
+	netif_device_detach(dev);
+
+	priv->hw_unavailable++;
+=09
+	orinoco_unlock(priv, &flags);
+
+	free_irq(pdev->irq, dev);
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int orinoco_plx_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	pci_set_power_state(pdev, 0);
+	pci_enable_device(pdev);
+	pci_restore_state(pdev);
+
+	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
+		       dev->name);
+		pci_disable_device(pdev);
+		return -EBUSY;
+	}
+
+	err =3D orinoco_reinit_firmware(dev);
+	if (err) {
+		printk(KERN_ERR "%s: error %d re-initializing firmware "
+		       "on resume\n", dev->name, err);
+		return err;
+	}
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	netif_device_attach(dev);
+
+	priv->hw_unavailable--;
+
+	if (priv->open && (! priv->hw_unavailable)) {
+		err =3D __orinoco_up(dev);
+		if (err)
+			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
+			       dev->name, err);
+	}
+=09
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
=20
 static struct pci_device_id orinoco_plx_pci_id_table[] =3D {
 	{0x111a, 0x1023, PCI_ANY_ID, PCI_ANY_ID,},	/* Siemens SpeedStream SS102=
3 */
@@ -369,6 +446,8 @@ static struct pci_driver orinoco_plx_dri
 	.id_table	=3D orinoco_plx_pci_id_table,
 	.probe		=3D orinoco_plx_init_one,
 	.remove		=3D __devexit_p(orinoco_plx_remove_one),
+	.suspend	=3D orinoco_plx_suspend,
+	.resume		=3D orinoco_plx_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/or=
inoco_tmd.c
index 5e68b70..b74807d 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -215,6 +215,83 @@ static void __devexit orinoco_tmd_remove
 	pci_disable_device(pdev);
 }
=20
+static int orinoco_tmd_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	err =3D orinoco_lock(priv, &flags);
+	if (err) {
+		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
+		       dev->name);
+		return err;
+	}
+
+	err =3D __orinoco_down(dev);
+	if (err)
+		printk(KERN_WARNING "%s: error %d bringing interface down "
+		       "for suspend\n", dev->name, err);
+=09
+	netif_device_detach(dev);
+
+	priv->hw_unavailable++;
+=09
+	orinoco_unlock(priv, &flags);
+
+	free_irq(pdev->irq, dev);
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int orinoco_tmd_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	pci_set_power_state(pdev, 0);
+	pci_enable_device(pdev);
+	pci_restore_state(pdev);
+
+	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
+		       dev->name);
+		pci_disable_device(pdev);
+		return -EBUSY;
+	}
+
+	err =3D orinoco_reinit_firmware(dev);
+	if (err) {
+		printk(KERN_ERR "%s: error %d re-initializing firmware "
+		       "on resume\n", dev->name, err);
+		return err;
+	}
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	netif_device_attach(dev);
+
+	priv->hw_unavailable--;
+
+	if (priv->open && (! priv->hw_unavailable)) {
+		err =3D __orinoco_up(dev);
+		if (err)
+			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
+			       dev->name, err);
+	}
+=09
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
=20
 static struct pci_device_id orinoco_tmd_pci_id_table[] =3D {
 	{0x15e8, 0x0131, PCI_ANY_ID, PCI_ANY_ID,},      /* NDC and OEMs, e.g. p=
heecom */
@@ -228,6 +305,8 @@ static struct pci_driver orinoco_tmd_dri
 	.id_table	=3D orinoco_tmd_pci_id_table,
 	.probe		=3D orinoco_tmd_init_one,
 	.remove		=3D __devexit_p(orinoco_tmd_remove_one),
+	.suspend	=3D orinoco_tmd_suspend,
+	.resume		=3D orinoco_tmd_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
