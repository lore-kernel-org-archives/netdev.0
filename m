From: Sven Schuster <schuster.sven@gmx.de>
Subject: [RFC/PATCH] check tcp_v4_md5_do_add retval in tcp-2.6 tree
Date: Fri, 22 Oct 2004 16:38:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022143837.GA1173@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi everybody, hi David,

after the recent posting asking for the tcp md5 implementation I
checked out the tcp-2.6 repo and had a look at it. I found that in
a few places the return value of tcp_v4_md5_do_add() isn't checked
and then kmalloc()ed memory is not kfree()ed. This patch does this,
or at least tries to...but I'm not sure if the kfree() on newkey is
enough in tcp_v4_syn_recv_sock(), shouldn't we also call
tcp_v4_destroy_sock() or something like that and sk_free() on newsk,
too??
Also there is another case in tcp_minisocks.c::tcp_check_req() where
tcp_v4_md5_do_add() is called indirectly over af_specific->md5_add().
What should be done there? RST the connection??


Regards

Sven Schuster



# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/22 12:12:11+02:00 sven@zion.homelinux.com=20
#   tcp_ipv4.c:
#     [TCP-MD5]: check return values of tcp_v4_md5_do_add
#
#     Signed-off-by: Sven Schuster <schuster.sven@gmx.de>
#=20
# net/ipv4/tcp_ipv4.c
#   2004/10/22 12:11:03+02:00 sven@zion.homelinux.com +10 -2
#   [TCP-MD5]: check return values of tcp_v4_md5_do_add
#
#   Signed-off-by: Sven Schuster <schuster.sven@gmx.de>
#=20
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-10-22 12:13:42 +02:00
+++ b/net/ipv4/tcp_ipv4.c	2004-10-22 12:13:42 +02:00
@@ -1731,11 +1731,16 @@
 			 * memory, then we end up not copying the key
 			 * across. Shucks.
 			 */
+			int ret;
 			char *newkey =3D kmalloc(key->keylen, GFP_ATOMIC);
 			if (newkey) {
 				memcpy(newkey, key->key, key->keylen);
-				tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
+				ret =3D tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 						  newkey, key->keylen);
+				if (ret !=3D 0) {
+					kfree(newkey);
+					goto exit;
+				}
 			}
 		}
 	}
@@ -2334,6 +2339,7 @@
=20
 static int tcp_v4_md5_add(struct sock *sk, struct tcp_rfc2385_cmd *cmd)
 {
+	int ret;
 	unsigned char *newkey;
=20
 	/* Was a key already defined for this address?
@@ -2347,7 +2353,11 @@
 		return -EFAULT;
 	}
=20
-	return tcp_v4_md5_do_add(sk, cmd->address, newkey, cmd->keylen);
+	ret =3D  tcp_v4_md5_do_add(sk, cmd->address, newkey, cmd->keylen);
+	if (ret !=3D 0)
+		kfree(newkey);
+
+	return ret;
 }
=20
 /* This can be called on a newly created socket, from other files */

--=20
Linux zion 2.6.9-rc1-mm4 #1 Tue Sep 7 12:57:19 CEST 2004 i686 athlon i386 G=
NU/Linux
 16:34:02 up 26 days, 15:48,  1 user,  load average: 0.00, 0.01, 0.00

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBeRtto4FAdB2PneQRAqEeAJ9kUsXNzB77voGD04fuIERRb4hUeQCfdnNv
n817BRfW14HZxPcT7wrC2ao=
=OD2K
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
