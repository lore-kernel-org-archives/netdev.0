From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 17:58:25 +0200
Message-ID: <1285084705.2617.636.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
	 <1285006844.2323.17.camel@edumazet-laptop>
	 <20100920195256.GA14330@elliptictech.com>
	 <1285013853.2323.148.camel@edumazet-laptop>
	 <1285018272.2323.243.camel@edumazet-laptop>
	 <20100921140501.GA21572@elliptictech.com>
	 <1285078613.2617.503.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285078613.2617.503.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 septembre 2010 =C3=A0 16:16 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le mardi 21 septembre 2010 =C3=A0 10:05 -0400, Nick Bowler a =C3=A9cr=
it :
>=20
> > This hunk introduces some whitespace damage.
> >=20
> > Anyway, I tried this with ESP on both IPv4 and IPv6 and it appears =
to
> > correct the issue.  Thanks!
> >=20
>=20
> Indeed good catch.
>=20
> Here is an updated patch, I added your Tested-by
>=20
> Thanks for testing !
>=20
> [PATCH] ip : fix truesize mismatch in ip fragmentation
>=20
> We should not set frag->destructor to sock_wkfree() until we are sure=
 we
> dont hit slow path in ip_fragment(). Or we risk uncharging
> frag->truesize twice, and in the end, having negative socket
> sk_wmem_alloc counter, or even freeing socket sooner than expected.
>=20
> Many thanks to Nick Bowler, who provided a very clean bug report and
> test program.
>=20
> While Nick bisection pointed to commit 2b85a34e911bf483 (net: No more
> expensive sock_hold()/sock_put() on each tx), underlying bug is older=
=2E
>=20


Hmm, while looking at git history, I found commit from Patrick
b2722b1c3a893e (ip_fragment: also adjust skb->truesize for packets not
owned by a socket)
As my patch reverts it, we probably want a more polished patch.

(Also port Patrick work to ipv6)

So here is a V3

[PATCH v3] ip: fix truesize mismatch in ip fragmentation

Special care should be taken when slow path is hit in ip_fragment() :

When walking through frags, we transfert truesize ownership from skb to
frags. Then if we hit a slow_path condition, we must undo this or risk
uncharging frags->truesize twice, and in the end, having negative socke=
t
sk_wmem_alloc counter, or even freeing socket sooner than expected.

Many thanks to Nick Bowler, who provided a very clean bug report and
test program.

Thanks to Jarek for reviewing my first patch and providing a V2

While Nick bisection pointed to commit 2b85a34e911 (net: No more
expensive sock_hold()/sock_put() on each tx), underlying bug is older
(2.6.12-rc5)

A side effect is to extend work done in commit b2722b1c3a893e
(ip_fragment: also adjust skb->truesize for packets not owned by a
socket) to ipv6 as well.

Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
Tested-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ip_output.c  |   19 +++++++++++++------
 net/ipv6/ip6_output.c |   18 +++++++++++++-----
 2 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 04b6989..a643f7a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -488,9 +488,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
 	 * we can switch to copy when see the first bad fragment.
 	 */
 	if (skb_has_frags(skb)) {
-		struct sk_buff *frag;
+		struct sk_buff *frag, *frag2;
 		int first_len =3D skb_pagelen(skb);
-		int truesizes =3D 0;
=20
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -503,18 +502,18 @@ int ip_fragment(struct sk_buff *skb, int (*output=
)(struct sk_buff *))
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
 			    skb_headroom(frag) < hlen)
-			    goto slow_path;
+			    goto slow_path_undo;
=20
 			/* Partially cloned skb? */
 			if (skb_shared(frag))
-				goto slow_path;
+				goto slow_path_undo;
=20
 			BUG_ON(frag->sk);
 			if (skb->sk) {
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
 			}
-			truesizes +=3D frag->truesize;
+			skb->truesize -=3D frag->truesize;
 		}
=20
 		/* Everything is OK. Generate! */
@@ -524,7 +523,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
 		frag =3D skb_shinfo(skb)->frag_list;
 		skb_frag_list_init(skb);
 		skb->data_len =3D first_len - skb_headlen(skb);
-		skb->truesize -=3D truesizes;
 		skb->len =3D first_len;
 		iph->tot_len =3D htons(first_len);
 		iph->frag_off =3D htons(IP_MF);
@@ -576,6 +574,15 @@ int ip_fragment(struct sk_buff *skb, int (*output)=
(struct sk_buff *))
 		}
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		return err;
+
+slow_path_undo:
+		skb_walk_frags(skb, frag2) {
+			if (frag2 =3D=3D frag)
+				break;
+			frag2->sk =3D NULL;
+			frag2->destructor =3D NULL;
+			skb->truesize +=3D frag2->truesize;
+		}
 	}
=20
 slow_path:
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d40b330..ca7ba44 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -639,7 +639,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 	if (skb_has_frags(skb)) {
 		int first_len =3D skb_pagelen(skb);
-		int truesizes =3D 0;
+		struct sk_buff *frag2;
=20
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -651,18 +651,18 @@ static int ip6_fragment(struct sk_buff *skb, int =
(*output)(struct sk_buff *))
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
 			    skb_headroom(frag) < hlen)
-			    goto slow_path;
+			    goto slow_path_undo;
=20
 			/* Partially cloned skb? */
 			if (skb_shared(frag))
-				goto slow_path;
+				goto slow_path_undo;
=20
 			BUG_ON(frag->sk);
 			if (skb->sk) {
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
-				truesizes +=3D frag->truesize;
 			}
+			skb->truesize -=3D frag->truesize;
 		}
=20
 		err =3D 0;
@@ -693,7 +693,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 		first_len =3D skb_pagelen(skb);
 		skb->data_len =3D first_len - skb_headlen(skb);
-		skb->truesize -=3D truesizes;
 		skb->len =3D first_len;
 		ipv6_hdr(skb)->payload_len =3D htons(first_len -
 						   sizeof(struct ipv6hdr));
@@ -756,6 +755,15 @@ static int ip6_fragment(struct sk_buff *skb, int (=
*output)(struct sk_buff *))
 			      IPSTATS_MIB_FRAGFAILS);
 		dst_release(&rt->dst);
 		return err;
+
+slow_path_undo:
+		skb_walk_frags(skb, frag2) {
+			if (frag2 =3D=3D frag)
+				break;
+			frag2->sk =3D NULL;
+			frag2->destructor =3D NULL;
+			skb->truesize +=3D frag2->truesize;
+		}
 	}
=20
 slow_path:
