From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: x_tables: align per cpu xt_counter
Date: Fri, 19 Jun 2015 19:17:40 +0200
Message-ID: <1434734269-4545-4-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Let's force a 16 bytes alignment on xt_counter percpu allocations,
so that bytes and packets sit in same cache line.

xt_counter being exported to user space, we cannot add __align(16) on
the structure itself.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 95693c4..1c97a22 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -356,7 +356,8 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
  * so nothing needs to be done there.
  *
  * xt_percpu_counter_alloc returns the address of the percpu
- * counter, or 0 on !SMP.
+ * counter, or 0 on !SMP. We force an alignment of 16 bytes
+ * so that bytes/packets share a common cache line.
  *
  * Hence caller must use IS_ERR_VALUE to check for error, this
  * allows us to return 0 for single core systems without forcing
@@ -365,7 +366,8 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 static inline u64 xt_percpu_counter_alloc(void)
 {
 	if (nr_cpu_ids > 1) {
-		void __percpu *res = alloc_percpu(struct xt_counters);
+		void __percpu *res = __alloc_percpu(sizeof(struct xt_counters),
+						    sizeof(struct xt_counters));
 
 		if (res == NULL)
 			return (u64) -ENOMEM;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
