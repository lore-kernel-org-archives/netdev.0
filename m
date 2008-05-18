From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 13:22:48 +0200
Message-ID: <20080518112247.GA10502@yamamaya.is-a-geek.org>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <20080517223622.GA2668@yamamaya.is-a-geek.org> <20080517232411.GA8792@yamamaya.is-a-geek.org> <200805181245.13899.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:48151 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbYERLXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 07:23:21 -0400
Content-Disposition: inline
In-Reply-To: <200805181245.13899.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> > Tobias Diedrich wrote:
> > > > > Shouldn't there be a 'prepare for poweroff'-callback, which g=
ets
> > > > > called
> > > > > before the system is powered off for real?
> > > >=20
> > > > Yes, it should and it's called in recent kernels.
> > >=20
> > > For what values of 'recent'?
> > > I'm running 2.6.26-rc2 here. :)
> > > How do I hook into this callback?
> > > (suspend_late maybe? Going to try that one next...)
> >=20
> > Ok, this patch fixes the 'regression' introduced by the previous
> > patch (at least for me ;)):
>=20
> Well, what exactly do you do to hibernate the box?

/usr/local/bin/s2disk:
|#!/bin/sh
|
|SYSPRINTK=3D/proc/sys/kernel/printk
|OLDPRINTK=3D$(cat $SYSPRINTK)
|chvt 1
|# work around forcedeth wake-on-lan bug
|#rmmod forcedeth
|echo 9 > $SYSPRINTK
|# shutdown/reboot/platform
|echo shutdown > /sys/power/disk
|echo disk > /sys/power/state
|echo "$OLDPRINTK" > $SYSPRINTK
|# work around forcedeth wake-on-lan bug
|#modprobe forcedeth
|#brctl addif br0 eth0
|#brctl addif br0 eth1
|#ifconfig eth0 up
|#ifconfig eth1 up

I now also now why I get the 'swapped mac' problem:

In my case (DEV_HAS_CORRECT_MACADDR unset and
NVREG_TRANSMITPOLL_MAC_ADDR_REV unset on probe)
nv_probe() reads the original macaddress in reversed order to
correct it and sets NVREG_TRANSMITPOLL_MAC_ADDR_REV.

However the suspend/resume path does not touch the mac address at
all, so after a cold boot and resume from disk the macaddress is
again in 'BIOS order' and NVREG_TRANSMITPOLL_MAC_ADDR_REV is unset,
but NVREG_TRANSMITPOLL_MAC_ADDR_REV gets set unconditionally in
nv_resume(), so the net effect is that the MAC is now reversed.

With the promisc fix this is hidden for my brige setup and only
noticeable at the next hibernate, where I now have to use a reversed
MAC to wakeup the device.

The following patch (on top of the other two) fixes this by saving
and restoring the memory mapped device configuration space in
suspend/resume.  The shutdown hook is still needed since the promisc
mode seems to be incompatible with wake on lan.

It also reorders the code in suspend/resume to match that in e100/e1000=
e.
(configuration space is also saved for devices that are not running)

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 =
11:26:12.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:00=
:23.000000000 +0200
@@ -426,6 +426,7 @@
 #define NV_PCI_REGSZ_VER1      	0x270
 #define NV_PCI_REGSZ_VER2      	0x2d4
 #define NV_PCI_REGSZ_VER3      	0x604
+#define NV_PCI_REGSZ_MAX       	0x604
=20
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -784,6 +785,9 @@
=20
 	/* flow control */
 	u32 pause_flags;
+
+	/* power saved state */
+	u32 saved_config_space[NV_PCI_REGSZ_MAX/4];
 };
=20
 /*
@@ -5785,19 +5789,24 @@
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct fe_priv *np =3D netdev_priv(dev);
-
-	if (!netif_running(dev))
-		goto out;
+	u8 __iomem *base =3D get_hwbase(dev);
+	int i;
=20
 	netif_device_detach(dev);
=20
-	// Gross.
-	nv_close(dev);
+	if (netif_running(dev)) {
+		// Gross.
+		nv_close(dev);
+	}
+
+	/* save non-pci configuration space */
+	for (i =3D 0;i <=3D np->register_size/sizeof(u32); i++)
+		np->saved_config_space[i] =3D readl(base + i*sizeof(u32));
=20
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
=20
 	return 0;
 }
@@ -5805,27 +5814,25 @@
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct fe_priv *np =3D netdev_priv(dev);
 	u8 __iomem *base =3D get_hwbase(dev);
-	int rc =3D 0;
-	u32 txreg;
-
-	if (!netif_running(dev))
-		goto out;
-
-	netif_device_attach(dev);
+	int i, rc =3D 0;
=20
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/* ack any pending wake events, disable PME */
 	pci_enable_wake(pdev, PCI_D0, 0);
=20
-	/* restore mac address reverse flag */
-	txreg =3D readl(base + NvRegTransmitPoll);
-	txreg |=3D NVREG_TRANSMITPOLL_MAC_ADDR_REV;
-	writel(txreg, base + NvRegTransmitPoll);
+	/* restore non-pci configuration space */
+	for (i =3D 0;i <=3D np->register_size/sizeof(u32); i++)
+		writel(np->saved_config_space[i], base+i*sizeof(u32));
+
+	netif_device_attach(dev);
+	if (netif_running(dev)) {
+		rc =3D nv_open(dev);
+		nv_set_multicast(dev);
+	}
=20
-	rc =3D nv_open(dev);
-	nv_set_multicast(dev);
-out:
 	return rc;
 }
=20
@@ -5833,7 +5840,6 @@
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct fe_priv *np =3D netdev_priv(dev);
-	u8 __iomem *base =3D get_hwbase(dev);
=20
 	if (netif_running(dev))
 		nv_close(dev);
@@ -5841,7 +5847,9 @@
 	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
 	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	if (np->wolenabled)=20
+		pci_set_power_state(pdev, PCI_D3hot);
+	else pci_set_power_state(pdev, PCI_D3cold);
 }
 #else
 #define nv_suspend NULL

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
