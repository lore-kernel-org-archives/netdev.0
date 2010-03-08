From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix route cache rebuilds
Date: Mon, 08 Mar 2010 14:20:00 +0100
Message-ID: <1268054400.6148.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:59828 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab0CHNUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 08:20:06 -0500
Received: by bwz1 with SMTP id 1so2766741bwz.21
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 05:20:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We added an automatic route cache rebuilding in commit 1080d709fb9d8cd4=
3
but had to correct few bugs. One of the assumption of original patch,
was that entries where kept sorted in a given way.

This assumption is known to be wrong (commit 1ddbcb005c395518 gave an
explanation of this and corrected a leak) and expensive to respect.

Pawe=C5=82 Staszewski reported to me one of his machine got its routing=
 cache
disabled after few messages like :

[ 2677.850065] Route hash chain too long!
[ 2677.850080] Adjust your secret_interval!
[82839.662993] Route hash chain too long!
[82839.662996] Adjust your secret_interval!
[155843.731650] Route hash chain too long!
[155843.731664] Adjust your secret_interval!
[155843.811881] Route hash chain too long!
[155843.811891] Adjust your secret_interval!
[155843.858209] vlan0811: 5 rebuilds is over limit, route caching
disabled
[155843.858212] Route hash chain too long!
[155843.858213] Adjust your secret_interval!

This is because rt_intern_hash() might be fooled when computing a chain
length, because multiple entries with same keys can differ because of
TOS (or mark/oif) bits.

In the rare case the fast algorithm see a too long chain, and before
taking expensive path, we call a helper function in order to not count
duplicates of same routes, that only differ with tos/mark/oif bits. Thi=
s
helper works with data already in cpu cache and is not be very
expensive, despite its O(N^2) implementation.

Pawe=C5=82 Staszewski sucessfully tested this patch on his loaded route=
r.

Reported-and-tested-by: Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   50 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b2ba558..d9b4024 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -146,7 +146,6 @@ static struct dst_entry *ipv4_negative_advice(struc=
t dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
-static void rt_emergency_hash_rebuild(struct net *net);
=20
=20
 static struct dst_ops ipv4_dst_ops =3D {
@@ -780,11 +779,30 @@ static void rt_do_flush(int process_context)
 #define FRACT_BITS 3
 #define ONE (1UL << FRACT_BITS)
=20
+/*
+ * Given a hash chain and an item in this hash chain,
+ * find if a previous entry has the same hash_inputs
+ * (but differs on tos, mark or oif)
+ * Returns 0 if an alias is found.
+ * Returns ONE if rth has no alias before itself.
+ */
+static int has_noalias(const struct rtable *head, const struct rtable =
*rth)
+{
+	const struct rtable *aux =3D head;
+
+	while (aux !=3D rth) {
+		if (compare_hash_inputs(&aux->fl, &rth->fl))
+			return 0;
+		aux =3D aux->u.dst.rt_next;
+	}
+	return ONE;
+}
+
 static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i =3D rover, goal;
-	struct rtable *rth, *aux, **rthp;
+	struct rtable *rth, **rthp;
 	unsigned long samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
 	unsigned long delta;
@@ -835,15 +853,7 @@ nofree:
 					 * attributes don't unfairly skew
 					 * the length computation
 					 */
-					for (aux =3D rt_hash_table[i].chain;;) {
-						if (aux =3D=3D rth) {
-							length +=3D ONE;
-							break;
-						}
-						if (compare_hash_inputs(&aux->fl, &rth->fl))
-							break;
-						aux =3D aux->u.dst.rt_next;
-					}
+					length +=3D has_noalias(rt_hash_table[i].chain, rth);
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
@@ -1073,6 +1083,21 @@ work_done:
 out:	return 0;
 }
=20
+/*
+ * Returns number of entries in a hash chain that have different hash_=
inputs
+ */
+static int slow_chain_length(const struct rtable *head)
+{
+	int length =3D 0;
+	const struct rtable *rth =3D head;
+
+	while (rth) {
+		length +=3D has_noalias(head, rth);
+		rth =3D rth->u.dst.rt_next;
+	}
+	return length >> FRACT_BITS;
+}
+
 static int rt_intern_hash(unsigned hash, struct rtable *rt,
 			  struct rtable **rp, struct sk_buff *skb)
 {
@@ -1185,7 +1210,8 @@ restart:
 			rt_free(cand);
 		}
 	} else {
-		if (chain_length > rt_chain_length_max) {
+		if (chain_length > rt_chain_length_max &&
+		    slow_chain_length(rt_hash_table[hash].chain) > rt_chain_length_m=
ax) {
 			struct net *net =3D dev_net(rt->u.dst.dev);
 			int num =3D ++net->ipv4.current_rt_cache_rebuild_count;
 			if (!rt_caching(dev_net(rt->u.dst.dev))) {




