From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 11:02:03 +0800
Message-ID: <1337742123.14538.175.camel@ymzhang.sh.intel.com>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kunx.jiang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61708 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964786Ab2EWDBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 23:01:12 -0400
In-Reply-To: <20120522.151554.106838106733194160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 15:15 -0400, David Miller wrote:
> From: "kun.jiang" <kunx.jiang@intel.com>
> Date: Tue, 22 May 2012 17:48:53 +0800
> 
> > From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> > 
> > We hit a kernel OOPS.
>  ...
> > In function free_fib_info, we don't reset nexthop_nh->nh_dev to NULL before releasing
> > nh_dev. kfree_rcu(fi, rcu) would release the whole area.
> > 
> > Signed-off-by: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> > Signed-off-by: Kun Jiang <kunx.jiang@intel.com>
> 
> This isn't a fix.  You're keeping around a pointer to a completely
> released object, which is therefore illegal to dereference.
> 
> That's why we must set it to NULL, to catch such illegal accesses.
Thanks for the comments. The network stack in kernel is complicated.

Questions:
1) Why does free_fib_info call call_rcu instead of releasing fi directly?
I assume other cpu might be accessing it. nexthop_nh->nh_dev is in fi.
If other cpu are accessing it, here resetting to NULL would cause other
cpu panic.

void free_fib_info(struct fib_info *fi)
{
        if (fi->fib_dead == 0) {
                pr_warn("Freeing alive fib_info %p\n", fi);
                return;
        }
        change_nexthops(fi) {
                if (nexthop_nh->nh_dev)
                        dev_put(nexthop_nh->nh_dev);
                nexthop_nh->nh_dev = NULL;
        } endfor_nexthops(fi);
        fib_info_cnt--;
        release_net(fi->fib_net);
        call_rcu(&fi->rcu, free_fib_info_rcu);		<=====rcu
}
2) dev_put is to decrease the counter and doesn't release nh_dev.

If 2) is incorrect, how about below solution? It delays the resetting
in rcu.

================

We hit a kernel OOPS.

<3>[23898.789643] BUG: sleeping function called from invalid context at
/data/buildbot/workdir/ics/hardware/intel/linux-2.6/arch/x86/mm/fault.c:1103
<3>[23898.862215] in_atomic(): 0, irqs_disabled(): 0, pid: 10526, name:
Thread-6683
<4>[23898.967805] HSU serial 0000:00:05.1: 0000:00:05.2:HSU serial prevented me
to suspend...
<4>[23899.258526] Pid: 10526, comm: Thread-6683 Tainted: G        W
3.0.8-137685-ge7742f9 #1
<4>[23899.357404] HSU serial 0000:00:05.1: 0000:00:05.2:HSU serial prevented me
to suspend...
<4>[23899.904225] Call Trace:
<4>[23899.989209]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.000416]  [<c1238c2a>] __might_sleep+0x10a/0x110
<4>[23900.007357]  [<c1228021>] do_page_fault+0xd1/0x3c0
<4>[23900.013764]  [<c18e9ba9>] ? restore_all+0xf/0xf
<4>[23900.024024]  [<c17c007b>] ? napi_complete+0x8b/0x690
<4>[23900.029297]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.123739]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.128955]  [<c18ea0c3>] error_code+0x5f/0x64
<4>[23900.133466]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.138450]  [<c17f6298>] ? __ip_route_output_key+0x698/0x7c0
<4>[23900.144312]  [<c17f5f8d>] ? __ip_route_output_key+0x38d/0x7c0
<4>[23900.150730]  [<c17f63df>] ip_route_output_flow+0x1f/0x60
<4>[23900.156261]  [<c181de58>] ip4_datagram_connect+0x188/0x2b0
<4>[23900.161960]  [<c18e981f>] ? _raw_spin_unlock_bh+0x1f/0x30
<4>[23900.167834]  [<c18298d6>] inet_dgram_connect+0x36/0x80
<4>[23900.173224]  [<c14f9e88>] ? _copy_from_user+0x48/0x140
<4>[23900.178817]  [<c17ab9da>] sys_connect+0x9a/0xd0
<4>[23900.183538]  [<c132e93c>] ? alloc_file+0xdc/0x240
<4>[23900.189111]  [<c123925d>] ? sub_preempt_count+0x3d/0x50

Function free_fib_info resets nexthop_nh->nh_dev to NULL before releasing
fi. Other cpu might be accessing fi. Fixing it by delaying the resetting.

Signed-off-by: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Signed-off-by: Kun Jiang <kunx.jiang@intel.com>
---
 net/ipv4/fib_semantics.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 5063fa3..56d8a97 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -145,6 +145,14 @@ static void free_fib_info_rcu(struct rcu_head *head)
 {
 	struct fib_info *fi = container_of(head, struct fib_info, rcu);
 
+	change_nexthops(fi) {
+		if (nexthop_nh->nh_dev)
+			dev_put(nexthop_nh->nh_dev);
+		nexthop_nh->nh_dev = NULL;
+	} endfor_nexthops(fi);
+
+	fib_info_cnt--;
+	release_net(fi->fib_net);
 	if (fi->fib_metrics != (u32 *) dst_default_metrics)
 		kfree(fi->fib_metrics);
 	kfree(fi);
@@ -156,13 +164,6 @@ void free_fib_info(struct fib_info *fi)
 		pr_warn("Freeing alive fib_info %p\n", fi);
 		return;
 	}
-	change_nexthops(fi) {
-		if (nexthop_nh->nh_dev)
-			dev_put(nexthop_nh->nh_dev);
-		nexthop_nh->nh_dev = NULL;
-	} endfor_nexthops(fi);
-	fib_info_cnt--;
-	release_net(fi->fib_net);
 	call_rcu(&fi->rcu, free_fib_info_rcu);
 }
 
-- 
1.7.5.4
