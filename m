From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Fri, 23 Nov 2007 14:39:33 +0100
Message-ID: <20071123133933.GA31396@innominate.com>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11955644702194-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Nov 20, 2007 at 02:14:28PM +0100, Laszlo Attila Toth wrote:
> Interface group values can be checked on both input and output interfaces
> with optional mask.

> Index: extensions/libxt_ifgroup.c
> ===================================================================
> --- extensions/libxt_ifgroup.c	(revision 0)
> +++ extensions/libxt_ifgroup.c	(revision 0)

> +		info->in_group = strtoul(optarg, &end, 0);

This is somewhat inconsistent with the iproute patch which targets
specific groups (with names).
Should iptables be allowed to read "/etc/iproute2/rt_ifgroup"?
There is no standard API like getservbyname()...

I do have a draft patch for physdev which is however against
iptables-1.3.8 and linux-2.6.19 so it will need some more work
but I will attach it for discussion.

(This will leave ebtables to be touched...)

Best regards,
	Lutz
-- 
Dr.-Ing. Lutz Jänicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.6392-3308
fax: +49.30.6392-3307
Albert-Einstein-Str. 14
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Joachim Fietz, Dirk Seewald
Chairman of the Supervisory Board: Edward M. Stadum

----------------------------------------------------------------------------

Visit us at the SPS/IPC/Drives in Nuremberg / Germany

27 - 29 November 2007, Hall 9, Stand 9-141

----------------------------------------------------------------------------

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ifgroup_physdev.patch"

diff -ruN iptables-1.3.8-vanilla/extensions/libipt_physdev.c iptables-1.3.8/extensions/libipt_physdev.c
--- iptables-1.3.8-vanilla/extensions/libipt_physdev.c	2007-01-23 13:50:00.000000000 +0100
+++ iptables-1.3.8/extensions/libipt_physdev.c	2007-11-01 16:57:58.000000000 +0100
@@ -19,6 +19,8 @@
 "physdev v%s options:\n"
 " --physdev-in [!] input name[+]		bridge port name ([+] for wildcard)\n"
 " --physdev-out [!] output name[+]	bridge port name ([+] for wildcard)\n"
+" --physgroup-in [!] input group		bridge port group value\n"
+" --physgroup-out [!] output group	bridge port group value\n"
 " [!] --physdev-is-in			arrived on a bridge device\n"
 " [!] --physdev-is-out			will leave on a bridge device\n"
 " [!] --physdev-is-bridged		it's a bridged packet\n"
@@ -31,6 +33,8 @@
 	{ "physdev-is-in", 0, 0, '3' },
 	{ "physdev-is-out", 0, 0, '4' },
 	{ "physdev-is-bridged", 0, 0, '5' },
+	{ "physgroup-in", 1, 0, '6' },
+	{ "physgroup-out", 1, 0, '7' },
 	{0}
 };
 
@@ -47,6 +51,7 @@
 {
 	struct ipt_physdev_info *info =
 		(struct ipt_physdev_info*)(*match)->data;
+	char *end;
 
 	switch (c) {
 	case '1':
@@ -103,6 +108,44 @@
 		info->bitmask |= IPT_PHYSDEV_OP_BRIDGED;
 		break;
 
+	case '6':
+		if (*flags & IPT_PHYSDEV_OP_GROUPIN)
+			goto multiple_use;
+		check_inverse(argv[optind-1], &invert, &optind, 0);
+	 	end = optarg = argv[optind-1];
+		info->ingroup = strtoul(optarg, &end, 0);
+		info->ingroupmask = 0xffffffffUL;
+		if (*end == '/')
+			info->ingroupmask = strtoul(end+1, &end, 0);
+		if (*end != '\0' || end == optarg)
+			exit_error(PARAMETER_PROBLEM,
+				"physdev match: Bad ifgroup value `%s'",
+				optarg);
+		if (invert)
+			info->invert |= IPT_PHYSDEV_OP_GROUPIN;
+		*flags |= IPT_PHYSDEV_OP_GROUPIN;
+		info->bitmask |= IPT_PHYSDEV_OP_GROUPIN;
+		break;
+
+	case '7':
+		if (*flags & IPT_PHYSDEV_OP_GROUPOUT)
+			goto multiple_use;
+               check_inverse(argv[optind-1], &invert, &optind, 0);
+               end = optarg = argv[optind-1];
+		info->outgroup = strtoul(optarg, &end, 0);
+		info->outgroupmask = 0xffffffffUL;
+		if (*end == '/')
+			info->outgroupmask = strtoul(end+1, &end, 0);
+		if (*end != '\0' || end == optarg)
+			exit_error(PARAMETER_PROBLEM,
+				"physdev match: Bad ifgroup value `%s'",
+				optarg);
+		if (invert)
+			info->invert |= IPT_PHYSDEV_OP_GROUPOUT;
+		*flags |= IPT_PHYSDEV_OP_GROUPOUT;
+		info->bitmask |= IPT_PHYSDEV_OP_GROUPOUT;
+		break;
+
 	default:
 		return 0;
 	}
@@ -145,6 +186,13 @@
 	if (info->bitmask & IPT_PHYSDEV_OP_BRIDGED)
 		printf("%s --physdev-is-bridged",
 		       info->invert & IPT_PHYSDEV_OP_BRIDGED ? " !":"");
+
+	if (info->bitmask & IPT_PHYSDEV_OP_GROUPIN)
+		printf("%s --physgroup-in 0x%x/0x%x",
+		(info->invert & IPT_PHYSDEV_OP_GROUPIN) ? " !":"", info->ingroup, info->ingroupmask);
+	if (info->bitmask & IPT_PHYSDEV_OP_GROUPOUT)
+		printf("%s --physgroup-out 0x%x/0x%x",
+		(info->invert & IPT_PHYSDEV_OP_GROUPOUT) ? " !":"", info->outgroup, info->outgroupmask);
 	printf(" ");
 }
 
diff -ruN iptables-1.3.8-vanilla/include/linux/netfilter_ipv4/ipt_physdev.h iptables-1.3.8/include/linux/netfilter_ipv4/ipt_physdev.h
--- iptables-1.3.8-vanilla/include/linux/netfilter_ipv4/ipt_physdev.h	2007-01-23 13:49:51.000000000 +0100
+++ iptables-1.3.8/include/linux/netfilter_ipv4/ipt_physdev.h	2007-11-01 16:15:38.000000000 +0100
@@ -10,13 +10,19 @@
 #define IPT_PHYSDEV_OP_BRIDGED		0x04
 #define IPT_PHYSDEV_OP_ISIN		0x08
 #define IPT_PHYSDEV_OP_ISOUT		0x10
-#define IPT_PHYSDEV_OP_MASK		(0x20 - 1)
+#define IPT_PHYSDEV_OP_GROUPIN		0x20
+#define IPT_PHYSDEV_OP_GROUPOUT		0x40
+#define IPT_PHYSDEV_OP_MASK		(0x80 - 1)
 
 struct ipt_physdev_info {
 	char physindev[IFNAMSIZ];
 	char in_mask[IFNAMSIZ];
 	char physoutdev[IFNAMSIZ];
 	char out_mask[IFNAMSIZ];
+	u_int32_t ingroup;
+	u_int32_t ingroupmask;
+	u_int32_t outgroup;
+	u_int32_t outgroupmask;
 	u_int8_t invert;
 	u_int8_t bitmask;
 };
diff -ruN iptables-1.3.8-vanilla/include/linux/netfilter_ipv6/ip6t_physdev.h iptables-1.3.8/include/linux/netfilter_ipv6/ip6t_physdev.h
--- iptables-1.3.8-vanilla/include/linux/netfilter_ipv6/ip6t_physdev.h	2007-01-23 13:49:51.000000000 +0100
+++ iptables-1.3.8/include/linux/netfilter_ipv6/ip6t_physdev.h	2007-11-01 16:15:21.000000000 +0100
@@ -10,13 +10,19 @@
 #define IP6T_PHYSDEV_OP_BRIDGED		0x04
 #define IP6T_PHYSDEV_OP_ISIN		0x08
 #define IP6T_PHYSDEV_OP_ISOUT		0x10
-#define IP6T_PHYSDEV_OP_MASK		(0x20 - 1)
+#define IP6T_PHYSDEV_OP_GROUPIN		0x20
+#define IP6T_PHYSDEV_OP_GROUPOUT	0x40
+#define IP6T_PHYSDEV_OP_MASK		(0x80 - 1)
 
 struct ip6t_physdev_info {
 	char physindev[IFNAMSIZ];
 	char in_mask[IFNAMSIZ];
 	char physoutdev[IFNAMSIZ];
 	char out_mask[IFNAMSIZ];
+	u_int32_t ingroup;
+	u_int32_t ingroupmask;
+	u_int32_t outgroup;
+	u_int32_t outgroupmask;
 	u_int8_t invert;
 	u_int8_t bitmask;
 };

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ifgroup_physdev_kernel.patch"

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index fbcc7ce..75cdc51 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -23,6 +23,23 @@ MODULE_DESCRIPTION("iptables bridge physical device match module");
 MODULE_ALIAS("ipt_physdev");
 MODULE_ALIAS("ip6t_physdev");
 
+static inline bool
+ifgroup_match_in(u_int32_t ingroup, 
+		 const struct xt_physdev_info *info)
+{
+
+	return ((ingroup & info->ingroupmask) == info->ingroup) ^ 
+		((info->invert & XT_PHYSDEV_OP_GROUPIN) == XT_PHYSDEV_OP_GROUPIN);
+}
+
+static inline bool
+ifgroup_match_out(u_int32_t outgroup,
+		 const struct xt_physdev_info *info)
+{
+	return ((outgroup & info->outgroupmask) == info->outgroup) ^ 
+		((info->invert & XT_PHYSDEV_OP_GROUPOUT) == XT_PHYSDEV_OP_GROUPOUT);
+}
+
 static int
 match(const struct sk_buff *skb,
       const struct net_device *in,
@@ -38,6 +55,7 @@ match(const struct sk_buff *skb,
 	const struct xt_physdev_info *info = matchinfo;
 	unsigned int ret;
 	const char *indev, *outdev;
+	u_int32_t ingroup, outgroup;
 	struct nf_bridge_info *nf_bridge;
 
 	/* Not a bridged IP packet or no info available yet:
@@ -60,6 +78,12 @@ match(const struct sk_buff *skb,
 		if ((info->bitmask & XT_PHYSDEV_OP_OUT) &&
 		    !(info->invert & XT_PHYSDEV_OP_OUT))
 			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_GROUPIN) &&
+		    !(info->invert & XT_PHYSDEV_OP_GROUPIN))
+			return NOMATCH;
+		if ((info->bitmask & XT_PHYSDEV_OP_GROUPOUT) &&
+		    !(info->invert & XT_PHYSDEV_OP_GROUPOUT))
+			return NOMATCH;
 		return MATCH;
 	}
 
@@ -75,6 +99,18 @@ match(const struct sk_buff *skb,
 	    (!nf_bridge->physoutdev ^ !!(info->invert & XT_PHYSDEV_OP_ISOUT))))
 		return NOMATCH;
 
+	if (info->bitmask & XT_PHYSDEV_OP_GROUPIN) {
+		ingroup = nf_bridge->physindev ? nf_bridge->physindev->ifgroup : -1;
+		if (!ifgroup_match_in(ingroup, info))
+			return NOMATCH;
+	}
+
+	if (info->bitmask & XT_PHYSDEV_OP_GROUPOUT) {
+		outgroup = nf_bridge->physoutdev ? nf_bridge->physoutdev->ifgroup : -1;
+		if (!ifgroup_match_out(outgroup, info))
+			return NOMATCH;
+	}
+
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
@@ -114,6 +150,7 @@ checkentry(const char *tablename,
 	    info->bitmask & ~XT_PHYSDEV_OP_MASK)
 		return 0;
 	if (brnf_deferred_hooks == 0 &&
+	    info->bitmask & XT_PHYSDEV_OP_GROUPOUT &&
 	    info->bitmask & XT_PHYSDEV_OP_OUT &&
 	    (!(info->bitmask & XT_PHYSDEV_OP_BRIDGED) ||
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&

--3V7upXqbjpZ4EhLz--
