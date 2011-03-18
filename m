From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH RFC] net: unify features for drivers which use skb_copy_and_csum_dev
Date: Fri, 18 Mar 2011 07:57:03 -0300
Message-ID: <1300445823-2968-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Tristram Ha <Tristram.Ha@micrel.com>,
	Roger Luethi <rl@hellgate.ch>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Cesar Eduardo Barros <cesarb@cesarb.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-03.mandic.com.br ([200.225.81.143]:52625 "EHLO
	smtp-03.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab1CRLEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 07:04:22 -0400
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 18 Mar 2011 10:57:40 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few network drivers use skb_copy_and_csum_dev as the core of their
=2Endo_start_xmit function. Which NETIF_F_* features these drivers can =
use
should depend only on the implementation of skb_copy_and_csum_dev, and
so should be the same for all of them.  However, I could find three
different sets of feature flags on these drivers.

To prevent these drivers from getting out of sync again, move this set
of feature flags to a central location. With the advantage that if the
set of flags is later found to be wrong or skb_copy_and_csum_dev is
modified, it can be changed in a single place.

This also enables NETIF_F_FRAGLIST for these drivers. Unless I misread
the code behind skb_copy_and_csum_dev, it can also deal with frag lists=
=2E

There were other drivers using skb_copy_and_csum_dev (ksz884x and
via-rhine), but I did not touch them, since they are doing things on
their .ndo_start_xmit which are more complex than a simple call of
skb_copy_and_csum_dev.

Cc: Jeff Garzik <jgarzik@pobox.com> (8139too)
Cc: Lennert Buytenhek <kernel@wantstofly.org> (ep93xx_eth, ixp2000)
Cc: Tristram Ha <Tristram.Ha@micrel.com> (ksz884x)
Cc: Roger Luethi <rl@hellgate.ch> (via-rhine)
Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/8139too.c        |    2 +-
 drivers/net/arm/ep93xx_eth.c |    2 +-
 drivers/net/ixp2000/ixpdev.c |    2 +-
 drivers/net/sc92031.c        |    3 +--
 include/linux/netdevice.h    |    4 ++++
 5 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 98517a3..0fc2127 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -991,7 +991,7 @@ static int __devinit rtl8139_init_one (struct pci_d=
ev *pdev,
 	 * through the use of skb_copy_and_csum_dev we enable these
 	 * features
 	 */
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+	dev->features |=3D NETIF_F_XMIT_COPY_AND_CSUM;
=20
 	dev->irq =3D pdev->irq;
=20
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.=
c
index 5a77001..50ebd33 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -769,7 +769,7 @@ static struct net_device *ep93xx_dev_alloc(struct e=
p93xx_eth_data *data)
 	dev->ethtool_ops =3D &ep93xx_ethtool_ops;
 	dev->netdev_ops =3D &ep93xx_netdev_ops;
=20
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |=3D NETIF_F_XMIT_COPY_AND_CSUM;
=20
 	return dev;
 }
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.=
c
index 78ddd8b..0df0734 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -303,7 +303,7 @@ struct net_device *ixpdev_alloc(int channel, int si=
zeof_priv)
=20
 	dev->netdev_ops =3D &ixpdev_netdev_ops;
=20
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |=3D NETIF_F_XMIT_COPY_AND_CSUM;
=20
 	ip =3D netdev_priv(dev);
 	ip->dev =3D dev;
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 76290a8..63db429 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1449,8 +1449,7 @@ static int __devinit sc92031_probe(struct pci_dev=
 *pdev,
 	dev->irq =3D pdev->irq;
=20
 	/* faked with skb_copy_and_csum_dev */
-	dev->features =3D NETIF_F_SG | NETIF_F_HIGHDMA |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	dev->features =3D NETIF_F_XMIT_COPY_AND_CSUM;
=20
 	dev->netdev_ops		=3D &sc92031_netdev_ops;
 	dev->watchdog_timeo	=3D TX_TIMEOUT;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5eeb2cd..680ed33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1110,6 +1110,10 @@ struct net_device {
 	/* changeable features with no special hardware requirements */
 #define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
=20
+	/* skb_copy_and_csum_dev is able to fake a few features */
+#define NETIF_F_XMIT_COPY_AND_CSUM	(NETIF_F_SG | NETIF_F_HW_CSUM | \
+					 NETIF_F_HIGHDMA | NETIF_F_FRAGLIST)
+
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
--=20
1.7.4

