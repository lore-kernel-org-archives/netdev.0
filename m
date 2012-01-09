From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 9 Jan 2012 16:38:12 +1100
Message-ID: <20120109163812.4cb695944ea9716953afbfc9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__9_Jan_2012_16_38_12_+1100_GEAnf6bjRymC5xO5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Glauber Costa <glommer@parallels.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__9_Jan_2012_16_38_12_+1100_GEAnf6bjRymC5xO5
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
include/net/sock.h: In function 'sk_update_clone':
include/net/sock.h:1109:3: error: implicit declaration of function 'sock_up=
date_memcg' [-Werror=3Dimplicit-function-declaration]

Caused by commit f3f511e1ce6f ("net: fix sock_clone reference mismatch
with tcp memcontrol") from the net tree.  In this build, CONFIG_INET is not=
 set.

I applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Jan 2012 16:33:16 +1100
Subject: [PATCH] net: sk_update_clone is only used in net/core/sock.c

so move it there.  Fixes build errors when CONFIG_INET is not defeined:

In file included from include/linux/tcp.h:211:0,
                 from include/linux/ipv6.h:221,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:26,
                 from include/linux/nfs_fs.h:50,
                 from init/do_mounts.c:20:
include/net/sock.h: In function 'sk_update_clone':
include/net/sock.h:1109:3: error: implicit declaration of function 'sock_up=
date_memcg' [-Werror=3Dimplicit-function-declaration]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/net/sock.h |    6 ------
 net/core/sock.c    |    6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0ed65e3..bb972d2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1103,12 +1103,6 @@ sk_sockets_allocated_read_positive(struct sock *sk)
 	return percpu_counter_sum_positive(prot->sockets_allocated);
 }
=20
-static inline void sk_update_clone(const struct sock *sk, struct sock *new=
sk)
-{
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		sock_update_memcg(newsk);
-}
-
 static inline int
 proto_sockets_allocated_sum_positive(struct proto *prot)
 {
diff --git a/net/core/sock.c b/net/core/sock.c
index e80b64f..c3ae73d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1272,6 +1272,12 @@ void sk_release_kernel(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_release_kernel);
=20
+static void sk_update_clone(const struct sock *sk, struct sock *newsk)
+{
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sock_update_memcg(newsk);
+}
+
 /**
  *	sk_clone_lock - clone a socket, and lock its clone
  *	@sk: the socket to clone
--=20
1.7.8.197.g73c6b

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__9_Jan_2012_16_38_12_+1100_GEAnf6bjRymC5xO5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPCn1EAAoJEECxmPOUX5FElWYP/jd3B2eza0Np7caCMJvwxdgl
FydE7VUd5lalHoDDvTFgoBmg+OPO9IO3DtkLaIz3dThzuHGoM/HemD2rLXXmqinY
BrJ0k3LEteafm2BMW7t255uNkwyPvaM3L9E9wqFfunnC8L8eB0GWpSbXKKmP3Vpz
f6Jq0eCaIcPys478s8877ThFaSqQlVeMmPwv2KdWPOMHkvLTG8cDOD7/FhHVmeuY
/VCF5NB/4TehxNq8GvvfMf+t54vFItZE9ZDs/mM7YqedVybNeU44zOQD4bAfDxI6
fRH7f7Q8KRCCacqouHUUkxtOaMPMS83yNrZdDjxKUbPyoJAH77C8aqUgtQol6vtH
n6RfVdr8XBiuFe3uTDMiM+jvnrQ8zjccyeC48AUDNa047vCbu6wzO16YzdMiebxQ
+4csXaniGMl6c57PGJ9uWxqbt2xzN7/OVxmOHGvXXrTkeL3dCWBXP5s346fJmpIG
LZ4EdDh1ZFXqLYlPwX4EfWBSJSJ3N9rSTELRL5pMWvsGJN5mHDG67stDH38EyVMd
UgYJow3o+Mf//ovU+QR96wdGQi1qrvALgzZPeBIagOW+9a4IEt9fMyYvNazwoAP3
846vQDnCA9CdPHTCpUkiwWJUoLEnqbEzrNFnKCa1VtxKyb5yUfTB+QLRjIiqtYEv
oNSZIuZy+XR8N6aKjO8+
=Y/o7
-----END PGP SIGNATURE-----

--Signature=_Mon__9_Jan_2012_16_38_12_+1100_GEAnf6bjRymC5xO5--
