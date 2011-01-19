From: kaber@trash.net
Subject: [PATCH 63/79] netfilter: create audit records for x_tables replaces
Date: Wed, 19 Jan 2011 20:15:03 +0100
Message-ID: <1295464519-21763-64-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51975 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976Ab1ASTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:40 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>

The setsockopt() syscall to replace tables is already recorded
in the audit logs. This patch stores additional information
such as table name and netfilter protocol.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Paris <eparis@parisplace.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/audit.h    |    1 +
 net/netfilter/x_tables.c |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index ae227df..32b5c62 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -104,6 +104,7 @@
 #define AUDIT_CAPSET		1322	/* Record showing argument to sys_capset */
 #define AUDIT_MMAP		1323	/* Record showing descriptor and flags in mmap */
 #define AUDIT_NETFILTER_PKT	1324	/* Packets traversing netfilter chains */
+#define AUDIT_NETFILTER_CFG	1325	/* Netfilter chain modifications */
 
 #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
 #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index ee5de3a..fbc2b72 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -23,6 +23,7 @@
 #include <linux/mutex.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/audit.h>
 #include <net/net_namespace.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -834,6 +835,21 @@ xt_replace_table(struct xt_table *table,
 	 */
 	local_bh_enable();
 
+#ifdef CONFIG_AUDIT
+	if (audit_enabled) {
+		struct audit_buffer *ab;
+
+		ab = audit_log_start(current->audit_context, GFP_KERNEL,
+				     AUDIT_NETFILTER_CFG);
+		if (ab) {
+			audit_log_format(ab, "table=%s family=%u entries=%u",
+					 table->name, table->af,
+					 private->number);
+			audit_log_end(ab);
+		}
+	}
+#endif
+
 	return private;
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
-- 
1.7.2.3

