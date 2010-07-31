From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 05/29] LMC: Remove non-LMC_PPP modes, everything is already handled by generic HDLC.
Date: Sat, 31 Jul 2010 17:05:28 +0200
Message-ID: <1280588752-9340-5-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41822 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab0GaPGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:05 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |   31 ------------------------
 drivers/net/wan/lmc/proto.c |   55 ++++++-----------------------------=
-------
 drivers/net/wan/lmc/var.h   |    1 -
 3 files changed, 8 insertions(+), 79 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 63297a5..a6de32f 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -161,36 +161,6 @@ int lmc_ioctl(struct net_device *dev, struct ifreq=
 *ifr, int cmd)
 		ret =3D 0;
 		break;
=20
-	case LMCIOCIFTYPE:
-	{
-		u16 old_type =3D sc->if_type;
-		u16 new_type;
-
-		if (!capable(CAP_NET_ADMIN)) {
-			ret =3D -EPERM;
-			break;
-		}
-
-		if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u16))) {
-			ret =3D -EFAULT;
-			break;
-		}
-
-		if (new_type =3D=3D old_type) {
-			ret =3D 0 ;
-			break;				/* no change */
-		}
-
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		lmc_proto_close(sc);
-
-		sc->if_type =3D new_type;
-		lmc_proto_attach(sc);
-		ret =3D lmc_proto_open(sc);
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
-		break;
-	}
-
 	case LMCIOCGETXINFO:
 		spin_lock_irqsave(&sc->lmc_lock, flags);
 		sc->lmc_xinfo.Magic0 =3D 0xBEEFCAFE;
@@ -819,7 +789,6 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	dev->tx_queue_len =3D 100;
 	sc->lmc_device =3D dev;
 	sc->name =3D dev->name;
-	sc->if_type =3D LMC_PPP;
 	sc->check =3D 0xBEAFCAFE;
 	dev->base_addr =3D pci_resource_start(pdev, 0);
 	dev->irq =3D pdev->irq;
diff --git a/drivers/net/wan/lmc/proto.c b/drivers/net/wan/lmc/proto.c
index 547c8d8..ffd952a 100644
--- a/drivers/net/wan/lmc/proto.c
+++ b/drivers/net/wan/lmc/proto.c
@@ -49,22 +49,13 @@
 void lmc_proto_attach(struct card *sc)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_attach in");
-	if (sc->if_type =3D=3D LMC_NET) {
-		struct net_device *dev =3D sc->lmc_device;
-		/* They set a few basics because they don't use HDLC */
-		dev->flags |=3D IFF_POINTOPOINT;
-		dev->hard_header_len =3D 0;
-		dev->addr_len =3D 0;
-	}
 	lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
=20
 int lmc_proto_ioctl(struct card *sc, struct ifreq *ifr, int cmd)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_ioctl");
-	if (sc->if_type =3D=3D LMC_PPP)
-		return hdlc_ioctl(sc->lmc_device, ifr, cmd);
-	return -EOPNOTSUPP;
+	return hdlc_ioctl(sc->lmc_device, ifr, cmd);
 }
=20
 int lmc_proto_open(struct card *sc)
@@ -73,12 +64,10 @@ int lmc_proto_open(struct card *sc)
=20
 	lmc_trace(sc->lmc_device, "lmc_proto_open in");
=20
-	if (sc->if_type =3D=3D LMC_PPP) {
-		ret =3D hdlc_open(sc->lmc_device);
-		if (ret < 0)
-			printk(KERN_WARNING "%s: HDLC open failed: %d\n",
-			       sc->name, ret);
-	}
+	ret =3D hdlc_open(sc->lmc_device);
+	if (ret < 0)
+		printk(KERN_WARNING "%s: HDLC open failed: %d\n",
+		       sc->name, ret);
=20
 	lmc_trace(sc->lmc_device, "lmc_proto_open out");
 	return ret;
@@ -87,48 +76,20 @@ int lmc_proto_open(struct card *sc)
 void lmc_proto_close(struct card *sc)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_close in");
-
-	if (sc->if_type =3D=3D LMC_PPP)
-		hdlc_close(sc->lmc_device);
-
+	hdlc_close(sc->lmc_device);
 	lmc_trace(sc->lmc_device, "lmc_proto_close out");
 }
=20
 __be16 lmc_proto_type(struct card *sc, struct sk_buff *skb)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_type in");
-	switch (sc->if_type) {
-	case LMC_PPP:
-		return hdlc_type_trans(skb, sc->lmc_device);
-		break;
-	case LMC_NET:
-		return htons(ETH_P_802_2);
-		break;
-	case LMC_RAW: /* Packet type for skbuff kind of useless */
-		return htons(ETH_P_802_2);
-		break;
-	default:
-		printk(KERN_WARNING
-		       "%s: No protocol set for this interface, assuming 802.2 (whic=
h is wrong!!)\n",
-		       sc->name);
-		return htons(ETH_P_802_2);
-		break;
-	}
+	return hdlc_type_trans(skb, sc->lmc_device);
 	lmc_trace(sc->lmc_device, "lmc_proto_tye out");
-
 }
=20
 void lmc_proto_netif(struct card *sc, struct sk_buff *skb)
 {
 	lmc_trace(sc->lmc_device, "lmc_proto_netif in");
-	switch (sc->if_type) {
-	case LMC_PPP:
-	case LMC_NET:
-	default:
-		netif_rx(skb);
-		break;
-	case LMC_RAW:
-		break;
-	}
+	netif_rx(skb);
 	lmc_trace(sc->lmc_device, "lmc_proto_netif out");
 }
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index e9aad37..b889bf6 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -321,7 +321,6 @@ struct card {
 	u32 num_int;
=20
 	spinlock_t lmc_lock;
-	u16 if_type;			/* HDLC/PPP or NET */
=20
 	u8 failed_ring;			/* Failure cases */
 	u8 failed_recv_alloc;
--=20
1.7.1.1

