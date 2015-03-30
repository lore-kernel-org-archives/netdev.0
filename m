From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the vfs tree
Date: Mon, 30 Mar 2015 14:24:36 +1100
Message-ID: <20150330142436.56a5556e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/nvPI6XMcUCWvAFvR4XoDl8t"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"tadeusz.struk@intel.com" <tadeusz.struk@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/nvPI6XMcUCWvAFvR4XoDl8t
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/socket.c between commit 774157aa4897 ("net: switch importing msghdr
from userland to {compat_,}import_iovec()") from the vfs tree and
commit 0345f93138b2 ("net: socket: add support for async operations")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/socket.c
index abc721654ab5,073809f4125f..000000000000
--- a/net/socket.c
+++ b/net/socket.c
@@@ -841,11 -808,10 +794,10 @@@ static ssize_t sock_read_iter(struct ki
  	if (iocb->ki_pos !=3D 0)
  		return -ESPIPE;
 =20
 -	if (iocb->ki_nbytes =3D=3D 0)	/* Match SYS5 behaviour */
 +	if (!iov_iter_count(to))	/* Match SYS5 behaviour */
  		return 0;
 =20
- 	res =3D __sock_recvmsg(iocb, sock, &msg,
- 			     iov_iter_count(to), msg.msg_flags);
 -	res =3D sock_recvmsg(sock, &msg, iocb->ki_nbytes, msg.msg_flags);
++	res =3D sock_recvmsg(sock, &msg, iov_iter_count(to), msg.msg_flags);
  	*to =3D msg.msg_iter;
  	return res;
  }
@@@ -866,7 -833,7 +819,7 @@@ static ssize_t sock_write_iter(struct k
  	if (sock->type =3D=3D SOCK_SEQPACKET)
  		msg.msg_flags |=3D MSG_EOR;
 =20
- 	res =3D __sock_sendmsg(iocb, sock, &msg, iov_iter_count(from));
 -	res =3D sock_sendmsg(sock, &msg, iocb->ki_nbytes);
++	res =3D sock_sendmsg(sock, &msg, iov_iter_count(from));
  	*from =3D msg.msg_iter;
  	return res;
  }
@@@ -1921,8 -1896,15 +1874,10 @@@ static int copy_msghdr_from_user(struc
  	if (nr_segs > UIO_MAXIOV)
  		return -EMSGSIZE;
 =20
+ 	kmsg->msg_iocb =3D NULL;
+=20
 -	err =3D rw_copy_check_uvector(save_addr ? READ : WRITE,
 -				    uiov, nr_segs,
 -				    UIO_FASTIOV, *iov, iov);
 -	if (err >=3D 0)
 -		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
 -			      *iov, nr_segs, err);
 -	return err;
 +	return import_iovec(save_addr ? READ : WRITE, uiov, nr_segs,
 +			    UIO_FASTIOV, iov, &kmsg->msg_iter);
  }
 =20
  static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user =
*msg,

--Sig_/nvPI6XMcUCWvAFvR4XoDl8t
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVGMH4AAoJEMDTa8Ir7ZwVSm8P/j+JkDHE/8kKmpju33OG4flC
D+L+fPEO404YfJ5zQf3b+t9G1eONbHKaiJgC3X2pZDWszCcQ1qADPnSf5Q7QR9pS
C4t+IbKJYVJIWLQJmiep8OZ0tistbwgAvueEKUm6oLFoYaL1GOBS2svTzMtjl4Dk
WkPfNCJC60DrECiZBr/SkziR68k2Ew5o8pKjPvQOemlJZvxa3p/XCabRh3aihjUu
pzlakI6bophbijQDER9P6U9V2WjB7v2+/ie7s6TzbQRrX/vrSb5eJK7AAgSalvVl
AqK1drIWZRnbEJU/O5/wEr0bO9FHaIisLGR+8HkZ5CG0pJWQKwoJeLuCJRsBWIH/
3SiHyKvUTKMYUBiRRP2qnmajAjrcexVNcGDh7JgRZE3mwkY6Id0bY55NpSde0KKZ
vTs7GTDyQJ6DrstZx1eZSre1iZgoj6o4bdbiE98N27NXIibvQDaR41N5BUGRLwGz
+1wzqirGnT8rJIZivfo1ttW7rIidi50Ze1nA4UArqanvPDiNg1i0KkF5SW9yEJR8
JCHJwFEYnusGLBK0c01c7g/dtwqTZITSWLzNKOzCRWcNTCNon/hBUEq6elwHhw09
CvryAzpGTmZxnrc41ggoFsmXmuG8tvNNfkRuzJSAdseyEfYuwhyrX7q/9VIUEyGn
m0sgEBrfqTvvPkiUr6Mn
=4WBa
-----END PGP SIGNATURE-----

--Sig_/nvPI6XMcUCWvAFvR4XoDl8t--
