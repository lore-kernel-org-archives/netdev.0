From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 1/3] caif: Fix memory leakage in the chnl_net.c.
Date: Thu, 12 Apr 2012 20:18:07 +0200
Message-ID: <1334254689-2843-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:50874 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934578Ab2DLSSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:18:17 -0400
Received: by lahj13 with SMTP id j13so1789559lah.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:18:15 -0700 (PDT)
In-Reply-To: <1334254689-2843-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tomasz Gregorek <tomasz.gregorek@stericsson.com>

Added kfree_skb() calls in the chnk_net.c file on
the error paths.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 93e9c6d..69771c0 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -103,6 +103,7 @@ static int chnl_recv_cb(struct cflayer *layr, struc=
t cfpkt *pkt)
 		skb->protocol =3D htons(ETH_P_IPV6);
 		break;
 	default:
+		kfree_skb(skb);
 		priv->netdev->stats.rx_errors++;
 		return -EINVAL;
 	}
@@ -220,14 +221,16 @@ static int chnl_net_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
=20
 	if (skb->len > priv->netdev->mtu) {
 		pr_warn("Size of skb exceeded MTU\n");
+		kfree_skb(skb);
 		dev->stats.tx_errors++;
-		return -ENOSPC;
+		return NETDEV_TX_OK;
 	}
=20
 	if (!priv->flowenabled) {
 		pr_debug("dropping packets flow off\n");
+		kfree_skb(skb);
 		dev->stats.tx_dropped++;
-		return NETDEV_TX_BUSY;
+		return NETDEV_TX_OK;
 	}
=20
 	if (priv->conn_req.protocol =3D=3D CAIFPROTO_DATAGRAM_LOOP)
@@ -242,7 +245,7 @@ static int chnl_net_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 	result =3D priv->chnl.dn->transmit(priv->chnl.dn, pkt);
 	if (result) {
 		dev->stats.tx_dropped++;
-		return result;
+		return NETDEV_TX_OK;
 	}
=20
 	/* Update statistics. */
--=20
1.7.5.4
