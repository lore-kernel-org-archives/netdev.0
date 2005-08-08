From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ip_conntrack: fix handling of OOM
Date: Mon, 8 Aug 2005 22:05:59 +0200
Message-ID: <20050808200559.GW25303@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FIfSo9pyi3Jhph90"
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


--FIfSo9pyi3Jhph90
Content-Type: multipart/mixed; boundary="+Pu8h6CsJtbukPM9"
Content-Disposition: inline


--+Pu8h6CsJtbukPM9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply to net-2.6.14,

[ok, now back to vdev]
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--+Pu8h6CsJtbukPM9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="41-conntrack_alloc-errptr.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] return ENOMEM when ip_conntrack_alloc() fails.

This patch fixes the bug which doesn't return ERR_PTR(-ENOMEM) if it failed
to allocate memory space from slab cache.  This bug leads to erroneously
not dropped packets under stress, and wrong statistic counters ('invalid'
is incremented instead of 'drop').  It was introduced during the ctnetlink
merge in the net-2.6.14 tree, so no stable or mainline releases affected.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 5fd482be95fb5c0f60e1dc51bcd956ed535c33cb
tree 64c3930d4f4e701db945b27ebfe972d83ee1ed30
parent 041cf7f2c1158ae8e9b6d8173b77cbcc878cb54c
author Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 21:57:59 +0200
committer Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 21:57:59 +02=
00

 net/ipv4/netfilter/ip_conntrack_core.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -655,7 +655,7 @@ struct ip_conntrack *ip_conntrack_alloc(
 	conntrack =3D kmem_cache_alloc(ip_conntrack_cachep, GFP_ATOMIC);
 	if (!conntrack) {
 		DEBUGP("Can't allocate conntrack.\n");
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	}
=20
 	memset(conntrack, 0, sizeof(*conntrack));
@@ -696,8 +696,9 @@ init_conntrack(struct ip_conntrack_tuple
 		return NULL;
 	}
=20
-	if (!(conntrack =3D ip_conntrack_alloc(tuple, &repl_tuple)))
-		return NULL;
+	conntrack =3D ip_conntrack_alloc(tuple, &repl_tuple);
+	if (conntrack =3D=3D NULL || IS_ERR(conntrack))
+		return (struct ip_conntrack_tuple_hash *)conntrack;
=20
 	if (!protocol->new(conntrack, skb)) {
 		ip_conntrack_free(conntrack);

--+Pu8h6CsJtbukPM9--

--FIfSo9pyi3Jhph90
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC97snXaXGVTD0i/8RAixMAKCKxwAi1UQGjNm3cUK6XRCj7VleBQCgq36f
KRK1t16IegWBnjN7mj/zzPI=
=7lJg
-----END PGP SIGNATURE-----

--FIfSo9pyi3Jhph90--
