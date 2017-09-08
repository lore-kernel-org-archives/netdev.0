From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter: xt_hashlimit: fix build error caused by 64bit division
Date: Thu,  7 Sep 2017 22:14:45 -0400
Message-ID: <1504836885-29088-1-git-send-email-vpai@akamai.com>
Cc: kadlec@blackhole.kfki.hu, johunt@akamai.com, fw@strlen.de,
        netdev@vger.kernel.org, pai.vishwain@gmail.com, mingo@kernel.org,
        ilubashe@akamai.com, bp@alien8.de, luto@kernel.org, x86@kernel.org,
        linux-kernel@vger.kernel.org, brgerst@gmail.com,
        andrew.cooper3@citrix.com, jgross@suse.com,
        boris.ostrovsky@oracle.com, keescook@chromium.org,
        akpm@linux-foundation.org, arnd@arndb.de
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        torvalds@linux-foundation.org, davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

64bit division causes build/link errors on 32bit architectures. It
prints out error messages like:

ERROR: "__aeabi_uldivmod" [net/netfilter/xt_hashlimit.ko] undefined!

The value of avg passed through by userspace in BYTE mode cannot exceed
U32_MAX. Which means 64bit division in user2rate_bytes is unnecessary.

This fix changes the size of both the param as well as return type on
user2rate_bytes to u32.

Since anything greater than U32_MAX is an invalid input we error out in
hashlimit_mt_check_common() when this is the case.

Also fixed warning about const pointer conversion in cfg_copy().

Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 net/netfilter/xt_hashlimit.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10d4823..1d818f1 100644
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
+static u32 user2rate_bytes(u32 user)
 {
-	u64 r;
+	u32 r;
 
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
1.9.1

