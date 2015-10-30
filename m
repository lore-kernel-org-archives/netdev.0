From: Ani Sinha <ani@arista.com>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Thu, 29 Oct 2015 18:41:56 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1510291841480.68875@animac.local>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local> <20151030001510.GG18062@breakpoint.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ani Sinha <ani@arista.com>, netdev@vger.kernel.org,
	ani@anirban.org, fruggeri@arista.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35283 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbbJ3BmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 21:42:01 -0400
Received: by pasz6 with SMTP id z6so57222788pas.2
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 18:42:01 -0700 (PDT)
In-Reply-To: <20151030001510.GG18062@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Oct 2015, Florian Westphal wrote:

> Ani Sinha <ani@arista.com> wrote:
> 
> [ trimmed CC list ]
> 
> > We are noticing the following kernel BUG in 3.18 kernel. The 
> > code path that leads to the crash is the following :
> > 
> >  ip_mroute_setsockopt()
> >   ->ipmr_mfc_add()
> >       ->ipmr_cache_resolve()
> >         ->ip_mr_forward()
> >            -> ipmr_queue_xmit()
> >              -> ipmr_forward_finish()
> >                ->IP_INC_STATS_BH()
> >                   -> SNMP_INC_STATS64_BH()
> >                     -> SNMP_INC_STATS_BH()
> >                           -> __this_cpu_inc()
> >                               -> __this_cpu_add()
> >                                   -> __this_cpu_preempt_check()
> >                                      -> check_preemption_disabled()
> > 
> > I have verified that preempt_count() is 0 when the crash happens.
> > Is anyone else seeing the same crash in the laetst upstream code? I dug 
> > around a little bit and it does not look like there were any fixes that 
> > went into post 3.18 kernel which could have disabled preemption in this 
> > code path but I could be wrong. 
> > 
> > thoughts?
> 
> Send a patch to preempt_disable before ip_mr_forward call in the affected
> setsockopt path?
> 

>From bfa982b5f8d91294d724486542163d3db5e6908a Mon Sep 17 00:00:00 2001
From: Ani Sinha <ani@arista.com>
Date: Thu, 29 Oct 2015 18:09:20 -0700
Subject: [PATCH 1/1] ipmr: fix a kernel BUG() due to calling __this_cpu_add()
 in preemptible  context. Reproduced in 3.18.19 kernel version.

BUG: using __this_cpu_add() in preemptible [00000000] code: KernelMfib/2758
caller is __this_cpu_preempt_check+0x13/0x15
CPU: 0 PID: 2758 Comm: KernelMfib Tainted: P       O   3.18.19 #2
 ffffffff8170eaca ffff880110d1b788 ffffffff81482b2a 0000000000000000
 0000000000000000 ffff880110d1b7b8 ffffffff812010ae ffff880007cab800
 ffff88001a060800 ffff88013a899108 ffff880108b84240 ffff880110d1b7c8
Call Trace:
[<ffffffff81482b2a>] dump_stack+0x52/0x80
[<ffffffff812010ae>] check_preemption_disabled+0xce/0xe1
[<ffffffff812010d4>] __this_cpu_preempt_check+0x13/0x15
[<ffffffff81419d60>] ipmr_queue_xmit+0x647/0x70c
[<ffffffff8141a154>] ip_mr_forward+0x32f/0x34e
[<ffffffff8141af76>] ip_mroute_setsockopt+0xe03/0x108c
[<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[<ffffffff810e6974>] ? pollwake+0x4d/0x51
[<ffffffff81058ac0>] ? default_wake_function+0x0/0xf
[<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[<ffffffff810613d9>] ? __wake_up_common+0x45/0x77
[<ffffffff81486ea9>] ? _raw_spin_unlock_irqrestore+0x1d/0x32
[<ffffffff810618bc>] ? __wake_up_sync_key+0x4a/0x53
[<ffffffff8139a519>] ? sock_def_readable+0x71/0x75
[<ffffffff813dd226>] do_ip_setsockopt+0x9d/0xb55
[<ffffffff81429818>] ? unix_seqpacket_sendmsg+0x3f/0x41
[<ffffffff813963fe>] ? sock_sendmsg+0x6d/0x86
[<ffffffff813959d4>] ? sockfd_lookup_light+0x12/0x5d
[<ffffffff8139650a>] ? SyS_sendto+0xf3/0x11b
[<ffffffff810d5738>] ? new_sync_read+0x82/0xaa
[<ffffffff813ddd19>] compat_ip_setsockopt+0x3b/0x99
[<ffffffff813fb24a>] compat_raw_setsockopt+0x11/0x32
[<ffffffff81399052>] compat_sock_common_setsockopt+0x18/0x1f
[<ffffffff813c4d05>] compat_SyS_setsockopt+0x1a9/0x1cf
[<ffffffff813c4149>] compat_SyS_socketcall+0x180/0x1e3
[<ffffffff81488ea1>] cstar_dispatch+0x7/0x1e

Signed-off-by: Ani Sinha <ani@arista.com>
---
 net/ipv4/ipmr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 866ee89..48df3cc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -936,7 +936,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else {
+			preempt_disable();
 			ip_mr_forward(net, mrt, skb, c, 0);
+			preempt_enable();
 		}
 	}
 }
-- 
1.8.1.4
