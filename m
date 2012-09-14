From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 14 Sep 2012 11:18:10 +1000
Message-ID: <20120914111810.f88f60875881742ce92cbf43@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__14_Sep_2012_11_18_10_+1000_z=XJr1t.G6QUt5yC"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:58615 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab2INBSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 21:18:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__14_Sep_2012_11_18_10_+1000_z=XJr1t.G6QUt5yC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/netfilter/nfnetlink_log.c between commit 0626af313957 ("netfilter:
take care of timewait sockets") from the  tree and commit 9eea9515cb5f
("userns: nfnetlink_log: Report socket uids in the log sockets user
namespace") from the net-next tree.

Just context changes. I fixed it up (see below) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netfilter/nfnetlink_log.c
index 5cfb5be,8cb67c4..0000000
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@@ -500,14 -501,16 +502,17 @@@ __build_packet_message(struct nfulnl_in
  	}
 =20
  	/* UID */
 -	if (skb->sk) {
 -		read_lock_bh(&skb->sk->sk_callback_lock);
 -		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
 -			struct file *file =3D skb->sk->sk_socket->file;
 +	sk =3D skb->sk;
 +	if (sk && sk->sk_state !=3D TCP_TIME_WAIT) {
 +		read_lock_bh(&sk->sk_callback_lock);
 +		if (sk->sk_socket && sk->sk_socket->file) {
 +			struct file *file =3D sk->sk_socket->file;
- 			__be32 uid =3D htonl(file->f_cred->fsuid);
- 			__be32 gid =3D htonl(file->f_cred->fsgid);
+ 			__be32 uid =3D htonl(from_kuid_munged(inst->peer_user_ns,
+ 							    file->f_cred->fsuid));
+ 			__be32 gid =3D htonl(from_kgid_munged(inst->peer_user_ns,
+ 							    file->f_cred->fsgid));
+ 			/* need to unlock here since NLA_PUT may goto */
 -			read_unlock_bh(&skb->sk->sk_callback_lock);
 +			read_unlock_bh(&sk->sk_callback_lock);
  			if (nla_put_be32(inst->skb, NFULA_UID, uid) ||
  			    nla_put_be32(inst->skb, NFULA_GID, gid))
  				goto nla_put_failure;

--Signature=_Fri__14_Sep_2012_11_18_10_+1000_z=XJr1t.G6QUt5yC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQUoXSAAoJEECxmPOUX5FEbnoP/2NLujmAdcoQbe47Ow85kDi3
Q5Dw1uMOrkxgv7Cy006tre6mgafEsm/X/2vIb1eV2l26Yy8aB6LxXW4mPb5eMpUN
TolHfl/PBNATMpm11xY1Z7dYUPb91Y9rNSHMpeLPO5qWgANp8GIFG+K6SUj4Ivdq
sF4DjG29jvCuELe0jhv9xeqdAqbaP4bNvD0ffNattJVcn3KPA2R8mxO6S0jZBpZz
rgMzOd5R+u6TZmpF2/zqkE5+ftqOXQ7tfJpaKCxZ1KBLf8NxraYGD7AjW0mzyMFo
qYr6h5TelGNVkm7e59xVQ/mMNFDTAcqWZEqenRCzK6F3d7buuIlvmxHhrSa67X5l
EduKWICVgSX0xbpYl6EV8O0oZDCEL4iWzp7Z9uhWses68AZ2Qr2aK/8Mu206U+6A
d3Yjzs3PebtenJ8AUlcTh33mFJcXxZ/J+fGMzd1e8rAbSNFTYEHPuvGx5Ip8sJsq
RMXKLpCpf9oICccarb9/5hnoSo+S72MgM7QC9qrRbENyxHD3mkf3wK/Ao3I6qqdO
U7Zn93XNkh69MV3jkI022oliN5EP7RHXzfzMZsSGzcumXf47qbeBCLkap6VRfKWB
xxlgjWN2c9Sx5DYBpnY710/UGYlaZtfVXrAsTmYoQix0iStiaGF7Gu2XDHgN02zG
k1O9K3YGGtxawZg49k2p
=C0hZ
-----END PGP SIGNATURE-----

--Signature=_Fri__14_Sep_2012_11_18_10_+1000_z=XJr1t.G6QUt5yC--
