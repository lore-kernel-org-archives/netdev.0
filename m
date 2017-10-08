From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] ipv6: Do not use this_cpu_ptr() in preemptible context
Date: Sun,  8 Oct 2017 18:18:39 +0300
Message-ID: <20171008151839.24519-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, weiwan@google.com, mlxsw@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30048.outbound.protection.outlook.com ([40.107.3.48]:61314
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751772AbdJHPT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 11:19:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without the rwlock and with PREEMPT_RCU we're no longer guaranteed to be
in non-preemptible context when performing a route lookup, so use
raw_cpu_ptr() instead.

Takes care of the following splat:
[  122.221814] BUG: using smp_processor_id() in preemptible [00000000] code: sshd/2672
[  122.221845] caller is debug_smp_processor_id+0x17/0x20
[  122.221866] CPU: 0 PID: 2672 Comm: sshd Not tainted 4.14.0-rc3-idosch-next-custom #639
[  122.221880] Hardware name: Mellanox Technologies Ltd. MSN2100-CB2FO/SA001017, BIOS 5.6.5 06/07/2016
[  122.221893] Call Trace:
[  122.221919]  dump_stack+0xb1/0x10c
[  122.221946]  ? _atomic_dec_and_lock+0x124/0x124
[  122.221974]  ? ___ratelimit+0xfe/0x240
[  122.222020]  check_preemption_disabled+0x173/0x1b0
[  122.222060]  debug_smp_processor_id+0x17/0x20
[  122.222083]  ip6_pol_route+0x1482/0x24a0
...

Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 net/ipv6/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399d1bceec4a..579d4b73beb1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1112,7 +1112,7 @@ static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 {
 	struct rt6_info *pcpu_rt, **p;
 
-	p = this_cpu_ptr(rt->rt6i_pcpu);
+	p = raw_cpu_ptr(rt->rt6i_pcpu);
 	pcpu_rt = *p;
 
 	if (pcpu_rt && ip6_hold_safe(NULL, &pcpu_rt, false))
@@ -1134,7 +1134,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 	}
 
 	dst_hold(&pcpu_rt->dst);
-	p = this_cpu_ptr(rt->rt6i_pcpu);
+	p = raw_cpu_ptr(rt->rt6i_pcpu);
 	prev = cmpxchg(p, NULL, pcpu_rt);
 	if (prev) {
 		/* If someone did it before us, return prev instead */
-- 
2.13.6
