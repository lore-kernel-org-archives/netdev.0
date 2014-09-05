From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netfilter: create audit records for ebtables replaces
Date: Fri,  5 Sep 2014 10:50:15 +0200
Message-ID: <1409907015-6145-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: nicolas.dichtel@6wind.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42795 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353AbaIEIue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 04:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is already done for x_tables (family AF_INET and AF_INET6), let's do it
for AF_BRIDGE also.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/bridge/netfilter/ebtables.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 6d69631b9f4d..4ba0c5c78778 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -26,6 +26,7 @@
 #include <asm/uaccess.h>
 #include <linux/smp.h>
 #include <linux/cpumask.h>
+#include <linux/audit.h>
 #include <net/sock.h>
 /* needed for logical [in,out]-dev filtering */
 #include "../br_private.h"
@@ -1126,6 +1127,20 @@ static int do_replace(struct net *net, const void __user *user,
 	}
 
 	ret = do_replace_finish(net, &tmp, newinfo);
+#ifdef CONFIG_AUDIT
+	if (audit_enabled) {
+		struct audit_buffer *ab;
+
+		ab = audit_log_start(current->audit_context, GFP_KERNEL,
+				     AUDIT_NETFILTER_CFG);
+		if (ab) {
+			audit_log_format(ab, "table=%s family=%u entries=%u",
+					 tmp.name, AF_BRIDGE,
+					 tmp.nentries);
+			audit_log_end(ab);
+		}
+	}
+#endif
 	if (ret == 0)
 		return ret;
 free_entries:
-- 
1.9.0
