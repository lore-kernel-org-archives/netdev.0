From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IPTABLES PATCH] Interface group match
Date: Thu, 18 Oct 2007 12:15:17 +0200
Message-ID: <11927025171799-git-send-email-panther@balabit.hu>
References: <11927025171404-git-send-email-panther@balabit.hu>
 <1192702517840-git-send-email-panther@balabit.hu>
 <11927025171911-git-send-email-panther@balabit.hu>
 <11927025171740-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11927025171740-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071018-120757-1192702077-panther@balabit.hu>
References: <ifgroup-20071018-120757-1192702077-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matching ifgroup value of incoming and/or outgoing interface.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 extensions/Makefile                  |    2 +-
 extensions/libip6t_ifgroup.man       |   36 +++++++
 extensions/libipt_ifgroup.man        |   36 +++++++
 extensions/libxt_ifgroup.c           |  178 ++++++++++++++++++++++++++++++++++
 include/linux/netfilter/xt_ifgroup.h |   18 ++++
 5 files changed, 269 insertions(+), 1 deletions(-)

diff --git a/extensions/Makefile b/extensions/Makefile
index 5af234e..938cf0b 100644
--- a/extensions/Makefile
+++ b/extensions/Makefile
@@ -7,7 +7,7 @@
 #
 PF_EXT_SLIB:=ah addrtype conntrack ecn icmp iprange owner policy realm recent tos ttl unclean CLUSTERIP DNAT ECN LOG MASQUERADE MIRROR NETMAP REDIRECT REJECT SAME SNAT TOS TTL ULOG
 PF6_EXT_SLIB:=ah dst eui64 frag hbh hl icmp6 ipv6header mh owner policy rt HL LOG REJECT
-PFX_EXT_SLIB:=connbytes connmark connlimit comment dccp dscp esp hashlimit helper length limit mac mark multiport physdev pkttype quota sctp state statistic standard string tcp tcpmss time u32 udp CLASSIFY CONNMARK DSCP MARK NFLOG NFQUEUE NOTRACK TCPMSS TRACE
+PFX_EXT_SLIB:=connbytes connmark connlimit comment dccp dscp esp hashlimit helper ifgroup length limit mac mark multiport physdev pkttype quota sctp state statistic standard string tcp tcpmss time u32 udp CLASSIFY CONNMARK DSCP MARK NFLOG NFQUEUE NOTRACK TCPMSS TRACE
 
 PF_EXT_SELINUX_SLIB:=
 PF6_EXT_SELINUX_SLIB:=
diff --git a/extensions/libip6t_ifgroup.man b/extensions/libip6t_ifgroup.man
new file mode 100644
index 0000000..a96ec91
--- /dev/null
+++ b/extensions/libip6t_ifgroup.man
@@ -0,0 +1,36 @@
+Maches packets on an interface if it is in the same interface group
+as specified by the
+.B "--in-ifgroup"
+or
+.B "--out-ifgroup"
+parameter. If a mask is also specified, the masked value of
+the inteface's group must be equal to the given value of the
+.B "--in-ifgroup"
+or
+.B "--out-ifgroup"
+parameter to match. This match is available in all tables.
+.TP
+.BR "--in-ifgroup \fIgroup[/mask]\fR"
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
+.BR "--out-ifgroup \fIgroup[/mask]\fR"
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
diff --git a/extensions/libipt_ifgroup.man b/extensions/libipt_ifgroup.man
new file mode 100644
index 0000000..a96ec91
--- /dev/null
+++ b/extensions/libipt_ifgroup.man
@@ -0,0 +1,36 @@
+Maches packets on an interface if it is in the same interface group
+as specified by the
+.B "--in-ifgroup"
+or
+.B "--out-ifgroup"
+parameter. If a mask is also specified, the masked value of
+the inteface's group must be equal to the given value of the
+.B "--in-ifgroup"
+or
+.B "--out-ifgroup"
+parameter to match. This match is available in all tables.
+.TP
+.BR "--in-ifgroup \fIgroup[/mask]\fR"
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
+.BR "--out-ifgroup \fIgroup[/mask]\fR"
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
diff --git a/extensions/libxt_ifgroup.c b/extensions/libxt_ifgroup.c
new file mode 100644
index 0000000..d7f982c
--- /dev/null
+++ b/extensions/libxt_ifgroup.c
@@ -0,0 +1,178 @@
+/* 
+ * Shared library add-on to iptables to match 
+ * packets by the incoming interface group.
+ *
+ * Balazs Scheidler <bazsi@balabit.hu>
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
+"  --in-ifgroup  [!] group[/mask]  incoming interface group and its mask\n"
+"  --out-ifgroup [!] group[/mask]  outgoing interface group and its mask\n"
+"\n", IPTABLES_VERSION);
+}
+
+static struct option opts[] = {
+	{"in-ifgroup", 1, 0, '1'},
+	{"out-ifgroup", 1, 0, '2'},
+	{ }
+};
+
+#define PARAM_MATCH_IN   0x01
+#define PARAM_MATCH_OUT  0x02
+
+static int
+ifgroup_parse(int c, char **argv, int invert, unsigned int *flags,
+      const void *entry, struct xt_entry_match **match)
+{
+	struct xt_ifgroup_info *info = (struct xt_ifgroup_info *) (*match)->data;
+	char *end;
+	
+	switch (c)
+	{
+		case '1':
+			if (*flags & PARAM_MATCH_IN)
+				exit_error(PARAMETER_PROBLEM,
+					  "ifgroup match: Can't specify --in-ifgroup twice");
+											         
+			check_inverse(optarg, &invert, &optind, 0);
+			
+			info->in_group = strtoul(optarg, &end, 0);
+			info->in_mask = 0xffffffffUL;
+			
+			if (*end == '/')
+				info->in_mask = strtoul(end+1, &end, 0);
+
+			if (*end != '\0' || end == optarg)
+				exit_error(PARAMETER_PROBLEM, "ifgroup match: Bad ifgroup value `%s'", optarg);
+			
+			if (invert)
+				info->flags |= XT_IFGROUP_INVERT_IN;
+
+			*flags |= PARAM_MATCH_IN;
+			info->flags |= XT_IFGROUP_MATCH_IN;			
+			break;
+		case '2':
+			if (*flags & PARAM_MATCH_OUT)
+				exit_error(PARAMETER_PROBLEM,
+					  "ifgroup match: Can't specify --out-ifgroup twice");
+											         
+			check_inverse(optarg, &invert, &optind, 0);
+			
+			info->out_group = strtoul(optarg, &end, 0);
+			info->out_mask = 0xffffffffUL;
+			
+			if (*end == '/')
+				info->out_mask = strtoul(end+1, &end, 0);
+
+			if (*end != '\0' || end == optarg)
+				exit_error(PARAMETER_PROBLEM, "ifgroup match: Bad ifgroup value `%s'", optarg);
+			
+			if (invert)
+				info->flags |= XT_IFGROUP_INVERT_OUT;
+
+			*flags |= PARAM_MATCH_OUT;
+			info->flags |= XT_IFGROUP_MATCH_OUT;			
+			break;
+		default: 
+			return 0;
+	}
+
+	return 1;
+}
+
+static void
+ifgroup_final_check(unsigned int flags)
+{
+	if (!flags)
+		exit_error(PARAMETER_PROBLEM, "You must specify `--in-ifgroup' or `--out-ifgroup'");
+}
+
+static void
+ifgroup_print_value_in(struct xt_ifgroup_info *info)
+{
+	printf("0x%x/0x%x ", info->in_group, info->in_mask);
+}
+
+static void
+ifgroup_print_value_out(struct xt_ifgroup_info *info)
+{
+	printf("0x%x/0x%x ", info->out_group, info->out_mask);
+}
+
+static void
+ifgroup_print(const void *ip, const struct xt_entry_match *match, int numeric)
+{
+	struct xt_ifgroup_info *info = (struct xt_ifgroup_info *) match->data;
+	
+	printf("ifgroup ");
+	
+	if (info->flags & XT_IFGROUP_MATCH_IN) {
+		printf("in %s", info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
+		ifgroup_print_value_in(info);
+	}
+	if (info->flags & XT_IFGROUP_MATCH_OUT) {
+		printf("out %s", info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
+		ifgroup_print_value_out(info);
+	}
+}
+
+static void
+ifgroup_save(const void *ip, const struct xt_entry_match *match)
+{
+	struct xt_ifgroup_info *info = (struct xt_ifgroup_info *) match->data;
+	
+	if (info->flags & XT_IFGROUP_MATCH_IN) {
+		printf("--in-ifgroup %s", info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
+		ifgroup_print_value_in(info);
+	}
+	if (info->flags & XT_IFGROUP_MATCH_OUT) {
+		printf("--out-ifgroup %s", info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
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
+
diff --git a/include/linux/netfilter/xt_ifgroup.h b/include/linux/netfilter/xt_ifgroup.h
new file mode 100644
index 0000000..9ac75de
--- /dev/null
+++ b/include/linux/netfilter/xt_ifgroup.h
@@ -0,0 +1,18 @@
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
+
-- 
1.5.2.5

