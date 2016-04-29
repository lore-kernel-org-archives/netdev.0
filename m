From: Tim Bingham <tbingham@akamai.com>
Subject: [PATCH] net: Implement net_dbg_ratelimited() for CONFIG_DYNAMIC_DEBUG case
Date: Fri, 29 Apr 2016 13:30:23 -0400
Message-ID: <1461951023-14311-1-git-send-email-tbingham@akamai.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Tim Bingham <tbingham@akamai.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:21429 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752463AbcD2RkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 13:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to commit d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op
when !DEBUG") the implementation of net_dbg_ratelimited() was buggy
for both the DEBUG and CONFIG_DYNAMIC_DEBUG cases.

The bug was that net_ratelimit() was being called and, despite
returning true, nothing was being printed to the console. This
resulted in messages like the following -

"net_ratelimit: %d callbacks suppressed"

with no other output nearby.

After commit d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op when
!DEBUG") the bug is fixed for the DEBUG case. However, there's no
output at all for CONFIG_DYNAMIC_DEBUG case.

This patch restores debug output (if enabled) for the
CONFIG_DYNAMIC_DEBUG case.

Add a definition of net_dbg_ratelimited() for the CONFIG_DYNAMIC_DEBUG
case. The implementation takes care to check that dynamic debugging is
enabled before calling net_ratelimit().

Fixes: d92cff89a0c8 ("net_dbg_ratelimited: turn into no-op when !DEBUG")
Signed-off-by: Tim Bingham <tbingham@akamai.com>
---
 include/linux/net.h | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 49175e4..f840d77 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -246,7 +246,15 @@ do {								\
 	net_ratelimited_function(pr_warn, fmt, ##__VA_ARGS__)
 #define net_info_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_info, fmt, ##__VA_ARGS__)
-#if defined(DEBUG)
+#if defined(CONFIG_DYNAMIC_DEBUG)
+#define net_dbg_ratelimited(fmt, ...)					\
+do {									\
+	DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);			\
+	if (unlikely(descriptor.flags & _DPRINTK_FLAGS_PRINT) &&	\
+	    net_ratelimit())						\
+		__dynamic_pr_debug(&descriptor, fmt, ##__VA_ARGS__);	\
+} while (0)
+#elif defined(DEBUG)
 #define net_dbg_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
 #else
-- 
1.9.1
