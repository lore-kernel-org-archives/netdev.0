From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] net: Don't forget pr_fmt on net_dbg_ratelimited for CONFIG_DYNAMIC_DEBUG
Date: Wed, 15 Jun 2016 11:14:53 +0200
Message-ID: <20160615091453.29609-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Tim Bingham <tbingham@akamai.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:59231 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbcFOJPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 05:15:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The implementation of net_dbg_ratelimited in the CONFIG_DYNAMIC_DEBUG
case was added with 2c94b5373 ("net: Implement net_dbg_ratelimited() for
CONFIG_DYNAMIC_DEBUG case"). The implementation strategy was to take the
usual definition of the dynamic_pr_debug macro, but alter it by adding a
call to "net_ratelimit()" in the if statement. This is, in fact, the
correct approach.

However, while doing this, the author of the commit forgot to surround
fmt by pr_fmt, resulting in unprefixed log messages appearing in the
console. So, this commit adds back the pr_fmt(fmt) invocation, making
net_dbg_ratelimited properly consistent across DEBUG, no DEBUG, and
DYNAMIC_DEBUG cases, and bringing parity with the behavior of
dynamic_pr_debug as well.

Fixes: 2c94b5373 ("net: Implement net_dbg_ratelimited() for CONFIG_DYNAMIC_DEBUG case")
Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Tim Bingham <tbingham@akamai.com>
---
 include/linux/net.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 9aa49a0..25aa03b 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -251,7 +251,8 @@ do {									\
 	DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);			\
 	if (unlikely(descriptor.flags & _DPRINTK_FLAGS_PRINT) &&	\
 	    net_ratelimit())						\
-		__dynamic_pr_debug(&descriptor, fmt, ##__VA_ARGS__);	\
+		__dynamic_pr_debug(&descriptor, pr_fmt(fmt),		\
+		                   ##__VA_ARGS__);			\
 } while (0)
 #elif defined(DEBUG)
 #define net_dbg_ratelimited(fmt, ...)				\
-- 
2.8.4
