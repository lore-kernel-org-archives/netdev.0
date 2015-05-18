From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 18 May 2015 13:39:11 +1000
Message-ID: <20150518133911.0b420f4f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/XcNP17C0_6VwIaJY_JPzuFO"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:34954 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbbERDjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 23:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/XcNP17C0_6VwIaJY_JPzuFO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/switchdev/switchdev.c between commit eea39946a1f3 ("rename
RTNH_F_EXTERNAL to RTNH_F_OFFLOAD") from the net tree and various
commits from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/switchdev/switchdev.c
index 055453d48668,0409f9b5bdbc..000000000000
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@@ -328,18 -670,13 +670,13 @@@ int switchdev_fib_ipv4_add(u32 dst, in
  	if (fi->fib_net->ipv4.fib_offload_disabled)
  		return 0;
 =20
- 	dev =3D netdev_switch_get_dev_by_nhs(fi);
+ 	dev =3D switchdev_get_dev_by_nhs(fi);
  	if (!dev)
  		return 0;
- 	ops =3D dev->swdev_ops;
-=20
- 	if (ops->swdev_fib_ipv4_add) {
- 		err =3D ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
- 					      fi, tos, type, nlflags,
- 					      tb_id);
- 		if (!err)
- 			fi->fib_flags |=3D RTNH_F_OFFLOAD;
- 	}
+=20
+ 	err =3D switchdev_port_obj_add(dev, &fib_obj);
+ 	if (!err)
 -		fi->fib_flags |=3D RTNH_F_EXTERNAL;
++		fi->fib_flags |=3D RTNH_F_OFFLOAD;
 =20
  	return err;
  }
@@@ -357,27 -694,34 +694,34 @@@ EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_ad
   *
   *	Delete IPv4 route entry from switch device.
   */
- int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
- 			       u8 tos, u8 type, u32 tb_id)
+ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+ 			   u8 tos, u8 type, u32 tb_id)
  {
+ 	struct switchdev_obj fib_obj =3D {
+ 		.id =3D SWITCHDEV_OBJ_IPV4_FIB,
+ 		.u.ipv4_fib =3D {
+ 			.dst =3D dst,
+ 			.dst_len =3D dst_len,
+ 			.fi =3D fi,
+ 			.tos =3D tos,
+ 			.type =3D type,
+ 			.nlflags =3D 0,
+ 			.tb_id =3D tb_id,
+ 		},
+ 	};
  	struct net_device *dev;
- 	const struct swdev_ops *ops;
  	int err =3D 0;
 =20
 -	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
 +	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
  		return 0;
 =20
- 	dev =3D netdev_switch_get_dev_by_nhs(fi);
+ 	dev =3D switchdev_get_dev_by_nhs(fi);
  	if (!dev)
  		return 0;
- 	ops =3D dev->swdev_ops;
 =20
- 	if (ops->swdev_fib_ipv4_del) {
- 		err =3D ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
- 					      fi, tos, type, tb_id);
- 		if (!err)
- 			fi->fib_flags &=3D ~RTNH_F_OFFLOAD;
- 	}
+ 	err =3D switchdev_port_obj_del(dev, &fib_obj);
+ 	if (!err)
 -		fi->fib_flags &=3D ~RTNH_F_EXTERNAL;
++		fi->fib_flags &=3D ~RTNH_F_OFFLOAD;
 =20
  	return err;
  }

--Sig_/XcNP17C0_6VwIaJY_JPzuFO
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVWV7kAAoJEMDTa8Ir7ZwVPoUP+wZkms9MDgUOHbWwFvytOh4i
bH4ELNofF+5h9QBKIZy5/tQXUnabwTdyc2WilvbPv5B/z3pcz9Z3Lb9xyWHTRR56
vD7pkQ9W/SP23UFflqsi6DIquL5TkX0ttPOhGwYgX0Yqt0857LLFZTYKDipO4czt
zfMjdMQ/tUsNfYOFdm4Q62U3ux2vicilmpOahwUZwgOTT1Z3XAHioxIbOxvKBfL+
xdkasm1QVB2eIXSwZIyQNq11huqD3pz5gg5J4aCVKVNY8/KaK8rbGXBOPZ9DWVfL
PvrDpXe2bhd7c6y6673Z0Hrx+lei3DDC8275zrw7YMsTxXClGOfz0PHcwVI7ZJjo
klqng81c27y7Radc3eaKqmauM+LqTrbrx2YElRcDGO+1XfRolNjrLxwTg9GjVdrg
jfcs7nZKAdP6dCxizcWNlajUhQvK6YMPBmxi7WgxNmhn8MGdqDOzTEwQ2pRgkZry
rm9oJKcJ3E8rt6uUNN9VWXm/kwCe3TMyX9NsJkFsSvYpWLGJOA72+hV3+pl+W7Qm
3aPH4PX8YTF9duRKUZMJ1tW3oVL+OkOBkE5hi/IYopNzjqKJWuZ4V32jhSD30YZ8
aqlgkqQ2yvjVdWiLQkxhTUH/qGJGe5XFP7l01PUhWh0MQumoh3slse5rk5EhGu/e
F7qti614Zdu9tooB3a/h
=xQbG
-----END PGP SIGNATURE-----

--Sig_/XcNP17C0_6VwIaJY_JPzuFO--
