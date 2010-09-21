From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip : fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 16:16:53 +0200
Message-ID: <1285078613.2617.503.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
	 <1285006844.2323.17.camel@edumazet-laptop>
	 <20100920195256.GA14330@elliptictech.com>
	 <1285013853.2323.148.camel@edumazet-laptop>
	 <1285018272.2323.243.camel@edumazet-laptop>
	 <20100921140501.GA21572@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100921140501.GA21572@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 septembre 2010 =C3=A0 10:05 -0400, Nick Bowler a =C3=A9crit=
 :

> This hunk introduces some whitespace damage.
>=20
> Anyway, I tried this with ESP on both IPv4 and IPv6 and it appears to
> correct the issue.  Thanks!
>=20

Indeed good catch.

Here is an updated patch, I added your Tested-by

Thanks for testing !

[PATCH] ip : fix truesize mismatch in ip fragmentation

We should not set frag->destructor to sock_wkfree() until we are sure w=
e
dont hit slow path in ip_fragment(). Or we risk uncharging
frag->truesize twice, and in the end, having negative socket
sk_wmem_alloc counter, or even freeing socket sooner than expected.

Many thanks to Nick Bowler, who provided a very clean bug report and
test program.

While Nick bisection pointed to commit 2b85a34e911bf483 (net: No more
expensive sock_hold()/sock_put() on each tx), underlying bug is older.

Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
Tested-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_output.c  |    8 ++++----
 net/ipv6/ip6_output.c |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 04b6989..126d9b3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -490,7 +490,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
 	if (skb_has_frags(skb)) {
 		struct sk_buff *frag;
 		int first_len =3D skb_pagelen(skb);
-		int truesizes =3D 0;
=20
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -510,11 +509,13 @@ int ip_fragment(struct sk_buff *skb, int (*output=
)(struct sk_buff *))
 				goto slow_path;
=20
 			BUG_ON(frag->sk);
-			if (skb->sk) {
+		}
+		if (skb->sk) {
+			skb_walk_frags(skb, frag) {
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
+				skb->truesize -=3D frag->truesize;
 			}
-			truesizes +=3D frag->truesize;
 		}
=20
 		/* Everything is OK. Generate! */
@@ -524,7 +525,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
 		frag =3D skb_shinfo(skb)->frag_list;
 		skb_frag_list_init(skb);
 		skb->data_len =3D first_len - skb_headlen(skb);
-		skb->truesize -=3D truesizes;
 		skb->len =3D first_len;
 		iph->tot_len =3D htons(first_len);
 		iph->frag_off =3D htons(IP_MF);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d40b330..633217d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -639,7 +639,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 	if (skb_has_frags(skb)) {
 		int first_len =3D skb_pagelen(skb);
-		int truesizes =3D 0;
=20
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -658,10 +657,12 @@ static int ip6_fragment(struct sk_buff *skb, int =
(*output)(struct sk_buff *))
 				goto slow_path;
=20
 			BUG_ON(frag->sk);
-			if (skb->sk) {
+		}
+		if (skb->sk) {
+			skb_walk_frags(skb, frag) {
 				frag->sk =3D skb->sk;
 				frag->destructor =3D sock_wfree;
-				truesizes +=3D frag->truesize;
+				skb->truesize -=3D frag->truesize;
 			}
 		}
=20
@@ -693,7 +694,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 		first_len =3D skb_pagelen(skb);
 		skb->data_len =3D first_len - skb_headlen(skb);
-		skb->truesize -=3D truesizes;
 		skb->len =3D first_len;
 		ipv6_hdr(skb)->payload_len =3D htons(first_len -
 						   sizeof(struct ipv6hdr));
