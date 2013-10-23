From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: x_tables: fix ordering of jumpstack allocation and table update
Date: Wed, 23 Oct 2013 11:15:24 +0200
Message-ID: <1382519724-3953-4-git-send-email-pablo@netfilter.org>
References: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36895 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab3JWJPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 05:15:35 -0400
In-Reply-To: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>

During kernel stability testing on an SMP ARMv7 system, Yalin Wang
reported the following panic from the netfilter code:

  1fe0: 0000001c 5e2d3b10 4007e779 4009e110 60000010 00000032 ff565656 ff545454
  [<c06c48dc>] (ipt_do_table+0x448/0x584) from [<c0655ef0>] (nf_iterate+0x48/0x7c)
  [<c0655ef0>] (nf_iterate+0x48/0x7c) from [<c0655f7c>] (nf_hook_slow+0x58/0x104)
  [<c0655f7c>] (nf_hook_slow+0x58/0x104) from [<c0683bbc>] (ip_local_deliver+0x88/0xa8)
  [<c0683bbc>] (ip_local_deliver+0x88/0xa8) from [<c0683718>] (ip_rcv_finish+0x418/0x43c)
  [<c0683718>] (ip_rcv_finish+0x418/0x43c) from [<c062b1c4>] (__netif_receive_skb+0x4cc/0x598)
  [<c062b1c4>] (__netif_receive_skb+0x4cc/0x598) from [<c062b314>] (process_backlog+0x84/0x158)
  [<c062b314>] (process_backlog+0x84/0x158) from [<c062de84>] (net_rx_action+0x70/0x1dc)
  [<c062de84>] (net_rx_action+0x70/0x1dc) from [<c0088230>] (__do_softirq+0x11c/0x27c)
  [<c0088230>] (__do_softirq+0x11c/0x27c) from [<c008857c>] (do_softirq+0x44/0x50)
  [<c008857c>] (do_softirq+0x44/0x50) from [<c0088614>] (local_bh_enable_ip+0x8c/0xd0)
  [<c0088614>] (local_bh_enable_ip+0x8c/0xd0) from [<c06b0330>] (inet_stream_connect+0x164/0x298)
  [<c06b0330>] (inet_stream_connect+0x164/0x298) from [<c061d68c>] (sys_connect+0x88/0xc8)
  [<c061d68c>] (sys_connect+0x88/0xc8) from [<c000e340>] (ret_fast_syscall+0x0/0x30)
  Code: 2a000021 e59d2028 e59de01c e59f011c (e7824103)
  ---[ end trace da227214a82491bd ]---
  Kernel panic - not syncing: Fatal exception in interrupt

This comes about because CPU1 is executing xt_replace_table in response
to a setsockopt syscall, resulting in:

	ret = xt_jumpstack_alloc(newinfo);
		--> newinfo->jumpstack = kzalloc(size, GFP_KERNEL);

	[...]

	table->private = newinfo;
	newinfo->initial_entries = private->initial_entries;

Meanwhile, CPU0 is handling the network receive path and ends up in
ipt_do_table, resulting in:

	private = table->private;

	[...]

	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];

On weakly ordered memory architectures, the writes to table->private
and newinfo->jumpstack from CPU1 can be observed out of order by CPU0.
Furthermore, on architectures which don't respect ordering of address
dependencies (i.e. Alpha), the reads from CPU0 can also be re-ordered.

This patch adds an smp_wmb() before the assignment to table->private
(which is essentially publishing newinfo) to ensure that all writes to
newinfo will be observed before plugging it into the table structure.
A dependent-read barrier is also added on the consumer sides, to ensure
the same ordering requirements are also respected there.

Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Reported-by: Wang, Yalin <Yalin.Wang@sonymobile.com>
Tested-by: Wang, Yalin <Yalin.Wang@sonymobile.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c |    5 +++++
 net/ipv4/netfilter/ip_tables.c  |    5 +++++
 net/ipv6/netfilter/ip6_tables.c |    5 +++++
 net/netfilter/x_tables.c        |    7 ++++++-
 4 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 85a4f21..59da7cd 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -271,6 +271,11 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
 	private = table->private;
+	/*
+	 * Ensure we load private-> members after we've fetched the base
+	 * pointer.
+	 */
+	smp_read_barrier_depends();
 	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d23118d..718dfbd 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -327,6 +327,11 @@ ipt_do_table(struct sk_buff *skb,
 	addend = xt_write_recseq_begin();
 	private = table->private;
 	cpu        = smp_processor_id();
+	/*
+	 * Ensure we load private-> members after we've fetched the base
+	 * pointer.
+	 */
+	smp_read_barrier_depends();
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
 	stackptr   = per_cpu_ptr(private->stackptr, cpu);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 44400c2..710238f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -349,6 +349,11 @@ ip6t_do_table(struct sk_buff *skb,
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
 	private = table->private;
+	/*
+	 * Ensure we load private-> members after we've fetched the base
+	 * pointer.
+	 */
+	smp_read_barrier_depends();
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8b03028..227aa11 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -845,8 +845,13 @@ xt_replace_table(struct xt_table *table,
 		return NULL;
 	}
 
-	table->private = newinfo;
 	newinfo->initial_entries = private->initial_entries;
+	/*
+	 * Ensure contents of newinfo are visible before assigning to
+	 * private.
+	 */
+	smp_wmb();
+	table->private = newinfo;
 
 	/*
 	 * Even though table entries have now been swapped, other CPU's
-- 
1.7.10.4
