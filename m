From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-rps: fixes for rps flow limit
Date: Thu, 13 Jun 2013 15:29:38 -0400
Message-ID: <1371151778-14697-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:65144 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab3FMT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 15:29:40 -0400
Received: by mail-vb0-f74.google.com with SMTP id w16so537402vbb.5
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 12:29:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caught by sparse:
- __rcu: missing annotation to sd->flow_limit
- __user: direct access in cpumask_scnprintf

Also
- add endline character when printing bitmap if room in buffer
- avoid bucket overflow by reducing FLOW_LIMIT_HISTORY

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
(first item)

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

The last item warrants some explanation. The hashtable buckets are
subject to overflow if FLOW_LIMIT_HISTORY is larger than or equal
to bucket size, since all packets may end up in a single bucket. The
current (rather arbitrary) history value of 256 happens to match the
buffer size (u8).

As a result, with a single flow, the first 128 packets are accepted
(correct), the second 128 packets dropped (correct) and then the
history[] array has filled, so that each subsequent new packet
causes an increment in the bucket for new_flow plus a decrement
for old_flow: a steady state.

This is fine if packets are dropped, as the steady state goes away
as soon as a mix of traffic reappears. But, because the 256th packet
overflowed the bucket to 0: no packets are dropped.

Instead of explicitly adding an overflow check, this patch changes
FLOW_LIMIT_HISTORY to never be able to overflow a single bucket.
---
 include/linux/netdevice.h  |  4 ++--
 net/core/sysctl_net_core.c | 19 ++++++++++++++++---
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e5d6557..8c9fcc4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1840,7 +1840,7 @@ static inline int unregister_gifconf(unsigned int family)
 }
 
 #ifdef CONFIG_NET_FLOW_LIMIT
-#define FLOW_LIMIT_HISTORY	(1 << 8)	/* must be ^2 */
+#define FLOW_LIMIT_HISTORY	(1 << 7)  /* must be ^2 and !overflow buckets */
 struct sd_flow_limit {
 	u64			count;
 	unsigned int		num_buckets;
@@ -1883,7 +1883,7 @@ struct softnet_data {
 	struct napi_struct	backlog;
 
 #ifdef CONFIG_NET_FLOW_LIMIT
-	struct sd_flow_limit	*flow_limit;
+	struct sd_flow_limit __rcu *flow_limit;
 #endif
 };
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 637a42e..78c746e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -132,6 +132,8 @@ static int flow_limit_cpu_sysctl(struct ctl_table *table, int write,
 write_unlock:
 		mutex_unlock(&flow_limit_update_mutex);
 	} else {
+		char kbuf[128];
+
 		if (*ppos || !*lenp) {
 			*lenp = 0;
 			goto done;
@@ -146,9 +148,20 @@ write_unlock:
 		}
 		rcu_read_unlock();
 
-		len = cpumask_scnprintf(buffer, *lenp, mask);
-		*lenp = len + 1;
-		*ppos += len + 1;
+		len = min(sizeof(kbuf) - 1, *lenp);
+		len = cpumask_scnprintf(kbuf, len, mask);
+		if (!len) {
+			*lenp = 0;
+			goto done;
+		}
+		if (len < *lenp)
+			kbuf[len++] = '\n';
+		if (copy_to_user(buffer, kbuf, len)) {
+			ret = -EFAULT;
+			goto done;
+		}
+		*lenp = len;
+		*ppos += len;
 	}
 
 done:
-- 
1.8.3
