From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 14 Dec 2011 18:07:52 +1100
Message-ID: <20111214180752.7893d5460c6fca84d63cab0e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__14_Dec_2011_18_07_52_+1100_QpVIfYuXMlGGI0_q"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Glauber Costa <glommer@parallels.com>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__14_Dec_2011_18_07_52_+1100_QpVIfYuXMlGGI0_q
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi ,

After merging the final tree, today's linux-next build (powerpc
allnoconfig) failed like this:

In file included from include/linux/tcp.h:211:0,
                 from include/linux/ipv6.h:221,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:26,
                 from include/linux/nfs_fs.h:50,
                 from init/do_mounts.c:20:
include/net/sock.h: In function 'memcg_memory_allocated_add':
include/net/sock.h:1000:20: error: 'OVER_LIMIT' undeclared (first use in th=
is function)

And several other similar ones.

Caused by commit e1aab161e013 ("socket: initial cgroup code") from the
net-next tree. OVER_LIMIT is only defined it CONFIG_INET is set.

I applied the following (stupid) patch for today (just because reverting
the above commit would probably be too hard - we have cgroup stuff all
over the place :-( ):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 14 Dec 2011 18:01:12 +1100
Subject: [PATCH] socket: bad fix for cgroup code breakage

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/net/sock.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 6fe0dae..0603973 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -986,6 +986,7 @@ static inline long sk_prot_mem_limits(const struct sock=
 *sk, int index)
 	return prot[index];
 }
=20
+#ifdef CONFIG_INET
 static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 					      unsigned long amt,
 					      int *parent_status)
@@ -999,6 +1000,7 @@ static inline void memcg_memory_allocated_add(struct c=
g_proto *prot,
 	if (ret < 0)
 		*parent_status =3D OVER_LIMIT;
 }
+#endif
=20
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
 					      unsigned long amt)
@@ -1028,12 +1030,14 @@ sk_memory_allocated_add(struct sock *sk, int amt, i=
nt *parent_status)
 {
 	struct proto *prot =3D sk->sk_prot;
=20
+#ifdef CONFIG_INET
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
 		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
 		/* update the root cgroup regardless */
 		atomic_long_add_return(amt, prot->memory_allocated);
 		return memcg_memory_allocated_read(sk->sk_cgrp);
 	}
+#endif
=20
 	return atomic_long_add_return(amt, prot->memory_allocated);
 }
@@ -1043,9 +1047,11 @@ sk_memory_allocated_sub(struct sock *sk, int amt, in=
t parent_status)
 {
 	struct proto *prot =3D sk->sk_prot;
=20
+#ifdef CONFIG_INET
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
 	    parent_status !=3D OVER_LIMIT) /* Otherwise was uncharged already */
 		memcg_memory_allocated_sub(sk->sk_cgrp, amt);
+#endif
=20
 	atomic_long_sub(amt, prot->memory_allocated);
 }
--=20
1.7.7.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__14_Dec_2011_18_07_52_+1100_QpVIfYuXMlGGI0_q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO6EtIAAoJEECxmPOUX5FExBIP/3BBbg3m5976rYplrg/lCEVx
TnoiWzegGqakCEQ13hmnXeVRauwpyke4g705tU2+TniVmh7r9Hhr2C46wJBnLRuL
nQ9pB5Nz8tI9epMUEwajEUEisBUb8sus+pLKBCayNpfZplrexZkjW61ByS4qIKcT
I/VSZqsx/F5Nx0UsmJF25tY5SUiv/ZUnXjrPsd8or+nT1KgtMf70vnEl6rJQ1CdD
DV23I+vkoKOCwaloxHdQ+NEHlL7HRCMpv01ruclr3BXm/Q5dP4J99GOJ4e+Ir0qH
b1VVlQU9wEzGMxnbRprP9Qj/RjNrzwmTHpzsa6JgkurSngtFZRxq0N0zeCCmbERC
8nC259errA+DCwX2dLOBj9Cw1OrI5DFSacM6frchVPr5oYUaraKvuVANXmygx/+n
wjsGsm7XBW4b4dyhvm7rt8Z3E8OUFUNulWK71uucAZtvckJPMqLI+pkefp1wMpD6
9q44OQN27R8t/4R+3BgshQbZYIWHVgf5TVttyCn1Hg+Y67sftKnv+Cl3rMlEE83K
zJIv8h2HUyw9NWA3hK5gZy0x8f+ChoOZvgpWpNTvkviB+mEkEVeMtewIxIW2x6nk
sCfExA/zSFB/pqQXABBnv3dS7VeolHJ8DIbS5Taqg95rI+mlW30UphYtEflR3o2m
7138Pl1AUfBzuLzGDrHt
=tvX2
-----END PGP SIGNATURE-----

--Signature=_Wed__14_Dec_2011_18_07_52_+1100_QpVIfYuXMlGGI0_q--
