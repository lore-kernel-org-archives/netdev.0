From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/50] netfilter: x_tables: pack percpu counter allocations
Date: Wed,  7 Dec 2016 22:52:31 +0100
Message-ID: <1481147576-5690-26-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

instead of allocating each xt_counter individually, allocate 4k chunks
and then use these for counter allocation requests.

This should speed up rule evaluation by increasing data locality,
also speeds up ruleset loading because we reduce calls to the percpu
allocator.

As Eric points out we can't use PAGE_SIZE, page_allocator would fail on
arches with 64k page size.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |  7 ++++++-
 net/ipv4/netfilter/arp_tables.c    |  9 ++++++---
 net/ipv4/netfilter/ip_tables.c     |  9 ++++++---
 net/ipv6/netfilter/ip6_tables.c    |  9 ++++++---
 net/netfilter/x_tables.c           | 33 ++++++++++++++++++++++++---------
 5 files changed, 48 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 05a94bd32c55..5117e4d2ddfa 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -403,8 +403,13 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	return ret;
 }
 
+struct xt_percpu_counter_alloc_state {
+	unsigned int off;
+	const char __percpu *mem;
+};
 
-bool xt_percpu_counter_alloc(struct xt_counters *counters);
+bool xt_percpu_counter_alloc(struct xt_percpu_counter_alloc_state *state,
+			     struct xt_counters *counter);
 void xt_percpu_counter_free(struct xt_counters *cnt);
 
 static inline struct xt_counters *
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 808deb275ceb..1258a9ab62ef 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -411,13 +411,14 @@ static inline int check_target(struct arpt_entry *e, const char *name)
 }
 
 static inline int
-find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
+find_check_entry(struct arpt_entry *e, const char *name, unsigned int size,
+		 struct xt_percpu_counter_alloc_state *alloc_state)
 {
 	struct xt_entry_target *t;
 	struct xt_target *target;
 	int ret;
 
-	if (!xt_percpu_counter_alloc(&e->counters))
+	if (!xt_percpu_counter_alloc(alloc_state, &e->counters))
 		return -ENOMEM;
 
 	t = arpt_get_target(e);
@@ -525,6 +526,7 @@ static inline void cleanup_entry(struct arpt_entry *e)
 static int translate_table(struct xt_table_info *newinfo, void *entry0,
 			   const struct arpt_replace *repl)
 {
+	struct xt_percpu_counter_alloc_state alloc_state = { 0 };
 	struct arpt_entry *iter;
 	unsigned int *offsets;
 	unsigned int i;
@@ -587,7 +589,8 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, repl->name, repl->size);
+		ret = find_check_entry(iter, repl->name, repl->size,
+				       &alloc_state);
 		if (ret != 0)
 			break;
 		++i;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a48430d3420f..308b456723f0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -531,7 +531,8 @@ static int check_target(struct ipt_entry *e, struct net *net, const char *name)
 
 static int
 find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
-		 unsigned int size)
+		 unsigned int size,
+		 struct xt_percpu_counter_alloc_state *alloc_state)
 {
 	struct xt_entry_target *t;
 	struct xt_target *target;
@@ -540,7 +541,7 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
 
-	if (!xt_percpu_counter_alloc(&e->counters))
+	if (!xt_percpu_counter_alloc(alloc_state, &e->counters))
 		return -ENOMEM;
 
 	j = 0;
@@ -676,6 +677,7 @@ static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		const struct ipt_replace *repl)
 {
+	struct xt_percpu_counter_alloc_state alloc_state = { 0 };
 	struct ipt_entry *iter;
 	unsigned int *offsets;
 	unsigned int i;
@@ -735,7 +737,8 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, net, repl->name, repl->size);
+		ret = find_check_entry(iter, net, repl->name, repl->size,
+				       &alloc_state);
 		if (ret != 0)
 			break;
 		++i;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index a5a92083fd62..d56d8ac09a94 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -562,7 +562,8 @@ static int check_target(struct ip6t_entry *e, struct net *net, const char *name)
 
 static int
 find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
-		 unsigned int size)
+		 unsigned int size,
+		 struct xt_percpu_counter_alloc_state *alloc_state)
 {
 	struct xt_entry_target *t;
 	struct xt_target *target;
@@ -571,7 +572,7 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
 
-	if (!xt_percpu_counter_alloc(&e->counters))
+	if (!xt_percpu_counter_alloc(alloc_state, &e->counters))
 		return -ENOMEM;
 
 	j = 0;
@@ -705,6 +706,7 @@ static int
 translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		const struct ip6t_replace *repl)
 {
+	struct xt_percpu_counter_alloc_state alloc_state = { 0 };
 	struct ip6t_entry *iter;
 	unsigned int *offsets;
 	unsigned int i;
@@ -764,7 +766,8 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, net, repl->name, repl->size);
+		ret = find_check_entry(iter, net, repl->name, repl->size,
+				       &alloc_state);
 		if (ret != 0)
 			break;
 		++i;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index be5e83047594..f6ce4a7036e6 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -40,6 +40,7 @@ MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("{ip,ip6,arp,eb}_tables backend module");
 
 #define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
+#define XT_PCPU_BLOCK_SIZE 4096
 
 struct compat_delta {
 	unsigned int offset; /* offset in kernel */
@@ -1618,6 +1619,7 @@ EXPORT_SYMBOL_GPL(xt_proto_fini);
 /**
  * xt_percpu_counter_alloc - allocate x_tables rule counter
  *
+ * @state: pointer to xt_percpu allocation state
  * @counter: pointer to counter struct inside the ip(6)/arpt_entry struct
  *
  * On SMP, the packet counter [ ip(6)t_entry->counters.pcnt ] will then
@@ -1626,21 +1628,34 @@ EXPORT_SYMBOL_GPL(xt_proto_fini);
  * Rule evaluation needs to use xt_get_this_cpu_counter() helper
  * to fetch the real percpu counter.
  *
+ * To speed up allocation and improve data locality, a 4kb block is
+ * allocated.
+ *
+ * xt_percpu_counter_alloc_state contains the base address of the
+ * allocated page and the current sub-offset.
+ *
  * returns false on error.
  */
-bool xt_percpu_counter_alloc(struct xt_counters *counter)
+bool xt_percpu_counter_alloc(struct xt_percpu_counter_alloc_state *state,
+			     struct xt_counters *counter)
 {
-	void __percpu *res;
+	BUILD_BUG_ON(XT_PCPU_BLOCK_SIZE < (sizeof(*counter) * 2));
 
 	if (nr_cpu_ids <= 1)
 		return true;
 
-	res = __alloc_percpu(sizeof(struct xt_counters),
-			     sizeof(struct xt_counters));
-	if (!res)
-		return false;
-
-	counter->pcnt = (__force unsigned long)res;
+	if (!state->mem) {
+		state->mem = __alloc_percpu(XT_PCPU_BLOCK_SIZE,
+					    XT_PCPU_BLOCK_SIZE);
+		if (!state->mem)
+			return false;
+	}
+	counter->pcnt = (__force unsigned long)(state->mem + state->off);
+	state->off += sizeof(*counter);
+	if (state->off > (XT_PCPU_BLOCK_SIZE - sizeof(*counter))) {
+		state->mem = NULL;
+		state->off = 0;
+	}
 	return true;
 }
 EXPORT_SYMBOL_GPL(xt_percpu_counter_alloc);
@@ -1649,7 +1664,7 @@ void xt_percpu_counter_free(struct xt_counters *counters)
 {
 	unsigned long pcnt = counters->pcnt;
 
-	if (nr_cpu_ids > 1)
+	if (nr_cpu_ids > 1 && (pcnt & (XT_PCPU_BLOCK_SIZE - 1)) == 0)
 		free_percpu((void __percpu *)pcnt);
 }
 EXPORT_SYMBOL_GPL(xt_percpu_counter_free);
-- 
2.1.4

