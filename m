From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH nf-next] netfilter: nf_conntrack: make nf_ct_zone_dflt built-in
Date: Thu,  3 Sep 2015 01:26:07 +0200
Message-ID: <e3e68a263cbf95761bd3f759f458f43973741584.1441235714.git.daniel@iogearbox.net>
Cc: fengguang.wu@intel.com, fw@strlen.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54914 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbbIBX0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang reported, that some randconfig generated the following linker
issue with nf_ct_zone_dflt object involved:

  [...]
  CC      init/version.o
  LD      init/built-in.o
  net/built-in.o: In function `ipv4_conntrack_defrag':
  nf_defrag_ipv4.c:(.text+0x93e95): undefined reference to `nf_ct_zone_dflt'
  net/built-in.o: In function `ipv6_defrag':
  nf_defrag_ipv6_hooks.c:(.text+0xe3ffe): undefined reference to `nf_ct_zone_dflt'
  make: *** [vmlinux] Error 1

Given that configurations exist where we have a built-in part, which is
accessing nf_ct_zone_dflt such as the two handlers nf_ct_defrag_user()
and nf_ct6_defrag_user(), and a part that configures nf_conntrack as a
module, we must move nf_ct_zone_dflt into a fixed, guaranteed built-in
area when netfilter is configured in general.

Therefore, split the more generic parts into a common header under
include/linux/netfilter/ and move nf_ct_zone_dflt into the built-in
section that already holds parts related to CONFIG_NF_CONNTRACK in the
netfilter core. This fixes the issue on my side.

Fixes: 308ac9143ee2 ("netfilter: nf_conntrack: push zone object into functions")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ Here's the 2nd one for either nf-next or net-next. I've tried various
   Kconfig combinations including the one Fengguang reported, seems to be
   okay from my side. ]

 include/linux/netfilter.h                          |  2 ++
 .../linux/netfilter/nf_conntrack_zones_common.h    | 23 ++++++++++++++++++++++
 include/net/netfilter/nf_conntrack_zones.h         | 19 +-----------------
 net/netfilter/core.c                               |  6 ++++++
 net/netfilter/nf_conntrack_core.c                  |  7 -------
 5 files changed, 32 insertions(+), 25 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_zones_common.h

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index d788ce6..36a6525 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -368,6 +368,8 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 #endif /*CONFIG_NETFILTER*/
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#include <linux/netfilter/nf_conntrack_zones_common.h>
+
 extern void (*ip_ct_attach)(struct sk_buff *, const struct sk_buff *) __rcu;
 void nf_ct_attach(struct sk_buff *, const struct sk_buff *);
 extern void (*nf_ct_destroy)(struct nf_conntrack *) __rcu;
diff --git a/include/linux/netfilter/nf_conntrack_zones_common.h b/include/linux/netfilter/nf_conntrack_zones_common.h
new file mode 100644
index 0000000..5d7cf36
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_zones_common.h
@@ -0,0 +1,23 @@
+#ifndef _NF_CONNTRACK_ZONES_COMMON_H
+#define _NF_CONNTRACK_ZONES_COMMON_H
+
+#include <uapi/linux/netfilter/nf_conntrack_tuple_common.h>
+
+#define NF_CT_DEFAULT_ZONE_ID	0
+
+#define NF_CT_ZONE_DIR_ORIG	(1 << IP_CT_DIR_ORIGINAL)
+#define NF_CT_ZONE_DIR_REPL	(1 << IP_CT_DIR_REPLY)
+
+#define NF_CT_DEFAULT_ZONE_DIR	(NF_CT_ZONE_DIR_ORIG | NF_CT_ZONE_DIR_REPL)
+
+#define NF_CT_FLAG_MARK		1
+
+struct nf_conntrack_zone {
+	u16	id;
+	u8	flags;
+	u8	dir;
+};
+
+extern const struct nf_conntrack_zone nf_ct_zone_dflt;
+
+#endif /* _NF_CONNTRACK_ZONES_COMMON_H */
diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 5316c7b..4e32512 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -1,24 +1,7 @@
 #ifndef _NF_CONNTRACK_ZONES_H
 #define _NF_CONNTRACK_ZONES_H
 
-#include <linux/netfilter/nf_conntrack_tuple_common.h>
-
-#define NF_CT_DEFAULT_ZONE_ID	0
-
-#define NF_CT_ZONE_DIR_ORIG	(1 << IP_CT_DIR_ORIGINAL)
-#define NF_CT_ZONE_DIR_REPL	(1 << IP_CT_DIR_REPLY)
-
-#define NF_CT_DEFAULT_ZONE_DIR	(NF_CT_ZONE_DIR_ORIG | NF_CT_ZONE_DIR_REPL)
-
-#define NF_CT_FLAG_MARK		1
-
-struct nf_conntrack_zone {
-	u16	id;
-	u8	flags;
-	u8	dir;
-};
-
-extern const struct nf_conntrack_zone nf_ct_zone_dflt;
+#include <linux/netfilter/nf_conntrack_zones_common.h>
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack_extend.h>
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 0b939b7..8e47f81 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -388,6 +388,12 @@ EXPORT_SYMBOL(nf_conntrack_destroy);
 struct nfq_ct_hook __rcu *nfq_ct_hook __read_mostly;
 EXPORT_SYMBOL_GPL(nfq_ct_hook);
 
+/* Built-in default zone used e.g. by modules. */
+const struct nf_conntrack_zone nf_ct_zone_dflt = {
+	.id	= NF_CT_DEFAULT_ZONE_ID,
+	.dir	= NF_CT_DEFAULT_ZONE_DIR,
+};
+EXPORT_SYMBOL_GPL(nf_ct_zone_dflt);
 #endif /* CONFIG_NF_CONNTRACK */
 
 #ifdef CONFIG_NF_NAT_NEEDED
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ac3be9b..eedf049 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1286,13 +1286,6 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
 
-/* Built-in default zone used e.g. by modules. */
-const struct nf_conntrack_zone nf_ct_zone_dflt = {
-	.id	= NF_CT_DEFAULT_ZONE_ID,
-	.dir	= NF_CT_DEFAULT_ZONE_DIR,
-};
-EXPORT_SYMBOL_GPL(nf_ct_zone_dflt);
-
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 static struct nf_ct_ext_type nf_ct_zone_extend __read_mostly = {
 	.len	= sizeof(struct nf_conntrack_zone),
-- 
1.9.3
