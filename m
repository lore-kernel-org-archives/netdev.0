From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Mon, 20 Sep 2010 23:31:12 +0200
Message-ID: <1285018272.2323.243.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
	 <1285006844.2323.17.camel@edumazet-laptop>
	 <20100920195256.GA14330@elliptictech.com>
	 <1285013853.2323.148.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285013853.2323.148.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 20 septembre 2010 =C3=A0 22:17 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le lundi 20 septembre 2010 =C3=A0 15:52 -0400, Nick Bowler a =C3=A9cr=
it :
> > On 2010-09-20 20:20 +0200, Eric Dumazet wrote:
> > > If you change your program to send small frames (so they are not
> > > fragmented), is the problem still present ?
> >=20
> > I changed MAX_DGRAM_SIZE in the test program to 1000 (mtu on the
> > interface is 1500).  The short answer is that the references are
> > not leaked, and things seem to get cleaned up.  So the rest of this
> > mail probably describes a separate issue.
> >=20
> > The long answer, however, is interesting: With latest Linus' git, t=
he
> > references are cleaned up much later than I would expect.  After ru=
nning
> > the test program and flushing the SAD/SPD, the reference count is s=
till
> > 1.  If I repeat the test immediately, the reference count will incr=
ease
> > further.  I can easily raise the reference count to, say, 100.  Now=
, if
> > I wait a while (10 minutes or so), the reference count will still b=
e
> > 100.  However, when I run the setkey script after this delay, the
> > reference count drops immediately to 1.  If I then flush the SAD/SP=
D, it
> > drops to 0.
> >=20
> > This behaviour is new: newer than the reported leak.  For example, =
with
> > 2.6.34, everything works perfectly with MAX_DGRAM_SIZE set to 1000 =
(the
> > SAs are destroyed immediately when the SAD/SPD are flushed), but th=
e
> > leak occurs with MAX_DGRAM_SIZE set to 10000.
> >=20
>=20
> Thanks Nick
>=20
> I suspect a skb->truesize bug somewhere.
>=20
> I can see atomic_read(&sk->sk_wmem_alloc) becoming negative after a
> while...
>=20
> I am investigating and let you know.
>=20
> Thanks
>=20

OK, I found a bug in ip_fragment() and ip6_fragment()

In case slow_path is hit, we have a truesize mismatch

Could you try following patch ?

Thanks !

[PATCH] ip : fix truesize mismatch in ip fragmentation

We should not set frag->destructor to sock_wkfree() until we are sure w=
e
dont hit slow path in ip_fragment(). Or we risk uncharging
frag->truesize twice, and in the end, having negative socket
sk_wmem_alloc counter, or even freeing socket sooner than expected.

Many thanks to Nick Bowler, who provided a very clean bug report and
test programs.

While Nick bisection pointed to commit 2b85a34e911bf483 (net: No more
expensive sock_hold()/sock_put() on each tx), underlying bug is older.

Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_output.c  |    8 ++++----
 net/ipv6/ip6_output.c |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

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
index d40b330..10983ab 100644
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
@@ -658,13 +657,15 @@ static int ip6_fragment(struct sk_buff *skb, int =
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
-
+			=09
 		err =3D 0;
 		offset =3D 0;
 		frag =3D skb_shinfo(skb)->frag_list;
@@ -693,7 +694,6 @@ static int ip6_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
=20
 		first_len =3D skb_pagelen(skb);
 		skb->data_len =3D first_len - skb_headlen(skb);
-		skb->truesize -=3D truesizes;
 		skb->len =3D first_len;
 		ipv6_hdr(skb)->payload_len =3D htons(first_len -
 						   sizeof(struct ipv6hdr));
