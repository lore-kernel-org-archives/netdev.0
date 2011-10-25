From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the driver-core tree with the net-next
 tree
Date: Tue, 25 Oct 2011 19:07:21 +1100
Message-ID: <20111025190721.0fe8674b55e7a0b25902113a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Oct_2011_19_07_21_+1100_pieV9NWhS7qAh8gL"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mikulas Patocka <mpatocka@redhat.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Oct_2011_19_07_21_+1100_pieV9NWhS7qAh8gL
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the driver-core tree got a conflict in
fs/sysfs/dir.c between commit 23396180a977 ("sysfs: Remove support for
tagged directories with untagged members") from the net-next tree and
commits 4f72c0cab405 ("sysfs: use rb-tree for name lookups") and
a406f75840e1 ("sysfs: use rb-tree for inode number lookup") from the
driver-core tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc fs/sysfs/dir.c
index 26f370a,83bb9d1..0000000
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@@ -547,22 -558,36 +565,43 @@@ struct sysfs_dirent *sysfs_find_dirent(
  				       const void *ns,
  				       const unsigned char *name)
  {
- 	struct sysfs_dirent *sd;
+ 	struct rb_node *p =3D parent_sd->s_dir.name_tree.rb_node;
+ 	struct sysfs_dirent *found =3D NULL;
 =20
 +	if (!!sysfs_ns_type(parent_sd) !=3D !!ns) {
 +		WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
 +			sysfs_ns_type(parent_sd)? "required": "invalid",
 +			parent_sd->s_name, name);
 +		return NULL;
 +	}
 +
- 	for (sd =3D parent_sd->s_dir.children; sd; sd =3D sd->s_sibling) {
- 		if (sd->s_ns !=3D ns)
- 			continue;
- 		if (!strcmp(sd->s_name, name))
- 			return sd;
+ 	while (p) {
+ 		int c;
+ #define node	rb_entry(p, struct sysfs_dirent, name_node)
+ 		c =3D strcmp(name, node->s_name);
+ 		if (c < 0) {
+ 			p =3D node->name_node.rb_left;
+ 		} else if (c > 0) {
+ 			p =3D node->name_node.rb_right;
+ 		} else {
+ 			found =3D node;
+ 			p =3D node->name_node.rb_left;
+ 		}
+ #undef node
  	}
- 	return NULL;
+=20
+ 	if (found && ns) {
+ 		while (found->s_ns && found->s_ns !=3D ns) {
+ 			p =3D rb_next(&found->name_node);
+ 			if (!p)
+ 				return NULL;
+ 			found =3D rb_entry(p, struct sysfs_dirent, name_node);
+ 			if (strcmp(name, found->s_name))
+ 				return NULL;
+ 		}
+ 	}
+=20
+ 	return found;
  }
 =20
  /**
@@@ -895,12 -918,28 +932,28 @@@ static struct sysfs_dirent *sysfs_dir_p
  			pos =3D NULL;
  	}
  	if (!pos && (ino > 1) && (ino < INT_MAX)) {
- 		pos =3D parent_sd->s_dir.children;
- 		while (pos && (ino > pos->s_ino))
- 			pos =3D pos->s_sibling;
+ 		struct rb_node *p =3D parent_sd->s_dir.inode_tree.rb_node;
+ 		while (p) {
+ #define node	rb_entry(p, struct sysfs_dirent, inode_node)
+ 			if (ino < node->s_ino) {
+ 				pos =3D node;
+ 				p =3D node->inode_node.rb_left;
+ 			} else if (ino > node->s_ino) {
+ 				p =3D node->inode_node.rb_right;
+ 			} else {
+ 				pos =3D node;
+ 				break;
+ 			}
+ #undef node
+ 		}
+ 	}
 -	while (pos && pos->s_ns && pos->s_ns !=3D ns) {
++	while (pos && pos->s_ns !=3D ns) {
+ 		struct rb_node *p =3D rb_next(&pos->inode_node);
+ 		if (!p)
+ 			pos =3D NULL;
+ 		else
+ 			pos =3D rb_entry(p, struct sysfs_dirent, inode_node);
  	}
- 	while (pos && pos->s_ns !=3D ns)
- 		pos =3D pos->s_sibling;
  	return pos;
  }
 =20
@@@ -908,10 -947,13 +961,13 @@@ static struct sysfs_dirent *sysfs_dir_n
  	struct sysfs_dirent *parent_sd,	ino_t ino, struct sysfs_dirent *pos)
  {
  	pos =3D sysfs_dir_pos(ns, parent_sd, ino, pos);
- 	if (pos)
- 		pos =3D pos->s_sibling;
- 	while (pos && pos->s_ns !=3D ns)
- 		pos =3D pos->s_sibling;
+ 	if (pos) do {
+ 		struct rb_node *p =3D rb_next(&pos->inode_node);
+ 		if (!p)
+ 			pos =3D NULL;
+ 		else
+ 			pos =3D rb_entry(p, struct sysfs_dirent, inode_node);
 -	} while (pos && pos->s_ns && pos->s_ns !=3D ns);
++	} while (pos && pos->s_ns !=3D ns);
  	return pos;
  }
 =20

--Signature=_Tue__25_Oct_2011_19_07_21_+1100_pieV9NWhS7qAh8gL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOpm45AAoJEECxmPOUX5FEGHwP/R5TOJ+2WPLGgb8etZwPPMp1
Dmwf3rVkkhxnOiu73PYdtHZErc64+VIGUXuWi5o5/qnJhWPnNhQLUyK48GUPFFow
k0KrMdqFebtwroJ/RYv6TMUOGr44qmF90Ff5p2xE17ocdv3MWyjiFXFE7yNKAWM8
I8QGmxmPdFTS9min5cBjoKST+q5rJl/eIcYBjH7irI+Un0iN8tAuP9VTb0a5KI5B
jHHJQQIX2CKWnv6jMdND3/QU79raxhyqJLkqd4yMIosCOsqIaozzmidL7x4om313
RM/A8befLdLdbVCob5/4ROeLuv3MFKnstZ30IcFL3V5EpditLzJ6thOhFXiK1Kr+
eP8iqsJ71iI5X8/C+r9m1lLrBF2g6WcVKWN/XbOzrls+4zMkPtSU/C4YJXBmkSCv
jvNYeaGRBs2vRNrReEPWLRM6YS7a1MlUzY//qrDTb7r/SFXaVWJnx4LR298kuWGy
NEAGWe0BGHATxseeHtkydSYrqqQN8AjCgog0N7X0baMN4aRYLV2tkBV8tC2Luw9U
d4Qw/ygA9T+JbAiXFJxzQ8l9k8mhr0tFuUxlJkHQSZ+C8Z42cPronb0zsXbkTf/Q
6FZW6pKzhGXvhEHJGom1P5u46v+zHAgoiA5D6C06NOz9sMgTfX0/UUMw6UM/wUh9
+fpi20I+r1kZTMekuhYp
=B38p
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Oct_2011_19_07_21_+1100_pieV9NWhS7qAh8gL--
