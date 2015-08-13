From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC net 3/3] ipv6: Fix potential deadlock when creating pcpu rt
Date: Thu, 13 Aug 2015 00:58:03 -0700
Message-ID: <1439452683-964514-4-git-send-email-kafai@fb.com>
References: <20150808100028.GA14897@sesse.net>
 <1439452683-964514-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14304 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752297AbbHMH6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 03:58:34 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7D7utJ2012300
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 00:58:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w8pm1g5cy-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 00:58:33 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 17480a96419111e5b01d0002c9931860-1c3f62b0 for <netdev@vger.kernel.org>;	Thu,
 13 Aug 2015 00:58:32 -0700
In-Reply-To: <1439452683-964514-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt6_make_pcpu_route() is called under read_lock(&table->tb6_lock).
rt6_make_pcpu_route() calls ip6_rt_pcpu_alloc(rt) which then
calls dst_alloc().  dst_alloc() _may_ call ip6_dst_gc() which takes
the write_lock(&tabl->tb6_lock).  A visualized version:

read_lock(&table->tb6_lock);
rt6_make_pcpu_route();
=> ip6_rt_pcpu_alloc();
=> dst_alloc();
=> ip6_dst_gc();
=> write_lock(&table->tb6_lock); /* oops */

The fix is to do a read_unlock first before calling ip6_rt_pcpu_alloc().

A reported stack:

[141625.537638] INFO: rcu_sched self-detected stall on CPU { 27}  (t=60000 jiffies g=4159086 c=4159085 q=2139)
[141625.547469] Task dump for CPU 27:
[141625.550881] mtr             R  running task        0 22121  22081 0x00000008
[141625.558069]  0000000000000000 ffff88103f363d98 ffffffff8106e488 000000000000001b
[141625.565641]  ffffffff81684900 ffff88103f363db8 ffffffff810702b0 0000000008000000
[141625.573220]  ffffffff81684900 ffff88103f363de8 ffffffff8108df9f ffff88103f375a00
[141625.580803] Call Trace:
[141625.583345]  <IRQ>  [<ffffffff8106e488>] sched_show_task+0xc1/0xc6
[141625.589650]  [<ffffffff810702b0>] dump_cpu_task+0x35/0x39
[141625.595144]  [<ffffffff8108df9f>] rcu_dump_cpu_stacks+0x6a/0x8c
[141625.601320]  [<ffffffff81090606>] rcu_check_callbacks+0x1f6/0x5d4
[141625.607669]  [<ffffffff810940c8>] update_process_times+0x2a/0x4f
[141625.613925]  [<ffffffff8109fbee>] tick_sched_handle+0x32/0x3e
[141625.619923]  [<ffffffff8109fc2f>] tick_sched_timer+0x35/0x5c
[141625.625830]  [<ffffffff81094a1f>] __hrtimer_run_queues+0x8f/0x18d
[141625.632171]  [<ffffffff81094c9e>] hrtimer_interrupt+0xa0/0x166
[141625.638258]  [<ffffffff8102bf2a>] local_apic_timer_interrupt+0x4e/0x52
[141625.645036]  [<ffffffff8102c36f>] smp_apic_timer_interrupt+0x39/0x4a
[141625.651643]  [<ffffffff8140b9e8>] apic_timer_interrupt+0x68/0x70
[141625.657895]  <EOI>  [<ffffffff81346ee8>] ? dst_destroy+0x7c/0xb5
[141625.664188]  [<ffffffff813d45b5>] ? fib6_flush_trees+0x20/0x20
[141625.670272]  [<ffffffff81082b45>] ? queue_write_lock_slowpath+0x60/0x6f
[141625.677140]  [<ffffffff8140aa33>] _raw_write_lock_bh+0x23/0x25
[141625.683218]  [<ffffffff813d4553>] __fib6_clean_all+0x40/0x82
[141625.689124]  [<ffffffff813d45b5>] ? fib6_flush_trees+0x20/0x20
[141625.695207]  [<ffffffff813d6058>] fib6_clean_all+0xe/0x10
[141625.700854]  [<ffffffff813d60d3>] fib6_run_gc+0x79/0xc8
[141625.706329]  [<ffffffff813d0510>] ip6_dst_gc+0x85/0xf9
[141625.711718]  [<ffffffff81346d68>] dst_alloc+0x55/0x159
[141625.717105]  [<ffffffff813d09b5>] __ip6_dst_alloc.isra.32+0x19/0x63
[141625.723620]  [<ffffffff813d1830>] ip6_pol_route+0x36a/0x3e8
[141625.729441]  [<ffffffff813d18d6>] ip6_pol_route_output+0x11/0x13
[141625.735700]  [<ffffffff813f02c8>] fib6_rule_action+0xa7/0x1bf
[141625.741698]  [<ffffffff813d18c5>] ? ip6_pol_route_input+0x17/0x17
[141625.748043]  [<ffffffff81357c48>] fib_rules_lookup+0xb5/0x12a
[141625.754050]  [<ffffffff81141628>] ? poll_select_copy_remaining+0xf9/0xf9
[141625.761002]  [<ffffffff813f0535>] fib6_rule_lookup+0x37/0x5c
[141625.766914]  [<ffffffff813d18c5>] ? ip6_pol_route_input+0x17/0x17
[141625.773260]  [<ffffffff813d008c>] ip6_route_output+0x7a/0x82
[141625.779177]  [<ffffffff813c44c8>] ip6_dst_lookup_tail+0x53/0x112
[141625.785437]  [<ffffffff813c45c3>] ip6_dst_lookup_flow+0x2a/0x6b
[141625.791604]  [<ffffffff813ddaab>] rawv6_sendmsg+0x407/0x9b6
[141625.797423]  [<ffffffff813d7914>] ? do_ipv6_setsockopt.isra.8+0xd87/0xde2
[141625.804464]  [<ffffffff8139d4b4>] inet_sendmsg+0x57/0x8e
[141625.810028]  [<ffffffff81329ba3>] sock_sendmsg+0x2e/0x3c
[141625.815588]  [<ffffffff8132be57>] SyS_sendto+0xfe/0x143
[141625.821063]  [<ffffffff813dd551>] ? rawv6_setsockopt+0x5e/0x67
[141625.827146]  [<ffffffff8132c9f8>] ? sock_common_setsockopt+0xf/0x11
[141625.833660]  [<ffffffff8132c08c>] ? SyS_setsockopt+0x81/0xa2
[141625.839565]  [<ffffffff8140ac17>] entry_SYSCALL_64_fastpath+0x12/0x6a

Fixes: d52d3997f843 ("pv6: Create percpu rt6_info")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reported-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
---
 net/ipv6/ip6_fib.c |  2 ++
 net/ipv6/route.c   | 44 +++++++++++++++++++++++++++++++++-----------
 2 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 55d1986..548c623 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -172,6 +172,8 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 			*ppcpu_rt = NULL;
 		}
 	}
+
+	non_pcpu_rt->rt6i_pcpu = NULL;
 }
 
 static void rt6_release(struct rt6_info *rt)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0a82653..d155864 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1007,27 +1007,39 @@ static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 
 static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 {
+	struct fib6_table *table = rt->rt6i_table;
 	struct rt6_info *pcpu_rt, *prev, **p;
 
 	pcpu_rt = ip6_rt_pcpu_alloc(rt);
 	if (!pcpu_rt) {
 		struct net *net = dev_net(rt->dst.dev);
 
-		pcpu_rt = net->ipv6.ip6_null_entry;
-		goto done;
+		dst_hold(&net->ipv6.ip6_null_entry->dst);
+		return net->ipv6.ip6_null_entry;
 	}
 
-	p = this_cpu_ptr(rt->rt6i_pcpu);
-	prev = cmpxchg(p, NULL, pcpu_rt);
-	if (prev) {
-		/* If someone did it before us, return prev instead */
+	read_lock_bh(&table->tb6_lock);
+	if (rt->rt6i_pcpu) {
+		p = this_cpu_ptr(rt->rt6i_pcpu);
+		prev = cmpxchg(p, NULL, pcpu_rt);
+		if (prev) {
+			/* If someone did it before us, return prev instead */
+			dst_destroy(&pcpu_rt->dst);
+			pcpu_rt = prev;
+		}
+	} else {
+		/* rt has been removed from the fib6 tree
+		 * before we have a chance to acquire the read_lock.
+		 * In this case, don't brother to create a pcpu rt
+		 * since rt is going away anyway.  The next
+		 * dst_check() will trigger a re-lookup.
+		 */
 		dst_destroy(&pcpu_rt->dst);
-		pcpu_rt = prev;
+		pcpu_rt = rt;
 	}
-
-done:
 	dst_hold(&pcpu_rt->dst);
 	rt6_dst_from_metrics_check(pcpu_rt);
+	read_unlock_bh(&table->tb6_lock);
 	return pcpu_rt;
 }
 
@@ -1103,11 +1115,21 @@ redo_rt6_select:
 		rt->dst.__use++;
 		pcpu_rt = rt6_get_pcpu_route(rt);
 
-		if (!pcpu_rt)
+		if (pcpu_rt) {
+			read_unlock_bh(&table->tb6_lock);
+		} else {
+			/* We have to do the read_unlock first
+			 * because rt6_make_pcpu_route() may trigger
+			 * ip6_dst_gc() which will take the write_lock.
+			 */
+			dst_hold(&rt->dst);
+			read_unlock_bh(&table->tb6_lock);
 			pcpu_rt = rt6_make_pcpu_route(rt);
+			dst_release(&rt->dst);
+		}
 
-		read_unlock_bh(&table->tb6_lock);
 		return pcpu_rt;
+
 	}
 }
 
-- 
1.8.1
