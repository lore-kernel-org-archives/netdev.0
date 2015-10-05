From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/5] net: Refactor path selection in __ip_route_output_key_hash
Date: Mon,  5 Oct 2015 08:51:25 -0700
Message-ID: <1444060287-11024-4-git-send-email-dsa@cumulusnetworks.com>
References: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34602 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbJEPvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:51:39 -0400
Received: by padhy16 with SMTP id hy16so40309667pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:51:38 -0700 (PDT)
In-Reply-To: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRF device needs the same path selection following lookup to set source
address. Rather than duplicating code, move existing code into a
function that is exported to modules.

Code move only; no functional change.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip_fib.h     |  2 ++
 net/ipv4/fib_semantics.c | 21 +++++++++++++++++++++
 net/ipv4/route.c         | 16 +---------------
 3 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 7a51fd8d99e4..ac5c6e80586a 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -329,6 +329,8 @@ static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
 }
 
 void fib_select_multipath(struct fib_result *res, int hash);
+void fib_select_path(struct net *net, struct fib_result *res,
+		     struct flowi4 *fl4, int mp_hash);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 0c49d2f3bbc0..caf994c66d59 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1557,3 +1557,24 @@ void fib_select_multipath(struct fib_result *res, int hash)
 	res->nh_sel = 0;
 }
 #endif
+
+void fib_select_path(struct net *net, struct fib_result *res,
+		     struct flowi4 *fl4, int mp_hash)
+{
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
+		if (mp_hash < 0)
+			mp_hash = fib_multipath_hash(fl4->saddr, fl4->daddr);
+		fib_select_multipath(res, mp_hash);
+	}
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
index 54297d3a0559..54e6f456a760 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2238,21 +2238,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		goto make_route;
 	}
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
-		if (mp_hash < 0)
-			mp_hash = fib_multipath_hash(fl4->saddr, fl4->daddr);
-		fib_select_multipath(&res, mp_hash);
-	}
-	else
-#endif
-	if (!res.prefixlen &&
-	    res.table->tb_num_default > 1 &&
-	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
-		fib_select_default(fl4, &res);
-
-	if (!fl4->saddr)
-		fl4->saddr = FIB_RES_PREFSRC(net, res);
+	fib_select_path(net, &res, fl4, mp_hash);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4->flowi4_oif = dev_out->ifindex;
-- 
1.9.1
