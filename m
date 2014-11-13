From: Pranith Kumar <bobby.prani@gmail.com>
Subject: [PATCH 15/16] netfilter: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 14:24:21 -0500
Message-ID: <1415906662-4576-16-git-send-email-bobby.prani@gmail.com>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Cc: paulmck@linux.vnet.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recently lockless_dereference() was added which can be used in place of
hard-coding smp_read_barrier_depends(). The following PATCH makes the change.

Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>
---
 net/ipv4/netfilter/arp_tables.c | 3 +--
 net/ipv4/netfilter/ip_tables.c  | 3 +--
 net/ipv6/netfilter/ip6_tables.c | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f95b6f9..fc7533d 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -270,12 +270,11 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
-	private = table->private;
 	/*
 	 * Ensure we load private-> members after we've fetched the base
 	 * pointer.
 	 */
-	smp_read_barrier_depends();
+	private = lockless_dereference(table->private);
 	table_base = private->entries[smp_processor_id()];
 
 	e = get_entry(table_base, private->hook_entry[hook]);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 99e810f..e0fd044 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -325,13 +325,12 @@ ipt_do_table(struct sk_buff *skb,
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
-	private = table->private;
 	cpu        = smp_processor_id();
 	/*
 	 * Ensure we load private-> members after we've fetched the base
 	 * pointer.
 	 */
-	smp_read_barrier_depends();
+	private = lockless_dereference(table->private);
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
 	stackptr   = per_cpu_ptr(private->stackptr, cpu);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index e080fbb..0459d6a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -348,12 +348,11 @@ ip6t_do_table(struct sk_buff *skb,
 
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
-	private = table->private;
 	/*
 	 * Ensure we load private-> members after we've fetched the base
 	 * pointer.
 	 */
-	smp_read_barrier_depends();
+	private = lockless_dereference(table->private);
 	cpu        = smp_processor_id();
 	table_base = private->entries[cpu];
 	jumpstack  = (struct ip6t_entry **)private->jumpstack[cpu];
-- 
1.9.1
