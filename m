From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 17:47:14 +0100
Message-ID: <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FF050.7040400@mellanox.com>
	 <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120206.113145.1284864994961472499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ogerlitz@mellanox.com, sean.hefty@intel.com,
	herbert@gondor.hengli.com.au, linux-rdma@vger.kernel.org,
	shlomop@mellanox.com, roland@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39400 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab2BFQrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:47:18 -0500
In-Reply-To: <20120206.113145.1284864994961472499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 11:31 -0500, David Miller a =C3=A9=
crit :

> We really need an explanation, probably both in the commit message an=
d
> the comments next to this new struct member, explaining why in the wo=
rld
> we can't use ->hard_header_len for this.

OK, I added some information from Or Gerlitz in V2

Thanks !

[PATCH net-next V2] gro: introduce gro_mac_header_len

Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
only, and failed on IB/ipoib traffic.

He provided a patch faking a zeroed header to let GRO aggregates frames=
=2E

Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
check to be more generic.

This patch introduces a new netdevice field, gro_mac_header_len, giving
L2 header length, default to ETH_HLEN (14 bytes)

A device setup function can override this default value.

gro_max_header_len can be different than hard_header_len because as Or
Gerlitz said :

	IPoIB advertizes hard_header_len which is bigger than the
	IPoIB header len, this is done such that skbs sent by the
	network stack have enough headroom for a "pseudoheader"
	which for few flows (e.g unicast arp replies and multicast)
	is placed there by the ipoib hard_header function and later
	used by the xmit function.

__napi_gro_receive() has special handling for the common case (Ethernet=
)
to avoid a memcmp() call and use an inline optimized function instead.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Shlomo Pongratz <shlomop@mellanox.com>
Cc: Roland Dreier <roland@kernel.org>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
V2: added a comment saying why we dont use hard_header_len but a new
field.

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..903bb6e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1095,6 +1095,7 @@ struct net_device {
 	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
+	unsigned int		gro_mac_header_len; /* L2 header length for GRO */
=20
 	/* extra head- and tailroom the hardware may need, but not in all cas=
es
 	 * can this be guaranteed, especially tailroom. Some cases also use
diff --git a/net/core/dev.c b/net/core/dev.c
index f124947..0b43939 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3491,14 +3491,20 @@ static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	unsigned int maclen =3D skb->dev->gro_mac_header_len;
=20
 	for (p =3D napi->gro_list; p; p =3D p->next) {
 		unsigned long diffs;
=20
 		diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
 		diffs |=3D p->vlan_tci ^ skb->vlan_tci;
-		diffs |=3D compare_ether_header(skb_mac_header(p),
-					      skb_gro_mac_header(skb));
+		if (maclen =3D=3D ETH_HLEN)
+			diffs |=3D compare_ether_header(skb_mac_header(p),
+						      skb_gro_mac_header(skb));
+		else if (!diffs)
+			diffs =3D memcmp(skb_mac_header(p),
+				       skb_gro_mac_header(skb),
+				       maclen);
 		NAPI_GRO_CB(p)->same_flow =3D !diffs;
 		NAPI_GRO_CB(p)->flush =3D 0;
 	}
@@ -5962,6 +5968,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_pr=
iv, const char *name,
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
 	dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
+	dev->gro_mac_header_len =3D ETH_HLEN;
 	setup(dev);
=20
 	dev->num_tx_queues =3D txqs;
