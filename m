From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 2/2] TProxy: added IPv6 support to the TPROXY target
Date: Fri, 28 Aug 2009 07:58:08 +0200
Message-ID: <1253548039.12519.16.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58461 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751594AbZIUQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 extensions/libxt_TPROXY.c           |  213 +++++++++++++++++++++++++++++------
 include/linux/netfilter/xt_TPROXY.h |   15 ++-
 2 files changed, 187 insertions(+), 41 deletions(-)

diff --git a/extensions/libxt_TPROXY.c b/extensions/libxt_TPROXY.c
index d410c52..72edd4f 100644
--- a/extensions/libxt_TPROXY.c
+++ b/extensions/libxt_TPROXY.c
@@ -1,7 +1,7 @@
 /*
  * Shared library add-on to iptables to add TPROXY target support.
  *
- * Copyright (C) 2002-2008 BalaBit IT Ltd.
+ * Copyright (C) 2002-2009 BalaBit IT Ltd.
  */
 #include <getopt.h>
 #include <stdbool.h>
@@ -36,65 +36,114 @@ static void tproxy_tg_help(void)
 "  --tproxy-mark value[/mask]	    Mark packets with the given value/mask\n\n");
 }
 
-static void parse_tproxy_lport(const char *s, struct xt_tproxy_target_info *info)
+static void parse_tproxy_lport(const char *s, unsigned short *lport)
 {
-	unsigned int lport;
+	unsigned int value;
 
-	if (xtables_strtoui(s, NULL, &lport, 0, UINT16_MAX))
-		info->lport = htons(lport);
+	if (xtables_strtoui(s, NULL, &value, 0, UINT16_MAX))
+		*lport = htons(value);
 	else
 		xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--on-port", s);
 }
 
-static void parse_tproxy_laddr(const char *s, struct xt_tproxy_target_info *info)
+static void parse_tproxy_laddr_v0(const char *s, __be32 *laddr)
 {
-	struct in_addr *laddr;
+	struct in_addr *ina;
 
-	if ((laddr = xtables_numeric_to_ipaddr(s)) == NULL)
+	if ((ina = xtables_numeric_to_ipaddr(s)) == NULL)
 		xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--on-ip", s);
 
-	info->laddr = laddr->s_addr;
+	*laddr = ina->s_addr;
 }
 
-static void parse_tproxy_mark(char *s, struct xt_tproxy_target_info *info)
+static void parse_tproxy_laddr(const char *s, int family, union nf_inet_addr *laddr)
+{
+
+	if (family == NFPROTO_IPV6) {
+		struct in6_addr *addr6;
+
+		if ((addr6 = xtables_numeric_to_ip6addr(s))) {
+			laddr->in6 = *addr6;
+		} else {
+			xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--on-ip", s);
+		}
+	} else {
+		struct in_addr *addr;
+
+		if ((addr = xtables_numeric_to_ipaddr(s))) {
+			laddr->in = *addr;
+		} else {
+			xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--on-ip", s);
+		}
+
+	}
+}
+
+static void parse_tproxy_mark(char *s, unsigned int *value, unsigned int *mask)
 {
-	unsigned int value, mask = UINT32_MAX;
 	char *end;
 
-	if (!xtables_strtoui(s, &end, &value, 0, UINT32_MAX))
+	*mask = UINT32_MAX;
+	if (!xtables_strtoui(s, &end, value, 0, UINT32_MAX))
 		xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--tproxy-mark", s);
 	if (*end == '/')
-		if (!xtables_strtoui(end + 1, &end, &mask, 0, UINT32_MAX))
+		if (!xtables_strtoui(end + 1, &end, mask, 0, UINT32_MAX))
 			xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--tproxy-mark", s);
 	if (*end != '\0')
 		xtables_param_act(XTF_BAD_VALUE, "TPROXY", "--tproxy-mark", s);
+}
+
+static int tproxy_tg_parse_v0(int c, char **argv, int invert, unsigned int *flags,
+			const void *entry, struct xt_entry_target **target)
+{
+	struct xt_tproxy_target_info_v0 *tproxyinfo = (void *)(*target)->data;
+
+	switch (c) {
+	case '1':
+		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--on-port", *flags & PARAM_ONPORT);
+		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--on-port", invert);
+		parse_tproxy_lport(optarg, &tproxyinfo->lport);
+		*flags |= PARAM_ONPORT;
+		return 1;
+	case '2':
+		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--on-ip", *flags & PARAM_ONIP);
+		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--on-ip", invert);
+		parse_tproxy_laddr_v0(optarg, &tproxyinfo->laddr);
+		*flags |= PARAM_ONIP;
+		return 1;
+	case '3':
+		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--tproxy-mark", *flags & PARAM_MARK);
+		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--tproxy-mark", invert);
+		parse_tproxy_mark(optarg, &tproxyinfo->mark_value, &tproxyinfo->mark_mask);
+		*flags |= PARAM_MARK;
+		return 1;
+	}
 
-	info->mark_mask = mask;
-	info->mark_value = value;
+	return 0;
 }
 
-static int tproxy_tg_parse(int c, char **argv, int invert, unsigned int *flags,
+static int tproxy_tg_parse_v1(int family, int c, char **argv, int invert, unsigned int *flags,
 			const void *entry, struct xt_entry_target **target)
 {
-	struct xt_tproxy_target_info *tproxyinfo = (void *)(*target)->data;
+	struct xt_tproxy_target_info_v1 *tproxyinfo = (void *)(*target)->data;
 
 	switch (c) {
 	case '1':
 		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--on-port", *flags & PARAM_ONPORT);
 		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--on-port", invert);
-		parse_tproxy_lport(optarg, tproxyinfo);
+		parse_tproxy_lport(optarg, &tproxyinfo->lport);
 		*flags |= PARAM_ONPORT;
 		return 1;
 	case '2':
 		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--on-ip", *flags & PARAM_ONIP);
 		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--on-ip", invert);
-		parse_tproxy_laddr(optarg, tproxyinfo);
+		parse_tproxy_laddr(optarg, family, &tproxyinfo->laddr);
 		*flags |= PARAM_ONIP;
 		return 1;
 	case '3':
 		xtables_param_act(XTF_ONLY_ONCE, "TPROXY", "--tproxy-mark", *flags & PARAM_MARK);
 		xtables_param_act(XTF_NO_INVERT, "TPROXY", "--tproxy-mark", invert);
-		parse_tproxy_mark(optarg, tproxyinfo);
+		parse_tproxy_mark(optarg, &tproxyinfo->mark_value, &tproxyinfo->mark_mask);
 		*flags |= PARAM_MARK;
 		return 1;
 	}
@@ -102,6 +151,18 @@ static int tproxy_tg_parse(int c, char **argv, int invert, unsigned int *flags,
 	return 0;
 }
 
+static int tproxy_tg_parse4_v1(int c, char **argv, int invert, unsigned int *flags,
+			const void *entry, struct xt_entry_target **target)
+{
+	return tproxy_tg_parse_v1(NFPROTO_IPV4, c, argv, invert, flags, entry, target);
+}
+
+static int tproxy_tg_parse6_v1(int c, char **argv, int invert, unsigned int *flags,
+			const void *entry, struct xt_entry_target **target)
+{
+	return tproxy_tg_parse_v1(NFPROTO_IPV6, c, argv, invert, flags, entry, target);
+}
+
 static void tproxy_tg_check(unsigned int flags)
 {
 	if (!(flags & PARAM_ONPORT))
@@ -109,19 +170,43 @@ static void tproxy_tg_check(unsigned int flags)
 			   "TPROXY target: Parameter --on-port is required");
 }
 
-static void tproxy_tg_print(const void *ip, const struct xt_entry_target *target,
+static void tproxy_tg_print_v0(const void *ip, const struct xt_entry_target *target,
 			 int numeric)
 {
-	const struct xt_tproxy_target_info *info = (const void *)target->data;
+	const struct xt_tproxy_target_info_v0 *info = (const void *)target->data;
 	printf("TPROXY redirect %s:%u mark 0x%x/0x%x",
 	       xtables_ipaddr_to_numeric((const struct in_addr *)&info->laddr),
 	       ntohs(info->lport), (unsigned int)info->mark_value,
 	       (unsigned int)info->mark_mask);
 }
 
-static void tproxy_tg_save(const void *ip, const struct xt_entry_target *target)
+static void tproxy_tg_print_v1(int family, const void *ip, const struct xt_entry_target *target,
+			 int numeric)
 {
-	const struct xt_tproxy_target_info *info = (const void *)target->data;
+	const struct xt_tproxy_target_info_v1 *info = (const void *)target->data;
+	printf("TPROXY redirect %s:%u mark 0x%x/0x%x",
+	       family == AF_INET 
+	       ? xtables_ipaddr_to_numeric(&info->laddr.in) 
+	       : xtables_ip6addr_to_numeric(&info->laddr.in6),
+	       ntohs(info->lport), (unsigned int)info->mark_value,
+	       (unsigned int)info->mark_mask);
+}
+
+static void tproxy_tg_print4_v1(const void *ip, const struct xt_entry_target *target,
+			       int numeric)
+{
+	return tproxy_tg_print_v1(NFPROTO_IPV4, ip, target, numeric);
+}
+
+static void tproxy_tg_print6_v1(const void *ip, const struct xt_entry_target *target,
+			       int numeric)
+{
+	return tproxy_tg_print_v1(NFPROTO_IPV6, ip, target, numeric);
+}
+
+static void tproxy_tg_save_v0(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_tproxy_target_info_v0 *info = (const void *)target->data;
 
 	printf("--on-port %u ", ntohs(info->lport));
 	printf("--on-ip %s ",
@@ -130,21 +215,75 @@ static void tproxy_tg_save(const void *ip, const struct xt_entry_target *target)
 	       (unsigned int)info->mark_value, (unsigned int)info->mark_mask);
 }
 
-static struct xtables_target tproxy_tg_reg = {
-	.name	       = "TPROXY",
-	.family	       = NFPROTO_IPV4,
-	.version       = XTABLES_VERSION,
-	.size	       = XT_ALIGN(sizeof(struct xt_tproxy_target_info)),
-	.userspacesize = XT_ALIGN(sizeof(struct xt_tproxy_target_info)),
-	.help	       = tproxy_tg_help,
-	.parse	       = tproxy_tg_parse,
-	.final_check   = tproxy_tg_check,
-	.print	       = tproxy_tg_print,
-	.save	       = tproxy_tg_save,
-	.extra_opts    = tproxy_tg_opts,
+static void tproxy_tg_save_v1(int family, const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_tproxy_target_info_v1 *info = (const void *)target->data;
+
+	printf("--on-port %u ", ntohs(info->lport));
+	printf("--on-ip %s ",
+	       family == AF_INET 
+	       ? xtables_ipaddr_to_numeric(&info->laddr.in) 
+	       : xtables_ip6addr_to_numeric(&info->laddr.in6));
+	printf("--tproxy-mark 0x%x/0x%x ",
+	       (unsigned int)info->mark_value, (unsigned int)info->mark_mask);
+}
+
+static void tproxy_tg_save4_v1(const void *ip, const struct xt_entry_target *target)
+{
+	return tproxy_tg_save_v1(NFPROTO_IPV4, ip, target);
+}
+
+static void tproxy_tg_save6_v1(const void *ip, const struct xt_entry_target *target)
+{
+	return tproxy_tg_save_v1(NFPROTO_IPV6, ip, target);
+}
+
+
+static struct xtables_target tproxy_tg_reg[] = {
+	{
+		.name	       = "TPROXY",
+		.family	       = NFPROTO_IPV4,
+		.version       = XTABLES_VERSION,
+		.size	       = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v0)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v0)),
+		.help	       = tproxy_tg_help,
+		.parse	       = tproxy_tg_parse_v0,
+		.final_check   = tproxy_tg_check,
+		.print	       = tproxy_tg_print_v0,
+		.save	       = tproxy_tg_save_v0,
+		.extra_opts    = tproxy_tg_opts,
+	},
+	{
+		.name	       = "TPROXY",
+		.family	       = NFPROTO_IPV4,
+		.version       = XTABLES_VERSION,
+		.revision      = 1,
+		.size	       = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v1)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v1)),
+		.help	       = tproxy_tg_help,
+		.parse	       = tproxy_tg_parse4_v1,
+		.final_check   = tproxy_tg_check,
+		.print	       = tproxy_tg_print4_v1,
+		.save	       = tproxy_tg_save4_v1,
+		.extra_opts    = tproxy_tg_opts,
+	},
+	{
+		.name	       = "TPROXY",
+		.family	       = NFPROTO_IPV6,
+		.version       = XTABLES_VERSION,
+		.revision      = 1,
+		.size	       = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v1)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_tproxy_target_info_v1)),
+		.help	       = tproxy_tg_help,
+		.parse	       = tproxy_tg_parse6_v1,
+		.final_check   = tproxy_tg_check,
+		.print	       = tproxy_tg_print6_v1,
+		.save	       = tproxy_tg_save6_v1,
+		.extra_opts    = tproxy_tg_opts,
+	},
 };
 
 void _init(void)
 {
-	xtables_register_target(&tproxy_tg_reg);
+	xtables_register_targets(tproxy_tg_reg, ARRAY_SIZE(tproxy_tg_reg));
 }
diff --git a/include/linux/netfilter/xt_TPROXY.h b/include/linux/netfilter/xt_TPROXY.h
index 152e8f9..7b4e06d 100644
--- a/include/linux/netfilter/xt_TPROXY.h
+++ b/include/linux/netfilter/xt_TPROXY.h
@@ -1,14 +1,21 @@
-#ifndef _XT_TPROXY_H_target
-#define _XT_TPROXY_H_target
+#ifndef _XT_TPROXY_H
+#define _XT_TPROXY_H
 
 /* TPROXY target is capable of marking the packet to perform
  * redirection. We can get rid of that whenever we get support for
  * mutliple targets in the same rule. */
-struct xt_tproxy_target_info {
+struct xt_tproxy_target_info_v0 {
 	u_int32_t mark_mask;
 	u_int32_t mark_value;
 	__be32 laddr;
 	__be16 lport;
 };
 
-#endif /* _XT_TPROXY_H_target */
+struct xt_tproxy_target_info_v1 {
+	u_int32_t mark_mask;
+	u_int32_t mark_value;
+	union nf_inet_addr laddr;
+	__be16 lport;
+};
+
+#endif /* _XT_TPROXY_H */
-- 
1.6.0.4

