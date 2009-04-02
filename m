From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [netfilter bug] BUG: using smp_processor_id() in preemptible
	[00000000] code: ssh/9115, caller is ipt_do_table+0xc8/0x559
Date: Thu, 2 Apr 2009 22:32:20 +0200
Message-ID: <20090402203220.GA30375@elte.hu>
References: <20090402200128.GA21805@elte.hu> <49D51D86.9030906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D51D86.9030906@cosmosbay.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> David put into its tree fix for that a few hours ago
> 
> commit fa9a86ddc8ecd2830a5e773facc250f110300ae7
> 
> (netfilter: iptables: lock free counters) forgot to disable BH
> in arpt_do_table(), ipt_do_table() and  ip6t_do_table()
> 
> Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.

ok, got your fix (attached below), thanks Eric for the pointer.

But i think my fix might be slightly better, because it does not 
manipulate the preempt counter and leaves preemption enabled. 

There's no BH context worries since this code did not seem to have 
BH protection before either. (it used a plain read_lock(), not 
read_lock_bh(), AFAICS)

I dont see any preemption worries either. I must be missing 
something :)

With my patch applied the box appears to boot fine and there's no 
syslog flood either. (no heavy testing done though)

	Ingo

--------------->
>From fa9a86ddc8ecd2830a5e773facc250f110300ae7 Mon Sep 17 00:00:00 2001
From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 2 Apr 2009 00:53:49 -0700
Subject: [PATCH] netfilter: use rcu_read_bh() in ipt_do_table()

Commit 784544739a25c30637397ace5489eeb6e15d7d49
(netfilter: iptables: lock free counters) forgot to disable BH
in arpt_do_table(), ipt_do_table() and  ip6t_do_table()

Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.

Reported-and-bisected-by: Roman Mindalev <r000n@r000n.net>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/arp_tables.c |    4 ++--
 net/ipv4/netfilter/ip_tables.c  |    4 ++--
 net/ipv6/netfilter/ip6_tables.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 35c5f6a..5ba533d 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -253,7 +253,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 
-	rcu_read_lock();
+	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
 	table_base = rcu_dereference(private->entries[smp_processor_id()]);
 
@@ -329,7 +329,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 	if (hotdrop)
 		return NF_DROP;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 82ee7c9..810c0b6 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -339,7 +339,7 @@ ipt_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock();
+	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
 	table_base = rcu_dereference(private->entries[smp_processor_id()]);
 
@@ -437,7 +437,7 @@ ipt_do_table(struct sk_buff *skb,
 		}
 	} while (!hotdrop);
 
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index e89cfa3..dfed176 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -365,7 +365,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 
-	rcu_read_lock();
+	rcu_read_lock_bh();
 	private = rcu_dereference(table->private);
 	table_base = rcu_dereference(private->entries[smp_processor_id()]);
 
@@ -466,7 +466,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef CONFIG_NETFILTER_DEBUG
 	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
-	rcu_read_unlock();
+	rcu_read_unlock_bh();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
