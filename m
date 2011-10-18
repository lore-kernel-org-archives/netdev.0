From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Tue, 18 Oct 2011 14:56:00 +0200
Message-ID: <1318942560.2657.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	 <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
	 <1318905032.2571.35.camel@edumazet-laptop>
	 <20111018093411.GA15165@gondor.apana.org.au>
	 <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018100527.GA15383@gondor.apana.org.au>
	 <1318933423.2657.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018104504.GA15913@gondor.apana.org.au>
	 <1318937878.2657.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018114945.GA16359@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018114945.GA16359@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 13:49 +0200, Herbert Xu a =C3=A9crit :
> On Tue, Oct 18, 2011 at 01:37:58PM +0200, Eric Dumazet wrote:
> >
> > In the bug we try to fix, we have :
> >=20
> > skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.de=
v)=20
> >=20
> > ... < increase of dev->needed_headroom by another cpu/task >
> >=20
> > skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
>=20
> OK, in that case one fix would be to replace LL_ALLOCATED_SPACE
> with its two constiuents so that they may be stored in local
> variables for later use.
>=20
> 	hlen =3D LL_HEADROOM(skb);
> 	tlen =3D LL_TAILROOM(skb);
> 	skb_alloc_send_skb(sk, ... + LL_ALIGN(hlen + tlen));
>=20
> 	skb_reserve(skb, LL_ALIGN(hlen));
>=20
> Cheers,

I am ok by this way, but we might hit another similar problem elsewhere=
=2E

(igmp.c ip6_output, ...)

We effectively want to remove LL_ALLOCATED_SPACE() usage and obfuscate
code...


[PATCH] raw: allow dev->needed_headroom dynamic change

It seems ip_gre is able to change dev->needed_headroom on the fly.

It triggers a BUG in raw_sendmsg()

skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.dev)=20

< another cpu change dev->needed_headromm (making it bigger)

=2E..
skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));

We end with LL_RESERVED_SPACE() being bigger than LL_ALLOCATED_SPACE()
-> we crash later because skb head is exhausted.

Bug introduced in commit 243aad83 in 2.6.34 (ip_gre: include route
header_len in max_headroom calculation)

Reported-by: Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Timo Ter=C3=A4s <timo.teras@iki.fi>
CC: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/netdevice.h |   10 +++++++---
 net/ipv4/raw.c            |    9 +++++++--
 net/ipv6/raw.c            |    9 +++++++--
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..dba2399 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -276,12 +276,16 @@ struct hh_cache {
  * LL_ALLOCATED_SPACE also takes into account the tailroom the device
  * may need.
  */
+#define LL_ALIGN(__len) (((__len)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+
 #define LL_RESERVED_SPACE(dev) \
-	((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1))=
 + HH_DATA_MOD)
+	LL_ALIGN((dev)->hard_header_len + (dev)->needed_headroom))
+
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
-	((((dev)->hard_header_len+(dev)->needed_headroom+(extra))&~(HH_DATA_M=
OD - 1)) + HH_DATA_MOD)
+	LL_ALIGN((dev)->hard_header_len + (dev)->needed_headroom + (extra))
+
 #define LL_ALLOCATED_SPACE(dev) \
-	((((dev)->hard_header_len+(dev)->needed_headroom+(dev)->needed_tailro=
om)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
+	LL_ALIGN((dev)->hard_header_len + (dev)->needed_headroom + (dev)->nee=
ded_tailroom)
=20
 struct header_ops {
 	int	(*create) (struct sk_buff *skb, struct net_device *dev,
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 61714bd..4ed4eda 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -326,6 +326,9 @@ static int raw_send_hdrinc(struct sock *sk, struct =
flowi4 *fl4,
 	unsigned int iphlen;
 	int err;
 	struct rtable *rt =3D *rtp;
+	unsigned int hard_header_len =3D rt->dst.dev->hard_header_len;
+	unsigned int needed_headroom =3D rt->dst.dev->needed_headroom;
+	unsigned int needed_tailroom =3D rt->dst.dev->needed_tailroom;
=20
 	if (length > rt->dst.dev->mtu) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -336,11 +339,13 @@ static int raw_send_hdrinc(struct sock *sk, struc=
t flowi4 *fl4,
 		goto out;
=20
 	skb =3D sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
+				  length + LL_ALIGN(hard_header_len +
+						    needed_headroom +
+					            needed_tailroom) + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (skb =3D=3D NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
+	skb_reserve(skb, LL_ALIGN(hard_header_len + needed_headroom));
=20
 	skb->priority =3D sk->sk_priority;
 	skb->mark =3D sk->sk_mark;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 343852e..eb0a797 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -610,6 +610,9 @@ static int rawv6_send_hdrinc(struct sock *sk, void =
*from, int length,
 	struct sk_buff *skb;
 	int err;
 	struct rt6_info *rt =3D (struct rt6_info *)*dstp;
+	unsigned int hard_header_len =3D rt->dst.dev->hard_header_len;
+	unsigned int needed_headroom =3D rt->dst.dev->needed_headroom;
+	unsigned int needed_tailroom =3D rt->dst.dev->needed_tailroom;
=20
 	if (length > rt->dst.dev->mtu) {
 		ipv6_local_error(sk, EMSGSIZE, fl6, rt->dst.dev->mtu);
@@ -619,11 +622,13 @@ static int rawv6_send_hdrinc(struct sock *sk, voi=
d *from, int length,
 		goto out;
=20
 	skb =3D sock_alloc_send_skb(sk,
-				  length + LL_ALLOCATED_SPACE(rt->dst.dev) + 15,
+				  length + LL_ALIGN(hard_header_len +
+						    needed_headroom +
+					            needed_tailroom) + 15,
 				  flags & MSG_DONTWAIT, &err);
 	if (skb =3D=3D NULL)
 		goto error;
-	skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
+	skb_reserve(skb, LL_ALIGN(hard_header_len + needed_headroom));
=20
 	skb->priority =3D sk->sk_priority;
 	skb->mark =3D sk->sk_mark;
