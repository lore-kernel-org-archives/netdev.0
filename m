From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] extensions: libipt_CHECKSUM extension
Date: Fri, 9 Jul 2010 01:35:24 +0300
Message-ID: <20100708223524.GA4614__33835.4504005567$1278628942$gmane$org@redhat.com>
References: <20100708222913.GA4475@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755966Ab0GHWls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 18:41:48 -0400
Content-Disposition: inline
In-Reply-To: <20100708222913.GA4475@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a `CHECKSUM' target, which can be used in the iptables mangle
table.

You can use this target to compute and fill in the checksum in
an IP packet that lacks a checksum.  This is particularly useful,
if you need to work around old applications such as dhcp clients,
that do not work well with checksum offloads, but don't want to disable
checksum offload in your device.

The problem happens in the field with virtualized applications.
For reference, see Red Hat bz 605555, as well as
http://www.spinics.net/lists/kvm/msg37660.html

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This patch adds userspace support for the CHECKSUM kernel module I sent previously.

 extensions/libipt_CHECKSUM.c   |  100 ++++++++++++++++++++++++++++++++++++++++
 extensions/libipt_CHECKSUM.man |    8 +++
 2 files changed, 108 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libipt_CHECKSUM.c
 create mode 100644 extensions/libipt_CHECKSUM.man

diff --git a/extensions/libipt_CHECKSUM.c b/extensions/libipt_CHECKSUM.c
new file mode 100644
index 0000000..93d3e3f
--- /dev/null
+++ b/extensions/libipt_CHECKSUM.c
@@ -0,0 +1,100 @@
+/* Shared library add-on to iptables for CHECKSUM
+ *
+ * (C) 2002 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2010 by Red Hat, Inc
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * This program is distributed under the terms of GNU GPL v2, 1991
+ *
+ * libipt_CHECKSUM.c borrowed heavily from libipt_ECN.c
+ *
+ * $Id$
+ */
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <getopt.h>
+
+#include <xtables.h>
+#include <linux/netfilter_ipv4/ipt_CHECKSUM.h>
+
+static void CHECKSUM_help(void)
+{
+	printf(
+"CHECKSUM target options\n"
+"  --checksum-fill			Fill in packet checksum.\n");
+}
+
+static const struct option CHECKSUM_opts[] = {
+	{ "checksum-fill", 0, NULL, 'F' },
+	{ .name = NULL }
+};
+
+static int CHECKSUM_parse(int c, char **argv, int invert, unsigned int *flags,
+                     const void *entry, struct xt_entry_target **target)
+{
+	unsigned int result;
+	struct ipt_CHECKSUM_info *einfo
+		= (struct ipt_CHECKSUM_info *)(*target)->data;
+
+	switch (c) {
+	case 'F':
+		if (*flags)
+			xtables_error(PARAMETER_PROBLEM,
+			        "CHECKSUM target: Only use --checksum-fill ONCE!");
+		einfo->operation = IPT_CHECKSUM_OP_FILL;
+		*flags |= IPT_CHECKSUM_OP_FILL;
+		break;
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
+static void CHECKSUM_check(unsigned int flags)
+{
+	if (!flags)
+		xtables_error(PARAMETER_PROBLEM,
+		           "CHECKSUM target: Parameter --checksum-fill is required");
+}
+
+static void CHECKSUM_print(const void *ip, const struct xt_entry_target *target,
+                      int numeric)
+{
+	const struct ipt_CHECKSUM_info *einfo =
+		(const struct ipt_CHECKSUM_info *)target->data;
+
+	printf("CHECKSUM ");
+
+	if (einfo->operation & IPT_CHECKSUM_OP_FILL)
+		printf("fill ");
+}
+
+static void CHECKSUM_save(const void *ip, const struct xt_entry_target *target)
+{
+	const struct ipt_CHECKSUM_info *einfo =
+		(const struct ipt_CHECKSUM_info *)target->data;
+
+	if (einfo->operation & IPT_CHECKSUM_OP_FILL)
+		printf("--checksum-fill ");
+}
+
+static struct xtables_target checksum_tg_reg = {
+	.name		= "CHECKSUM",
+	.version	= XTABLES_VERSION,
+	.family		= NFPROTO_IPV4,
+	.size		= XT_ALIGN(sizeof(struct ipt_CHECKSUM_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct ipt_CHECKSUM_info)),
+	.help		= CHECKSUM_help,
+	.parse		= CHECKSUM_parse,
+	.final_check	= CHECKSUM_check,
+	.print		= CHECKSUM_print,
+	.save		= CHECKSUM_save,
+	.extra_opts	= CHECKSUM_opts,
+};
+
+void _init(void)
+{
+	xtables_register_target(&checksum_tg_reg);
+}
diff --git a/extensions/libipt_CHECKSUM.man b/extensions/libipt_CHECKSUM.man
new file mode 100644
index 0000000..4f83335
--- /dev/null
+++ b/extensions/libipt_CHECKSUM.man
@@ -0,0 +1,8 @@
+This target allows to selectively work around broken/old applications.
+It can only be used in the mangle table.
+.TP
+\fB\-\-checksum\-fill\fP
+Compute and fill in the checksum in an IP packet that lacks a checksum.
+This is particularly useful, if you need to work around old applications
+such as dhcp clients, that do not work well with checksum offloads,
+but don't want to disable checksum offload in your device.
-- 
1.7.2.rc0.14.g41c1c
