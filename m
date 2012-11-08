From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipip: add GSO support
Date: Thu, 08 Nov 2012 11:59:52 -0800
Message-ID: <1352404792.19779.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:32969 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab2KHT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 14:59:54 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so1324888dak.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 11:59:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

In commit 6b78f16e4b (gre: add GSO support) we added GSO support to GRE
tunnels.

This patch does the same for IPIP tunnels.

Performance of single TCP flow over an IPIP tunnel is increased by 40%

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ipip.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e15b452..cc49cc1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -479,6 +479,10 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev)
 	if (skb->protocol !=3D htons(ETH_P_IP))
 		goto tx_error;
=20
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
+	    skb_checksum_help(skb))
+		goto tx_error;
+
 	if (tos & 1)
 		tos =3D old_iph->tos;
=20
@@ -773,6 +777,11 @@ static void ipip_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
=20
+#define IPIP_FEATURES (NETIF_F_SG |		\
+		       NETIF_F_FRAGLIST |	\
+		       NETIF_F_HIGHDMA |	\
+		       NETIF_F_HW_CSUM)
+
 static void ipip_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		=3D &ipip_netdev_ops;
@@ -787,6 +796,9 @@ static void ipip_tunnel_setup(struct net_device *de=
v)
 	dev->features		|=3D NETIF_F_NETNS_LOCAL;
 	dev->features		|=3D NETIF_F_LLTX;
 	dev->priv_flags		&=3D ~IFF_XMIT_DST_RELEASE;
+
+	dev->features		|=3D IPIP_FEATURES;
+	dev->hw_features	|=3D IPIP_FEATURES;
 }
=20
 static int ipip_tunnel_init(struct net_device *dev)
