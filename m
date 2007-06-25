From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 26 Jun 2007 00:40:10 +0200
Message-ID: <1182811210.6644.22.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rubW/q6gunss9wiPO/mF"
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53910 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbXFZItq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 04:49:46 -0400
In-Reply-To: <1182223964.5411.76.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rubW/q6gunss9wiPO/mF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-19 at 11:32 +0800, Zhang Rui wrote:

> > Ok, by inspection (sorry, still dont have much time) - your kernel code
> > is sending to group 1; i.e
> >=20
> > genlmsg_multicast(skb, 0, 1, GFP_ATOMIC);
> >=20
> > you need to change that to send to your assigned id, i.e:
> > genlmsg_multicast(skb, 0, acpi_event_genl_family.id, GFP_ATOMIC);
> >=20
> Oh, that's the problem.
> Great, now it works happily. :).
> Jamal, thanks for your help!

I wonder if we should hold off on this API until we've worked out the
multicast issue.

Right now we have (mostly by convention afaict) in generic netlink that
everybody has the same group ID as the family ID but that breaks down as
soon as somebody needs more groups than that, which nl80211 will most
likely need.

Hence, the proposal Jamal had was to have a dynamic multicast number
allocator and (if I understood correctly) look up multicast numbers by
family ID/name. This is fairly extensive API/ABI change, but luckily
there are no generic netlink multicast users yet except for the
controller which luckily has the fixed ID "1".

Therefore, if we hold off on this patch until we've written the code for
dynamic multicast groups, we can hardcode the group for controller and
have all others dynamically assigned; if we merge the ACPI events now
we'll have to hardcode the ACPI family ID (and thus multicast group) to
a small number to avoid problems with dynamic multicast groups where the
numbers will be !=3D family ID.



My proposition for the actual dynamic registration interface would be to
add a .groups array to pointers to struct genl_family with that just
being

struct genl_multicast_group {
	char *name;
	u32 id;
}
(as usual, NULL signifies array termination)

and the controller is responsible for assigning the ID and exporting it
to userspace. "name" is a per-family field, something like this patch:

---
 include/linux/genetlink.h |    3 +
 include/net/genetlink.h   |   15 ++++++
 net/netlink/genetlink.c   |  111 +++++++++++++++++++++++++++++++++++++++++=
+++++
 3 files changed, 129 insertions(+)

--- wireless-dev.orig/include/net/genetlink.h	2007-06-25 23:56:59.085732308=
 +0200
+++ wireless-dev/include/net/genetlink.h	2007-06-26 00:01:43.935732308 +020=
0
@@ -5,12 +5,26 @@
 #include <net/netlink.h>
=20
 /**
+ * struct genl_multicast_group - generic netlink multicast group
+ * @name: name of the multicast group, names are per-family
+ * @id: multicast group ID, assigned by the core, to use with
+ *      genlmsg_multicast().
+ */
+struct genl_multicast_group
+{
+	char	name[GENL_NAMSIZ];
+	u32	id;
+};
+
+/**
  * struct genl_family - generic netlink family
  * @id: protocol family idenfitier
  * @hdrsize: length of user specific header in bytes
  * @name: name of family
  * @version: protocol version
  * @maxattr: maximum number of attributes supported
+ * @multicast_groups: multicast groups to be registered
+ *	for this family (%NULL-terminated array)
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
@@ -22,6 +36,7 @@ struct genl_family
 	char			name[GENL_NAMSIZ];
 	unsigned int		version;
 	unsigned int		maxattr;
+	struct genl_multicast_group **multicast_groups;
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
--- wireless-dev.orig/net/netlink/genetlink.c	2007-06-25 23:56:02.805732308=
 +0200
+++ wireless-dev/net/netlink/genetlink.c	2007-06-26 00:39:26.985732308 +020=
0
@@ -3,6 +3,7 @@
  *
  * 		Authors:	Jamal Hadi Salim
  * 				Thomas Graf <tgraf@suug.ch>
+ *				Johannes Berg <johannes@sipsolutions.net>
  */
=20
 #include <linux/module.h>
@@ -13,6 +14,7 @@
 #include <linux/string.h>
 #include <linux/skbuff.h>
 #include <linux/mutex.h>
+#include <linux/bitmap.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
=20
@@ -42,6 +44,15 @@ static void genl_unlock(void)
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
=20
 static struct list_head family_ht[GENL_FAM_TAB_SIZE];
+/*
+ * To avoid an allocation at boot of just one unsigned long,
+ * declare it global instead.
+ * Bit 0 (special?) and bit 1 are marked as already used
+ * since group 1 is the controller group.
+ */
+static unsigned long mcast_group_start =3D 0x3;
+static unsigned long *multicast_groups =3D &mcast_group_start;
+static unsigned long multicast_group_bits =3D BITS_PER_LONG;
=20
 static int genl_ctrl_event(int event, void *data);
=20
@@ -116,6 +127,76 @@ static inline u16 genl_generate_id(void)
 	return id_gen_idx;
 }
=20
+static int genl_register_mcast_group(struct genl_multicast_group *grp)
+{
+	int id =3D find_first_zero_bit(multicast_groups, multicast_group_bits);
+
+	if (id >=3D multicast_group_bits) {
+		if (multicast_groups =3D=3D &mcast_group_start) {
+			multicast_groups =3D
+				kzalloc(multicast_group_bits/BITS_PER_LONG + 1,
+					GFP_KERNEL);
+			if (!multicast_groups)
+				return -ENOMEM;
+			*multicast_groups =3D mcast_group_start;
+		} else {
+			multicast_groups =3D
+				krealloc(multicast_groups,
+					 multicast_group_bits/BITS_PER_LONG + 1,
+					 GFP_KERNEL);
+			if (!multicast_groups)
+				return -ENOMEM;
+			multicast_groups[multicast_group_bits/BITS_PER_LONG] =3D 0;
+		}
+		multicast_group_bits +=3D BITS_PER_LONG;
+	}
+
+	grp->id =3D id;
+	set_bit(id, multicast_groups);
+	return 0;
+}
+
+static void genl_unregister_mcast_group(struct genl_multicast_group *grp)
+{
+	if (grp->id) {
+		clear_bit(grp->id, multicast_groups);
+		grp->id =3D 0;
+	}
+}
+
+static int genl_register_mcast_groups(struct genl_family *family)
+{
+	struct genl_multicast_group **grp;
+	int err;
+
+	if (!family->multicast_groups)
+		return 0;
+
+	for (grp =3D family->multicast_groups; *grp; grp++) {
+		err =3D genl_register_mcast_group(*grp);
+		if (err) {
+			while (grp !=3D family->multicast_groups) {
+				genl_unregister_mcast_group(*grp);
+				grp--;
+			}
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+static void genl_unregister_mcast_groups(struct genl_family *family)
+{
+	struct genl_multicast_group **grp;
+
+	if (!family->multicast_groups)
+		return;
+
+	for (grp =3D family->multicast_groups; *grp; grp++)
+		genl_unregister_mcast_group(*grp);
+}
+
 /**
  * genl_register_ops - register generic netlink operations
  * @family: generic netlink family
@@ -240,6 +321,10 @@ int genl_register_family(struct genl_fam
 		family->id =3D newid;
 	}
=20
+	err =3D genl_register_mcast_groups(family);
+	if (err)
+		goto errout_locked;
+
 	if (family->maxattr) {
 		family->attrbuf =3D kmalloc((family->maxattr+1) *
 					sizeof(struct nlattr *), GFP_KERNEL);
@@ -290,6 +375,8 @@ int genl_unregister_family(struct genl_f
 		return 0;
 	}
=20
+	genl_unregister_mcast_groups(family);
+
 	genl_unlock();
=20
 	return -ENOENT;
@@ -374,6 +461,7 @@ static int ctrl_fill_info(struct genl_fa
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
 	void *hdr;
+	struct genl_multicast_group **grp;
=20
 	hdr =3D genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
 	if (hdr =3D=3D NULL)
@@ -410,6 +498,29 @@ static int ctrl_fill_info(struct genl_fa
 		nla_nest_end(skb, nla_ops);
 	}
=20
+	if (family->multicast_groups) {
+		struct nlattr *nla_grps;
+		int idx =3D 1;
+
+		nla_grps =3D nla_nest_start(skb, CTRL_ATTR_MCAST_GROUPS);
+		if (nla_grps =3D=3D NULL)
+			goto nla_put_failure;
+
+		for (grp =3D family->multicast_groups; *grp; grp++) {
+			struct nlattr *nest;
+
+			nest =3D nla_nest_start(skb, idx++);
+			if (nest =3D=3D NULL)
+				goto nla_put_failure;
+
+			NLA_PUT_U32(skb, CTRL_ATTR_MCAST_GRP_ID, (*grp)->id);
+			NLA_PUT_STRING(skb, CTRL_ATTR_MCAST_GRP_NAME, (*grp)->name);
+
+			nla_nest_end(skb, nest);
+		}
+		nla_nest_end(skb, nla_grps);
+	}
+
 	return genlmsg_end(skb, hdr);
=20
 nla_put_failure:
--- wireless-dev.orig/include/linux/genetlink.h	2007-06-25 23:56:19.8957323=
08 +0200
+++ wireless-dev/include/linux/genetlink.h	2007-06-26 00:33:36.785732308 +0=
200
@@ -52,6 +52,9 @@ enum {
 	CTRL_ATTR_HDRSIZE,
 	CTRL_ATTR_MAXATTR,
 	CTRL_ATTR_OPS,
+	CTRL_ATTR_MCAST_GROUPS,
+	CTRL_ATTR_MCAST_GRP_NAME,
+	CTRL_ATTR_MCAST_GRP_ID,
 	__CTRL_ATTR_MAX,
 };
=20



johannes

--=-rubW/q6gunss9wiPO/mF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGgERK/ETPhpq3jKURAti3AKC5x0vuDcwM2pbcWxmpMNFfYde1PgCglxhz
V+77Twe4DprA7doKsoCVD94=
=MPnN
-----END PGP SIGNATURE-----

--=-rubW/q6gunss9wiPO/mF--

