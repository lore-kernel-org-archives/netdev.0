From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v10 PATCH 3/3] NETFILTER userspace part for target HMARK
Date: Mon, 12 Mar 2012 17:31:40 +0100
Message-ID: <1331569900-2032-4-git-send-email-hans.schillstrom@ericsson.com>
References: <1331569900-2032-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: hans@schillstrom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: kaber@trash.net, pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:58837 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab2CLQbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 12:31:45 -0400
In-Reply-To: <1331569900-2032-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    The target allows you to create rules in the "raw" and "mangle" tables
    which alter the netfilter mark (nfmark) field within a given range.
    First a 32 bit hash value is generated then modulus by <limit> and
    finally an offset is added before it's written to nfmark.
    Prior to routing, the nfmark can influence the routing method (see
    "Use netfilter MARK value as routing key") and can also be used by
    other subsystems to change their behaviour.

    The mark match can also be used to match nfmark produced by this module.

Ver 10
    conntrack reduced to --hmark-ct switch
    renaming of vars in xt_hmark_info
    Adding helptext and updated man due to --hmark-ct switch

Ver 9
    Formating changes.

Ver 8
    Syntax changes more descriptive options
    --hmark-method added.

Ver 6-7 -

Ver 5
      smask and dmask changed to length

Ver 4
      xtoptions used for parsing.

Ver 3
       -

Ver 2
      IPv4 NAT added
      iptables ver 1.4.12.1 adaptions.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 extensions/libxt_HMARK.c           |  469 ++++++++++++++++++++++++++++++++++++
 extensions/libxt_HMARK.man         |   84 +++++++
 include/linux/netfilter/xt_HMARK.h |   62 +++++
 3 files changed, 615 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_HMARK.c
 create mode 100644 extensions/libxt_HMARK.man
 create mode 100644 include/linux/netfilter/xt_HMARK.h

diff --git a/extensions/libxt_HMARK.c b/extensions/libxt_HMARK.c
new file mode 100644
index 0000000..d657d85
--- /dev/null
+++ b/extensions/libxt_HMARK.c
@@ -0,0 +1,469 @@
+/*
+ * Shared library add-on to iptables to add HMARK target support.
+ *
+ * The kernel module calculates a hash value that can be modified by modulus
+ * and an offset. The hash value is based on a direction independent
+ * five tuple: src & dst addr src & dst ports and protocol.
+ * However src & dst port can be masked and are not used for fragmented
+ * packets, ESP and AH don't have ports so SPI will be used instead.
+ * For ICMP error messages the hash mark values will be calculated on
+ * the source packet i.e. the packet caused the error (If sufficient
+ * amount of data exists).
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <stdbool.h>
+#include <stdio.h>
+#include <string.h>
+
+#include "xtables.h"
+#include <linux/netfilter/xt_HMARK.h>
+
+
+#define DEF_HRAND 0xc175a3b8	/* Default "random" value to jhash */
+
+#define XT_F_HMARK_L4_OPTS  (XT_F_HMARK_SPI_AND | XT_F_HMARK_SPI_OR\
+			     | XT_F_HMARK_SPORT_AND | XT_F_HMARK_SPORT_OR\
+			     | XT_F_HMARK_DPORT_AND | XT_F_HMARK_DPORT_OR\
+			     | XT_F_HMARK_PROTO_AND)
+
+static void HMARK_help(void)
+{
+	printf(
+"HMARK target options, i.e. modify hash calculation by:\n"
+"  --hmark-method <method>          Overall L3/L4 and fragment behavior\n"
+"                 L3                Fragment safe, do not use ports or proto\n"
+"                                   i.e. Fragments don't need special care.\n"
+"                 L3-4 (Default)    Fragment unsafe, use ports and proto\n"
+"                                   if defrag off in conntrack\n"
+"                                      no hmark on any part of a fragment\n"
+"  Limit/modify the calculated hash mark by:\n"
+"  --hmark-mod value                nfmark modulus value\n"
+"  --hmark-offset value             Last action add value to nfmark\n\n"
+" Fine tuning of what will be included in hash calculation\n"
+"  --hmark-src-mask length          Source address mask length\n"
+"  --hmark-dst-mask length          Dest address mask length\n"
+"  --hmark-sport-mask value         Mask src port with value\n"
+"  --hmark-dport-mask value         Mask dst port with value\n"
+"  --hmark-spi-mask value           For esp and ah AND spi with value\n"
+"  --hmark-sport-set value          OR src port with value\n"
+"  --hmark-dport-set value          OR dst port with value\n"
+"  --hmark-spi-set value            For esp and ah OR spi with value\n"
+"  --hmark-proto-mask value         Mask Protocol with value\n"
+"  --hmark-rnd                      Initial Random value to hash cacl.\n"
+" For NAT in IPv4: src part from original/reply tuple will always be used\n"
+" i.e. orig src part will be used as src address/port.\n"
+"     reply src part will be used as dst address/port\n"
+" Make sure to qualify the rule in a proper way when using NAT flag\n"
+" When --ct is used only tracked connections will match\n"
+"  --hmark-ct                       Force conntrack orig and rely tuples as\n"
+"                                   source and destination.\n\n"
+" In many cases hmark can be omitted i.e. --src-mask can be used\n");
+}
+
+#define hi struct xt_hmark_info
+
+static const struct xt_option_entry HMARK_opts[]= {
+ 	{ .name  = "hmark-method",
+	  .type  = XTTYPE_STRING,
+	  .id    = XT_HMARK_METHOD_L3
+	},
+	{ .name  = "hmark-src-mask",
+	  .type  = XTTYPE_PLENMASK,
+	  .id    = XT_HMARK_SADR_AND,
+	  .flags = XTOPT_PUT, XTOPT_POINTER(hi, src_mask)
+	},
+	{ .name  = "hmark-dst-mask",
+	  .type  = XTTYPE_PLENMASK,
+	  .id    = XT_HMARK_DADR_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, dst_mask)
+	},
+	{ .name  = "hmark-sport-mask",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_SPORT_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.src)
+	},
+	{ .name  = "hmark-dport-mask",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_DPORT_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.dst)
+	},
+	{ .name  = "hmark-spi-mask",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_SPI_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, spi_mask)
+	},
+	{ .name  = "hmark-sport-set",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_SPORT_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.src)
+	},
+	{ .name  = "hmark-dport-set",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_DPORT_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.dst)
+	},
+	{ .name  = "hmark-spi-set",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_SPI_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, spi_set)
+	},
+	{ .name  = "hmark-proto-mask",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_PROTO_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, proto_mask)
+	},
+	{ .name  = "hmark-rnd",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_RND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, hashrnd)
+	},
+	{ .name = "hmark-mod",
+	  .type = XTTYPE_UINT32,
+	  .id = XT_HMARK_MODULUS,
+	  .min = 1,
+	  .flags = XTOPT_PUT | XTOPT_MAND,
+	  XTOPT_POINTER(hi, hmodulus)
+	},
+	{ .name  = "hmark-offset",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_OFFSET,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, hoffset)
+	},
+	{ .name  = "hmark-ct",
+	  .type  = XTTYPE_NONE,
+	  .id    = XT_HMARK_CT
+	},
+
+	{ .name  = "method",
+	  .type  = XTTYPE_STRING,
+	  .id    = XT_HMARK_METHOD_L3
+	},
+	{ .name  = "src-mask",
+	  .type  = XTTYPE_PLENMASK,
+	  .id    = XT_HMARK_SADR_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, src_mask)
+	},
+	{ .name  = "dst-mask",
+	  .type  = XTTYPE_PLENMASK,
+	  .id    = XT_HMARK_DADR_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, dst_mask)
+	},
+	{ .name  = "sport-mask",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_SPORT_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.src)
+	},
+	{ .name  = "dport-mask", .type = XTTYPE_UINT16,
+	  .id = XT_HMARK_DPORT_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_mask.p16.dst)
+	},
+	{ .name  = "spi-mask",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_SPI_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, spi_mask)
+	},
+	{ .name  = "sport-set",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_SPORT_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.src)
+	},
+	{ .name  = "dport-set",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_DPORT_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, port_set.p16.dst)
+	},
+	{ .name  = "spi-set",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_SPI_OR,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, spi_set)
+	},
+	{ .name  = "proto-mask",
+	  .type  = XTTYPE_UINT16,
+	  .id    = XT_HMARK_PROTO_AND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, proto_mask)
+	},
+	{ .name  = "rnd",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_RND,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, hashrnd)
+	},
+	{ .name  = "mod",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_MODULUS,
+	  .min   = 1,
+	  .flags = XTOPT_PUT,
+	  XTOPT_MAND, XTOPT_POINTER(hi, hmodulus)
+	},
+	{ .name  = "offset",
+	  .type  = XTTYPE_UINT32,
+	  .id    = XT_HMARK_OFFSET,
+	  .flags = XTOPT_PUT,
+	  XTOPT_POINTER(hi, hoffset)
+	},
+	{ .name  = "ct",
+	  .type  = XTTYPE_NONE,
+	  .id    = XT_HMARK_CT
+	},
+	XTOPT_TABLEEND,
+};
+
+static void HMARK_parse(struct xt_option_call *cb)
+{
+	struct xt_hmark_info *info = cb->data;
+
+	if (!cb->xflags) {
+		memset(info, 0xff, sizeof(struct xt_hmark_info));
+		info->port_set.v32 = 0;
+		info->flags = 0;
+		info->spi_set = 0;
+		info->hoffset = 0;
+		info->hashrnd = DEF_HRAND;
+	}
+	xtables_option_parse(cb);
+
+	switch (cb->entry->id) {
+	case XT_HMARK_SPI_AND:
+		info->spi_mask = htonl(cb->val.u32);
+		break;
+	case XT_HMARK_SPI_OR:
+		info->spi_set = htonl(cb->val.u32);
+		break;
+	case XT_HMARK_SPORT_AND:
+		info->port_mask.p16.src = htons(cb->val.u16);
+		break;
+	case XT_HMARK_DPORT_AND:
+		info->port_mask.p16.dst = htons(cb->val.u16);
+		break;
+	case XT_HMARK_SPORT_OR:
+		info->port_set.p16.src = htons(cb->val.u16);
+		break;
+	case XT_HMARK_DPORT_OR:
+		info->port_set.p16.dst = htons(cb->val.u16);
+		break;
+	case XT_HMARK_MODULUS:
+		if (info->hmodulus == 0) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "xxx modulus 0 ? "
+				      "thats a div by 0");
+			info->hmodulus = 0xffffffff;
+		}
+		break;
+	case XT_HMARK_METHOD_L3:
+		if (strcmp(cb->arg, "L3") == 0) {
+			info->proto_mask = 0;
+			cb->xflags &= ~XT_F_HMARK_METHOD_L3_4;
+		} else if (strcmp(cb->arg, "L3-4") == 0) {
+			cb->xflags &= ~XT_F_HMARK_METHOD_L3;
+			cb->xflags |= XT_F_HMARK_METHOD_L3_4;
+		}
+	}
+	info->flags = cb->xflags;
+}
+
+static void HMARK_check(struct xt_fcheck_call *cb)
+{
+	if (!(cb->xflags & XT_F_HMARK_MODULUS))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: the --hmark-mod, "
+			      "is not set, or zero wich is a div by zero");
+	/* Check for invalid options */
+	if (cb->xflags & XT_F_HMARK_METHOD_L3 &&
+	   (cb->xflags & XT_F_HMARK_L4_OPTS))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: --hmark-method L3, "
+			      "can not be combined by an Layer 4 options: "
+		              "port, spi or proto ");
+}
+/*
+ * Common print for IPv4 & IPv6
+ */
+static void HMARK_print(const struct xt_hmark_info *info)
+{
+	if (info->flags & XT_F_HMARK_METHOD_L3) {
+		printf("method L3 ");
+	} else {
+		if (info->flags & XT_F_HMARK_METHOD_L3_4)
+			printf("method L3-4 ");
+		if (info->flags & XT_F_HMARK_SPORT_AND)
+			printf("sport-mask 0x%x ", htons(info->port_mask.p16.src));
+		if (info->flags & XT_F_HMARK_DPORT_AND)
+			printf("dport-mask 0x%x ", htons(info->port_mask.p16.dst));
+		if (info->flags & XT_F_HMARK_SPI_AND)
+			printf("spi-mask 0x%x ", htonl(info->spi_mask));
+		if (info->flags & XT_F_HMARK_SPORT_OR)
+			printf("sport-set 0x%x ", htons(info->port_set.p16.src));
+		if (info->flags & XT_F_HMARK_DPORT_OR)
+			printf("dport-set 0x%x ", htons(info->port_set.p16.dst));
+		if (info->flags & XT_F_HMARK_SPI_OR)
+			printf("spi-set 0x%x ", htonl(info->spi_set));
+		if (info->flags & XT_F_HMARK_PROTO_AND)
+			printf("proto-mask 0x%x ", info->proto_mask);
+	}
+	if (info->flags & XT_F_HMARK_RND)
+		printf("rnd 0x%x ", info->hashrnd);
+
+}
+
+static void HMARK_ip6_print(const void *ip,
+			    const struct xt_entry_target *target, int numeric)
+{
+	const struct xt_hmark_info *info =
+			(const struct xt_hmark_info *)target->data;
+
+	printf(" HMARK ");
+	if (info->flags & XT_F_HMARK_MODULUS)
+		printf("%% 0x%x ", info->hmodulus);
+	if (info->flags & XT_F_HMARK_OFFSET)
+		printf("+ 0x%x ", info->hoffset);
+	if (info->flags & XT_F_HMARK_CT)
+		printf("ct, ");
+	if (info->flags & XT_F_HMARK_SADR_AND)
+		printf("src-mask %s ",
+		       xtables_ip6mask_to_numeric(&info->src_mask.in6) + 1);
+	if (info->flags & XT_F_HMARK_DADR_AND)
+		printf("dst-mask %s ",
+		       xtables_ip6mask_to_numeric(&info->dst_mask.in6) + 1);
+	HMARK_print(info);
+}
+static void HMARK_ip4_print(const void *ip,
+			    const struct xt_entry_target *target, int numeric)
+{
+	const struct xt_hmark_info *info =
+		(const struct xt_hmark_info *)target->data;
+
+	printf(" HMARK ");
+	if (info->flags & XT_F_HMARK_MODULUS)
+		printf("%% 0x%x ", info->hmodulus);
+	if (info->flags & XT_F_HMARK_OFFSET)
+		printf("+ 0x%x ", info->hoffset);
+	if (info->flags & XT_F_HMARK_CT)
+		printf("ct, ");
+	if (info->flags & XT_F_HMARK_SADR_AND)
+		printf("src-mask %s ",
+		       xtables_ipmask_to_numeric(&info->src_mask.in) + 1);
+	if (info->flags & XT_F_HMARK_DADR_AND)
+		printf("dst-mask %s ",
+		       xtables_ipmask_to_numeric(&info->dst_mask.in) + 1);
+	HMARK_print(info);
+}
+static void HMARK_save(const struct xt_hmark_info *info)
+{
+	if (info->flags & XT_F_HMARK_METHOD_L3) {
+		printf(" --hmark-method L3");
+	} else {
+		if (info->flags & XT_F_HMARK_METHOD_L3_4)
+			printf(" --hmark-method L3-4");
+		if (info->flags & XT_F_HMARK_SPORT_AND)
+			printf(" --hmark-sport-mask 0x%x",
+			       htons(info->port_mask.p16.src));
+		if (info->flags & XT_F_HMARK_DPORT_AND)
+			printf(" --hmark-dport-mask 0x%x",
+			       htons(info->port_mask.p16.dst));
+		if (info->flags & XT_F_HMARK_SPI_AND)
+			printf(" --hmark-spi-mask 0x%x",
+			       htonl(info->spi_mask));
+		if (info->flags & XT_F_HMARK_SPORT_OR)
+			printf(" --hmark-sport-set 0x%x",
+			       htons(info->port_set.p16.src));
+		if (info->flags & XT_F_HMARK_DPORT_OR)
+			printf(" --hmark-dport-set 0x%x",
+			       htons(info->port_set.p16.dst));
+		if (info->flags & XT_F_HMARK_SPI_OR)
+			printf(" --hmark-spi-set 0x%x", htonl(info->spi_set));
+		if (info->flags & XT_F_HMARK_PROTO_AND)
+			printf(" --hmark-proto-mask 0x%x", info->proto_mask);
+	}
+	if (info->flags & XT_F_HMARK_RND)
+		printf(" --hmark-rnd 0x%x", info->hashrnd);
+	if (info->flags & XT_F_HMARK_MODULUS)
+		printf(" --hmark-mod 0x%x", info->hmodulus);
+	if (info->flags & XT_F_HMARK_OFFSET)
+		printf(" --hmark-offset 0x%x", info->hoffset);
+	if (info->flags & XT_F_HMARK_CT)
+		printf(" --hmark-ct");
+}
+
+static void HMARK_ip6_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_hmark_info *info =
+		(const struct xt_hmark_info *)target->data;
+
+	if (info->flags & XT_F_HMARK_SADR_AND)
+		printf(" --hmark-src-mask %s",
+		       xtables_ip6mask_to_numeric(&info->src_mask.in6) + 1);
+	if (info->flags & XT_F_HMARK_DADR_AND)
+		printf(" --hmark-dst-mask %s",
+		       xtables_ip6mask_to_numeric(&info->dst_mask.in6) + 1);
+	HMARK_save(info);
+}
+
+static void HMARK_ip4_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_hmark_info *info =
+		(const struct xt_hmark_info *)target->data;
+
+	if (info->flags & XT_F_HMARK_SADR_AND)
+		printf(" --hmark-src-mask %s",
+		       xtables_ipmask_to_numeric(&info->src_mask.in) + 1);
+	if (info->flags & XT_F_HMARK_DADR_AND)
+		printf(" --hmark-dst-mask %s",
+		       xtables_ipmask_to_numeric(&info->dst_mask.in) + 1);
+	HMARK_save(info);
+}
+
+static struct xtables_target mark_tg_reg[] = {
+	{
+		.family        = NFPROTO_IPV4,
+		.name          = "HMARK",
+		.version       = XTABLES_VERSION,
+		.revision      = 0,
+		.size          = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.help          = HMARK_help,
+		.print         = HMARK_ip4_print,
+		.save          = HMARK_ip4_save,
+		.x6_parse      = HMARK_parse,
+		.x6_fcheck     = HMARK_check,
+		.x6_options    = HMARK_opts,
+	},
+	{
+		.family        = NFPROTO_IPV6,
+		.name          = "HMARK",
+		.version       = XTABLES_VERSION,
+		.revision      = 0,
+		.size          = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.help          = HMARK_help,
+		.print         = HMARK_ip6_print,
+		.save          = HMARK_ip6_save,
+		.x6_parse      = HMARK_parse,
+		.x6_fcheck     = HMARK_check,
+		.x6_options    = HMARK_opts,
+	},
+};
+
+void _init(void)
+{
+	xtables_register_targets(mark_tg_reg, ARRAY_SIZE(mark_tg_reg));
+}
+
diff --git a/extensions/libxt_HMARK.man b/extensions/libxt_HMARK.man
new file mode 100644
index 0000000..92bd1ed
--- /dev/null
+++ b/extensions/libxt_HMARK.man
@@ -0,0 +1,84 @@
+This module does the same as MARK, i.e. set an fwmark, but the mark is based on a hash value.
+The hash is based on src-addr, dst-addr, sport, dport and proto. The same mark will be produced independent of direction if no masks is set or the same masks is used for src and dest.
+The hash mark could be adjusted by modulus and finally an offset could be added, i.e the final mark will be within a range.
+ICMP error will use the the original message for hash calculation not the icmp it self.
+
+Note: IPv4 packets with nf_defrag_ipv4 loaded will be defragmented before they reach hmark,
+      IPv6 nf_defrag is not implemented this way, hence fragmented ipv6 packets will reach hmark.
+      Default behavior is to completely ignore any fragment if it reach hmark.
+      --hmark-method L3 is fragment safe since neither ports or L4 protocol field is used.
+      None of the parameters effect the packet it self only the calculated hash value.
+      
+.PP
+Parameters:
+Short hand methods
+.TP
+\fB\-\-hmark\-method\fP \fIL3\fP
+Do not use L4 protocol field, ports or spi, only Layer 3 addresses, mask length 
+of L3 addresses can still be used. Fragment or not does not matter in 
+this case since only L3 address can be used in calc. of hash value.
+.TP
+\fB\-\-hmark\-method\fP \fIL3-4\fP (Default)
+Include L4 in calculation. of hash value i.e. all masks below are valid. 
+Fragments will be ignored. (i.e no hash value produced)
+.PP
+For all masks default is all "1:s", to disable a field use mask 0
+.TP
+\fB\-\-hmark\-src\-mask\fP \fIlength\fP
+The length of the mask to AND the source address with (saddr & value).
+.TP
+\fB\-\-hmark\-dst\-mask\fP \fIlength\fP
+The length of the mask to AND the dest. address with (daddr & value).
+.TP
+\fB\-\-hmark\-sport\-mask\fP \fIvalue\fP
+A 16 bit value to AND the src port with (sport & value).
+.TP
+\fB\-\-hmark\-dport\-mask\fP \fIvalue\fP
+A 16 bit value to AND the dest port with (dport & value).
+.TP
+\fB\-\-hmark\-sport\-set\fP \fIvalue\fP
+A 16 bit value to OR the src port with (sport | value).
+.TP
+\fB\-\-hmark\-dport\-set\fP \fIvalue\fP
+A 16 bit value to OR the dest port with (dport | value).
+.TP
+\fB\-\-hmark\-spi\-mask\fP \fIvalue\fP
+Value to AND the spi field with (spi & value) valid for proto esp or ah.
+.TP
+\fB\-\-hmark\-spi\-set\fP \fIvalue\fP
+Value to OR the spi field with (spi | value) valid for proto esp or ah.
+.TP
+\fB\-\-hmark\-proto\-mask\fP \fIvalue\fP
+An 8 bit value to AND the L4 proto field with (proto & value).
+.TP
+\fB\-\-hmark\-ct\fP
+When flag is set, conntrack data should be used. Useful when NAT internal addressed should be used in calculation.
+Be careful when using DNAT since mangle table is handled before nat table. I.e it will not work as expected to put HMARK in table mangle and PREROUTING chain. The initial packet will have it's hash based on the original address, while the rest of the flow will use the NAT:ed address.
+.TP
+\fB\-\-hmark\-rnd\fP \fIvalue\fP
+A 32 bit initial value for hash calc, default is 0xc175a3b8.
+.PP
+Final processing of the mark in order of execution.
+.TP
+\fB\-\-hmark\-mod\fP \fIvalue (must be > 0)\fP
+The easiest way to describe this is:  hash = hash mod <value>
+.TP
+\fB\-\-hmark\-offset\fP \fIvalue\fP
+The easiest way to describe this is:  hash = hash + <value>
+.PP
+\fIExamples:\fP
+.PP
+Default rule handles all TCP, UDP, SCTP, ESP & AH
+.IP
+iptables \-t mangle \-A PREROUTING \-m state \-\-state NEW,ESTABLISHED,RELATED
+ \-j HMARK \-\-hmark-offs 10000 \-\-hmark-mod 10
+.PP
+Handle SCTP and hash dest port only and produce a nfmark between 100-119.
+.IP
+iptables \-t mangle \-A PREROUTING -p SCTP \-j HMARK \-\-src\-mask 0 \-\-dst\-mask 0
+ \-\-sp\-mask 0 \-\-offset 100 \-\-mod 20
+.PP
+Fragment safe Layer 3 only that keep a class C network flow together
+.IP
+iptables \-t mangle \-A PREROUTING \-j HMARK \-\-method L3 \-\-src\-mask 24 \-\-mod 20 \-\-offset 100
+
diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
new file mode 100644
index 0000000..cdf4a8f
--- /dev/null
+++ b/include/linux/netfilter/xt_HMARK.h
@@ -0,0 +1,62 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+enum {
+	XT_HMARK_NONE,
+	XT_HMARK_SADR_AND,
+	XT_HMARK_DADR_AND,
+	XT_HMARK_SPI_AND,
+	XT_HMARK_SPI_OR,
+	XT_HMARK_SPORT_AND,
+	XT_HMARK_DPORT_AND,
+	XT_HMARK_SPORT_OR,
+	XT_HMARK_DPORT_OR,
+	XT_HMARK_PROTO_AND,
+	XT_HMARK_RND,
+	XT_HMARK_MODULUS,
+	XT_HMARK_OFFSET,
+	XT_HMARK_CT,
+	XT_HMARK_METHOD_L3,
+	XT_HMARK_METHOD_L3_4,
+	XT_F_HMARK_SADR_AND    = 1 << XT_HMARK_SADR_AND,
+	XT_F_HMARK_DADR_AND    = 1 << XT_HMARK_DADR_AND,
+	XT_F_HMARK_SPI_AND     = 1 << XT_HMARK_SPI_AND,
+	XT_F_HMARK_SPI_OR      = 1 << XT_HMARK_SPI_OR,
+	XT_F_HMARK_SPORT_AND   = 1 << XT_HMARK_SPORT_AND,
+	XT_F_HMARK_DPORT_AND   = 1 << XT_HMARK_DPORT_AND,
+	XT_F_HMARK_SPORT_OR    = 1 << XT_HMARK_SPORT_OR,
+	XT_F_HMARK_DPORT_OR    = 1 << XT_HMARK_DPORT_OR,
+	XT_F_HMARK_PROTO_AND   = 1 << XT_HMARK_PROTO_AND,
+	XT_F_HMARK_RND         = 1 << XT_HMARK_RND,
+	XT_F_HMARK_MODULUS     = 1 << XT_HMARK_MODULUS,
+	XT_F_HMARK_OFFSET      = 1 << XT_HMARK_OFFSET,
+	XT_F_HMARK_CT          = 1 << XT_HMARK_CT,
+	XT_F_HMARK_METHOD_L3   = 1 << XT_HMARK_METHOD_L3,
+	XT_F_HMARK_METHOD_L3_4 = 1 << XT_HMARK_METHOD_L3_4,
+};
+
+union hmark_ports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	__u32	v32;
+};
+
+struct xt_hmark_info {
+	union nf_inet_addr	src_mask;	/* Source address mask */
+	union nf_inet_addr	dst_mask;	/* Dest address mask */
+	union hmark_ports	port_mask;
+	union hmark_ports	port_set;
+	__u32			spi_mask;
+	__u32			spi_set;
+	__u32			flags;		/* Print out only */
+	__u16			proto_mask;	/* L4 Proto mask */
+	__u32			hashrnd;
+	__u32			hmodulus;	/* Modulus */
+	__u32			hoffset;	/* Offset */
+};
+
+#endif /* XT_HMARK_H_ */
-- 
1.7.2.3
