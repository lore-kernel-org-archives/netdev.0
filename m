From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] netfilter: xt_repldata.h should be at a reasonable path
Date: Mon, 24 Feb 2014 13:01:11 +0800
Message-ID: <1393218071-9674-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:47396 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaBXFBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 00:01:25 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so6018004pbb.17
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 21:01:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the file xt_repldata.h is in path net/netfilter, but in
net/ipv6(ipv4)/netfilter, several files include it, which leads that separately
building the ipv6(ipv4) module needs the net/netfilter source code. perhaps
'include /net/netfilter' is a good location for it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/netfilter/xt_repldata.h | 35 +++++++++++++++++++++++++++++++++++
 net/ipv4/netfilter/arp_tables.c     |  2 +-
 net/ipv4/netfilter/ip_tables.c      |  2 +-
 net/ipv6/netfilter/ip6_tables.c     |  2 +-
 net/netfilter/xt_repldata.h         | 35 -----------------------------------
 5 files changed, 38 insertions(+), 38 deletions(-)
 create mode 100644 include/net/netfilter/xt_repldata.h
 delete mode 100644 net/netfilter/xt_repldata.h

diff --git a/include/net/netfilter/xt_repldata.h b/include/net/netfilter/xt_repldata.h
new file mode 100644
index 0000000..6efe4e5
--- /dev/null
+++ b/include/net/netfilter/xt_repldata.h
@@ -0,0 +1,35 @@
+/*
+ * Today's hack: quantum tunneling in structs
+ *
+ * 'entries' and 'term' are never anywhere referenced by word in code. In fact,
+ * they serve as the hanging-off data accessed through repl.data[].
+ */
+
+#define xt_alloc_initial_table(type, typ2) ({ \
+	unsigned int hook_mask = info->valid_hooks; \
+	unsigned int nhooks = hweight32(hook_mask); \
+	unsigned int bytes = 0, hooknum = 0, i = 0; \
+	struct { \
+		struct type##_replace repl; \
+		struct type##_standard entries[nhooks]; \
+		struct type##_error term; \
+	} *tbl = kzalloc(sizeof(*tbl), GFP_KERNEL); \
+	if (tbl == NULL) \
+		return NULL; \
+	strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
+	tbl->term = (struct type##_error)typ2##_ERROR_INIT;  \
+	tbl->repl.valid_hooks = hook_mask; \
+	tbl->repl.num_entries = nhooks + 1; \
+	tbl->repl.size = nhooks * sizeof(struct type##_standard) + \
+	                 sizeof(struct type##_error); \
+	for (; hook_mask != 0; hook_mask >>= 1, ++hooknum) { \
+		if (!(hook_mask & 1)) \
+			continue; \
+		tbl->repl.hook_entry[hooknum] = bytes; \
+		tbl->repl.underflow[hooknum]  = bytes; \
+		tbl->entries[i++] = (struct type##_standard) \
+			typ2##_STANDARD_INIT(NF_ACCEPT); \
+		bytes += sizeof(struct type##_standard); \
+	} \
+	tbl; \
+})
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 59da7cd..7269607 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -28,7 +28,7 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_arp/arp_tables.h>
-#include "../../netfilter/xt_repldata.h"
+#include <net/netfilter/xt_repldata.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("David S. Miller <davem@redhat.com>");
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 718dfbd..cb85f74 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -29,7 +29,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <net/netfilter/nf_log.h>
-#include "../../netfilter/xt_repldata.h"
+#include <net/netfilter/xt_repldata.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 710238f..b11abad 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -30,7 +30,7 @@
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter/x_tables.h>
 #include <net/netfilter/nf_log.h>
-#include "../../netfilter/xt_repldata.h"
+#include <net/netfilter/xt_repldata.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
deleted file mode 100644
index 6efe4e5..0000000
--- a/net/netfilter/xt_repldata.h
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Today's hack: quantum tunneling in structs
- *
- * 'entries' and 'term' are never anywhere referenced by word in code. In fact,
- * they serve as the hanging-off data accessed through repl.data[].
- */
-
-#define xt_alloc_initial_table(type, typ2) ({ \
-	unsigned int hook_mask = info->valid_hooks; \
-	unsigned int nhooks = hweight32(hook_mask); \
-	unsigned int bytes = 0, hooknum = 0, i = 0; \
-	struct { \
-		struct type##_replace repl; \
-		struct type##_standard entries[nhooks]; \
-		struct type##_error term; \
-	} *tbl = kzalloc(sizeof(*tbl), GFP_KERNEL); \
-	if (tbl == NULL) \
-		return NULL; \
-	strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
-	tbl->term = (struct type##_error)typ2##_ERROR_INIT;  \
-	tbl->repl.valid_hooks = hook_mask; \
-	tbl->repl.num_entries = nhooks + 1; \
-	tbl->repl.size = nhooks * sizeof(struct type##_standard) + \
-	                 sizeof(struct type##_error); \
-	for (; hook_mask != 0; hook_mask >>= 1, ++hooknum) { \
-		if (!(hook_mask & 1)) \
-			continue; \
-		tbl->repl.hook_entry[hooknum] = bytes; \
-		tbl->repl.underflow[hooknum]  = bytes; \
-		tbl->entries[i++] = (struct type##_standard) \
-			typ2##_STANDARD_INIT(NF_ACCEPT); \
-		bytes += sizeof(struct type##_standard); \
-	} \
-	tbl; \
-})
-- 
1.8.3.1
