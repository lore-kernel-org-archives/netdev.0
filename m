From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/3] r8169 driver fixes
Date: Thu, 3 Feb 2011 18:26:11 +0100
Message-ID: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59338 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab1BCR2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 12:28:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series includes Ivan Rx fifo overflow fix and similar
changes I did after testing with various 8168 chipsets.

The series is available as
git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r81=
69-davem

Distance from 'master' (2ba451421b23636c45fabfa522858c5c124b3673)
-----------------------------------------------------------------

0331b3b022b9724019e4c42fded4a01eaa6946f5
407786ae1960eef585f97bfa7625a36512925de0
e4b6fa3d3d3db4fac32904ae12efe199de8efed0

Diffstat
--------

 drivers/net/r8169.c |   41 ++++++++++++++++++++++++++++++++---------
 1 files changed, 32 insertions(+), 9 deletions(-)

Shortlog
--------

=46rancois Romieu (2):
      r8169: RxFIFO overflow oddities with 8168 chipsets
      r8169: prevent RxFIFO induced loops in the irq handler.

Ivan Vecera (1):
      r8169: use RxFIFO overflow workaround for 8168c chipset

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bde7d61..59ccf0c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -973,7 +973,8 @@ static void __rtl8169_check_link_status(struct net_=
device *dev,
 		if (pm)
 			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
-		netif_info(tp, ifup, dev, "link up\n");
+		if (net_ratelimit())
+			netif_info(tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
 		netif_info(tp, ifdown, dev, "link down\n");
@@ -3757,7 +3758,8 @@ static void rtl_hw_start_8168(struct net_device *=
dev)
 	RTL_W16(IntrMitigate, 0x5151);
=20
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11) {
+	if (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11 ||
+	    tp->mac_version =3D=3D RTL_GIGA_MAC_VER_22) {
 		tp->intr_event |=3D RxFIFOOver | PCSTimeout;
 		tp->intr_event &=3D ~RxOverflow;
 	}
@@ -4639,12 +4641,33 @@ static irqreturn_t rtl8169_interrupt(int irq, v=
oid *dev_instance)
 			break;
 		}
=20
-		/* Work around for rx fifo overflow */
-		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11)) {
-			netif_stop_queue(dev);
-			rtl8169_tx_timeout(dev);
-			break;
+		if (unlikely(status & RxFIFOOver)) {
+			switch (tp->mac_version) {
+			/* Work around for rx fifo overflow */
+			case RTL_GIGA_MAC_VER_11:
+			case RTL_GIGA_MAC_VER_22:
+			case RTL_GIGA_MAC_VER_26:
+				netif_stop_queue(dev);
+				rtl8169_tx_timeout(dev);
+				goto done;
+			/* Testers needed. */
+			case RTL_GIGA_MAC_VER_17:
+			case RTL_GIGA_MAC_VER_19:
+			case RTL_GIGA_MAC_VER_20:
+			case RTL_GIGA_MAC_VER_21:
+			case RTL_GIGA_MAC_VER_23:
+			case RTL_GIGA_MAC_VER_24:
+			case RTL_GIGA_MAC_VER_27:
+			case RTL_GIGA_MAC_VER_28:
+			/* Experimental science. Pktgen proof. */
+			case RTL_GIGA_MAC_VER_12:
+			case RTL_GIGA_MAC_VER_25:
+				if (status =3D=3D RxFIFOOver)
+					goto done;
+				break;
+			default:
+				break;
+			}
 		}
=20
 		if (unlikely(status & SYSErr)) {
@@ -4680,7 +4703,7 @@ static irqreturn_t rtl8169_interrupt(int irq, voi=
d *dev_instance)
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 		status =3D RTL_R16(IntrStatus);
 	}
-
+done:
 	return IRQ_RETVAL(handled);
 }
=20
--=20
Ueimor
=E7=A5=9D=E4=BD=A0 =E6=96=B0=E5=B9=B4=E5=BF=AB=E4=B9=90=EF=BC=8C=E5=85=94=
=E5=B9=B4=E5=90=89=E7=A5=A5=EF=BC=8C=E5=BF=83=E6=83=B3=E4=BA=8B=E6=88=90=
=EF=BC=8C=E4=BA=8B=E4=BA=8B=E9=A1=BA=E5=88=A9, =E4=B8=87=E4=BA=8B=E5=A6=
=82=E6=84=8F=EF=BC=8C=E6=81=AD=E5=96=9C=E5=8F=91=E8=B4=A2 !
