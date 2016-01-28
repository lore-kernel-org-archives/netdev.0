From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v3 1/4] net/core: relax BUILD_BUG_ON in netdev_stats_to_stats64
Date: Thu, 28 Jan 2016 11:22:42 -0500
Message-ID: <1453998162-30136-1-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Eric Dumazet <edumazet@google.com>, netdev@ger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netdev_stats_to_stats64 function copies the deprecated
net_device_stats format stats into rtnl_link_stats64 for legacy support
purposes, but with the BUILD_BUG_ON as it was, it wasn't possible to
extend rtnl_link_stats64 without also extending net_device_stats. Relax
the BUILD_BUG_ON to only require that rtnl_link_stats64 is larger, and
zero out all the stat counters that aren't present in net_device_stats.

CC: Eric Dumazet <edumazet@google.com>
CC: netdev@ger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
v3: get the CC list right, moron

 net/core/dev.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..575a7df 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7253,25 +7253,30 @@ void netdev_run_todo(void)
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
 #else
 	size_t i, n = sizeof(*stats64) / sizeof(u64);
 	const unsigned long *src = (const unsigned long *)netdev_stats;
 	u64 *dst = (u64 *)stats64;
 
-	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
+	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) >
 		     sizeof(*stats64) / sizeof(u64));
 	for (i = 0; i < n; i++)
 		dst[i] = src[i];
 #endif
+	/* zero out counters that only exist in rtnl_link_stats64 */
+	memset((char *)stats64 + sizeof(*netdev_stats), 0,
+	       sizeof(*stats64) - sizeof(*netdev_stats));
 }
 EXPORT_SYMBOL(netdev_stats_to_stats64);
 
-- 
1.8.3.1
