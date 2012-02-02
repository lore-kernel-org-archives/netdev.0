From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Thu, 02 Feb 2012 15:44:25 +0100
Message-ID: <1328193865.2279.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	 <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>
	 <20120130081849.GA7848@gondor.apana.org.au>
	 <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120130085742.GA8262@gondor.apana.org.au>
	 <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>
	 <20120201083837.GA7081@gondor.apana.org.au>
	 <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>
	 <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2A974B.209@mellanox.com>
	 <1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 15:38 +0100, Eric Dumazet a =C3=A9=
crit :

> I guess changing hard_header_len might be difficult (for you).
>=20
> Adding gro_mac_header_len sounds the easy way.
>=20
> [ You'll need to set it in your device setup() ]
>=20

Something like :

 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   11 +++++++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..99b12c4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1095,7 +1095,7 @@ struct net_device {
 	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/
-
+	unsigned int		gro_mac_header_len;
 	/* extra head- and tailroom the hardware may need, but not in all cas=
es
 	 * can this be guaranteed, especially tailroom. Some cases also use
 	 * LL_MAX_HEADER instead to allocate the skb.
diff --git a/net/core/dev.c b/net/core/dev.c
index f124947..a3af7bc 100644
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
+					skb_gro_mac_header(skb),
+					maclen);
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


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
