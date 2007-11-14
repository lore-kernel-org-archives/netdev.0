From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter : struct xt_table_info diet
Date: Wed, 14 Nov 2007 16:47:35 +0100
Message-ID: <20071114164735.1ba04bc3.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44979 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbXKNPrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 10:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David & Patrick

Please find a patch against net-2.6.25

Thank you


[PATCH] netfilter : struct xt_table_info diet

Instead of using a big array of NR_CPUS entries, we can compute the size needed at runtime, using nr_cpu_ids

This should save some ram (especially on David's machines where NR_CPUS=4096 : 32 KB can be saved per table, and 64KB for dynamically allocated ones (because of slab/slub alignements) )

In particular, the 'bootstrap' tables are not any more static (in data section) but on stack as their
size is now very small.

This also should reduce the size used on stack in compat functions 
(get_info() declares an automatic variable, that could be bigger than kernel stack size for big NR_CPUS)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/linux/netfilter/x_tables.h |    5 ++++-
 net/ipv4/netfilter/arp_tables.c    |    4 ++--
 net/ipv4/netfilter/ip_tables.c     |   23 ++++++++++-------------
 net/ipv6/netfilter/ip6_tables.c    |    4 ++--
 net/netfilter/x_tables.c           |    2 +-
 5 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 9657c4e..e305f2d 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -269,9 +269,12 @@ struct xt_table_info
 	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* ipt_entry tables: one per CPU */
-	char *entries[NR_CPUS];
+	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
+	char *entries[1];
 };
 
+#define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
+			  + nr_cpu_ids * sizeof(char *))
 extern int xt_register_target(struct xt_target *target);
 extern void xt_unregister_target(struct xt_target *target);
 extern int xt_register_targets(struct xt_target *target, unsigned int n);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2909c92..ed3bd0b 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -811,7 +811,7 @@ static int do_replace(void __user *user, unsigned int len)
 		return -ENOPROTOOPT;
 
 	/* overflow check */
-	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
+	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
 			SMP_CACHE_BYTES)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
@@ -1090,7 +1090,7 @@ int arpt_register_table(struct arpt_table *table,
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	static struct xt_table_info bootstrap
+	struct xt_table_info bootstrap
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a99fe89..a2b1ec2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1090,7 +1090,8 @@ compat_calc_match(struct ipt_entry_match *m, int * size)
 	return 0;
 }
 
-static int compat_calc_entry(struct ipt_entry *e, struct xt_table_info *info,
+static int compat_calc_entry(struct ipt_entry *e,
+		const struct xt_table_info *info,
 		void *base, struct xt_table_info *newinfo)
 {
 	struct ipt_entry_target *t;
@@ -1118,7 +1119,7 @@ static int compat_calc_entry(struct ipt_entry *e, struct xt_table_info *info,
 	return 0;
 }
 
-static int compat_table_info(struct xt_table_info *info,
+static int compat_table_info(const struct xt_table_info *info,
 		struct xt_table_info *newinfo)
 {
 	void *loc_cpu_entry;
@@ -1127,13 +1128,9 @@ static int compat_table_info(struct xt_table_info *info,
 	if (!newinfo || !info)
 		return -EINVAL;
 
-	memset(newinfo, 0, sizeof(struct xt_table_info));
-	newinfo->size = info->size;
-	newinfo->number = info->number;
-	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
-		newinfo->hook_entry[i] = info->hook_entry[i];
-		newinfo->underflow[i] = info->underflow[i];
-	}
+	/* we dont care about newinfo->entries[] */
+	memcpy(newinfo, info, offsetof(struct xt_table_info, entries));
+	newinfo->initial_entries = 0;
 	loc_cpu_entry = info->entries[raw_smp_processor_id()];
 	return IPT_ENTRY_ITERATE(loc_cpu_entry, info->size,
 			compat_calc_entry, info, loc_cpu_entry, newinfo);
@@ -1327,7 +1324,7 @@ do_replace(void __user *user, unsigned int len)
 		return -ENOPROTOOPT;
 
 	/* overflow check */
-	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
+	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
 			SMP_CACHE_BYTES)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
@@ -1861,7 +1858,7 @@ compat_do_replace(void __user *user, unsigned int len)
 		return -ENOPROTOOPT;
 
 	/* overflow check */
-	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
+	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
 			SMP_CACHE_BYTES)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
@@ -2036,7 +2033,7 @@ compat_get_entries(struct compat_ipt_get_entries __user *uptr, int *len)
 		duprintf("t->private->number = %u\n",
 			 private->number);
 		ret = compat_table_info(private, &info);
-		if (!ret && get.size == info.size) {
+		if (!ret && get.size == info->size) {
 			ret = compat_copy_entries_to_user(private->size,
 						   t, uptr->entrytable);
 		} else if (!ret) {
@@ -2159,7 +2156,7 @@ int ipt_register_table(struct xt_table *table, const struct ipt_replace *repl)
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	static struct xt_table_info bootstrap
+	struct xt_table_info bootstrap
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index e1e87ef..429048f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1042,7 +1042,7 @@ do_replace(void __user *user, unsigned int len)
 		return -EFAULT;
 
 	/* overflow check */
-	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
+	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
 			SMP_CACHE_BYTES)
 		return -ENOMEM;
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
@@ -1339,7 +1339,7 @@ int ip6t_register_table(struct xt_table *table,
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	static struct xt_table_info bootstrap
+	struct xt_table_info bootstrap
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 	void *loc_cpu_entry;
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d9a3bde..862b27d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -495,7 +495,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
 	if ((SMP_ALIGN(size) >> PAGE_SHIFT) + 2 > num_physpages)
 		return NULL;
 
-	newinfo = kzalloc(sizeof(struct xt_table_info), GFP_KERNEL);
+	newinfo = kzalloc(XT_TABLE_INFO_SZ, GFP_KERNEL);
 	if (!newinfo)
 		return NULL;
 
