From: kaber@trash.net
Subject: [PATCH 1/7] netfilter: xtables: connlimit revision 1
Date: Thu, 20 Jan 2011 21:22:40 +0100
Message-ID: <1295554966-5263-2-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44056 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402Ab1ATUX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 15:23:57 -0500
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@medozas.de>

This adds destination address-based selection. The old "inverse"
member is overloaded (memory-wise) with a new "flags" variable,
similar to how J.Park did it with xt_string rev 1. Since revision=C2=A0=
0
userspace only sets flag 0x1, no great changes are made to explicitly
test for different revisions.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 Documentation/feature-removal-schedule.txt |    7 ++++
 include/linux/netfilter/xt_connlimit.h     |   12 +++++++
 net/netfilter/xt_connlimit.c               |   44 +++++++++++++++++++-=
--------
 3 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation=
/feature-removal-schedule.txt
index 22f1081..45cc804 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -576,3 +576,10 @@ Why:	The functions have been superceded by cancel_=
delayed_work_sync()
 Who:	Tejun Heo <tj@kernel.org>
=20
 ----------------------------
+
+What:	xt_connlimit rev 0
+When:	2012
+Who:	Jan Engelhardt <jengelh@medozas.de>
+Files:	net/netfilter/xt_connlimit.c
+
+----------------------------
diff --git a/include/linux/netfilter/xt_connlimit.h b/include/linux/net=
filter/xt_connlimit.h
index 7e3284b..8884efc 100644
--- a/include/linux/netfilter/xt_connlimit.h
+++ b/include/linux/netfilter/xt_connlimit.h
@@ -3,6 +3,11 @@
=20
 struct xt_connlimit_data;
=20
+enum {
+	XT_CONNLIMIT_INVERT =3D 1 << 0,
+	XT_CONNLIMIT_DADDR  =3D 1 << 1,
+};
+
 struct xt_connlimit_info {
 	union {
 		union nf_inet_addr mask;
@@ -14,6 +19,13 @@ struct xt_connlimit_info {
 #endif
 	};
 	unsigned int limit, inverse;
+	union {
+		/* revision 0 */
+		unsigned int inverse;
+
+		/* revision 1 */
+		__u32 flags;
+	};
=20
 	/* Used internally by the kernel */
 	struct xt_connlimit_data *data __attribute__((aligned(8)));
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.=
c
index 452bc16..7fd3fd5 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -193,10 +193,12 @@ connlimit_mt(const struct sk_buff *skb, struct xt=
_action_param *par)
=20
 	if (par->family =3D=3D NFPROTO_IPV6) {
 		const struct ipv6hdr *iph =3D ipv6_hdr(skb);
-		memcpy(&addr.ip6, &iph->saddr, sizeof(iph->saddr));
+		memcpy(&addr.ip6, (info->flags & XT_CONNLIMIT_DADDR) ?
+		       &iph->daddr : &iph->saddr, sizeof(addr.ip6));
 	} else {
 		const struct iphdr *iph =3D ip_hdr(skb);
-		addr.ip =3D iph->saddr;
+		addr.ip =3D (info->flags & XT_CONNLIMIT_DADDR) ?
+			  iph->daddr : iph->saddr;
 	}
=20
 	spin_lock_bh(&info->data->lock);
@@ -208,7 +210,8 @@ connlimit_mt(const struct sk_buff *skb, struct xt_a=
ction_param *par)
 		/* kmalloc failed, drop it entirely */
 		goto hotdrop;
=20
-	return (connections > info->limit) ^ info->inverse;
+	return (connections > info->limit) ^
+	       !!(info->flags & XT_CONNLIMIT_INVERT);
=20
  hotdrop:
 	par->hotdrop =3D true;
@@ -266,25 +269,38 @@ static void connlimit_mt_destroy(const struct xt_=
mtdtor_param *par)
 	kfree(info->data);
 }
=20
-static struct xt_match connlimit_mt_reg __read_mostly =3D {
-	.name       =3D "connlimit",
-	.revision   =3D 0,
-	.family     =3D NFPROTO_UNSPEC,
-	.checkentry =3D connlimit_mt_check,
-	.match      =3D connlimit_mt,
-	.matchsize  =3D sizeof(struct xt_connlimit_info),
-	.destroy    =3D connlimit_mt_destroy,
-	.me         =3D THIS_MODULE,
+static struct xt_match connlimit_mt_reg[] __read_mostly =3D {
+	{
+		.name       =3D "connlimit",
+		.revision   =3D 0,
+		.family     =3D NFPROTO_UNSPEC,
+		.checkentry =3D connlimit_mt_check,
+		.match      =3D connlimit_mt,
+		.matchsize  =3D sizeof(struct xt_connlimit_info),
+		.destroy    =3D connlimit_mt_destroy,
+		.me         =3D THIS_MODULE,
+	},
+	{
+		.name       =3D "connlimit",
+		.revision   =3D 1,
+		.family     =3D NFPROTO_UNSPEC,
+		.checkentry =3D connlimit_mt_check,
+		.match      =3D connlimit_mt,
+		.matchsize  =3D sizeof(struct xt_connlimit_info),
+		.destroy    =3D connlimit_mt_destroy,
+		.me         =3D THIS_MODULE,
+	},
 };
=20
 static int __init connlimit_mt_init(void)
 {
-	return xt_register_match(&connlimit_mt_reg);
+	return xt_register_matches(connlimit_mt_reg,
+	       ARRAY_SIZE(connlimit_mt_reg));
 }
=20
 static void __exit connlimit_mt_exit(void)
 {
-	xt_unregister_match(&connlimit_mt_reg);
+	xt_unregister_matches(connlimit_mt_reg, ARRAY_SIZE(connlimit_mt_reg))=
;
 }
=20
 module_init(connlimit_mt_init);
--=20
1.7.3.4

