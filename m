From: Peter Klausler <pmk@google.com>
Subject: [PATCH] net/openvswitch: replace memcmp() with specialized comparator
Date: Fri, 26 Apr 2013 17:46:32 -0400
Message-ID: <1367012792-25335-1-git-send-email-pmk@google.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Peter Klausler <pmk@google.com>
To: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:46194 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab3DZVq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 17:46:56 -0400
Received: by mail-qc0-f201.google.com with SMTP id o22so482244qcr.0
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 14:46:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tune flow table lookup in net/openvswitch, replacing a call to
the slow-but-safe memcmp() in lib/string.c with a key comparator
routine that presumes most comparisons will succeed.  Besides
avoiding an early-exit test on each iteration, it also compares
keys 4 or 8 bytes at a time on architectures that can load an
unaligned long efficiently.

On a 3.2GHz Xeon (5679) this patch reduces the minimum back-to-back
hot-cache latency of a 128-byte key comparison by 7x, from 130ns with
the default byte-at-a-time memcmp() in lib/string.c down to 17ns.

More important, replacing the default memcmp() with this specialized
routine speeds up openvswitch's packet rate by 10% in a closed-loop
benchmark that simply routes traffic from one tap device to another.

Signed-off-by: Peter Klausler <pmk@google.com>
---
 net/openvswitch/flow.c | 33 ++++++++++++++++++++++++++++++++-
 1 file changed, 32 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 67a2b78..d5facf6 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -764,6 +764,37 @@ u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len)
 	return jhash2((u32 *)key, DIV_ROUND_UP(key_len, sizeof(u32)), 0);
 }
 
+/*
+ * Key comparison routine, optimized for the common case of
+ * equality due to low average hash collision frequency
+ * (1.5 mean items per nonempty bucket when total table item
+ * count equals the number of buckets, which is when openvswitch
+ * expands its hash table).
+ */
+static bool equal_keys(const struct sw_flow_key *key1,
+		       const struct sw_flow_key *key2,
+		       size_t key_len)
+{
+	const char *cp1 = (const char *)key1;
+	const char *cp2 = (const char *)key2;
+	long diffs = 0;
+
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	{
+		const long *lp1 = (const long *)cp1;
+		const long *lp2 = (const long *)cp2;
+		for (; key_len >= sizeof(long); key_len -= sizeof(long))
+			diffs |= *lp1++ ^ *lp2++;
+		cp1 = (const char *)lp1;
+		cp2 = (const char *)lp2;
+	}
+#endif
+
+	while (key_len-- > 0)
+		diffs |= *cp1++ ^ *cp2++;
+	return diffs == 0;
+}
+
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
 				struct sw_flow_key *key, int key_len)
 {
@@ -777,7 +808,7 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
 	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
 
 		if (flow->hash == hash &&
-		    !memcmp(&flow->key, key, key_len)) {
+		    equal_keys(&flow->key, key, key_len)) {
 			return flow;
 		}
 	}
-- 
1.8.2.1
