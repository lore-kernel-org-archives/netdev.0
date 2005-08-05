From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ctnetlink: fix list traversal order
Date: Fri, 5 Aug 2005 18:26:50 +0200
Message-ID: <20050805162650.GC4033@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z4+8/lEcDcG5Ke9S"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--z4+8/lEcDcG5Ke9S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply.

[NETFILTER] fix list traversal order in ctnetlink

Currently conntracks are inserted after the head. That means that
conntracks are sorted from the biggest to the smallest id. This happens
because we use list_prepend (list_add) instead list_add_tail. This can
result in problems during the list iteration.

                 list_for_each(i, &ip_conntrack_hash[cb->args[0]]) {
                         h =3D (struct ip_conntrack_tuple_hash *) i;
                         if (DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
                                 continue;
                         ct =3D tuplehash_to_ctrack(h);
                         if (ct->id <=3D *id)
                                 continue;

In that case just the first conntrack in the bucket will be dumped. To
fix this, we iterate the list from the tail to the head via
list_for_each_prev. Same thing for the list of expectations.

Signed-off-by: Pablo Neira Ayuso <pablo@eurodev.net>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 570b2053cc2c68da90b71add2a4f4366673b48d8
tree bbcf496f0fb3fc468db26a03ccf1455e206a2251
parent 76596b57e2fe552da8beef4a59d5b559dfc3d0e5
author Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:25:50 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 14:25:50 +02=
00

 net/ipv4/netfilter/ip_conntrack_netlink.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_netlink.c b/net/ipv4/netfilter=
/ip_conntrack_netlink.c
--- a/net/ipv4/netfilter/ip_conntrack_netlink.c
+++ b/net/ipv4/netfilter/ip_conntrack_netlink.c
@@ -404,7 +404,7 @@ ctnetlink_dump_table(struct sk_buff *skb
=20
 	read_lock_bh(&ip_conntrack_lock);
 	for (; cb->args[0] < ip_conntrack_htable_size; cb->args[0]++, *id =3D 0) {
-		list_for_each(i, &ip_conntrack_hash[cb->args[0]]) {
+		list_for_each_prev(i, &ip_conntrack_hash[cb->args[0]]) {
 			h =3D (struct ip_conntrack_tuple_hash *) i;
 			if (DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
 				continue;
@@ -441,7 +441,7 @@ ctnetlink_dump_table_w(struct sk_buff *s
=20
 	write_lock_bh(&ip_conntrack_lock);
 	for (; cb->args[0] < ip_conntrack_htable_size; cb->args[0]++, *id =3D 0) {
-		list_for_each(i, &ip_conntrack_hash[cb->args[0]]) {
+		list_for_each_prev(i, &ip_conntrack_hash[cb->args[0]]) {
 			h =3D (struct ip_conntrack_tuple_hash *) i;
 			if (DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
 				continue;
@@ -1214,7 +1214,7 @@ ctnetlink_exp_dump_table(struct sk_buff=20
 	DEBUGP("entered %s, last id=3D%llu\n", __FUNCTION__, *id);
=20
 	read_lock_bh(&ip_conntrack_lock);
-	list_for_each(i, &ip_conntrack_expect_list) {
+	list_for_each_prev(i, &ip_conntrack_expect_list) {
 		exp =3D (struct ip_conntrack_expect *) i;
 		if (exp->id <=3D *id)
 			continue;
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--z4+8/lEcDcG5Ke9S
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC85NJXaXGVTD0i/8RAkRiAJ9Me58wuXBY0hiXtcIb/tkUxX2NvgCeJinE
rcruNMClcXBOHsnt0KH9mpY=
=6TTW
-----END PGP SIGNATURE-----

--z4+8/lEcDcG5Ke9S--
