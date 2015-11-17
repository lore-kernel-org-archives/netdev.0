From: Tejun Heo <tj@kernel.org>
Subject: [PATCH iptables] libxt_cgroup2: add support for cgroup2 path matching
Date: Tue, 17 Nov 2015 14:42:21 -0500
Message-ID: <20151117194221.GB22864@mtj.duckdns.org>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447789240-29394-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the extension for the xt_cgroup2 which matches packets
based on the v2 cgroup path of the associated socket.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 extensions/libxt_cgroup2.c           |   70 +++++++++++++++++++++++++++++++++++
 extensions/libxt_cgroup2.man         |   24 ++++++++++++
 include/linux/netfilter/xt_cgroup2.h |   14 +++++++
 3 files changed, 108 insertions(+)

--- /dev/null
+++ b/extensions/libxt_cgroup2.c
@@ -0,0 +1,70 @@
+#include <stdio.h>
+#include <mntent.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_cgroup2.h>
+#include <linux/limits.h>
+
+enum {
+	O_CGROUP2_PATH,
+};
+
+static void cgroup2_help(void)
+{
+	printf(
+"cgroup2 match options:\n"
+"[!] --path path                 path relative to cgroup2 root, recursive match\n");
+}
+
+static const struct xt_option_entry cgroup2_opts[] = {
+	{
+		.name = "path",
+		.id = O_CGROUP2_PATH,
+		.type = XTTYPE_STRING,
+		.flags = XTOPT_INVERT | XTOPT_MAND | XTOPT_PUT,
+		XTOPT_POINTER(struct xt_cgroup2_info, path)
+	},
+	XTOPT_TABLEEND,
+};
+
+static void cgroup2_parse(struct xt_option_call *cb)
+{
+	struct xt_cgroup2_info *info = cb->data;
+
+	xtables_option_parse(cb);
+
+	if (cb->invert)
+		info->invert = true;
+}
+
+static void cgroup2_print(const void *ip, const struct xt_entry_match *match,
+			  int numeric)
+{
+	const struct xt_cgroup2_info *info = (void *)match->data;
+
+	printf(" cgroup2 %s%s", info->invert ? "! ":"", info->path);
+}
+
+static void cgroup2_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_cgroup2_info *info = (void *)match->data;
+
+	printf("%s --path %s", info->invert ? " !" : "", info->path);
+}
+
+static struct xtables_match cgroup2_match = {
+	.family		= NFPROTO_UNSPEC,
+	.name		= "cgroup2",
+	.version	= XTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
+	.help		= cgroup2_help,
+	.print		= cgroup2_print,
+	.save		= cgroup2_save,
+	.x6_parse	= cgroup2_parse,
+	.x6_options	= cgroup2_opts,
+};
+
+void _init(void)
+{
+	xtables_register_match(&cgroup2_match);
+}
--- /dev/null
+++ b/extensions/libxt_cgroup2.man
@@ -0,0 +1,24 @@
+.TP
+[\fB!\fP] \fB\-\-path\fP \fIpath\fP
+Match cgroup2 membership.
+
+Each socket is associated with the v2 cgroup of the creating process.
+This matches packets coming from or going to all sockets in the
+sub-hierarchy of the specified path.  The path should be relative to
+the root of the cgroup2 hierarchy.  Can be used in the OUTPUT and
+INPUT chains to assign particular firewall policies for aggregated
+processes on the system. This allows for more fine-grained firewall
+policies that only match for a subset of the system's processes.
+
+\fBIMPORTANT\fP: when being used in the INPUT chain, the cgroup2
+matcher is currently only of limited functionality, meaning it
+will only match on packets that are processed for local sockets
+through early socket demuxing. Therefore, general usage on the
+INPUT chain is disadviced unless the implications are well
+understood.
+.PP
+Example:
+.IP
+iptables \-A OUTPUT \-p tcp \-\-sport 80 \-m cgroup2 ! \-\-path service/http-server \-j DROP
+.PP
+Available since Linux 4.5.
--- /dev/null
+++ b/include/linux/netfilter/xt_cgroup2.h
@@ -0,0 +1,14 @@
+#ifndef _XT_CGROUP2_H
+#define _XT_CGROUP2_H
+
+#include <linux/types.h>
+
+struct xt_cgroup2_info {
+	char				path[PATH_MAX];
+	__u8				invert;
+
+	/* kernel internal data */
+	void				*priv;
+};
+
+#endif /* _XT_CGROUP2_H */
