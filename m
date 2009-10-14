From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 5/5] Phonet: forward incoming packets
Date: Wed, 14 Oct 2009 13:48:31 +0300
Message-ID: <1255517311-19527-5-git-send-email-remi@remlab.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
 <1255517311-19527-1-git-send-email-remi@remlab.net>
 <1255517311-19527-2-git-send-email-remi@remlab.net>
 <1255517311-19527-3-git-send-email-remi@remlab.net>
 <1255517311-19527-4-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36525 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932897AbZJNKtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:49:08 -0400
In-Reply-To: <1255517311-19527-4-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index cc2eef1..66737aa 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -394,6 +394,38 @@ static int phonet_rcv(struct sk_buff *skb, struct =
net_device *dev,
 			send_obj_unreachable(skb);
 			send_reset_indications(skb);
 		}
+	} else if (unlikely(skb->pkt_type =3D=3D PACKET_LOOPBACK))
+		goto out; /* Race between address deletion and loopback */
+	else {
+		/* Phonet packet routing */
+		struct net_device *out_dev;
+
+		out_dev =3D phonet_route_output(net, pn_sockaddr_get_addr(&sa));
+		if (!out_dev) {
+			LIMIT_NETDEBUG(KERN_WARNING"No Phonet route to %02X\n",
+					pn_sockaddr_get_addr(&sa));
+			goto out;
+		}
+
+		__skb_push(skb, sizeof(struct phonethdr));
+		skb->dev =3D out_dev;
+		if (out_dev =3D=3D dev) {
+			LIMIT_NETDEBUG(KERN_ERR"Phonet loop to %02X on %s\n",
+					pn_sockaddr_get_addr(&sa), dev->name);
+			goto out_dev;
+		}
+		/* Some drivers (e.g. TUN) do not allocate HW header space */
+		if (skb_cow_head(skb, out_dev->hard_header_len))
+			goto out_dev;
+
+		if (dev_hard_header(skb, out_dev, ETH_P_PHONET, NULL, NULL,
+					skb->len) < 0)
+			goto out_dev;
+		dev_queue_xmit(skb);
+		dev_put(out_dev);
+		return NET_RX_SUCCESS;
+out_dev:
+		dev_put(out_dev);
 	}
=20
 out:
--=20
1.6.0.4

