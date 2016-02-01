From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v3 1/4] net/core: relax BUILD_BUG_ON in netdev_stats_to_stats64
Date: Mon,  1 Feb 2016 18:51:04 -0500
Message-ID: <1454370667-2328-2-git-send-email-jarod@redhat.com>
References: <1453996188-29965-1-git-send-email-jarod@redhat.com>
 <1454370667-2328-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbcBAXvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 18:51:13 -0500
In-Reply-To: <1454370667-2328-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netdev_stats_to_stats64 function copies the deprecated
net_device_stats format stats into rtnl_link_stats64 for legacy support
purposes, but with the BUILD_BUG_ON as it was, it wasn't possible to
extend rtnl_link_stats64 without also extending net_device_stats. Relax
the BUILD_BUG_ON to only require that rtnl_link_stats64 is larger, and
zero out all the stat counters that aren't present in net_device_stats.

CC: Eric Dumazet <edumazet@google.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/core/dev.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..65863e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7253,24 +7253,31 @@ void netdev_run_todo(void)
 	}
 }
 
-/* Convert net_device_stats to rtnl_link_stats64.  They have the same
- * fields in the same order, with only the type differing.
+/* Convert net_device_stats to rtnl_link_stats64. rtnl_link_stats64 has
+ * all the same fields in the same order as net_device_stats, with only
+ * the type differing, but rtnl_link_stats64 may have additional fields
+ * at the end for newer counters.
  */
 void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 			     const struct net_device_stats *netdev_stats)
 {
 #if BITS_PER_LONG == 64
-	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
+	BUILD_BUG_ON(sizeof(*stats64) < sizeof(*netdev_stats));
 	memcpy(stats64, netdev_stats, sizeof(*stats64));
+	/* zero out counters that only exist in rtnl_link_stats64 */
+	memset((char *)stats64 + sizeof(*netdev_stats), 0,
+	       sizeof(*stats64) - sizeof(*netdev_stats));
 #else
-	size_t i, n = sizeof(*stats64) / sizeof(u64);
+	size_t i, n = sizeof(*netdev_stats) / sizeof(unsigned long);
 	const unsigned long *src = (const unsigned long *)netdev_stats;
 	u64 *dst = (u64 *)stats64;
 
-	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
-		     sizeof(*stats64) / sizeof(u64));
+	BUILD_BUG_ON(n > sizeof(*stats64) / sizeof(u64));
 	for (i = 0; i < n; i++)
 		dst[i] = src[i];
+	/* zero out counters that only exist in rtnl_link_stats64 */
+	memset((char *)stats64 + n * sizeof(u64), 0,
+	       sizeof(*stats64) - n * sizeof(u64));
 #endif
 }
 EXPORT_SYMBOL(netdev_stats_to_stats64);
-- 
1.8.3.1
