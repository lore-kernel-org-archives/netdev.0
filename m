From: kaber@trash.net
Subject: [PATCH 09/79] netfilter: xt_CLASSIFY: add ARP support, allow CLASSIFY target on any table
Date: Wed, 19 Jan 2011 20:14:09 +0100
Message-ID: <1295464519-21763-10-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab1ASTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:26 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fr=E9d=E9ric Leroy <fredo@starox.org>

Signed-off-by: Fr=E9d=E9ric Leroy <fredo@starox.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_CLASSIFY.c |   36 ++++++++++++++++++++++++-----------=
-
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index c2c0e4a..af9c4da 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -19,12 +19,14 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_CLASSIFY.h>
+#include <linux/netfilter_arp.h>
=20
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Xtables: Qdisc classification");
 MODULE_ALIAS("ipt_CLASSIFY");
 MODULE_ALIAS("ip6t_CLASSIFY");
+MODULE_ALIAS("arpt_CLASSIFY");
=20
 static unsigned int
 classify_tg(struct sk_buff *skb, const struct xt_action_param *par)
@@ -35,26 +37,36 @@ classify_tg(struct sk_buff *skb, const struct xt_ac=
tion_param *par)
 	return XT_CONTINUE;
 }
=20
-static struct xt_target classify_tg_reg __read_mostly =3D {
-	.name       =3D "CLASSIFY",
-	.revision   =3D 0,
-	.family     =3D NFPROTO_UNSPEC,
-	.table      =3D "mangle",
-	.hooks      =3D (1 << NF_INET_LOCAL_OUT) | (1 << NF_INET_FORWARD) |
-		      (1 << NF_INET_POST_ROUTING),
-	.target     =3D classify_tg,
-	.targetsize =3D sizeof(struct xt_classify_target_info),
-	.me         =3D THIS_MODULE,
+static struct xt_target classify_tg_reg[] __read_mostly =3D {
+	{
+		.name       =3D "CLASSIFY",
+		.revision   =3D 0,
+		.family     =3D NFPROTO_UNSPEC,
+		.hooks      =3D (1 << NF_INET_LOCAL_OUT) | (1 << NF_INET_FORWARD) |
+		              (1 << NF_INET_POST_ROUTING),
+		.target     =3D classify_tg,
+		.targetsize =3D sizeof(struct xt_classify_target_info),
+		.me         =3D THIS_MODULE,
+	},
+	{
+		.name       =3D "CLASSIFY",
+		.revision   =3D 0,
+		.family     =3D NFPROTO_ARP,
+		.hooks      =3D (1 << NF_ARP_OUT) | (1 << NF_ARP_FORWARD),
+		.target     =3D classify_tg,
+		.targetsize =3D sizeof(struct xt_classify_target_info),
+		.me         =3D THIS_MODULE,
+	},
 };
=20
 static int __init classify_tg_init(void)
 {
-	return xt_register_target(&classify_tg_reg);
+	return xt_register_targets(classify_tg_reg, ARRAY_SIZE(classify_tg_re=
g));
 }
=20
 static void __exit classify_tg_exit(void)
 {
-	xt_unregister_target(&classify_tg_reg);
+	xt_unregister_targets(classify_tg_reg, ARRAY_SIZE(classify_tg_reg));
 }
=20
 module_init(classify_tg_init);
--=20
1.7.2.3

