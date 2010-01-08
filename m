From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Thu, 07 Jan 2010 17:10:15 -0800 (PST)
Message-ID: <20100107.171015.29035630.davem@davemloft.net>
References: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
	<20100107.012701.257511338.davem@davemloft.net>
	<55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org, lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754494Ab0AHBKH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 20:10:07 -0500
In-Reply-To: <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Thu, 7 Jan 2010 17:05:36 -0800

> I've spoken with Tom and we can't quite seem to figure out what
> exactly the code should be attempting to accomplish here.

"git blame net/ipv4/route.c >x.c" might help you solve that
mystery, here is one example of what it might show you:

commit 0010e46577a27c1d915034637f6c2fa57a9a091c
Author: Timo Teras <timo.teras@iki.fi>
Date:   Tue Apr 29 03:32:25 2008 -0700

    ipv4: Update MTU to all related cache entries in ip_rt_frag_needed(=
)
   =20
    Add struct net_device parameter to ip_rt_frag_needed() and update M=
TU to
    cache entries where ifindex is specified. This is similar to what i=
s
    already done in ip_rt_redirect().
   =20
    Signed-off-by: Timo Teras <timo.teras@iki.fi>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/route.h b/include/net/route.h
index c633880..fc836ff 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -116,7 +116,7 @@ extern int		__ip_route_output_key(struct net *, str=
uct rtable **, const struct f
 extern int		ip_route_output_key(struct net *, struct rtable **, struct=
 flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, str=
uct flowi *flp, struct sock *sk, int flags);
 extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8=
 tos, struct net_device *devin);
-extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr =
*iph, unsigned short new_mtu);
+extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr =
*iph, unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
=20
 extern unsigned		inet_addr_type(struct net *net, __be32 addr);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c67d00e..8739735 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -691,7 +691,8 @@ static void icmp_unreach(struct sk_buff *skb)
 					       NIPQUAD(iph->daddr));
 			} else {
 				info =3D ip_rt_frag_needed(net, iph,
-						     ntohs(icmph->un.frag.mtu));
+							 ntohs(icmph->un.frag.mtu),
+							 skb->dev);
 				if (!info)
 					goto out;
 			}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ce25a13..5e3685c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1430,11 +1430,13 @@ static inline unsigned short guess_mtu(unsigned=
 short old_mtu)
 }
=20
 unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
-				 unsigned short new_mtu)
+				 unsigned short new_mtu,
+				 struct net_device *dev)
 {
-	int i;
+	int i, k;
 	unsigned short old_mtu =3D ntohs(iph->tot_len);
 	struct rtable *rth;
+	int  ikeys[2] =3D { dev->ifindex, 0 };
 	__be32  skeys[2] =3D { iph->saddr, 0, };
 	__be32  daddr =3D iph->daddr;
 	unsigned short est_mtu =3D 0;
@@ -1442,22 +1444,26 @@ unsigned short ip_rt_frag_needed(struct net *ne=
t, struct iphdr *iph,
 	if (ipv4_config.no_pmtu_disc)
 		return 0;
=20
-	for (i =3D 0; i < 2; i++) {
-		unsigned hash =3D rt_hash(daddr, skeys[i], 0);
+	for (k =3D 0; k < 2; k++) {
+		for (i =3D 0; i < 2; i++) {
+			unsigned hash =3D rt_hash(daddr, skeys[i], ikeys[k]);
=20
-		rcu_read_lock();
-		for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
-		     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
-			if (rth->fl.fl4_dst =3D=3D daddr &&
-			    rth->fl.fl4_src =3D=3D skeys[i] &&
-			    rth->rt_dst  =3D=3D daddr &&
-			    rth->rt_src  =3D=3D iph->saddr &&
-			    rth->fl.iif =3D=3D 0 &&
-			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU)) &&
-			    net_eq(dev_net(rth->u.dst.dev), net) &&
-			    rth->rt_genid =3D=3D atomic_read(&rt_genid)) {
+			rcu_read_lock();
+			for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
+			     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
 				unsigned short mtu =3D new_mtu;
=20
+				if (rth->fl.fl4_dst !=3D daddr ||
+				    rth->fl.fl4_src !=3D skeys[i] ||
+				    rth->rt_dst !=3D daddr ||
+				    rth->rt_src !=3D iph->saddr ||
+				    rth->fl.oif !=3D ikeys[k] ||
+				    rth->fl.iif !=3D 0 ||
+				    dst_metric_locked(&rth->u.dst, RTAX_MTU) ||
+				    !net_eq(dev_net(rth->u.dst.dev), net) ||
+				    rth->rt_genid !=3D atomic_read(&rt_genid))
+					continue;
+
 				if (new_mtu < 68 || new_mtu >=3D old_mtu) {
=20
 					/* BSD 4.2 compatibility hack :-( */
@@ -1483,8 +1489,8 @@ unsigned short ip_rt_frag_needed(struct net *net,=
 struct iphdr *iph,
 					est_mtu =3D mtu;
 				}
 			}
+			rcu_read_unlock();
 		}
-		rcu_read_unlock();
 	}
 	return est_mtu ? : new_mtu;
 }
