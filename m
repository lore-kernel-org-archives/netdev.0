From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/8] Phonet: return an error when packet TX fails
Date: Wed,  9 Mar 2011 10:44:07 +0200
Message-ID: <1299660253-4446-2-git-send-email-remi.denis-courmont@nokia.com>
References: <201103091043.32391.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30264 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756689Ab1CIIoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 03:44:18 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p298iEY5019524
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 10:44:16 +0200
In-Reply-To: <201103091043.32391.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phonet assumes that packets are never dropped. We try our best to
avoid this situation. But lets return ENOBUFS if queueing to the
network device fails so that the caller knows things went wrong.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 4706b77..c6fffd9 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -195,11 +195,7 @@ static int pn_send(struct sk_buff *skb, struct net=
_device *dev,
 	if (skb->pkt_type =3D=3D PACKET_LOOPBACK) {
 		skb_reset_mac_header(skb);
 		skb_orphan(skb);
-		if (irq)
-			netif_rx(skb);
-		else
-			netif_rx_ni(skb);
-		err =3D 0;
+		err =3D (irq ? netif_rx(skb) : netif_rx_ni(skb)) ? -ENOBUFS : 0;
 	} else {
 		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
 					NULL, NULL, skb->len);
@@ -208,6 +204,8 @@ static int pn_send(struct sk_buff *skb, struct net_=
device *dev,
 			goto drop;
 		}
 		err =3D dev_queue_xmit(skb);
+		if (unlikely(err > 0))
+			err =3D net_xmit_errno(err);
 	}
=20
 	return err;
--=20
1.7.1

