From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: save cpu cycles from check_leaf()
Date: Mon, 18 Jul 2011 15:16:33 +0200
Message-ID: <1310994993.5756.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110717.122949.1167434585296050332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36189 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835Ab1GRNQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 09:16:43 -0400
Received: by wwe5 with SMTP id 5so3169191wwe.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 06:16:42 -0700 (PDT)
In-Reply-To: <20110717.122949.1167434585296050332.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 17 juillet 2011 =C3=A0 12:29 -0700, David Miller a =C3=A9cr=
it :

> I guess the indirection removal is a non-trivial improvement because
> these changes knock a full 2 seconds off of my udpflood tests. :-)

Excellent !

One other improvement is to get rid of ntohl(inet_make_mask(plen)) stuf=
f
in check_leaf(), this saves 0.5 second on udpflood on my machine (27.25
second -> 26.75)

[PATCH net-next-2.6] ipv4: save cpu cycles from check_leaf()

Compiler is not smart enough to avoid double BSWAP instructions in
ntohl(inet_make_mask(plen)).

Lets cache this value in struct leaf_info, (fill a hole on 64bit arches=
)

With route cache disabled, this saves ~2% of cpu in udpflood bench on
x86_64 machine.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_trie.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 58c25ea..de9e297 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -110,9 +110,10 @@ struct leaf {
=20
 struct leaf_info {
 	struct hlist_node hlist;
-	struct rcu_head rcu;
 	int plen;
+	u32 mask_plen; /* ntohl(inet_make_mask(plen)) */
 	struct list_head falh;
+	struct rcu_head rcu;
 };
=20
 struct tnode {
@@ -451,6 +452,7 @@ static struct leaf_info *leaf_info_new(int plen)
 	struct leaf_info *li =3D kmalloc(sizeof(struct leaf_info),  GFP_KERNE=
L);
 	if (li) {
 		li->plen =3D plen;
+		li->mask_plen =3D ntohl(inet_make_mask(plen));
 		INIT_LIST_HEAD(&li->falh);
 	}
 	return li;
@@ -1359,10 +1361,8 @@ static int check_leaf(struct fib_table *tb, stru=
ct trie *t, struct leaf *l,
=20
 	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
 		struct fib_alias *fa;
-		int plen =3D li->plen;
-		__be32 mask =3D inet_make_mask(plen);
=20
-		if (l->key !=3D (key & ntohl(mask)))
+		if (l->key !=3D (key & li->mask_plen))
 			continue;
=20
 		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
@@ -1394,7 +1394,7 @@ static int check_leaf(struct fib_table *tb, struc=
t trie *t, struct leaf *l,
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				t->stats.semantic_match_passed++;
 #endif
-				res->prefixlen =3D plen;
+				res->prefixlen =3D li->plen;
 				res->nh_sel =3D nhsel;
 				res->type =3D fa->fa_type;
 				res->scope =3D fa->fa_info->fib_scope;
@@ -1402,7 +1402,7 @@ static int check_leaf(struct fib_table *tb, struc=
t trie *t, struct leaf *l,
 				res->table =3D tb;
 				res->fa_head =3D &li->falh;
 				if (!(fib_flags & FIB_LOOKUP_NOREF))
-					atomic_inc(&res->fi->fib_clntref);
+					atomic_inc(&fi->fib_clntref);
 				return 0;
 			}
 		}


