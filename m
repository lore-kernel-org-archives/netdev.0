From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [v2 PATCH 2/2] NETFILTER userspace part for target HMARK
Date: Thu, 13 Oct 2011 21:02:10 +0200
Message-ID: <1318532530-29446-3-git-send-email-hans.schillstrom@ericsson.com>
References: <1318532530-29446-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <kaber@trash.net>, <pablo@netfilter.org>, <jengelh@medozas.de>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:46151 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab1JMTCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 15:02:14 -0400
In-Reply-To: <1318532530-29446-1-git-send-email-hans.schillstrom@ericsson.com>
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

Ver 2
  IPv4 NAT added
  iptables ver 1.4.12.1 adaptions.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 extensions/libxt_HMARK.c           |  381 ++++++++++++++++++++++++++++++++++++
 extensions/libxt_HMARK.man         |   66 ++++++
 include/linux/netfilter/xt_hmark.h |   48 +++++
 3 files changed, 495 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_HMARK.c
 create mode 100644 extensions/libxt_HMARK.man
 create mode 100644 include/linux/netfilter/xt_hmark.h

diff --git a/extensions/libxt_HMARK.c b/extensions/libxt_HMARK.c
new file mode 100644
index 0000000..0def034
--- /dev/null
+++ b/extensions/libxt_HMARK.c
@@ -0,0 +1,381 @@
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
+#include <stdlib.h>
+#include <getopt.h>
+
+#include <xtables.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_hmark.h>
+
+
+#define DEF_HRAND 0xc175a3b8	/* Default "random" value to jhash */
+
+static void HMARK_help(void)
+{
+	printf(
+"HMARK target options, i.e. modify hash calculation by:\n"
+"  --hmark-smask value                Mask source address with value\n"
+"  --hmark-dmask value                Mask Dest. address with value\n"
+"  --hmark-sp-mask value              Mask src port with value\n"
+"  --hmark-dp-mask value              Mask dst port with value\n"
+"  --hmark-spi-mask value             For esp and ah AND spi with value\n"
+"  --hmark-sp-set value               OR src port with value\n"
+"  --hmark-dp-set value               OR dst port with value\n"
+"  --hmark-spi-set value              For esp and ah OR spi with value\n"
+"  --hmark-proto-mask value           Mask Protocol with value\n"
+"  --hmark-rnd                        Random value to hash cacl.\n"
+"  Limit/modify the calculated hash mark by:\n"
+"  --hmark-mod value                  nfmark modulus value\n"
+"  --hmark-offs value                 Last action add value to nfmark\n"
+" For NAT in IPv4 the original address can be used in the return path.\n"
+" Make sure to qualify the statement in a proper way when using nat flags\n"
+"  --hmark-dnat                       Replace src addr/port with original dst addr/port\n"
+"  --hmark-snat                       Replace dst addr/port with original src addr/port\n"
+" In many cases hmark can be omitted i.e. --smask can be used\n");
+}
+
+static const struct option HMARK_opts[] = {
+	{ "hmark-smask", 1, NULL, XT_HMARK_SADR_AND },
+	{ "hmark-dmask", 1, NULL, XT_HMARK_DADR_AND },
+	{ "hmark-sp-mask", 1, NULL, XT_HMARK_SPORT_AND },
+	{ "hmark-dp-mask", 1, NULL, XT_HMARK_DPORT_AND },
+	{ "hmark-spi-mask", 1, NULL, XT_HMARK_SPI_AND },
+	{ "hmark-sp-set", 1, NULL, XT_HMARK_SPORT_OR },
+	{ "hmark-dp-set", 1, NULL, XT_HMARK_DPORT_OR },
+	{ "hmark-spi-set", 1, NULL, XT_HMARK_SPI_OR },
+	{ "hmark-proto-mask", 1, NULL, XT_HMARK_PROTO_AND },
+	{ "hmark-rnd", 1, NULL, XT_HMARK_RND },
+	{ "hmark-mod", 1, NULL, XT_HMARK_MODULUS },
+	{ "hmark-offs", 1, NULL, XT_HMARK_OFFSET },
+	{ "hmark-dnat", 1, NULL, XT_HMARK_USE_DNAT },
+	{ "hmark-snat", 1, NULL, XT_HMARK_USE_SNAT },
+	{ "smask", 1, NULL, XT_HMARK_SADR_AND },
+	{ "dmask", 1, NULL, XT_HMARK_DADR_AND },
+	{ "sp-mask", 1, NULL, XT_HMARK_SPORT_AND },
+	{ "dp-mask", 1, NULL, XT_HMARK_DPORT_AND },
+	{ "spi-mask", 1, NULL, XT_HMARK_SPI_AND },
+	{ "sp-set", 1, NULL, XT_HMARK_SPORT_OR },
+	{ "dp-set", 1, NULL, XT_HMARK_DPORT_OR },
+	{ "spi-set", 1, NULL, XT_HMARK_SPI_OR },
+	{ "proto-mask", 1, NULL, XT_HMARK_PROTO_AND },
+	{ "rnd", 1, NULL, XT_HMARK_RND },
+	{ "mod", 1, NULL, XT_HMARK_MODULUS },
+	{ "offs", 1, NULL, XT_HMARK_OFFSET },
+	{ "dnat", 1, NULL, XT_HMARK_USE_DNAT },
+	{ "snat", 1, NULL, XT_HMARK_USE_SNAT },
+	{ .name = NULL }
+};
+
+static int
+HMARK_parse(int c, char **argv, int invert, unsigned int *flags,
+	    const void *entry, struct xt_entry_target **target)
+{
+	struct xt_hmark_info *hmarkinfo
+		= (struct xt_hmark_info *)(*target)->data;
+	unsigned int value = 0xffffffff;
+	unsigned int maxint = UINT32_MAX;
+
+	if ((c < XT_HMARK_SADR_AND) || (c > XT_HMARK_OFFSET)) {
+		xtables_error(PARAMETER_PROBLEM, "Bad HMARK option \"%s\"",
+			      optarg);
+		return 0;
+	}
+
+	if (c >= XT_HMARK_SPORT_AND && c <= XT_HMARK_DPORT_OR)
+		maxint = UINT16_MAX;
+	else if (c == XT_HMARK_PROTO_AND)
+		maxint = UINT8_MAX;
+
+	if (!xtables_strtoui(optarg, NULL, &value, 0, maxint))
+		xtables_error(PARAMETER_PROBLEM, "Bad HMARK value \"%s\"",
+			      optarg);
+
+	if (*flags == 0) {
+		memset(hmarkinfo, 0xff, sizeof(struct xt_hmark_info));
+		hmarkinfo->pset.v32 = 0;
+		hmarkinfo->flags = 0;
+		hmarkinfo->spiset = 0;
+		hmarkinfo->hoffs = 0;
+		hmarkinfo->hashrnd = DEF_HRAND;
+	}
+	switch (c) {
+	case XT_HMARK_SADR_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-smask' once");
+		}
+		hmarkinfo->smask = htonl(value);
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_DADR_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-dmask' once");
+		}
+		hmarkinfo->dmask = htonl(value);
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_MODULUS:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-mod' once");
+		}
+		if (value == 0) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "xxx modulus 0 ? "
+				      "thats a div by 0");
+			value = 0xffffffff;
+		}
+		hmarkinfo->hmod = value;
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_OFFSET:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-offs' once");
+		}
+		hmarkinfo->hoffs = value;
+		if (value == 0)
+			c = 0;
+		break;
+
+	case XT_HMARK_SPORT_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-sp-mask' once");
+		}
+		hmarkinfo->pmask.p16.src = htons(value);
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_DPORT_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-dp-mask' once");
+		}
+		hmarkinfo->pmask.p16.dst = htons(value);
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_SPI_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-spi-mask' once");
+		}
+		hmarkinfo->spimask = htonl(value);
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_SPORT_OR:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-sp-set' once");
+		}
+		hmarkinfo->pset.p16.src = htons(value);
+		if (!value)
+			c = 0;
+		break;
+
+	case XT_HMARK_DPORT_OR:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-dp-set' once");
+		}
+		hmarkinfo->pset.p16.dst = htons(value);
+		if (!value)
+			c = 0;
+		break;
+
+	case XT_HMARK_SPI_OR:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-spi-set' once");
+		}
+		hmarkinfo->spiset = htonl(value);
+		if (!value)
+			c = 0;
+		break;
+
+	case XT_HMARK_PROTO_AND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify "
+				      "`--hmark-proto-mask' once");
+		}
+		hmarkinfo->prmask = value;
+		if (value == maxint)
+			c = 0;
+		break;
+
+	case XT_HMARK_RND:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify `--hmark-rnd' once");
+		}
+		hmarkinfo->hashrnd = value;
+		if (value == DEF_HRAND)
+			c = 0;
+		break;
+
+	case XT_HMARK_USE_DNAT:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify `--hmark-rnd' once");
+		}
+		break;
+
+	case XT_HMARK_USE_SNAT:
+		if (*flags & (1 << c)) {
+			xtables_error(PARAMETER_PROBLEM,
+				      "Can only specify `--hmark-rnd' once");
+		}
+		break;
+
+	default:
+		return 0;
+	}
+	*flags |= 1 << c;
+	hmarkinfo->flags = *flags;
+
+	return 1;
+}
+
+static void HMARK_check(unsigned int flags)
+{
+	if (!(flags & (1 << XT_HMARK_MODULUS)))
+		xtables_error(PARAMETER_PROBLEM, "HMARK: the --hmark-mod, "
+			   "is not set, that means the nfmark will be in range"
+			   " 0 - 0xffffffff");
+}
+
+static void HMARK_print(const void *ip, const struct xt_entry_target *target,
+			int numeric)
+{
+	const struct xt_hmark_info *info =
+			(const struct xt_hmark_info *)target->data;
+
+	printf(" HMARK ");
+	if (info->flags & (1 << XT_HMARK_USE_SNAT))
+		printf("snat, ");
+	if (info->flags & (1 << XT_HMARK_SADR_AND))
+		printf("smask 0x%x ", htonl(info->smask));
+
+	if (info->flags & (1 << XT_HMARK_USE_DNAT))
+		printf("dnat, ");
+	if (info->flags & (1 << XT_HMARK_DADR_AND))
+		printf("dmask 0x%x ", htonl(info->dmask));
+
+	if (info->flags & (1 << XT_HMARK_SPORT_AND))
+		printf("sp-mask 0x%x ", htons(info->pmask.p16.src));
+	if (info->flags & (1 << XT_HMARK_DPORT_AND))
+		printf("dp-mask 0x%x ", htons(info->pmask.p16.dst));
+	if (info->flags & (1 << XT_HMARK_SPI_AND))
+		printf("spi-mask 0x%x ", htonl(info->spimask));
+	if (info->flags & (1 << XT_HMARK_SPORT_OR))
+		printf("sp-set 0x%x ", htons(info->pset.p16.src));
+	if (info->flags & (1 << XT_HMARK_DPORT_OR))
+		printf("dp-set 0x%x ", htons(info->pset.p16.dst));
+	if (info->flags & (1 << XT_HMARK_SPI_OR))
+		printf("spi-set 0x%x ", htonl(info->spiset));
+	if (info->flags & (1 << XT_HMARK_PROTO_AND))
+		printf("proto-mask 0x%x ", info->prmask);
+	if (info->flags & (1 << XT_HMARK_RND))
+		printf("rnd 0x%x ", info->hashrnd);
+	if (info->flags & (1 << XT_HMARK_MODULUS))
+		printf("mark=hv %% 0x%x ", info->hmod);
+	if (info->flags & (1 << XT_HMARK_OFFSET))
+		printf("+ 0x%x ", info->hoffs);
+}
+
+static void HMARK_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct xt_hmark_info *info =
+		(const struct xt_hmark_info *)target->data;
+
+	if (info->flags & (1 << XT_HMARK_SADR_AND))
+		printf("--hmark-smask 0x%x ", htonl(info->smask));
+	if (info->flags & (1 << XT_HMARK_DADR_AND))
+		printf("--hmark-dmask 0x%x ", htonl(info->dmask));
+	if (info->flags & (1 << XT_HMARK_SPORT_AND))
+		printf("--hmark-sp-mask 0x%x ", htons(info->pmask.p16.src));
+	if (info->flags & (1 << XT_HMARK_DPORT_AND))
+		printf("--hmark-dp-mask 0x%x ", htons(info->pmask.p16.dst));
+	if (info->flags & (1 << XT_HMARK_SPI_AND))
+		printf("--hmark-spi-mask 0x%x ", htonl(info->spimask));
+	if (info->flags & (1 << XT_HMARK_SPORT_OR))
+		printf("--hmark-sp-set 0x%x ", htons(info->pset.p16.src));
+	if (info->flags & (1 << XT_HMARK_DPORT_OR))
+		printf("--hmark-dp-set 0x%x ", htons(info->pset.p16.dst));
+	if (info->flags & (1 << XT_HMARK_SPI_OR))
+		printf("--hmark-spi-set 0x%x ", htonl(info->spiset));
+	if (info->flags & (1 << XT_HMARK_PROTO_AND))
+		printf("--hmark-proto-mask 0x%x ", info->prmask);
+	if (info->flags & (1 << XT_HMARK_RND))
+		printf("--hmark-rnd 0x%x ", info->hashrnd);
+	if (info->flags & (1 << XT_HMARK_MODULUS))
+		printf("--hmark-mod 0x%x ", info->hmod);
+	if (info->flags & (1 << XT_HMARK_OFFSET))
+		printf("--hmark-offs 0x%x ", info->hoffs);
+	if (info->flags & (1 << XT_HMARK_USE_DNAT))
+		printf("--hmark-dnat ");
+	if (info->flags & (1 << XT_HMARK_USE_SNAT))
+		printf("--hmark-snat ");
+}
+
+static struct xtables_target mark_tg_reg[] = {
+	{
+		.family        = NFPROTO_UNSPEC,
+		.name          = "HMARK",
+		.version       = XTABLES_VERSION,
+		.revision      = 0,
+		.size          = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_hmark_info)),
+		.help          = HMARK_help,
+		.parse         = HMARK_parse,
+		.final_check   = HMARK_check,
+		.print         = HMARK_print,
+		.save          = HMARK_save,
+		.extra_opts    = HMARK_opts,
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
index 0000000..8f44676
--- /dev/null
+++ b/extensions/libxt_HMARK.man
@@ -0,0 +1,66 @@
+This module does the same as MARK, i.e. set an fwmark, but the mark is based on a hash value.
+The hash is based on saddr, daddr, sport, dport and proto. The same mark will be produced independet of direction if no masks is set or the same masks is used for src and dest.
+The hash mark could be adjusted by modulus and finally an offset could be added, i.e the final mark will be within a range. If state RELATED is used icmp will be handled also, i.e. hash will be calculated on the original message not the icmp it self.
+Note: None of the parameters effect the packet it self only the calculated hash value.
+.PP
+Parameters:
+For all masks default is all "1:s", to disable a field use mask 0
+For IPv6 it's just the last 32 bits that is included in the hash
+.TP
+\fB\-\-hmark\-smask\fP \fIvalue\fP
+The value to AND the source address with (saddr & value).
+.TP
+\fB\-\-hmark\-dmask\fP \fIvalue\fP
+The value to AND the dest. address with (daddr & value).
+.TP
+\fB\-\-hmark\-sp\-mask\fP \fIvalue\fP
+A 16 bit value to AND the src port with (sport & value).
+.TP
+\fB\-\-hmark\-dp\-mask\fP \fIvalue\fP
+A 16 bit value to AND the dest port with (dport & value).
+.TP
+\fB\-\-hmark\-sp\-set\fP \fIvalue\fP
+A 16 bit value to OR the src port with (sport | value).
+.TP
+\fB\-\-hmark\-dp\-set\fP \fIvalue\fP
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
+\fB\-\-hmark\-rnd\fP \fIvalue\fP
+A 32 bit initial value for hash calc, default is 0xc175a3b8.
+.TP
+\fB\-\-hmark\-dnat\fP
+Replace src addr/port with original dst addr/port before calc, hash
+.TP
+\fB\-\-hmark\-dnat\fP
+Replace dst addr/port with original src addr/port before calc, hash
+.PP
+Final processing of the mark in order of execution.
+.TP
+\fB\-\-hmark\-mod\fP \fvalue (must be > 0)\fP
+The easiest way to describe this is:  hash = hash mod <value>
+.TP
+\fB\-\-hmark\-offs\fP \fvalue\fP
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
+iptables \-t mangle \-A PREROUTING -p SCTP \-j HMARK \-\-smask 0 \-\-dmask 0
+ \-\-sp\-mask 0 \-\-offs 100 \-\-mod 20
+.PP
+
diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
new file mode 100644
index 0000000..7b3ee5d
--- /dev/null
+++ b/include/linux/netfilter/xt_hmark.h
@@ -0,0 +1,48 @@
+#ifndef XT_HMARK_H_
+#define XT_HMARK_H_
+
+#include <linux/types.h>
+
+/*
+ * Flags must not start at 0, since it's used as none.
+ */
+enum {
+	XT_HMARK_USE_SNAT = 1,	/* SNAT & DNAT are used by the kernel module */
+	XT_HMARK_USE_DNAT,
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
+};
+
+union ports {
+	struct {
+		__u16	src;
+		__u16	dst;
+	} p16;
+	__u32	v32;
+};
+
+struct xt_hmark_info {
+	__u32		smask;		/* Source address mask */
+	__u32		dmask;		/* Dest address mask */
+	union ports	pmask;
+	union ports	pset;
+	__u32		spimask;
+	__u32		spiset;
+	__u16		flags;		/* Print out only */
+	__u16		prmask;		/* L4 Proto mask */
+	__u32		hashrnd;
+	__u32		hmod;		/* Modulus */
+	__u32		hoffs;		/* Offset */
+};
+
+#endif /* XT_HMARK_H_ */
-- 
1.7.4.4
