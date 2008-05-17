From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 01:24:11 +0200
Message-ID: <20080517232411.GA8792@yamamaya.is-a-geek.org>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <200805172156.12686.rjw@sisk.pl> <20080517223622.GA2668@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:44633 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbYEQXYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 19:24:42 -0400
Content-Disposition: inline
In-Reply-To: <20080517223622.GA2668@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> > > Shouldn't there be a 'prepare for poweroff'-callback, which gets
> > > called
> > > before the system is powered off for real?
> >=20
> > Yes, it should and it's called in recent kernels.
>=20
> For what values of 'recent'?
> I'm running 2.6.26-rc2 here. :)
> How do I hook into this callback?
> (suspend_late maybe? Going to try that one next...)

Ok, this patch fixes the 'regression' introduced by the previous
patch (at least for me ;)):

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 =
01:10:18.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 01:11=
:33.000000000 +0200
@@ -5828,8 +5828,24 @@
 out:
 	return rc;
 }
+
+static void nv_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct fe_priv *np =3D netdev_priv(dev);
+	u8 __iomem *base =3D get_hwbase(dev);
+
+	if (netif_running(dev))
+		nv_close(dev);
+
+	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+}
 #else
 #define nv_suspend NULL
+#define nv_shutdown NULL
 #define nv_resume NULL
 #endif /* CONFIG_PM */
=20
@@ -6000,6 +6016,7 @@
 	.remove		=3D __devexit_p(nv_remove),
 	.suspend	=3D nv_suspend,
 	.resume		=3D nv_resume,
+	.shutdown	=3D nv_shutdown,
 };
=20
 static int __init init_nic(void)

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
