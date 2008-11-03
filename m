From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: xfrm_policy_kill: inconsistent {softirq-on-W} ->
	{in-softirq-W} usage
Date: Mon, 3 Nov 2008 23:57:26 +0300
Message-ID: <20081103205726.GA3589@x200.localdomain>
References: <490F3C08.6000209@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:2219 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbYKCUyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 15:54:10 -0500
Content-Disposition: inline
In-Reply-To: <490F3C08.6000209@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 05:59:36PM +0000, Simon Arlott wrote:
> [163040.503328] =================================
> [163040.504264] [ INFO: inconsistent lock state ]
> [163040.504264] 2.6.28-rc2-git #19424-g083ead5
> [163040.504264] ---------------------------------
> [163040.504264] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> [163040.504264] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [163040.531914]  (xfrm_policy_gc_lock){-+..}, at: [<7846bf3f>] xfrm_policy_kill+0x46/0x7e
> [163040.531914] {softirq-on-W} state was registered at:
> [163040.531914]   [<782430ea>] __lock_acquire+0x4d2/0x653
> [163040.531914]   [<782432b3>] lock_acquire+0x48/0x64
> [163040.531914]   [<784ca073>] _spin_lock+0x25/0x34
> [163040.531914]   [<7846bf3f>] xfrm_policy_kill+0x46/0x7e
> [163040.531914]   [<7846c052>] xfrm_policy_delete+0x44/0x4a
> [163040.531914]   [<783fadc7>] sk_common_release+0x61/0x9f
> [163040.531914]   [<784480fe>] udp_lib_close+0x8/0xa
> [163040.531914]   [<7844f0b6>] inet_release+0x42/0x48
> [163040.531914]   [<783f90d2>] sock_release+0x14/0x8a
> [163040.531914]   [<783f95a0>] sock_close+0x29/0x30
> [163040.531914]   [<782707c7>] __fput+0xad/0x159
> [163040.531914]   [<78270afa>] fput+0x17/0x19
> [163040.531914]   [<7826e247>] filp_close+0x50/0x5a
> [163040.531914]   [<7826e2b9>] sys_close+0x68/0xa7
> [163040.531914]   [<78202e11>] sysenter_do_call+0x12/0x35
> [163040.531914]   [<ffffffff>] 0xffffffff
> [163040.531914] irq event stamp: 1417665572
> [163040.531914] hardirqs last  enabled at (1417665572): [<7822ace6>] local_bh_enable_ip+0xa7/0xbd
> [163040.531914] hardirqs last disabled at (1417665571): [<7822ac84>] local_bh_enable_ip+0x45/0xbd
> [163040.531914] softirqs last  enabled at (1417665530): [<7822abe2>] __do_softirq+0x114/0x11c
> [163040.531914] softirqs last disabled at (1417665541): [<7822ac23>] do_softirq+0x39/0x55
> [163040.531914] 
> [163040.531914] other info that might help us debug this:
> [163040.531914] no locks held by swapper/0.
> [163040.531914] 
> [163040.531914] stack backtrace:
> [163040.531914] Pid: 0, comm: swapper Not tainted 2.6.28-rc2-git #19424-g083ead5
> [163040.531914] Call Trace:
> [163040.531914]  [<78240aa7>] print_usage_bug+0x144/0x150
> [163040.531914]  [<78241599>] mark_lock+0x2f9/0x7e7
> [163040.531914]  [<78243072>] __lock_acquire+0x45a/0x653
> [163040.531914]  [<782432b3>] lock_acquire+0x48/0x64
> [163040.531914]  [<7846bf3f>] ? xfrm_policy_kill+0x46/0x7e
> [163040.531914]  [<784ca073>] _spin_lock+0x25/0x34
> [163040.531914]  [<7846bf3f>] ? xfrm_policy_kill+0x46/0x7e
> [163040.531914]  [<7846bf3f>] xfrm_policy_kill+0x46/0x7e
> [163040.531914]  [<7846c052>] xfrm_policy_delete+0x44/0x4a
> [163040.531914]  [<7846d556>] xfrm_policy_timer+0x197/0x1c9
> [163040.531914]  [<78241c34>] ? trace_hardirqs_on_caller+0xca/0x101
> [163040.531914]  [<7822e3c3>] run_timer_softirq+0x102/0x15d
> [163040.531914]  [<7846d3bf>] ? xfrm_policy_timer+0x0/0x1c9
> [163040.531914]  [<7822ab4b>] __do_softirq+0x7d/0x11c
> [163040.531914]  [<7822ac23>] do_softirq+0x39/0x55

If it's easily reproducible, try this patch:

--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -315,9 +315,9 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 		return;
 	}
 
-	spin_lock(&xfrm_policy_gc_lock);
+	spin_lock_bh(&xfrm_policy_gc_lock);
 	hlist_add_head(&policy->bydst, &xfrm_policy_gc_list);
-	spin_unlock(&xfrm_policy_gc_lock);
+	spin_unlock_bh(&xfrm_policy_gc_lock);
 
 	schedule_work(&xfrm_policy_gc_work);
 }
