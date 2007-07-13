From: Mika.Lansirinne@stonesoft.com
Subject: Re: [PATCH 2.6.22-rc7] 8139cp: dev->tx_timeout
Date: Fri, 13 Jul 2007 18:26:18 +0300
Message-ID: <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
References: <4693B6ED.5030102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-2b.stonesoft.com ([84.34.144.172]:35466 "EHLO
	hki-smtp-2b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759787AbXGMP02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 11:26:28 -0400
In-Reply-To: <4693B6ED.5030102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm... that's strange. I just tested again and got it applied perfectly to
vanilla 2.6.22-rc7. The git version must be just that much different.


Can you test this one, this time it's made against the netdev-2.6 version.
There indeed is a slight offset in the line numbers.


By the way, we just got the problem recurred again. The timeout reset did
enable the traffic to flow again after a hang, so this patch clearly helps.

The problem "requires" very heavy network load when the tx queue is
constantly quite full.



-Mika



Jeff Garzik <jeff@garzik.org> wrote on 10.07.2007 19:42:21:

> Mika.Lansirinne@stonesoft.com wrote:
> > (Resending the patch against 2.6.22-rc7)
> >
> > This patch implements the missing dev->tx_timeout for 8139cp driver
> >
> > Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
>
> ACK but still fails to apply
>
>

---

This patch implements the missing dev->tx_timeout for 8139cp driver

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>

---

--- netdev-2.6/drivers/net/8139cp.c 2007-07-11 13:19:56.000000000 +0300
+++ netdev-2.6_8139cp-tx_timeout/drivers/net/8139cp.c 2007-07-11 13:26:44.000000000 +0300
@@ -26,7 +26,6 @@

      TODO:
      * Test Tx checksumming thoroughly
-     * Implement dev->tx_timeout

      Low priority TODO:
      * Complete reset on PciErr
@@ -1218,6 +1217,30 @@ static int cp_close (struct net_device *
      return 0;
 }

+static void cp_tx_timeout(struct net_device *dev)
+{
+     struct cp_private *cp = netdev_priv(dev);
+     int rc;
+     unsigned long flags;
+
+        printk (KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
+                dev->name, cpr8(Cmd), cpr16(CpCmd),
+                cpr16(IntrStatus), cpr16(IntrMask));
+
+     spin_lock_irqsave(&cp->lock, flags);
+
+     cp_stop_hw(cp);
+     cp_clean_rings(cp);
+     rc = cp_init_rings(cp);
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
@@ -1923,10 +1946,8 @@ static int cp_init_one (struct pci_dev *
      dev->change_mtu = cp_change_mtu;
 #endif
      dev->ethtool_ops = &cp_ethtool_ops;
-#if 0
      dev->tx_timeout = cp_tx_timeout;
      dev->watchdog_timeo = TX_TIMEOUT;
-#endif

 #if CP_VLAN_TAG_USED
      dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;


