From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/31: xtables: remove xt_owner v0
Date: Thu, 10 Sep 2009 18:11:59 +0200 (MEST)
Message-ID: <20090910161155.31179.99399.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64649 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbZIJQL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:57 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6461caed83412ae3e9a16785ffa64396fb66c6a6
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 19:46:26 2009 +0200

    netfilter: xtables: remove xt_owner v0
   =20
    Superseded by xt_owner v1 (v2.6.24-2388-g0265ab4).
   =20
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfil=
ter_ipv4/Kbuild
index 5e361ef..5413005 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -28,7 +28,6 @@ header-y +=3D ipt_limit.h
 header-y +=3D ipt_mac.h
 header-y +=3D ipt_mark.h
 header-y +=3D ipt_multiport.h
-header-y +=3D ipt_owner.h
 header-y +=3D ipt_physdev.h
 header-y +=3D ipt_pkttype.h
 header-y +=3D ipt_policy.h
diff --git a/include/linux/netfilter_ipv4/ipt_owner.h b/include/linux/n=
etfilter_ipv4/ipt_owner.h
deleted file mode 100644
index a78445b..0000000
--- a/include/linux/netfilter_ipv4/ipt_owner.h
+++ /dev/null
@@ -1,20 +0,0 @@
-#ifndef _IPT_OWNER_H
-#define _IPT_OWNER_H
-
-/* match and invert flags */
-#define IPT_OWNER_UID	0x01
-#define IPT_OWNER_GID	0x02
-#define IPT_OWNER_PID	0x04
-#define IPT_OWNER_SID	0x08
-#define IPT_OWNER_COMM	0x10
-
-struct ipt_owner_info {
-    __kernel_uid32_t uid;
-    __kernel_gid32_t gid;
-    __kernel_pid_t pid;
-    __kernel_pid_t sid;
-    char comm[16];
-    u_int8_t match, invert;	/* flags */
-};
-
-#endif /*_IPT_OWNER_H*/
diff --git a/include/linux/netfilter_ipv6/Kbuild b/include/linux/netfil=
ter_ipv6/Kbuild
index aca4bd1..4610a16 100644
--- a/include/linux/netfilter_ipv6/Kbuild
+++ b/include/linux/netfilter_ipv6/Kbuild
@@ -14,7 +14,6 @@ header-y +=3D ip6t_mark.h
 header-y +=3D ip6t_mh.h
 header-y +=3D ip6t_multiport.h
 header-y +=3D ip6t_opts.h
-header-y +=3D ip6t_owner.h
 header-y +=3D ip6t_physdev.h
 header-y +=3D ip6t_policy.h
 header-y +=3D ip6t_rt.h
diff --git a/include/linux/netfilter_ipv6/ip6t_owner.h b/include/linux/=
netfilter_ipv6/ip6t_owner.h
deleted file mode 100644
index ec5cc7a..0000000
--- a/include/linux/netfilter_ipv6/ip6t_owner.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _IP6T_OWNER_H
-#define _IP6T_OWNER_H
-
-/* match and invert flags */
-#define IP6T_OWNER_UID	0x01
-#define IP6T_OWNER_GID	0x02
-#define IP6T_OWNER_PID	0x04
-#define IP6T_OWNER_SID	0x08
-
-struct ip6t_owner_info {
-    __kernel_uid32_t uid;
-    __kernel_gid32_t gid;
-    __kernel_pid_t pid;
-    __kernel_pid_t sid;
-    u_int8_t match, invert;	/* flags */
-};
-
-#endif /*_IPT_OWNER_H*/
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index 22b2a5e..d24c76d 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -5,7 +5,6 @@
  * (C) 2000 Marc Boucher <marc@mbsi.ca>
  *
  * Copyright =C2=A9 CC Computer Consultants GmbH, 2007 - 2008
- * <jengelh@computergmbh.de>
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License version 2 as
@@ -17,60 +16,6 @@
 #include <net/sock.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_owner.h>
-#include <linux/netfilter_ipv4/ipt_owner.h>
-#include <linux/netfilter_ipv6/ip6t_owner.h>
-
-static bool
-owner_mt_v0(const struct sk_buff *skb, const struct xt_match_param *pa=
r)
-{
-	const struct ipt_owner_info *info =3D par->matchinfo;
-	const struct file *filp;
-
-	if (skb->sk =3D=3D NULL || skb->sk->sk_socket =3D=3D NULL)
-		return false;
-
-	filp =3D skb->sk->sk_socket->file;
-	if (filp =3D=3D NULL)
-		return false;
-
-	if (info->match & IPT_OWNER_UID)
-		if ((filp->f_cred->fsuid !=3D info->uid) ^
-		    !!(info->invert & IPT_OWNER_UID))
-			return false;
-
-	if (info->match & IPT_OWNER_GID)
-		if ((filp->f_cred->fsgid !=3D info->gid) ^
-		    !!(info->invert & IPT_OWNER_GID))
-			return false;
-
-	return true;
-}
-
-static bool
-owner_mt6_v0(const struct sk_buff *skb, const struct xt_match_param *p=
ar)
-{
-	const struct ip6t_owner_info *info =3D par->matchinfo;
-	const struct file *filp;
-
-	if (skb->sk =3D=3D NULL || skb->sk->sk_socket =3D=3D NULL)
-		return false;
-
-	filp =3D skb->sk->sk_socket->file;
-	if (filp =3D=3D NULL)
-		return false;
-
-	if (info->match & IP6T_OWNER_UID)
-		if ((filp->f_cred->fsuid !=3D info->uid) ^
-		    !!(info->invert & IP6T_OWNER_UID))
-			return false;
-
-	if (info->match & IP6T_OWNER_GID)
-		if ((filp->f_cred->fsgid !=3D info->gid) ^
-		    !!(info->invert & IP6T_OWNER_GID))
-			return false;
-
-	return true;
-}
=20
 static bool
 owner_mt(const struct sk_buff *skb, const struct xt_match_param *par)
@@ -107,81 +52,30 @@ owner_mt(const struct sk_buff *skb, const struct x=
t_match_param *par)
 	return true;
 }
=20
-static bool owner_mt_check_v0(const struct xt_mtchk_param *par)
-{
-	const struct ipt_owner_info *info =3D par->matchinfo;
-
-	if (info->match & (IPT_OWNER_PID | IPT_OWNER_SID | IPT_OWNER_COMM)) {
-		printk(KERN_WARNING KBUILD_MODNAME
-		       ": PID, SID and command matching is not "
-		       "supported anymore\n");
-		return false;
-	}
-
-	return true;
-}
-
-static bool owner_mt6_check_v0(const struct xt_mtchk_param *par)
-{
-	const struct ip6t_owner_info *info =3D par->matchinfo;
-
-	if (info->match & (IP6T_OWNER_PID | IP6T_OWNER_SID)) {
-		printk(KERN_WARNING KBUILD_MODNAME
-		       ": PID and SID matching is not supported anymore\n");
-		return false;
-	}
-
-	return true;
-}
-
-static struct xt_match owner_mt_reg[] __read_mostly =3D {
-	{
-		.name       =3D "owner",
-		.revision   =3D 0,
-		.family     =3D NFPROTO_IPV4,
-		.match      =3D owner_mt_v0,
-		.matchsize  =3D sizeof(struct ipt_owner_info),
-		.checkentry =3D owner_mt_check_v0,
-		.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
-		              (1 << NF_INET_POST_ROUTING),
-		.me         =3D THIS_MODULE,
-	},
-	{
-		.name       =3D "owner",
-		.revision   =3D 0,
-		.family     =3D NFPROTO_IPV6,
-		.match      =3D owner_mt6_v0,
-		.matchsize  =3D sizeof(struct ip6t_owner_info),
-		.checkentry =3D owner_mt6_check_v0,
-		.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
-		              (1 << NF_INET_POST_ROUTING),
-		.me         =3D THIS_MODULE,
-	},
-	{
-		.name       =3D "owner",
-		.revision   =3D 1,
-		.family     =3D NFPROTO_UNSPEC,
-		.match      =3D owner_mt,
-		.matchsize  =3D sizeof(struct xt_owner_match_info),
-		.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
-		              (1 << NF_INET_POST_ROUTING),
-		.me         =3D THIS_MODULE,
-	},
+static struct xt_match owner_mt_reg __read_mostly =3D {
+	.name       =3D "owner",
+	.revision   =3D 1,
+	.family     =3D NFPROTO_UNSPEC,
+	.match      =3D owner_mt,
+	.matchsize  =3D sizeof(struct xt_owner_match_info),
+	.hooks      =3D (1 << NF_INET_LOCAL_OUT) |
+	              (1 << NF_INET_POST_ROUTING),
+	.me         =3D THIS_MODULE,
 };
=20
 static int __init owner_mt_init(void)
 {
-	return xt_register_matches(owner_mt_reg, ARRAY_SIZE(owner_mt_reg));
+	return xt_register_match(&owner_mt_reg);
 }
=20
 static void __exit owner_mt_exit(void)
 {
-	xt_unregister_matches(owner_mt_reg, ARRAY_SIZE(owner_mt_reg));
+	xt_unregister_match(&owner_mt_reg);
 }
=20
 module_init(owner_mt_init);
 module_exit(owner_mt_exit);
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: socket owner matching");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_owner");
