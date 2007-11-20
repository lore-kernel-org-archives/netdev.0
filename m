From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv6 iptables]Interface group match
Date: Tue, 20 Nov 2007 14:14:28 +0100
Message-ID: <11955644702194-git-send-email-panther@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu>
 <1195564470928-git-send-email-panther@balabit.hu>
 <11955644702451-git-send-email-panther@balabit.hu>
 <11955644701536-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:57937 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758552AbXKTNOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 08:14:43 -0500
In-Reply-To: <11955644701536-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interface group values can be checked on both input and output interfaces
with optional mask.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 extensions/Makefile                  |    2 
 extensions/libxt_ifgroup.c           |  201 +++++++++++++++++++++++++++++++++++
 extensions/libxt_ifgroup.man         |   36 ++++++
 include/linux/netfilter/xt_ifgroup.h |   17 ++
 4 files changed, 255 insertions(+), 1 deletion(-)

Index: include/linux/netfilter/xt_ifgroup.h
===================================================================
--- include/linux/netfilter/xt_ifgroup.h	(revision 0)
+++ include/linux/netfilter/xt_ifgroup.h	(revision 0)
@@ -0,0 +1,17 @@
+#ifndef _XT_IFGROUP_H
+#define _XT_IFGROUP_H
+
+#define XT_IFGROUP_INVERT_IN	0x01
+#define XT_IFGROUP_INVERT_OUT	0x02
+#define XT_IFGROUP_MATCH_IN	0x04
+#define XT_IFGROUP_MATCH_OUT	0x08
+
+struct xt_ifgroup_info {
+	u_int32_t in_group;
+	u_int32_t in_mask;
+	u_int32_t out_group;
+	u_int32_t out_mask;
+	u_int8_t flags;
+};
+
+#endif /*_XT_IFGROUP_H*/
Index: extensions/libxt_ifgroup.c
===================================================================
--- extensions/libxt_ifgroup.c	(revision 0)
+++ extensions/libxt_ifgroup.c	(revision 0)
@@ -0,0 +1,201 @@
+/* 
+ * Shared library add-on to iptables to match 
+ * packets by the incoming interface group.
+ *
+ * (c) 2006, 2007 Balazs Scheidler <bazsi@balabit.hu>,
+ * Laszlo Attila Toth <panther@balabit.hu>
+ */
+#include <stdio.h>
+#include <netdb.h>
+#include <string.h>
+#include <stdlib.h>
+#include <getopt.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_ifgroup.h>
+
+static void
+ifgroup_help(void)
+{
+	printf(
+"ifgroup v%s options:\n"
+"  --ifgroup-in  [!] group[/mask]  incoming interface group and its mask\n"
+"  --ifgroup-out [!] group[/mask]  outgoing interface group and its mask\n"
+"\n", IPTABLES_VERSION);
+}
+
+static struct option opts[] = {
+	{"ifgroup-in", 1, NULL, '1'},
+	{"ifgroup-out", 1, NULL, '2'},
+	{ }
+};
+
+#define PARAM_MATCH_IN	0x01
+#define PARAM_MATCH_OUT	0x02
+
+
+#define IFGROUP_DEFAULT_MASK 0xffffffffU
+
+static int
+ifgroup_parse(int c, char **argv, int invert, unsigned int *flags,
+	      const void *entry, struct xt_entry_match **match)
+{
+	struct xt_ifgroup_info *info =
+			 (struct xt_ifgroup_info *) (*match)->data;
+	char *end;
+
+	switch (c) {
+	case '1':
+		if (*flags & PARAM_MATCH_IN)
+			exit_error(PARAMETER_PROBLEM,
+			    "ifgroup match: Can't specify --ifgroup-in twice");
+
+		check_inverse(optarg, &invert, &optind, 0);
+
+		info->in_group = strtoul(optarg, &end, 0);
+		info->in_mask = IFGROUP_DEFAULT_MASK;
+
+		if (*end == '/')
+			info->in_mask = strtoul(end+1, &end, 0);
+
+		if (*end != '\0' || end == optarg)
+			exit_error(PARAMETER_PROBLEM,
+				  "ifgroup match: Bad ifgroup value `%s'", optarg);
+
+		if (invert)
+			info->flags |= XT_IFGROUP_INVERT_IN;
+
+		*flags |= PARAM_MATCH_IN;
+		info->flags |= XT_IFGROUP_MATCH_IN;
+		break;
+
+	case '2':
+		if (*flags & PARAM_MATCH_OUT)
+			exit_error(PARAMETER_PROBLEM,
+			    "ifgroup match: Can't specify --ifgroup-out twice");
+
+		check_inverse(optarg, &invert, &optind, 0);
+
+		info->out_group = strtoul(optarg, &end, 0);
+		info->out_mask = IFGROUP_DEFAULT_MASK;
+
+		if (*end == '/')
+			info->out_mask = strtoul(end+1, &end, 0);
+
+		if (*end != '\0' || end == optarg)
+			exit_error(PARAMETER_PROBLEM,
+			    "ifgroup match: Bad ifgroup value `%s'", optarg);
+
+		if (invert)
+			info->flags |= XT_IFGROUP_INVERT_OUT;
+
+		*flags |= PARAM_MATCH_OUT;
+		info->flags |= XT_IFGROUP_MATCH_OUT;
+		break;
+
+	default: 
+		return 0;
+	}
+
+	return 1;
+}
+
+static void
+ifgroup_final_check(unsigned int flags)
+{
+	if (!flags)
+		exit_error(PARAMETER_PROBLEM,
+		    "You must specify either "
+		    "`--ifgroup-in' or `--ifgroup-out'");
+}
+
+static void
+ifgroup_print_value_in(struct xt_ifgroup_info *info)
+{
+	printf("0x%x", info->in_group);
+	if (info->in_mask != IFGROUP_DEFAULT_MASK)
+		printf("/0x%x", info->in_mask);
+	printf(" ");
+}
+
+static void
+ifgroup_print_value_out(struct xt_ifgroup_info *info)
+{
+	printf("0x%x", info->out_group);
+	if (info->out_mask != IFGROUP_DEFAULT_MASK)
+		printf("/0x%x", info->out_mask);
+	printf(" ");
+}
+
+static void
+ifgroup_print(const void *ip,
+	      const struct xt_entry_match *match,
+	      int numeric)
+{
+	struct xt_ifgroup_info *info =
+		(struct xt_ifgroup_info *) match->data;
+
+	printf("ifgroup ");
+
+	if (info->flags & XT_IFGROUP_MATCH_IN) {
+		printf("in %s",
+		       info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
+		ifgroup_print_value_in(info);
+	}
+	if (info->flags & XT_IFGROUP_MATCH_OUT) {
+		printf("out %s",
+		       info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
+		ifgroup_print_value_out(info);
+	}
+}
+
+static void
+ifgroup_save(const void *ip, const struct xt_entry_match *match)
+{
+	struct xt_ifgroup_info *info =
+		(struct xt_ifgroup_info *) match->data;
+
+	if (info->flags & XT_IFGROUP_MATCH_IN) {
+		printf("%s--ifgroup-in ",
+		       info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
+		ifgroup_print_value_in(info);
+	}
+	if (info->flags & XT_IFGROUP_MATCH_OUT) {
+		printf("%s--ifgroup-out ",
+		       info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
+		ifgroup_print_value_out(info);
+	}
+}
+
+static struct xtables_match ifgroup_match = {
+	.family		= AF_INET,
+	.name		= "ifgroup",
+	.version	= IPTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_ifgroup_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct xt_ifgroup_info)),
+	.help		= ifgroup_help,
+	.parse		= ifgroup_parse,
+	.final_check	= ifgroup_final_check,
+	.print		= ifgroup_print,
+	.save		= ifgroup_save,
+	.extra_opts	= opts
+};
+
+static struct xtables_match ifgroup_match6 = {
+	.family		= AF_INET6,
+	.name		= "ifgroup",
+	.version	= IPTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_ifgroup_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct xt_ifgroup_info)),
+	.help		= ifgroup_help,
+	.parse		= ifgroup_parse,
+	.final_check	= ifgroup_final_check,
+	.print		= ifgroup_print,
+	.save		= ifgroup_save,
+	.extra_opts	= opts
+};
+
+void _init(void)
+{
+	xtables_register_match(&ifgroup_match);
+	xtables_register_match(&ifgroup_match6);
+}
Index: extensions/Makefile
===================================================================
--- extensions/Makefile	(revision 7090)
+++ extensions/Makefile	(working copy)
@@ -7,7 +7,7 @@
 #
 PF_EXT_SLIB:=ah addrtype conntrack ecn icmp iprange owner policy realm recent tos ttl unclean CLUSTERIP DNAT ECN LOG MASQUERADE MIRROR NETMAP REDIRECT REJECT SAME SNAT TOS TTL ULOG
 PF6_EXT_SLIB:=ah dst eui64 frag hbh hl icmp6 ipv6header mh owner policy rt HL LOG REJECT
-PFX_EXT_SLIB:=connbytes connmark connlimit comment dccp dscp esp hashlimit helper length limit mac mark multiport physdev pkttype quota sctp state statistic standard string tcp tcpmss time u32 udp CLASSIFY CONNMARK DSCP MARK NFLOG NFQUEUE NOTRACK TCPMSS TRACE
+PFX_EXT_SLIB:=connbytes connmark connlimit comment dccp dscp esp hashlimit helper ifgroup length limit mac mark multiport physdev pkttype quota sctp state statistic standard string tcp tcpmss time u32 udp CLASSIFY CONNMARK DSCP MARK NFLOG NFQUEUE NOTRACK TCPMSS TRACE
 
 PF_EXT_SELINUX_SLIB:=
 PF6_EXT_SELINUX_SLIB:=
Index: extensions/libxt_ifgroup.man
===================================================================
--- extensions/libxt_ifgroup.man	(revision 0)
+++ extensions/libxt_ifgroup.man	(revision 0)
@@ -0,0 +1,36 @@
+Maches packets on an interface if it is in the same interface group
+as specified by the
+.B "--ifgroup-in"
+or
+.B "--ifgroup-in"
+parameter. If a mask is also specified, the masked value of
+the inteface's group must be equal to the given value of the
+.B "--ifgroup-in"
+or
+.B "--ifgroup-out"
+parameter to match. This match is available in all tables.
+.TP
+.BR "[!] --ifgroup-in \fIgroup[/mask]\fR"
+This specifies the interface group of input interface and the optional mask.
+Valid only in the in the
+.B PREROUTING
+and
+.B INPUT
+and
+.B FORWARD
+chains, and user-defined chains which are only called from those
+chains. 
+.TP
+.BR "[!] --ifgroup-out \fIgroup[/mask]\fR"
+This specifies the interface group of out interface and the optional mask.
+Valid only in the in the
+.B FORWARD
+and
+.B OUTPUT
+and
+.B POSTROUTING
+chains, and user-defined chains which are only called from those
+chains. 
+.RS
+.PP
+
