From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Tue, 31 Aug 2010 07:20:31 +0200
Message-ID: <1283232031.2405.38.camel@edumazet-laptop>
References: <20100830200917.GA10754@stratus.com>
	 <1283204118.2405.32.camel@edumazet-laptop>
	 <20100830232147.GB10754@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Bandan Das <bandan.das@stratus.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100830232147.GB10754@stratus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 30 ao=C3=BBt 2010 =C3=A0 19:21 -0400, Bandan Das a =C3=A9crit =
:
> >=20
> > I wonder if we want this.
> >=20
> > Maybe setting skb->local_df =3D 1 in bridge should be enough ?
> >=20
> >=20
> Thanks Eric for looking at this. Indeed, setting local_df to 1 seems =
to be enough! I will
> respin and post a different patch.
>=20

Reading this stuff again, I wonder if we should not revert commit
17762060c25590bfddd  and use a different trick

Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Jul 5 21:29:28 2010 +0000

    bridge: Clear IPCB before possible entry into IP stack
   =20
    The bridge protocol lives dangerously by having incestuous relation=
s
    with the IP stack.  In this instance an abomination has been create=
d
    where a bogus IPCB area from a bridged packet leads to a crash in
    the IP stack because it's interpreted as IP options.
   =20
    This patch papers over the problem by clearing the IPCB area in tha=
t
    particular spot.  To fix this properly we'd also need to parse any
    IP options if present but I'm way too lazy for that.
   =20
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>


We could have a padding in front of struct br_input_skb_cb to make sure
we dont overwrite IP (4|6) CB in bridge ?

Something like this untested patch :

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 2c911c0..9fdf1b1 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -598,9 +598,6 @@ static unsigned int br_nf_pre_routing(unsigned int =
hook, struct sk_buff *skb,
=20
 	pskb_trim_rcsum(skb, len);
=20
-	/* BUG: Should really parse the IP options here. */
-	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 75c90ed..b27163a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <linux/ipv6.h>
=20
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -244,6 +245,8 @@ struct net_bridge
 };
=20
 struct br_input_skb_cb {
+	struct inet6_skb_parm pad;
+
 	struct net_device *brdev;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
