From: Mika.Lansirinne@stonesoft.com
Subject: [PATCH] 8139cp dev->tx_timeout
Date: Wed, 27 Jun 2007 11:11:24 +0300
Message-ID: <OFC04C6285.18455C26-ONC2257306.00364F82-C2257307.002CFBE9@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stonesoft.com ([84.34.144.172]:57164 "EHLO
	hki-smtp-2b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbXF0Ib2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:31:28 -0400
Received: from hki-smtp-2b.stonesoft.com (localhost.localdomain [127.0.0.1])
	by localhost.stonesoft.com (Postfix) with ESMTP id C40561B4050
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 11:11:28 +0300 (EEST)
Received: from hki-notes-1.stonesoft.com (unknown [172.16.49.35])
	by hki-smtp-2b.stonesoft.com (Postfix) with ESMTP id 9C7B628FABA
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 11:11:28 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello All,

We have been experimenting a couple of interface hangs with the 8139cp
driver. It appears that the tx buffer stops transmitting and never star=
ts
up again in some yet unknown conditions. To be able to circumvent this =
we
implemented the missing dev->tx_timeout function which should reset the
interface and allow it work again.

The problem reoccurs quite seldom and we have yet to be able to confirm
that the attached patch helps the situation. We though that we should
submit the patch anyway for reviewing.

The patch is made against 2.6.21.5 kernel.

(please cc me in your answer)


diff -ru linux-2.6.21.5/drivers/net/8139cp.c linux-2.6.21.5_8139cp-tx_t=
imeout/drivers/net/8139cp.c
--- linux-2.6.21.5/drivers/net/8139cp.c   2007-06-11 21:37:06.000000000=
 +0300
+++ linux-2.6.21.5_8139cp-tx_timeout/drivers/net/8139cp.c   2007-06-26 =
15:48:23.000000000 +0300
@@ -26,7 +26,6 @@

      TODO:
      * Test Tx checksumming thoroughly
-     * Implement dev->tx_timeout

      Low priority TODO:
      * Complete reset on PciErr
@@ -1233,6 +1232,30 @@
      return 0;
 }

+static void cp_tx_timeout(struct net_device *dev)
+{
+     struct cp_private *cp =3D netdev_priv(dev);
+     int rc;
+     unsigned long flags;
+
+        printk (KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x=
 %4x\n",
+                dev->name, cpr8(Cmd), cpr16(CpCmd),
+                cpr16(IntrStatus), cpr16(IntrMask));
+
+     spin_lock_irqsave(&cp->lock, flags);
+
+     cp_stop_hw(cp);
+     cp_clean_rings(cp);
+     rc =3D cp_init_rings(cp);
+     cp_start_hw(cp);
+
+     netif_wake_queue(dev);
+
+     spin_unlock_irqrestore(&cp->lock, flags);
+
+     return;
+}
+
 #ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1938,10 +1961,8 @@
      dev->change_mtu =3D cp_change_mtu;
 #endif
      dev->ethtool_ops =3D &cp_ethtool_ops;
-#if 0
      dev->tx_timeout =3D cp_tx_timeout;
      dev->watchdog_timeo =3D TX_TIMEOUT;
-#endif

 #if CP_VLAN_TAG_USED
      dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;



Best regards,

Mr. Mika L=E4nsirinne
Sofware Specialist
Stonesoft Corporation
It=E4lahdenkatu 22 A, FIN-00210 Helsinki, Finland
Mobile. +358-40-749 2068
Mika.Lansirinne@stonesoft.com
http://www.stonesoft.com

