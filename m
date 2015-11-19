From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 iptables] libxt_cgroup2: add support for cgroup2 path
 matching
Date: Thu, 19 Nov 2015 13:57:15 -0500
Message-ID: <20151119185715.GB28608@mtj.duckdns.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1447959171-20749-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the extension for the xt_cgroup2 which matches packets
based on the v2 cgroup path of the associated socket.

v2: cgroup2_match->userspacesize and ->save and man page updated as
    per Jan.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
---
 extensions/libxt_cgroup2.c           |   71 +++++++++++++++++++++++++++++++++++
 extensions/libxt_cgroup2.man         |   24 +++++++++++
 include/linux/netfilter/xt_cgroup2.h |   15 +++++++
 3 files changed, 110 insertions(+)

--- /dev/null
+++ b/extensions/libxt_cgroup2.c
@@ -0,0 +1,71 @@
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
+	printf("%s --path", info->invert ? " !" : "");
+	xtables_save_string(info->path);
+}
+
+static struct xtables_match cgroup2_match = {
+	.family		= NFPROTO_UNSPEC,
+	.name		= "cgroup2",
+	.version	= XTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
+	.userspacesize	= offsetof(struct xt_cgroup2_info, priv),
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
+INPUT chain is not advised unless the implications are well
+understood.
+.PP
+Example:
+.IP
+iptables \-A OUTPUT \-p tcp \-\-sport 80 \-m cgroup2 ! \-\-path service/http-server \-j DROP
+.PP
+Available since Linux 4.5.
--- /dev/null
+++ b/include/linux/netfilter/xt_cgroup2.h
@@ -0,0 +1,15 @@
+#ifndef _XT_CGROUP2_H
+#define _XT_CGROUP2_H
+
+#include <linux/types.h>
+#include <linux/limits.h>
+
+struct xt_cgroup2_info {
+	char		path[PATH_MAX];
+	__u8		invert;
+
+	/* kernel internal data */
+	void		*priv __attribute__((aligned(8)));
+};
+
+#endif /* _XT_CGROUP2_H */
