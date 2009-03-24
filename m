From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: Use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
Date: Tue, 24 Mar 2009 20:54:53 +0100
Message-ID: <49C93A8D.8000603@cosmosbay.com>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50662 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbZCXTzK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 15:55:10 -0400
In-Reply-To: <49C8FBCA.40402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>=20
> We are working on a SLAB_DESTROY_BY_RCU implementation so that
> conntrack wont use call_rcu() anymore, give us a couple of days :)
>=20

While working on this stuff, I found one suspect use of hlist_add_head(=
)

Its not a hot path, I believe following patch would make sure nothing
wrong happens.

If a chain contains element A and B, then we might build a new table
with a new chain containing B and A (in this reverse order), and
a cpu could see A->next =3D B (new pointer),  B->next =3D A (old pointe=
r)

Thanks

[PATCH] netfilter: Use hlist_add_head_rcu() in nf_conntrack_set_hashsiz=
e()

Using hlist_add_head() in nf_conntrack_set_hashsize() is quite dangerou=
s.
Without any barrier, one CPU could see a loop while doing its lookup.
Its true new table cannot be seen by another cpu, but previous table is=
 still
readable.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 55befe5..54e983f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1121,7 +1121,7 @@ int nf_conntrack_set_hashsize(const char *val, st=
ruct kernel_param *kp)
 					struct nf_conntrack_tuple_hash, hnode);
 			hlist_del_rcu(&h->hnode);
 			bucket =3D __hash_conntrack(&h->tuple, hashsize, rnd);
-			hlist_add_head(&h->hnode, &hash[bucket]);
+			hlist_add_head_rcu(&h->hnode, &hash[bucket]);
 		}
 	}
 	old_size =3D nf_conntrack_htable_size;


