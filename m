From: kaber@trash.net
Subject: [PATCH 08/84] netfilter: xtables: merge xt_MARK into xt_mark
Date: Mon, 10 May 2010 22:17:39 +0200
Message-ID: <1273522735-24672-9-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jan Engelhardt <jengelh@medozas.de>

Two arguments for combining the two:
- xt_mark is pretty useless without xt_MARK
- the actual code is so small anyway that the kmod metadata and the mod=
ule
  in its loaded state totally outweighs the combined actual code size.

i586-before:
-rw-r--r-- 1 jengelh users 3821 Feb 10 01:01 xt_MARK.ko
-rw-r--r-- 1 jengelh users 2592 Feb 10 00:04 xt_MARK.o
-rw-r--r-- 1 jengelh users 3274 Feb 10 01:01 xt_mark.ko
-rw-r--r-- 1 jengelh users 2108 Feb 10 00:05 xt_mark.o
   text    data     bss     dec     hex filename
    354     264       0     618     26a xt_MARK.o
    223     176       0     399     18f xt_mark.o
And the runtime size is like 14 KB.

i586-after:
-rw-r--r-- 1 jengelh users 3264 Feb 18 17:28 xt_mark.o

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/xt_MARK.h |    6 +---
 include/linux/netfilter/xt_mark.h |    4 ++
 net/netfilter/Kconfig             |   46 +++++++++++++++++++----------=
-
 net/netfilter/Makefile            |    5 ++-
 net/netfilter/xt_MARK.c           |   56 -----------------------------=
--------
 net/netfilter/xt_mark.c           |   35 +++++++++++++++++++++-
 6 files changed, 70 insertions(+), 82 deletions(-)
 delete mode 100644 net/netfilter/xt_MARK.c

diff --git a/include/linux/netfilter/xt_MARK.h b/include/linux/netfilte=
r/xt_MARK.h
index bc9561b..41c456d 100644
--- a/include/linux/netfilter/xt_MARK.h
+++ b/include/linux/netfilter/xt_MARK.h
@@ -1,10 +1,6 @@
 #ifndef _XT_MARK_H_target
 #define _XT_MARK_H_target
=20
-#include <linux/types.h>
-
-struct xt_mark_tginfo2 {
-	__u32 mark, mask;
-};
+#include <linux/netfilter/xt_mark.h>
=20
 #endif /*_XT_MARK_H_target */
diff --git a/include/linux/netfilter/xt_mark.h b/include/linux/netfilte=
r/xt_mark.h
index 6607c8f..ecadc40 100644
--- a/include/linux/netfilter/xt_mark.h
+++ b/include/linux/netfilter/xt_mark.h
@@ -3,6 +3,10 @@
=20
 #include <linux/types.h>
=20
+struct xt_mark_tginfo2 {
+	__u32 mark, mask;
+};
+
 struct xt_mark_mtinfo1 {
 	__u32 mark, mask;
 	__u8 invert;
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index abf4ce6..236aa20 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -314,6 +314,23 @@ config NETFILTER_XTABLES
=20
 if NETFILTER_XTABLES
=20
+comment "Xtables combined modules"
+
+config NETFILTER_XT_MARK
+	tristate 'nfmark target and match support'
+	default m if NETFILTER_ADVANCED=3Dn
+	---help---
+	This option adds the "MARK" target and "mark" match.
+
+	Netfilter mark matching allows you to match packets based on the
+	"nfmark" value in the packet.
+	The target allows you to create rules in the "mangle" table which alt=
er
+	the netfilter mark (nfmark) field associated with the packet.
+
+	Prior to routing, the nfmark can influence the routing method (see
+	"Use netfilter MARK value as routing key") and can also be used by
+	other subsystems to change their behavior.
+
 # alphabetically ordered list of targets
=20
 comment "Xtables targets"
@@ -425,16 +442,12 @@ config NETFILTER_XT_TARGET_LED
=20
 config NETFILTER_XT_TARGET_MARK
 	tristate '"MARK" target support'
-	default m if NETFILTER_ADVANCED=3Dn
-	help
-	  This option adds a `MARK' target, which allows you to create rules
-	  in the `mangle' table which alter the netfilter mark (nfmark) field
-	  associated with the packet prior to routing. This can change
-	  the routing method (see `Use netfilter MARK value as routing
-	  key') and can also be used by other subsystems to change their
-	  behavior.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_MARK
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_MARK (combined mark/MARK module).
=20
 config NETFILTER_XT_TARGET_NFLOG
 	tristate '"NFLOG" target support'
@@ -739,13 +752,12 @@ config NETFILTER_XT_MATCH_MAC
=20
 config NETFILTER_XT_MATCH_MARK
 	tristate '"mark" match support'
-	default m if NETFILTER_ADVANCED=3Dn
-	help
-	  Netfilter mark matching allows you to match packets based on the
-	  `nfmark' value in the packet.  This can be set by the MARK target
-	  (see below).
-
-	  To compile it as a module, choose M here.  If unsure, say N.
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_XT_MARK
+	---help---
+	This is a backwards-compat option for the user's convenience
+	(e.g. when running oldconfig). It selects
+	CONFIG_NETFILTER_XT_MARK (combined mark/MARK module).
=20
 config NETFILTER_XT_MATCH_MULTIPORT
 	tristate '"multiport" Multiple port match support'
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index f873644..19775cc 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -40,6 +40,9 @@ obj-$(CONFIG_NETFILTER_TPROXY) +=3D nf_tproxy_core.o
 # generic X tables=20
 obj-$(CONFIG_NETFILTER_XTABLES) +=3D x_tables.o xt_tcpudp.o
=20
+# combos
+obj-$(CONFIG_NETFILTER_XT_MARK) +=3D xt_mark.o
+
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) +=3D xt_CLASSIFY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) +=3D xt_CONNMARK.o
@@ -48,7 +51,6 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CT) +=3D xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) +=3D xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) +=3D xt_HL.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) +=3D xt_LED.o
-obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) +=3D xt_MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) +=3D xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) +=3D xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) +=3D xt_NOTRACK.o
@@ -76,7 +78,6 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) +=3D xt_ipra=
nge.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) +=3D xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) +=3D xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) +=3D xt_mac.o
-obj-$(CONFIG_NETFILTER_XT_MATCH_MARK) +=3D xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) +=3D xt_multiport.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) +=3D xt_osf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) +=3D xt_owner.o
diff --git a/net/netfilter/xt_MARK.c b/net/netfilter/xt_MARK.c
deleted file mode 100644
index 225f8d1..0000000
--- a/net/netfilter/xt_MARK.c
+++ /dev/null
@@ -1,56 +0,0 @@
-/*
- *	xt_MARK - Netfilter module to modify the NFMARK field of an skb
- *
- *	(C) 1999-2001 Marc Boucher <marc@mbsi.ca>
- *	Copyright =C2=A9 CC Computer Consultants GmbH, 2007 - 2008
- *	Jan Engelhardt <jengelh@computergmbh.de>
- *
- *	This program is free software; you can redistribute it and/or modif=
y
- *	it under the terms of the GNU General Public License version 2 as
- *	published by the Free Software Foundation.
- */
-
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/ip.h>
-#include <net/checksum.h>
-
-#include <linux/netfilter/x_tables.h>
-#include <linux/netfilter/xt_MARK.h>
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("Xtables: packet mark modification");
-MODULE_ALIAS("ipt_MARK");
-MODULE_ALIAS("ip6t_MARK");
-
-static unsigned int
-mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct xt_mark_tginfo2 *info =3D par->targinfo;
-
-	skb->mark =3D (skb->mark & ~info->mask) ^ info->mark;
-	return XT_CONTINUE;
-}
-
-static struct xt_target mark_tg_reg __read_mostly =3D {
-	.name           =3D "MARK",
-	.revision       =3D 2,
-	.family         =3D NFPROTO_UNSPEC,
-	.target         =3D mark_tg,
-	.targetsize     =3D sizeof(struct xt_mark_tginfo2),
-	.me             =3D THIS_MODULE,
-};
-
-static int __init mark_tg_init(void)
-{
-	return xt_register_target(&mark_tg_reg);
-}
-
-static void __exit mark_tg_exit(void)
-{
-	xt_unregister_target(&mark_tg_reg);
-}
-
-module_init(mark_tg_init);
-module_exit(mark_tg_exit);
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 1db07d8..035c468 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -18,9 +18,20 @@
=20
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_DESCRIPTION("Xtables: packet mark match");
+MODULE_DESCRIPTION("Xtables: packet mark operations");
 MODULE_ALIAS("ipt_mark");
 MODULE_ALIAS("ip6t_mark");
+MODULE_ALIAS("ipt_MARK");
+MODULE_ALIAS("ip6t_MARK");
+
+static unsigned int
+mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_mark_tginfo2 *info =3D par->targinfo;
+
+	skb->mark =3D (skb->mark & ~info->mask) ^ info->mark;
+	return XT_CONTINUE;
+}
=20
 static bool
 mark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
@@ -30,6 +41,15 @@ mark_mt(const struct sk_buff *skb, const struct xt_m=
atch_param *par)
 	return ((skb->mark & info->mask) =3D=3D info->mark) ^ info->invert;
 }
=20
+static struct xt_target mark_tg_reg __read_mostly =3D {
+	.name           =3D "MARK",
+	.revision       =3D 2,
+	.family         =3D NFPROTO_UNSPEC,
+	.target         =3D mark_tg,
+	.targetsize     =3D sizeof(struct xt_mark_tginfo2),
+	.me             =3D THIS_MODULE,
+};
+
 static struct xt_match mark_mt_reg __read_mostly =3D {
 	.name           =3D "mark",
 	.revision       =3D 1,
@@ -41,12 +61,23 @@ static struct xt_match mark_mt_reg __read_mostly =3D=
 {
=20
 static int __init mark_mt_init(void)
 {
-	return xt_register_match(&mark_mt_reg);
+	int ret;
+
+	ret =3D xt_register_target(&mark_tg_reg);
+	if (ret < 0)
+		return ret;
+	ret =3D xt_register_match(&mark_mt_reg);
+	if (ret < 0) {
+		xt_unregister_target(&mark_tg_reg);
+		return ret;
+	}
+	return 0;
 }
=20
 static void __exit mark_mt_exit(void)
 {
 	xt_unregister_match(&mark_mt_reg);
+	xt_unregister_target(&mark_tg_reg);
 }
=20
 module_init(mark_mt_init);
--=20
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
