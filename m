From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] net: Refactor path selection in __ip_route_output_key
Date: Thu,  1 Oct 2015 08:27:25 -0700
Message-ID: <1443713247-11230-4-git-send-email-dsa@cumulusnetworks.com>
References: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34719 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756401AbbJAP1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:27:39 -0400
Received: by padhy16 with SMTP id hy16so77696933pad.1
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:27:39 -0700 (PDT)
In-Reply-To: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRF device needs same path selection following lookup to set source
address. Rather than duplicating code, move existing code into a
function that is exported to modules.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip_fib.h     |  2 ++
 net/ipv4/fib_semantics.c | 18 ++++++++++++++++++
 net/ipv4/route.c         | 13 +------------
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 727d6e9a9685..30469855edf5 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -321,6 +321,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 void fib_select_multipath(struct fib_result *res);
+void fib_select_path(struct net *net, struct fib_result *res,
+		     struct flowi4 *fl4);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 064bd3caaa4f..facba7ed27de 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1547,3 +1547,21 @@ void fib_select_multipath(struct fib_result *res)
 	spin_unlock_bh(&fib_multipath_lock);
 }
 #endif
+
+void fib_select_path(struct net *net, struct fib_result *res,
+		     struct flowi4 *fl4)
+{
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
+		fib_select_multipath(res);
+	else
+#endif
+	if (!res->prefixlen &&
+	    res->table->tb_num_default > 1 &&
+	    res->type == RTN_UNICAST && !fl4->flowi4_oif)
+		fib_select_default(fl4, res);
+
+	if (!fl4->saddr)
+		fl4->saddr = FIB_RES_PREFSRC(net, *res);
+}
+EXPORT_SYMBOL_GPL(fib_select_path);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1441de1550e6..747042504967 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2187,18 +2187,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		goto make_route;
 	}
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
-		fib_select_multipath(&res);
-	else
-#endif
-	if (!res.prefixlen &&
-	    res.table->tb_num_default > 1 &&
-	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
-		fib_select_default(fl4, &res);
-
-	if (!fl4->saddr)
-		fl4->saddr = FIB_RES_PREFSRC(net, res);
+	fib_select_path(net, &res, fl4);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4->flowi4_oif = dev_out->ifindex;
-- 
1.9.1
