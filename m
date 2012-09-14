From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] gre: add GSO support
Date: Fri, 14 Sep 2012 09:25:33 +0200
Message-ID: <1347607533.8555.269.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60513 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570Ab2INHZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 03:25:39 -0400
Received: by bkwj10 with SMTP id j10so1000996bkw.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 00:25:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Add GSO support to GRE tunnels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv4/ip_gre.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b062a98..f233c1d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -745,6 +745,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
=20
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
+	    skb_checksum_help(skb))
+		goto tx_error;
+
 	if (dev->type =3D=3D ARPHRD_ETHER)
 		IPCB(skb)->flags =3D 0;
=20
@@ -1296,6 +1300,11 @@ static void ipgre_dev_free(struct net_device *de=
v)
 	free_netdev(dev);
 }
=20
+#define GRE_FEATURES (NETIF_F_SG |		\
+		      NETIF_F_FRAGLIST |	\
+		      NETIF_F_HIGHDMA |		\
+		      NETIF_F_HW_CSUM)
+
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		=3D &ipgre_netdev_ops;
@@ -1309,6 +1318,9 @@ static void ipgre_tunnel_setup(struct net_device =
*dev)
 	dev->addr_len		=3D 4;
 	dev->features		|=3D NETIF_F_NETNS_LOCAL;
 	dev->priv_flags		&=3D ~IFF_XMIT_DST_RELEASE;
+
+	dev->features		|=3D GRE_FEATURES;
+	dev->hw_features	|=3D GRE_FEATURES;
 }
=20
 static int ipgre_tunnel_init(struct net_device *dev)
