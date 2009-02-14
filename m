From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: [PATCH 1/1] net: forcedeth:
	f55c21fd9a92a444e55ad1ca4e4732d56661bf2e caused wake-on-lan
	regression
Date: Sat, 14 Feb 2009 16:12:00 +0100
Message-ID: <20090214151200.GA5496@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Yinghai Lu <yhlu.kernel@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Philipp Matthias Hahn <pmhahn@titan.lahn.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752756AbZBNPMU@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f55c21fd9a92a444e55ad1ca4e4732d56661bf2e, which was
introduced to fix the regression tracked at
http://bugzilla.kernel.org/show_bug.cgi?id=3D11358
causes the wake-on-lan mac to be reversed in the shutdown path.
Apparently the forcedeth situation is rather messy in that the mac
we need to writeback for a subsequent modprobe to work is exactly
the reverse of what is needed for proper wake-on-lan.

The following patch explains the situation in the comments and
makes the call to nv_restore_mac_addr() conditional (only called if
we are not really going for poweroff).

Tobias Diedrich wrote:
> Hmm, I had not tried WOL for some time.
> With 2.6.29-rc3 is see the following behaviour:
>=20
> State            WOL Behaviour
> ------------------------------
> shutdown         reversed MAC
> disk/shutdown    reversed MAC
> disk/platform    OK
>=20
> Apparently nv_restore_mac_addr() restores the MAC in the wrong order
> for WOL (at least for my PCI_DEVICE_ID_NVIDIA_NVENET_15).  platform
> works, because the MAC is not touched in the nv_suspend() path.
>=20
> A possible fix might be to only call nv_restore_mac_addr() if
> system_state !=3D SYSTEM_POWER_OFF.

With the following patch:
shutdown         OK
disk/shutdown    OK
disk/platform    OK
kexec            OK

Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Tested-by: Philipp Matthias Hahn <pmhahn@titan.lahn.de>

Index: linux-2.6.29-rc3/drivers/net/forcedeth.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.29-rc3.orig/drivers/net/forcedeth.c	2009-02-08 16:31:29.0=
00000000 +0100
+++ linux-2.6.29-rc3/drivers/net/forcedeth.c	2009-02-08 16:39:58.000000=
000 +0100
@@ -6011,9 +6011,20 @@
 	if (netif_running(dev))
 		nv_close(dev);
=20
-	nv_restore_mac_addr(pdev);
+	/*
+	 * Restore the MAC so a kernel started by kexec won't get confused.
+	 * If we really go for poweroff, we must not restore the MAC,
+	 * otherwise the MAC for WOL will be reversed at least on some boards=
=2E
+	 */
+	if (system_state !=3D SYSTEM_POWER_OFF) {
+		nv_restore_mac_addr(pdev);
+	}
=20
 	pci_disable_device(pdev);
+	/*
+	 * Apparently it is not possible to reinitialise from D3 hot,
+	 * only put the device into D3 if we really go for poweroff.
+	 */
 	if (system_state =3D=3D SYSTEM_POWER_OFF) {
 		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
 			pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
