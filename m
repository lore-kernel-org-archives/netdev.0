From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Do not use this_cpu_ptr() in preemptible
 context
Date: Sun, 08 Oct 2017 09:03:53 -0700
Message-ID: <1507478633.14419.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171008151839.24519-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, weiwan@google.com,
        mlxsw@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37107 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdJHQDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 12:03:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id z80so3518340pff.4
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 09:03:55 -0700 (PDT)
In-Reply-To: <20171008151839.24519-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-08 at 18:18 +0300, Ido Schimmel wrote:
> Without the rwlock and with PREEMPT_RCU we're no longer guaranteed to be
> in non-preemptible context when performing a route lookup, so use
> raw_cpu_ptr() instead.
> 
> Takes care of the following splat:
> [  122.221814] BUG: using smp_processor_id() in preemptible [00000000] code: sshd/2672
> [  122.221845] caller is debug_smp_processor_id+0x17/0x20
> [  122.221866] CPU: 0 PID: 2672 Comm: sshd Not tainted 4.14.0-rc3-idosch-next-custom #639
> [  122.221880] Hardware name: Mellanox Technologies Ltd. MSN2100-CB2FO/SA001017, BIOS 5.6.5 06/07/2016
> [  122.221893] Call Trace:
> [  122.221919]  dump_stack+0xb1/0x10c
> [  122.221946]  ? _atomic_dec_and_lock+0x124/0x124
> [  122.221974]  ? ___ratelimit+0xfe/0x240
> [  122.222020]  check_preemption_disabled+0x173/0x1b0
> [  122.222060]  debug_smp_processor_id+0x17/0x20
> [  122.222083]  ip6_pol_route+0x1482/0x24a0
> ...
> 
> Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> ---


Thanks Ido for this patch.

IMO, we no longer play this read_lock() -> write_lock() game since
ip6_dst_gc() could be called from rt6_make_pcpu_route()


So we might simplify things quite a bit, by blocking BH (and thus
preventing preemption)

Something like :

 net/ipv6/route.c |   26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399d1bceec4a6e6736c367e706dd2acbd4093d58..606e80325b21c0e10a02e9c7d5b3fcfbfc26a003 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1136,15 +1136,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 	dst_hold(&pcpu_rt->dst);
 	p = this_cpu_ptr(rt->rt6i_pcpu);
 	prev = cmpxchg(p, NULL, pcpu_rt);
-	if (prev) {
-		/* If someone did it before us, return prev instead */
-		/* release refcnt taken by ip6_rt_pcpu_alloc() */
-		dst_release_immediate(&pcpu_rt->dst);
-		/* release refcnt taken by above dst_hold() */
-		dst_release_immediate(&pcpu_rt->dst);
-		dst_hold(&prev->dst);
-		pcpu_rt = prev;
-	}
+	BUG_ON(prev);
 
 	rt6_dst_from_metrics_check(pcpu_rt);
 	return pcpu_rt;
@@ -1739,31 +1731,25 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		struct rt6_info *pcpu_rt;
 
 		dst_use_noref(&rt->dst, jiffies);
+		local_bh_disable();
 		pcpu_rt = rt6_get_pcpu_route(rt);
 
-		if (pcpu_rt) {
-			rcu_read_unlock();
-		} else {
+		if (!pcpu_rt) {
 			/* atomic_inc_not_zero() is needed when using rcu */
 			if (atomic_inc_not_zero(&rt->rt6i_ref)) {
-				/* We have to do the read_unlock first
-				 * because rt6_make_pcpu_route() may trigger
-				 * ip6_dst_gc() which will take the write_lock.
-				 *
-				 * No dst_hold() on rt is needed because grabbing
+				/* No dst_hold() on rt is needed because grabbing
 				 * rt->rt6i_ref makes sure rt can't be released.
 				 */
-				rcu_read_unlock();
 				pcpu_rt = rt6_make_pcpu_route(rt);
 				rt6_release(rt);
 			} else {
 				/* rt is already removed from tree */
-				rcu_read_unlock();
 				pcpu_rt = net->ipv6.ip6_null_entry;
 				dst_hold(&pcpu_rt->dst);
 			}
 		}
-
+		local_bh_enable();
+		rcu_read_unlock();
 		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
 		return pcpu_rt;
 	}
