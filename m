From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH iptables] iptables: add libxt_cgroup frontend
Date: Fri,  4 Oct 2013 20:21:39 +0200
Message-ID: <1ec2a2a431cf329754e5441f00039c7062ff6e89.1380892786.git.dborkman@redhat.com>
References: <cover.1380892786.git.dborkman@redhat.com>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1380892786.git.dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the user space extension/frontend for process matching
based on cgroups from the kernel patch entitled "netfilter: xtables:
lightweight process control group matching".

Signed-off-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 extensions/libxt_cgroup.c           | 67 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_cgroup.man         | 14 ++++++++
 include/linux/netfilter/xt_cgroup.h | 11 ++++++
 3 files changed, 92 insertions(+)
 create mode 100644 extensions/libxt_cgroup.c
 create mode 100644 extensions/libxt_cgroup.man
 create mode 100644 include/linux/netfilter/xt_cgroup.h

diff --git a/extensions/libxt_cgroup.c b/extensions/libxt_cgroup.c
new file mode 100644
index 0000000..2ac6f22
--- /dev/null
+++ b/extensions/libxt_cgroup.c
@@ -0,0 +1,67 @@
+#include <stdio.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_cgroup.h>
+
+enum {
+	O_CGROUP = 0,
+};
+
+static void cgroup_help(void)
+{
+	printf(
+"cgroup match options:\n"
+"[!] --cgroup fwid  Match cgroup fwid\n");
+}
+
+static const struct xt_option_entry cgroup_opts[] = {
+	{
+		.name = "cgroup",
+		.id = O_CGROUP,
+		.type = XTTYPE_UINT32,
+		.flags = XTOPT_INVERT | XTOPT_MAND | XTOPT_PUT,
+		XTOPT_POINTER(struct xt_cgroup_info, id)
+	},
+	XTOPT_TABLEEND,
+};
+
+static void cgroup_parse(struct xt_option_call *cb)
+{
+	struct xt_cgroup_info *cgroupinfo = cb->data;
+
+	xtables_option_parse(cb);
+	if (cb->invert)
+		cgroupinfo->invert = true;
+}
+
+static void
+cgroup_print(const void *ip, const struct xt_entry_match *match, int numeric)
+{
+	const struct xt_cgroup_info *info = (void *) match->data;
+
+	printf(" cgroup %s%u", info->invert ? "! ":"", info->id);
+}
+
+static void cgroup_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_cgroup_info *info = (void *) match->data;
+
+	printf("%s --cgroup %u", info->invert ? " !" : "", info->id);
+}
+
+static struct xtables_match cgroup_match = {
+	.family		= NFPROTO_UNSPEC,
+ 	.name		= "cgroup",
+	.version	= XTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_cgroup_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup_info)),
+	.help		= cgroup_help,
+	.print		= cgroup_print,
+	.save		= cgroup_save,
+	.x6_parse	= cgroup_parse,
+	.x6_options	= cgroup_opts,
+};
+
+void _init(void)
+{
+	xtables_register_match(&cgroup_match);
+}
diff --git a/extensions/libxt_cgroup.man b/extensions/libxt_cgroup.man
new file mode 100644
index 0000000..7423dc7
--- /dev/null
+++ b/extensions/libxt_cgroup.man
@@ -0,0 +1,14 @@
+.TP
+[\fB!\fP] \fB\-\-cgroup\fP \fIfwid\fP
+Match corresponding cgroup for this packet.
+
+Can be used to assign particular firewall policies for aggregated
+task/jobs on the system. This allows for more fine-grained firewall
+policies that only match for a subset of the system's processes.
+.PP
+Example:
+.PP
+iptables \-A OUTPUT \-p tcp \-\-sport 80 \-m cgroup ! \-\-cgroup 1
+\-j DROP
+.PP
+Available since Linux 3.13.
diff --git a/include/linux/netfilter/xt_cgroup.h b/include/linux/netfilter/xt_cgroup.h
new file mode 100644
index 0000000..943d3a0
--- /dev/null
+++ b/include/linux/netfilter/xt_cgroup.h
@@ -0,0 +1,11 @@
+#ifndef _XT_CGROUP_H
+#define _XT_CGROUP_H
+
+#include <linux/types.h>
+
+struct xt_cgroup_info {
+	__u32 id;
+	__u32 invert;
+};
+
+#endif /* _XT_CGROUP_H */
-- 
1.8.3.1
