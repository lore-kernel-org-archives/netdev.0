From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/31: xtables: remove xt_mark v0
Date: Thu, 10 Sep 2009 18:11:58 +0200 (MEST)
Message-ID: <20090910161153.31179.65365.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4725c7287ef2c4340cb433f59e40d143c1f43c22
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 19:02:27 2009 +0200

    netfilter: xtables: remove xt_mark v0
   =20
    Superseded by xt_mark v1 (v2.6.24-2922-g17b0d7e).
   =20
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation=
/feature-removal-schedule.txt
index 8862b03..5556d23 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -238,9 +238,6 @@ What (Why):
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
=20
-	- xt_mark match revision 0
-	  (superseded by xt_mark match revision 1)
-
 	- xt_recent: the old ipt_recent proc dir
 	  (superseded by /proc/net/xt_recent)
=20
diff --git a/include/linux/netfilter/xt_mark.h b/include/linux/netfilte=
r/xt_mark.h
index 6fa460a..6607c8f 100644
--- a/include/linux/netfilter/xt_mark.h
+++ b/include/linux/netfilter/xt_mark.h
@@ -3,11 +3,6 @@
=20
 #include <linux/types.h>
=20
-struct xt_mark_info {
-    unsigned long mark, mask;
-    __u8 invert;
-};
-
 struct xt_mark_mtinfo1 {
 	__u32 mark, mask;
 	__u8 invert;
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 10b9e34..1db07d8 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -3,7 +3,7 @@
  *
  *	(C) 1999-2001 Marc Boucher <marc@mbsi.ca>
  *	Copyright =C2=A9 CC Computer Consultants GmbH, 2007 - 2008
- *	Jan Engelhardt <jengelh@computergmbh.de>
+ *	Jan Engelhardt <jengelh@medozas.de>
  *
  *	This program is free software; you can redistribute it and/or modif=
y
  *	it under the terms of the GNU General Public License version 2 as
@@ -23,14 +23,6 @@ MODULE_ALIAS("ipt_mark");
 MODULE_ALIAS("ip6t_mark");
=20
 static bool
-mark_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par=
)
-{
-	const struct xt_mark_info *info =3D par->matchinfo;
-
-	return ((skb->mark & info->mask) =3D=3D info->mark) ^ info->invert;
-}
-
-static bool
 mark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_mark_mtinfo1 *info =3D par->matchinfo;
@@ -38,81 +30,23 @@ mark_mt(const struct sk_buff *skb, const struct xt_=
match_param *par)
 	return ((skb->mark & info->mask) =3D=3D info->mark) ^ info->invert;
 }
=20
-static bool mark_mt_check_v0(const struct xt_mtchk_param *par)
-{
-	const struct xt_mark_info *minfo =3D par->matchinfo;
-
-	if (minfo->mark > 0xffffffff || minfo->mask > 0xffffffff) {
-		printk(KERN_WARNING "mark: only supports 32bit mark\n");
-		return false;
-	}
-	return true;
-}
-
-#ifdef CONFIG_COMPAT
-struct compat_xt_mark_info {
-	compat_ulong_t	mark, mask;
-	u_int8_t	invert;
-	u_int8_t	__pad1;
-	u_int16_t	__pad2;
-};
-
-static void mark_mt_compat_from_user_v0(void *dst, void *src)
-{
-	const struct compat_xt_mark_info *cm =3D src;
-	struct xt_mark_info m =3D {
-		.mark	=3D cm->mark,
-		.mask	=3D cm->mask,
-		.invert	=3D cm->invert,
-	};
-	memcpy(dst, &m, sizeof(m));
-}
-
-static int mark_mt_compat_to_user_v0(void __user *dst, void *src)
-{
-	const struct xt_mark_info *m =3D src;
-	struct compat_xt_mark_info cm =3D {
-		.mark	=3D m->mark,
-		.mask	=3D m->mask,
-		.invert	=3D m->invert,
-	};
-	return copy_to_user(dst, &cm, sizeof(cm)) ? -EFAULT : 0;
-}
-#endif /* CONFIG_COMPAT */
-
-static struct xt_match mark_mt_reg[] __read_mostly =3D {
-	{
-		.name		=3D "mark",
-		.revision	=3D 0,
-		.family		=3D NFPROTO_UNSPEC,
-		.checkentry	=3D mark_mt_check_v0,
-		.match		=3D mark_mt_v0,
-		.matchsize	=3D sizeof(struct xt_mark_info),
-#ifdef CONFIG_COMPAT
-		.compatsize	=3D sizeof(struct compat_xt_mark_info),
-		.compat_from_user =3D mark_mt_compat_from_user_v0,
-		.compat_to_user	=3D mark_mt_compat_to_user_v0,
-#endif
-		.me		=3D THIS_MODULE,
-	},
-	{
-		.name           =3D "mark",
-		.revision       =3D 1,
-		.family         =3D NFPROTO_UNSPEC,
-		.match          =3D mark_mt,
-		.matchsize      =3D sizeof(struct xt_mark_mtinfo1),
-		.me             =3D THIS_MODULE,
-	},
+static struct xt_match mark_mt_reg __read_mostly =3D {
+	.name           =3D "mark",
+	.revision       =3D 1,
+	.family         =3D NFPROTO_UNSPEC,
+	.match          =3D mark_mt,
+	.matchsize      =3D sizeof(struct xt_mark_mtinfo1),
+	.me             =3D THIS_MODULE,
 };
=20
 static int __init mark_mt_init(void)
 {
-	return xt_register_matches(mark_mt_reg, ARRAY_SIZE(mark_mt_reg));
+	return xt_register_match(&mark_mt_reg);
 }
=20
 static void __exit mark_mt_exit(void)
 {
-	xt_unregister_matches(mark_mt_reg, ARRAY_SIZE(mark_mt_reg));
+	xt_unregister_match(&mark_mt_reg);
 }
=20
 module_init(mark_mt_init);
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
