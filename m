From: "Woodruff, Richard" <r-woodruff2@ti.com>
Subject: [PATCH] Fix smc911x.c suspend/resume and power up issues.
Date: Wed, 2 Jul 2008 20:08:10 -0500
Message-ID: <13B9B4C6EF24D648824FF11BE8967162035BC6AEB3@dlee02.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_13B9B4C6EF24D648824FF11BE8967162035BC6AEB3dlee02enttico_"
To: "jgarzik@pobox.com" <jgarzik@pobox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:56517 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbYGCBIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:08:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_13B9B4C6EF24D648824FF11BE8967162035BC6AEB3dlee02enttico_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This patch fixes lockups seen on resume and allows a ifdown/ifup to work.

ifdown/up fix:
- MII BMCR_PDOWN is set on smc911x_close() but is not cleared on the
autonegotiaion path on open.  Clearing is added into smc911x_reset()
if bit was set after making sure chip is accessible.

suspend/resume fixes:
- When trying for D2 power state the part family specification says
MODE_CTRL_STS_EDPWRDOWN_ should be written before PM_CTRL, this was missing=
.
This same bit also needs to be cleared on resume after chip is woken.
- The sequence of resume was changed to match init {reset, config, enable}
from old {reset, enable, config}

Patch tested on SMC9211 variant on embedded boards.

Signed-off-by: Richard Woodruff <r-woodruff2@ti.com>

--- smc911x.c   2008-07-02 18:32:59.000000000 -0500
+++ ../smc911x.c        2008-07-02 19:24:35.000000000 -0500
@@ -232,14 +232,16 @@ static void smc911x_reset(struct net_dev
        struct smc911x_local *lp =3D netdev_priv(dev);
        unsigned int reg, timeout=3D0, resets=3D1;
        unsigned long flags;
+       int bmcr, phyaddr =3D lp->mii.phy_id;

        DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);

-       /*       Take out of PM setting first */
+       /* Take out of PM setting first */
        if ((SMC_GET_PMT_CTRL() & PMT_CTRL_READY_) =3D=3D 0) {
                /* Write to the bytetest will take out of powerdown */
                SMC_SET_BYTE_TEST(0);
                timeout=3D10;
+               /* no other writes to device before ready */
                do {
                        udelay(10);
                        reg =3D SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
@@ -248,6 +250,16 @@ static void smc911x_reset(struct net_dev
                        PRINTK("%s: smc911x_reset timeout waiting for PM re=
store\n", dev->name);
                        return;
                }
+               /* clear low power state */
+               SMC_SET_PHY_CTRL_STS(phyaddr, MODE_CTRL_STS_EDPWRDOWN_);
+
+               /* Link Power ON if off*/
+               SMC_GET_PHY_BMCR(phyaddr, bmcr);
+               if (bmcr & BMCR_PDOWN) {
+                       bmcr &=3D ~BMCR_PDOWN;
+                       SMC_SET_PHY_BMCR(phyaddr, bmcr);
+                       mdelay(10);
+               }
        }

        /* Disable all interrupts */
@@ -2207,18 +2219,28 @@ static int smc911x_drv_remove(struct pla
 static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t s=
tate)
 {
        struct net_device *ndev =3D platform_get_drvdata(dev);
-       unsigned long ioaddr =3D ndev->base_addr;
+       unsigned long flags, ioaddr =3D ndev->base_addr;

        DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
        if (ndev) {
-               if (netif_running(ndev)) {
+               struct smc911x_local *lp =3D netdev_priv(ndev);
+               spin_lock_irqsave(&lp->lock, flags);
+               if (netif_running(ndev))
                        netif_device_detach(ndev);
-                       smc911x_shutdown(ndev);
+
+               netif_stop_queue(ndev);
+               smc911x_shutdown(ndev);
+
 #if POWER_DOWN
-                       /* Set D2 - Energy detect only setting */
-                       SMC_SET_PMT_CTRL(2<<12);
-#endif
+               {
+               /* Set D2 - Energy detect only setting */
+               int phyaddr =3D lp->mii.phy_id;
+
+               SMC_SET_PHY_CTRL_STS(phyaddr, MODE_CTRL_STS_EDPWRDOWN_);
+               SMC_SET_PMT_CTRL(2<<12);
                }
+#endif
+               spin_unlock_irqrestore(&lp->lock, flags);
        }
        return 0;
 }
@@ -2226,18 +2248,20 @@ static int smc911x_drv_suspend(struct pl
 static int smc911x_drv_resume(struct platform_device *dev)
 {
        struct net_device *ndev =3D platform_get_drvdata(dev);
+       unsigned long flags;

        DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
        if (ndev) {
                struct smc911x_local *lp =3D netdev_priv(ndev);
+               spin_lock_irqsave(&lp->lock, flags);
+               smc911x_reset(ndev);
+               if (lp->phy_type !=3D 0)
+                       smc911x_phy_configure(&lp->phy_configure);
+               smc911x_enable(ndev);

-               if (netif_running(ndev)) {
-                       smc911x_reset(ndev);
-                       smc911x_enable(ndev);
-                       if (lp->phy_type !=3D 0)
-                               smc911x_phy_configure(&lp->phy_configure);
+               if (netif_running(ndev))
                        netif_device_attach(ndev);
-               }
+               spin_unlock_irqrestore(&lp->lock, flags);
        }
        return 0;
 }

--_002_13B9B4C6EF24D648824FF11BE8967162035BC6AEB3dlee02enttico_
Content-Type: application/octet-stream;
	name="smc911x_suspend_resume_fix.diff"
Content-Description: smc911x_suspend_resume_fix.diff
Content-Disposition: attachment; filename="smc911x_suspend_resume_fix.diff";
	size=3668; creation-date="Wed, 02 Jul 2008 20:04:43 GMT";
	modification-date="Wed, 02 Jul 2008 20:04:43 GMT"
Content-Transfer-Encoding: base64

VGhpcyBwYXRjaCBmaXhlcyBsb2NrdXBzIHNlZW4gb24gcmVzdW1lIGFuZCBhbGxvd3MgYSBpZmRv
d24vaWZ1cCB0byB3b3JrLgoKaWZkb3duL3VwIGZpeDoKLSBNSUkgQk1DUl9QRE9XTiBpcyBzZXQg
b24gc21jOTExeF9jbG9zZSgpIGJ1dCBpcyBub3QgY2xlYXJlZCBvbiB0aGUKYXV0b25lZ290aWFp
b24gcGF0aCBvbiBvcGVuLiAgQ2xlYXJpbmcgaXMgYWRkZWQgaW50byBzbWM5MTF4X3Jlc2V0KCkg
CmlmIGJpdCB3YXMgc2V0IGFmdGVyIG1ha2luZyBzdXJlIGNoaXAgaXMgYWNjZXNzaWJsZS4KCnN1
c3BlbmQvcmVzdW1lIGZpeGVzOgotIFdoZW4gdHJ5aW5nIGZvciBEMiBwb3dlciBzdGF0ZSB0aGUg
cGFydCBmYW1pbHkgc3BlY2lmaWNhdGlvbiBzYXlzCk1PREVfQ1RSTF9TVFNfRURQV1JET1dOXyBz
aG91bGQgYmUgd3JpdHRlbiBiZWZvcmUgUE1fQ1RSTCwgdGhpcyB3YXMgbWlzc2luZy4KVGhpcyBz
YW1lIGJpdCBhbHNvIG5lZWRzIHRvIGJlIGNsZWFyZWQgb24gcmVzdW1lIGFmdGVyIGNoaXAgaXMg
d29rZW4uCi0gVGhlIHNlcXVlbmNlIG9mIHJlc3VtZSB3YXMgY2hhbmdlZCB0byBtYXRjaCBpbml0
IHtyZXNldCwgY29uZmlnLCBlbmFibGV9CmZyb20gb2xkIHtyZXNldCwgZW5hYmxlLCBjb25maWd9
CgpQYXRjaCB0ZXN0ZWQgb24gU01DOTIxMSB2YXJpYW50IG9uIGVtYmVkZGVkIGJvYXJkcy4KClNp
Z25lZC1vZmYtYnk6IFJpY2hhcmQgV29vZHJ1ZmYgPHItd29vZHJ1ZmYyQHRpLmNvbT4KCi0tLSBz
bWM5MTF4LmMJMjAwOC0wNy0wMiAxODozMjo1OS4wMDAwMDAwMDAgLTA1MDAKKysrIC4uL3NtYzkx
MXguYwkyMDA4LTA3LTAyIDE5OjI0OjM1LjAwMDAwMDAwMCAtMDUwMApAQCAtMjMyLDE0ICsyMzIs
MTYgQEAgc3RhdGljIHZvaWQgc21jOTExeF9yZXNldChzdHJ1Y3QgbmV0X2RldgogCXN0cnVjdCBz
bWM5MTF4X2xvY2FsICpscCA9IG5ldGRldl9wcml2KGRldik7CiAJdW5zaWduZWQgaW50IHJlZywg
dGltZW91dD0wLCByZXNldHM9MTsKIAl1bnNpZ25lZCBsb25nIGZsYWdzOworCWludCBibWNyLCBw
aHlhZGRyID0gbHAtPm1paS5waHlfaWQ7CiAKIAlEQkcoU01DX0RFQlVHX0ZVTkMsICIlczogLS0+
ICVzXG4iLCBkZXYtPm5hbWUsIF9fRlVOQ1RJT05fXyk7CiAKLQkvKgkgVGFrZSBvdXQgb2YgUE0g
c2V0dGluZyBmaXJzdCAqLworCS8qIFRha2Ugb3V0IG9mIFBNIHNldHRpbmcgZmlyc3QgKi8KIAlp
ZiAoKFNNQ19HRVRfUE1UX0NUUkwoKSAmIFBNVF9DVFJMX1JFQURZXykgPT0gMCkgewogCQkvKiBX
cml0ZSB0byB0aGUgYnl0ZXRlc3Qgd2lsbCB0YWtlIG91dCBvZiBwb3dlcmRvd24gKi8KIAkJU01D
X1NFVF9CWVRFX1RFU1QoMCk7CiAJCXRpbWVvdXQ9MTA7CisJCS8qIG5vIG90aGVyIHdyaXRlcyB0
byBkZXZpY2UgYmVmb3JlIHJlYWR5ICovCiAJCWRvIHsKIAkJCXVkZWxheSgxMCk7CiAJCQlyZWcg
PSBTTUNfR0VUX1BNVF9DVFJMKCkgJiBQTVRfQ1RSTF9SRUFEWV87CkBAIC0yNDgsNiArMjUwLDE2
IEBAIHN0YXRpYyB2b2lkIHNtYzkxMXhfcmVzZXQoc3RydWN0IG5ldF9kZXYKIAkJCVBSSU5USygi
JXM6IHNtYzkxMXhfcmVzZXQgdGltZW91dCB3YWl0aW5nIGZvciBQTSByZXN0b3JlXG4iLCBkZXYt
Pm5hbWUpOwogCQkJcmV0dXJuOwogCQl9CisJCS8qIGNsZWFyIGxvdyBwb3dlciBzdGF0ZSAqLwor
CQlTTUNfU0VUX1BIWV9DVFJMX1NUUyhwaHlhZGRyLCBNT0RFX0NUUkxfU1RTX0VEUFdSRE9XTl8p
OworCisJCS8qIExpbmsgUG93ZXIgT04gaWYgb2ZmKi8KKwkJU01DX0dFVF9QSFlfQk1DUihwaHlh
ZGRyLCBibWNyKTsKKwkJaWYgKGJtY3IgJiBCTUNSX1BET1dOKSB7CisJCQlibWNyICY9IH5CTUNS
X1BET1dOOworCQkJU01DX1NFVF9QSFlfQk1DUihwaHlhZGRyLCBibWNyKTsKKwkJCW1kZWxheSgx
MCk7CisJCX0KIAl9CiAKIAkvKiBEaXNhYmxlIGFsbCBpbnRlcnJ1cHRzICovCkBAIC0yMjA3LDE4
ICsyMjE5LDI4IEBAIHN0YXRpYyBpbnQgc21jOTExeF9kcnZfcmVtb3ZlKHN0cnVjdCBwbGEKIHN0
YXRpYyBpbnQgc21jOTExeF9kcnZfc3VzcGVuZChzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlICpkZXYs
IHBtX21lc3NhZ2VfdCBzdGF0ZSkKIHsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqbmRldiA9IHBsYXRm
b3JtX2dldF9kcnZkYXRhKGRldik7Ci0JdW5zaWduZWQgbG9uZyBpb2FkZHIgPSBuZGV2LT5iYXNl
X2FkZHI7CisJdW5zaWduZWQgbG9uZyBmbGFncywgaW9hZGRyID0gbmRldi0+YmFzZV9hZGRyOwog
CiAJREJHKFNNQ19ERUJVR19GVU5DLCAiLS0+ICVzXG4iLCBfX0ZVTkNUSU9OX18pOwogCWlmIChu
ZGV2KSB7Ci0JCWlmIChuZXRpZl9ydW5uaW5nKG5kZXYpKSB7CisJCXN0cnVjdCBzbWM5MTF4X2xv
Y2FsICpscCA9IG5ldGRldl9wcml2KG5kZXYpOworCQlzcGluX2xvY2tfaXJxc2F2ZSgmbHAtPmxv
Y2ssIGZsYWdzKTsKKwkJaWYgKG5ldGlmX3J1bm5pbmcobmRldikpCiAJCQluZXRpZl9kZXZpY2Vf
ZGV0YWNoKG5kZXYpOwotCQkJc21jOTExeF9zaHV0ZG93bihuZGV2KTsKKworCQluZXRpZl9zdG9w
X3F1ZXVlKG5kZXYpOworCQlzbWM5MTF4X3NodXRkb3duKG5kZXYpOworCiAjaWYgUE9XRVJfRE9X
TgotCQkJLyogU2V0IEQyIC0gRW5lcmd5IGRldGVjdCBvbmx5IHNldHRpbmcgKi8KLQkJCVNNQ19T
RVRfUE1UX0NUUkwoMjw8MTIpOwotI2VuZGlmCisJCXsKKwkJLyogU2V0IEQyIC0gRW5lcmd5IGRl
dGVjdCBvbmx5IHNldHRpbmcgKi8KKwkJaW50IHBoeWFkZHIgPSBscC0+bWlpLnBoeV9pZDsKKwor
CQlTTUNfU0VUX1BIWV9DVFJMX1NUUyhwaHlhZGRyLCBNT0RFX0NUUkxfU1RTX0VEUFdSRE9XTl8p
OworCQlTTUNfU0VUX1BNVF9DVFJMKDI8PDEyKTsKIAkJfQorI2VuZGlmCisJCXNwaW5fdW5sb2Nr
X2lycXJlc3RvcmUoJmxwLT5sb2NrLCBmbGFncyk7CiAJfQogCXJldHVybiAwOwogfQpAQCAtMjIy
NiwxOCArMjI0OCwyMCBAQCBzdGF0aWMgaW50IHNtYzkxMXhfZHJ2X3N1c3BlbmQoc3RydWN0IHBs
CiBzdGF0aWMgaW50IHNtYzkxMXhfZHJ2X3Jlc3VtZShzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlICpk
ZXYpCiB7CiAJc3RydWN0IG5ldF9kZXZpY2UgKm5kZXYgPSBwbGF0Zm9ybV9nZXRfZHJ2ZGF0YShk
ZXYpOworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAKIAlEQkcoU01DX0RFQlVHX0ZVTkMsICItLT4g
JXNcbiIsIF9fRlVOQ1RJT05fXyk7CiAJaWYgKG5kZXYpIHsKIAkJc3RydWN0IHNtYzkxMXhfbG9j
YWwgKmxwID0gbmV0ZGV2X3ByaXYobmRldik7CisJCXNwaW5fbG9ja19pcnFzYXZlKCZscC0+bG9j
aywgZmxhZ3MpOworCQlzbWM5MTF4X3Jlc2V0KG5kZXYpOworCQlpZiAobHAtPnBoeV90eXBlICE9
IDApCisJCQlzbWM5MTF4X3BoeV9jb25maWd1cmUoJmxwLT5waHlfY29uZmlndXJlKTsKKwkJc21j
OTExeF9lbmFibGUobmRldik7CiAKLQkJaWYgKG5ldGlmX3J1bm5pbmcobmRldikpIHsKLQkJCXNt
YzkxMXhfcmVzZXQobmRldik7Ci0JCQlzbWM5MTF4X2VuYWJsZShuZGV2KTsKLQkJCWlmIChscC0+
cGh5X3R5cGUgIT0gMCkKLQkJCQlzbWM5MTF4X3BoeV9jb25maWd1cmUoJmxwLT5waHlfY29uZmln
dXJlKTsKKwkJaWYgKG5ldGlmX3J1bm5pbmcobmRldikpCiAJCQluZXRpZl9kZXZpY2VfYXR0YWNo
KG5kZXYpOwotCQl9CisJCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmxwLT5sb2NrLCBmbGFncyk7
CiAJfQogCXJldHVybiAwOwogfQo=

--_002_13B9B4C6EF24D648824FF11BE8967162035BC6AEB3dlee02enttico_--
