From: kaber@trash.net
Subject: [PATCH 2/2] netfilter: xtables: stackptr should be percpu
Date: Mon, 31 May 2010 18:14:47 +0200
Message-ID: <1275322487-19026-3-git-send-email-kaber@trash.net>
References: <1275322487-19026-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275322487-19026-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

commit f3c5c1bfd4 (netfilter: xtables: make ip_tables reentrant)
introduced a performance regression, because stackptr array is shared by
all cpus, adding cache line ping pongs. (16 cpus share a 64 bytes cache
line)

Fix this using alloc_percpu()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-By: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/x_tables.h |    2 +-
 net/ipv4/netfilter/ip_tables.c     |    2 +-
 net/ipv6/netfilter/ip6_tables.c    |    2 +-
 net/netfilter/x_tables.c           |   13 +++----------
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c00cc0c..24e5d01 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -397,7 +397,7 @@ struct xt_table_info {
 	 * @stacksize jumps (number of user chains) can possibly be made.
 	 */
 	unsigned int stacksize;
-	unsigned int *stackptr;
+	unsigned int __percpu *stackptr;
 	void ***jumpstack;
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 63958f3..4b6c5ca 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -336,7 +336,7 @@ ipt_do_table(struct sk_buff *skb,
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
-	stackptr   = &private->stackptr[cpu];
+	stackptr   = per_cpu_ptr(private->stackptr, cpu);
 	origptr    = *stackptr;
 
 	e = get_entry(table_base, private->hook_entry[hook]);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 6f517bd..9d2d68f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -363,7 +363,7 @@ ip6t_do_table(struct sk_buff *skb,
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
-	stackptr   = &private->stackptr[cpu];
+	stackptr   = per_cpu_ptr(private->stackptr, cpu);
 	origptr    = *stackptr;
 
 	e = get_entry(table_base, private->hook_entry[hook]);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 47b1e79..e34622f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -699,10 +699,8 @@ void xt_free_table_info(struct xt_table_info *info)
 		vfree(info->jumpstack);
 	else
 		kfree(info->jumpstack);
-	if (sizeof(unsigned int) * nr_cpu_ids > PAGE_SIZE)
-		vfree(info->stackptr);
-	else
-		kfree(info->stackptr);
+
+	free_percpu(info->stackptr);
 
 	kfree(info);
 }
@@ -753,14 +751,9 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 	unsigned int size;
 	int cpu;
 
-	size = sizeof(unsigned int) * nr_cpu_ids;
-	if (size > PAGE_SIZE)
-		i->stackptr = vmalloc(size);
-	else
-		i->stackptr = kmalloc(size, GFP_KERNEL);
+	i->stackptr = alloc_percpu(unsigned int);
 	if (i->stackptr == NULL)
 		return -ENOMEM;
-	memset(i->stackptr, 0, size);
 
 	size = sizeof(void **) * nr_cpu_ids;
 	if (size > PAGE_SIZE)
-- 
1.7.0.4

