From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 2/3] caif: Add drop count for caif_net device.
Date: Fri,  3 Feb 2012 15:36:20 +0100
Message-ID: <1328279781-4745-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60859 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756714Ab2BCOgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 09:36:39 -0500
Received: by lagu2 with SMTP id u2so1877414lag.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 06:36:37 -0800 (PST)
In-Reply-To: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Count dropped packets in CAIF Netdevice.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 8656909..a751d9b 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -74,7 +74,6 @@ static int chnl_recv_cb(struct cflayer *layr, struct =
cfpkt *pkt)
 	struct sk_buff *skb;
 	struct chnl_net *priv  =3D container_of(layr, struct chnl_net, chnl);
 	int pktlen;
-	int err =3D 0;
 	const u8 *ip_version;
 	u8 buf;
=20
@@ -95,8 +94,7 @@ static int chnl_recv_cb(struct cflayer *layr, struct =
cfpkt *pkt)
=20
 	/* check the version of IP */
 	ip_version =3D skb_header_pointer(skb, 0, 1, &buf);
-	if (!ip_version)
-		return -EINVAL;
+
 	switch (*ip_version >> 4) {
 	case 4:
 		skb->protocol =3D htons(ETH_P_IP);
@@ -105,6 +103,7 @@ static int chnl_recv_cb(struct cflayer *layr, struc=
t cfpkt *pkt)
 		skb->protocol =3D htons(ETH_P_IPV6);
 		break;
 	default:
+		priv->netdev->stats.rx_errors++;
 		return -EINVAL;
 	}
=20
@@ -123,7 +122,7 @@ static int chnl_recv_cb(struct cflayer *layr, struc=
t cfpkt *pkt)
 	priv->netdev->stats.rx_packets++;
 	priv->netdev->stats.rx_bytes +=3D pktlen;
=20
-	return err;
+	return 0;
 }
=20
 static int delete_device(struct chnl_net *dev)
@@ -221,11 +220,13 @@ static int chnl_net_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
=20
 	if (skb->len > priv->netdev->mtu) {
 		pr_warn("Size of skb exceeded MTU\n");
+		dev->stats.tx_errors++;
 		return -ENOSPC;
 	}
=20
 	if (!priv->flowenabled) {
 		pr_debug("dropping packets flow off\n");
+		dev->stats.tx_dropped++;
 		return NETDEV_TX_BUSY;
 	}
=20
@@ -240,8 +241,7 @@ static int chnl_net_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 	/* Send the packet down the stack. */
 	result =3D priv->chnl.dn->transmit(priv->chnl.dn, pkt);
 	if (result) {
-		if (result =3D=3D -EAGAIN)
-			result =3D NETDEV_TX_BUSY;
+		dev->stats.tx_dropped++;
 		return result;
 	}
=20
--=20
1.7.5.4
