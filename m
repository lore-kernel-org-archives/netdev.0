From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: xt_hashlimit: fix build error caused by 64bit division
Date: Fri,  8 Sep 2017 19:45:48 +0200
Message-ID: <1504892748-1605-10-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54512 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756756AbdIHRqG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:46:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 01CF18D050B
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:35 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DD49DB5026
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:34 +0200 (CEST)
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishwanath Pai <vpai@akamai.com>

64bit division causes build/link errors on 32bit architectures. It
prints out error messages like:

ERROR: "__aeabi_uldivmod" [net/netfilter/xt_hashlimit.ko] undefined!

The value of avg passed through by userspace in BYTE mode cannot exceed
U32_MAX. Which means 64bit division in user2rate_bytes is unnecessary.
To fix this I have changed the type of param 'user' to u32.

Since anything greater than U32_MAX is an invalid input we error out in
hashlimit_mt_check_common() when this is the case.

Changes in v2:
	Making return type as u32 would cause an overflow for small
	values of 'user' (for example 2, 3 etc). To avoid this I bumped up
	'r' to u64 again as well as the return type. This is OK since the
	variable that stores the result is u64. We still avoid 64bit
	division here since 'user' is u32.

Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 962ea4a63d9f..5da8746f7b88 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -35,6 +35,7 @@
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter/xt_hashlimit.h>
 #include <linux/mutex.h>
+#include <linux/kernel.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
@@ -527,12 +528,12 @@ static u64 user2rate(u64 user)
 	}
 }
 
-static u64 user2rate_bytes(u64 user)
+static u64 user2rate_bytes(u32 user)
 {
 	u64 r;
 
-	r = user ? 0xFFFFFFFFULL / user : 0xFFFFFFFFULL;
-	r = (r - 1) << 4;
+	r = user ? U32_MAX / user : U32_MAX;
+	r = (r - 1) << XT_HASHLIMIT_BYTE_SHIFT;
 	return r;
 }
 
@@ -588,7 +589,8 @@ static void rateinfo_init(struct dsthash_ent *dh,
 		dh->rateinfo.prev_window = 0;
 		dh->rateinfo.current_rate = 0;
 		if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
-			dh->rateinfo.rate = user2rate_bytes(hinfo->cfg.avg);
+			dh->rateinfo.rate =
+				user2rate_bytes((u32)hinfo->cfg.avg);
 			if (hinfo->cfg.burst)
 				dh->rateinfo.burst =
 					hinfo->cfg.burst * dh->rateinfo.rate;
@@ -870,7 +872,7 @@ static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 
 	/* Check for overflow. */
 	if (revision >= 3 && cfg->mode & XT_HASHLIMIT_RATE_MATCH) {
-		if (cfg->avg == 0) {
+		if (cfg->avg == 0 || cfg->avg > U32_MAX) {
 			pr_info("hashlimit invalid rate\n");
 			return -ERANGE;
 		}
-- 
2.1.4
