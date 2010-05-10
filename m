From: kaber@trash.net
Subject: [PATCH 09/84] netfilter: xtables: merge xt_CONNMARK into xt_connmark
Date: Mon, 10 May 2010 22:17:40 +0200
Message-ID: <1273522735-24672-10-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756642Ab0EJUS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:18:59 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/xt_CONNMARK.h |   22 +------
 include/linux/netfilter/xt_connmark.h |   11 +++
 net/netfilter/Kconfig                 |   39 +++++++-----
 net/netfilter/Makefile                |    3 +-
 net/netfilter/xt_CONNMARK.c           |  113 -------------------------=
--------
 net/netfilter/xt_connmark.c           |   84 +++++++++++++++++++++++-
 6 files changed, 116 insertions(+), 156 deletions(-)
 delete mode 100644 net/netfilter/xt_CONNMARK.c

diff --git a/include/linux/netfilter/xt_CONNMARK.h b/include/linux/netf=
ilter/xt_CONNMARK.h
index 0a85458..2f2e48e 100644
--- a/include/linux/netfilter/xt_CONNMARK.h
+++ b/include/linux/netfilter/xt_CONNMARK.h
@@ -1,26 +1,6 @@
 #ifndef _XT_CONNMARK_H_target
 #define _XT_CONNMARK_H_target
=20
-#include <linux/types.h>
-
-/* Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com=
>
- * by Henrik Nordstrom <hno@marasystems.com>
- *
- * This program is free software; you can redistribute it and/or modif=
y
- * it under the terms of the GNU General Public License as published b=
y
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-enum {
-	XT_CONNMARK_SET =3D 0,
-	XT_CONNMARK_SAVE,
-	XT_CONNMARK_RESTORE
-};
-
-struct xt_connmark_tginfo1 {
-	__u32 ctmark, ctmask, nfmask;
-	__u8 mode;
-};
+#include <linux/netfilter/xt_connmark.h>
=20
 #endif /*_XT_CONNMARK_H_target*/
diff --git a/include/linux/netfilter/xt_connmark.h b/include/linux/netf=
ilter/xt_connmark.h
index 619e47c..efc17a8 100644
--- a/include/linux/netfilter/xt_connmark.h
+++ b/include/linux/netfilter/xt_connmark.h
@@ -12,6 +12,17 @@
  * (at your option) any later version.
  */
=20
+enum {
+	XT_CONNMARK_SET =3D 0,
+	XT_CONNMARK_SAVE,
+	XT_CONNMARK_RESTORE
+};
+
+struct xt_connmark_tginfo1 {
+	__u32 ctmark, ctmask, nfmask;
+	__u8 mode;
+};
+
 struct xt_connmark_mtinfo1 {
 	__u32 mark, mask;
 	__u8 invert;
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 236aa20..8550dfd 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -331,6 +331,18 @@ config NETFILTER_XT_MARK
 	"Use netfilter MARK value as routing key") and can also be used by
 	other subsystems to change their behavior.
=20
+config NETFILTER_XT_CONNMARK
+	tristate 'ctmark target and match support'
+	depends on NF_CONNTRACK
+	depends on NETFILTER_ADVANCED
+	select NF_CONNTRACK_MARK
+	---help---
+	This option adds the "CONNMARK" target and "connmark" match.
+
+	Netfilter allows you to store a mark value per connection (a.k.a.
+	ctmark), similarly to the packet mark (nfmark). Using this
+	target and match, you can set and match on this mark.
+
 # alphabetically ordered list of targets
=20
 comment "Xtables targets"
@@ -351,15 +363,11 @@ config NETFILTER_XT_TARGET_CONNMARK
 	tristate  '"CONNMARK" target support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
-	select NF_CONNTRACK_MARK
-	help
-	  This option adds a `CONNMARK' target, which allows one to manipulat=
e
-	  the connection mark value.  Similar to the MARK target, but
-	  affects the connection mark value rather than the packet mark value=
=2E
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/kbuild/modules.txt>.  The module will be called
-	  ipt_CONNMARK.  If unsure, say `N'.
+	select NETFILTER_XT_CONNMARK
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_CONNMARK (combined connmark/CONNMARK module).
=20
 config NETFILTER_XT_TARGET_CONNSECMARK
 	tristate '"CONNSECMARK" target support'
@@ -621,14 +629,11 @@ config NETFILTER_XT_MATCH_CONNMARK
 	tristate  '"connmark" connection mark match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
-	select NF_CONNTRACK_MARK
-	help
-	  This option adds a `connmark' match, which allows you to match the
-	  connection mark value previously set for the session by `CONNMARK'.=
=20
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/kbuild/modules.txt>.  The module will be called
-	  ipt_connmark.  If unsure, say `N'.
+	select NETFILTER_XT_CONNMARK
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_CONNMARK (combined connmark/CONNMARK module).
=20
 config NETFILTER_XT_MATCH_CONNTRACK
 	tristate '"conntrack" connection tracking match support'
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 19775cc..cd31afe 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -42,10 +42,10 @@ obj-$(CONFIG_NETFILTER_XTABLES) +=3D x_tables.o xt_=
tcpudp.o
=20
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) +=3D xt_mark.o
+obj-$(CONFIG_NETFILTER_XT_CONNMARK) +=3D xt_connmark.o
=20
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) +=3D xt_CLASSIFY.o
-obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) +=3D xt_CONNMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) +=3D xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) +=3D xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) +=3D xt_DSCP.o
@@ -66,7 +66,6 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) +=3D xt_clus=
ter.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) +=3D xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) +=3D xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) +=3D xt_connlimit.o
-obj-$(CONFIG_NETFILTER_XT_MATCH_CONNMARK) +=3D xt_connmark.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) +=3D xt_conntrack.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DCCP) +=3D xt_dccp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DSCP) +=3D xt_dscp.o
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
deleted file mode 100644
index 5934570..0000000
--- a/net/netfilter/xt_CONNMARK.c
+++ /dev/null
@@ -1,113 +0,0 @@
-/*
- *	xt_CONNMARK - Netfilter module to modify the connection mark values
- *
- *	Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com=
>
- *	by Henrik Nordstrom <hno@marasystems.com>
- *	Copyright =C2=A9 CC Computer Consultants GmbH, 2007 - 2008
- *	Jan Engelhardt <jengelh@computergmbh.de>
- *
- * This program is free software; you can redistribute it and/or modif=
y
- * it under the terms of the GNU General Public License as published b=
y
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7  USA
- */
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-MODULE_AUTHOR("Henrik Nordstrom <hno@marasystems.com>");
-MODULE_DESCRIPTION("Xtables: connection mark modification");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("ipt_CONNMARK");
-MODULE_ALIAS("ip6t_CONNMARK");
-
-#include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/xt_CONNMARK.h>
-#include <net/netfilter/nf_conntrack_ecache.h>
-
-static unsigned int
-connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct xt_connmark_tginfo1 *info =3D par->targinfo;
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
-	u_int32_t newmark;
-
-	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct =3D=3D NULL)
-		return XT_CONTINUE;
-
-	switch (info->mode) {
-	case XT_CONNMARK_SET:
-		newmark =3D (ct->mark & ~info->ctmask) ^ info->ctmark;
-		if (ct->mark !=3D newmark) {
-			ct->mark =3D newmark;
-			nf_conntrack_event_cache(IPCT_MARK, ct);
-		}
-		break;
-	case XT_CONNMARK_SAVE:
-		newmark =3D (ct->mark & ~info->ctmask) ^
-		          (skb->mark & info->nfmask);
-		if (ct->mark !=3D newmark) {
-			ct->mark =3D newmark;
-			nf_conntrack_event_cache(IPCT_MARK, ct);
-		}
-		break;
-	case XT_CONNMARK_RESTORE:
-		newmark =3D (skb->mark & ~info->nfmask) ^
-		          (ct->mark & info->ctmask);
-		skb->mark =3D newmark;
-		break;
-	}
-
-	return XT_CONTINUE;
-}
-
-static bool connmark_tg_check(const struct xt_tgchk_param *par)
-{
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "proto=3D%u\n", par->family);
-		return false;
-	}
-	return true;
-}
-
-static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
-{
-	nf_ct_l3proto_module_put(par->family);
-}
-
-static struct xt_target connmark_tg_reg __read_mostly =3D {
-	.name           =3D "CONNMARK",
-	.revision       =3D 1,
-	.family         =3D NFPROTO_UNSPEC,
-	.checkentry     =3D connmark_tg_check,
-	.target         =3D connmark_tg,
-	.targetsize     =3D sizeof(struct xt_connmark_tginfo1),
-	.destroy        =3D connmark_tg_destroy,
-	.me             =3D THIS_MODULE,
-};
-
-static int __init connmark_tg_init(void)
-{
-	return xt_register_target(&connmark_tg_reg);
-}
-
-static void __exit connmark_tg_exit(void)
-{
-	xt_unregister_target(&connmark_tg_reg);
-}
-
-module_init(connmark_tg_init);
-module_exit(connmark_tg_exit);
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 122aa8b..d184515 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -1,5 +1,5 @@
 /*
- *	xt_connmark - Netfilter module to match connection mark values
+ *	xt_connmark - Netfilter module to operate on connection marks
  *
  *	Copyright (C) 2002,2004 MARA Systems AB <http://www.marasystems.com=
>
  *	by Henrik Nordstrom <hno@marasystems.com>
@@ -24,15 +24,71 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_connmark.h>
=20
 MODULE_AUTHOR("Henrik Nordstrom <hno@marasystems.com>");
-MODULE_DESCRIPTION("Xtables: connection mark match");
+MODULE_DESCRIPTION("Xtables: connection mark operations");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_CONNMARK");
+MODULE_ALIAS("ip6t_CONNMARK");
 MODULE_ALIAS("ipt_connmark");
 MODULE_ALIAS("ip6t_connmark");
=20
+static unsigned int
+connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_connmark_tginfo1 *info =3D par->targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u_int32_t newmark;
+
+	ct =3D nf_ct_get(skb, &ctinfo);
+	if (ct =3D=3D NULL)
+		return XT_CONTINUE;
+
+	switch (info->mode) {
+	case XT_CONNMARK_SET:
+		newmark =3D (ct->mark & ~info->ctmask) ^ info->ctmark;
+		if (ct->mark !=3D newmark) {
+			ct->mark =3D newmark;
+			nf_conntrack_event_cache(IPCT_MARK, ct);
+		}
+		break;
+	case XT_CONNMARK_SAVE:
+		newmark =3D (ct->mark & ~info->ctmask) ^
+		          (skb->mark & info->nfmask);
+		if (ct->mark !=3D newmark) {
+			ct->mark =3D newmark;
+			nf_conntrack_event_cache(IPCT_MARK, ct);
+		}
+		break;
+	case XT_CONNMARK_RESTORE:
+		newmark =3D (skb->mark & ~info->nfmask) ^
+		          (ct->mark & info->ctmask);
+		skb->mark =3D newmark;
+		break;
+	}
+
+	return XT_CONTINUE;
+}
+
+static bool connmark_tg_check(const struct xt_tgchk_param *par)
+{
+	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+		printk(KERN_WARNING "cannot load conntrack support for "
+		       "proto=3D%u\n", par->family);
+		return false;
+	}
+	return true;
+}
+
+static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_l3proto_module_put(par->family);
+}
+
 static bool
 connmark_mt(const struct sk_buff *skb, const struct xt_match_param *pa=
r)
 {
@@ -62,6 +118,17 @@ static void connmark_mt_destroy(const struct xt_mtd=
tor_param *par)
 	nf_ct_l3proto_module_put(par->family);
 }
=20
+static struct xt_target connmark_tg_reg __read_mostly =3D {
+	.name           =3D "CONNMARK",
+	.revision       =3D 1,
+	.family         =3D NFPROTO_UNSPEC,
+	.checkentry     =3D connmark_tg_check,
+	.target         =3D connmark_tg,
+	.targetsize     =3D sizeof(struct xt_connmark_tginfo1),
+	.destroy        =3D connmark_tg_destroy,
+	.me             =3D THIS_MODULE,
+};
+
 static struct xt_match connmark_mt_reg __read_mostly =3D {
 	.name           =3D "connmark",
 	.revision       =3D 1,
@@ -75,12 +142,23 @@ static struct xt_match connmark_mt_reg __read_most=
ly =3D {
=20
 static int __init connmark_mt_init(void)
 {
-	return xt_register_match(&connmark_mt_reg);
+	int ret;
+
+	ret =3D xt_register_target(&connmark_tg_reg);
+	if (ret < 0)
+		return ret;
+	ret =3D xt_register_match(&connmark_mt_reg);
+	if (ret < 0) {
+		xt_unregister_target(&connmark_tg_reg);
+		return ret;
+	}
+	return 0;
 }
=20
 static void __exit connmark_mt_exit(void)
 {
 	xt_unregister_match(&connmark_mt_reg);
+	xt_unregister_target(&connmark_tg_reg);
 }
=20
 module_init(connmark_mt_init);
--=20
1.7.0.4

