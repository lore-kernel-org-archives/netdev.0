From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netfilter: create audit records for ebtables replaces
Date: Mon,  8 Sep 2014 14:11:45 +0200
Message-ID: <1410178305-28800-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20140907160728.GA4589@salvia>
Cc: nicolas.dichtel@6wind.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51744 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbaIHMLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 08:11:50 -0400
In-Reply-To: <20140907160728.GA4589@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is already done for x_tables (family AF_INET and AF_INET6), let's do it
for AF_BRIDGE also.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: move audit chunks to do_replace_finish()

 net/bridge/netfilter/ebtables.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 6d69631b9f4d..d9a8c05d995d 100644
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
@@ -1058,6 +1059,20 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 	vfree(table);
 
 	vfree(counterstmp);
+
+#ifdef CONFIG_AUDIT
+	if (audit_enabled) {
+		struct audit_buffer *ab;
+
+		ab = audit_log_start(current->audit_context, GFP_KERNEL,
+				     AUDIT_NETFILTER_CFG);
+		if (ab) {
+			audit_log_format(ab, "table=%s family=%u entries=%u",
+					 repl->name, AF_BRIDGE, repl->nentries);
+			audit_log_end(ab);
+		}
+	}
+#endif
 	return ret;
 
 free_unlock:
-- 
1.9.0
