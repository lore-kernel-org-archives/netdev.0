From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: need help with wireless netns crash
Date: Sat, 11 Jul 2009 02:08:50 -0700
Message-ID: <m11vonsi1p.fsf@fess.ebiederm.org>
References: <1247302033.30647.72.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42562 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbZGKJI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 05:08:56 -0400
In-Reply-To: <1247302033.30647.72.camel@johannes.local> (Johannes Berg's message of "Sat\, 11 Jul 2009 10\:47\:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> Hi,
>
> can somebody explain this comment to me?
>
>  * Use these carefully.  If you implement a network device and it
>  * needs per network namespace operations use device pernet operations,
>  * otherwise use pernet subsys operations.
>  *
>  * This is critically important.  Most of the network code cleanup
>  * runs with the assumption that dev_remove_pack has been called so no
>  * new packets will arrive during and after the cleanup functions have
>  * been called.  dev_remove_pack is not per namespace so instead the
>  * guarantee of no more packets arriving in a network namespace is
>  * provided by ensuring that all network devices and all sockets have
>  * left the network namespace before the cleanup methods are called.
>  *
>  * For the longest time the ipv4 icmp code was registered as a pernet
>  * device which caused kernel oops, and panics during network
>  * namespace cleanup.   So please don't get this wrong.
>
> I was running with this patch:
> http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-cfg80211-netns.patch
>
> and if I use pernet_subsys I sometimes run into this warning and the
> crash below, but if I use pernet_device I don't -- and would like to
> understand why.
>
>
> [  732.092471] WARNING: at kernel/sysctl.c:2120 unregister_sysctl_table+0xb9/0x120()
> [  732.096093] Hardware name: 
> [  732.097069] Pid: 38, comm: netns Tainted: G        W  2.6.31-rc2-wl #407
> [  732.099415] Call Trace:
> [  732.103391]  [<ffffffff810520a6>] warn_slowpath_common+0x76/0xd0
> [  732.105880]  [<ffffffff81052114>] warn_slowpath_null+0x14/0x20
> [  732.108047]  [<ffffffff8105c429>] unregister_sysctl_table+0xb9/0x120
> [  732.118549]  [<ffffffff813ab845>] __devinet_sysctl_unregister+0x25/0x40
> [  732.120890]  [<ffffffff813ab8ec>] inetdev_destroy+0x8c/0x100
> [  732.123037]  [<ffffffff813abe66>] inetdev_event+0x156/0x280
> [  732.124939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
> [  732.126959]  [<ffffffff81072be6>] raw_notifier_call_chain+0x16/0x20
> [  732.129096]  [<ffffffff813618b6>] dev_change_net_namespace+0xc6/0x2b0
> [  732.137437]  [<ffffffff813c7c9f>] cfg80211_switch_netns+0x5f/0x130
> [  732.141569]  [<ffffffff813c7def>] cfg80211_pernet_exit+0x7f/0xa0
> [  732.143656]  [<ffffffff8135a83e>] cleanup_net+0x5e/0xb0
> [  732.145507]  [<ffffffff81067ae5>] run_workqueue+0x165/0x2a0
> [  732.149376]  [<ffffffff81067ccf>] worker_thread+0xaf/0x130
> [  732.155473]  [<ffffffff8106d136>] kthread+0xa6/0xb0
> [  732.157144]  [<ffffffff8100c99a>] child_rip+0xa/0x20
>
> and this error (sometimes _both_ but not always):
>
> [  139.352125] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  139.354812] last sysfs file: /sys/devices/virtual/mac80211_hwsim/hwsim0/phy0/index
> [  139.357859] CPU 3 
> [  139.358769] Pid: 38, comm: netns Tainted: G        W  2.6.31-rc2-wl #408 
> [  139.361542] RIP: 0010:[<ffffffff813b4e71>]  [<ffffffff813b4e71>] fib_magic+0x81/0xd0
> [  139.361939] RSP: 0018:ffff88001fa79a10  EFLAGS: 00010202
> [  139.361939] RAX: ffff88001ee75b18 RBX: 0000000000000019 RCX: 0000000000000000
> [  139.361939] RDX: 6b6b6b6b6b6b6b6b RSI: 0000000000000003 RDI: ffff88001fa79a70
> [  139.361939] RBP: ffff88001fa79a90 R08: 000000000000000c R09: ffff88001e4a0000
> [  139.361939] R10: 0000000000000001 R11: ffff88001fa79a10 R12: 000000000100000a
> [  139.361939] R13: 0000000000000018 R14: ffff88001e490cd8 R15: 000000000100000a
> [  139.361939] FS:  0000000000000000(0000) GS:ffff880003d91000(0000) knlGS:0000000000000000
> [  139.361939] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [  139.361939] CR2: 00007fced319b098 CR3: 000000001edb2000 CR4: 00000000000006e0
> [  139.361939] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  139.361939] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  139.361939] Process netns (pid: 38, threadinfo ffff88001fa78000, task ffff88001fa70000)
> [  139.361939] Stack:
> [  139.361939]  0000000100020018 0000000a00000000 0000000300000000 0000000000000000
> [  139.361939] <0> 000000000100000a 0000000000000000 0000000000000000 0000000000000000
> [  139.361939] <0> 00000c0000000000 0000000000000000 ffff88001e4a0000 0000000000000000
> [  139.361939] Call Trace:
> [  139.361939]  [<ffffffff813b5870>] fib_del_ifaddr+0x60/0x220
> [  139.361939]  [<ffffffff813b5a98>] fib_inetaddr_event+0x68/0xb0
> [  139.361939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
> [  139.361939]  [<ffffffff81072de3>] __blocking_notifier_call_chain+0x63/0x90
> [  139.361939]  [<ffffffff81072e26>] blocking_notifier_call_chain+0x16/0x20
> [  139.361939]  [<ffffffff813ab589>] __inet_del_ifa+0xa9/0x220
> [  139.361939]  [<ffffffff813ab8ba>] inetdev_destroy+0x5a/0x100
> [  139.361939]  [<ffffffff813abe66>] inetdev_event+0x156/0x280
> [  139.361939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
> [  139.361939]  [<ffffffff81072be6>] raw_notifier_call_chain+0x16/0x20
> [  139.361939]  [<ffffffff813618b6>] dev_change_net_namespace+0xc6/0x2b0
> [  139.361939]  [<ffffffff813c7c9f>] cfg80211_switch_netns+0x5f/0x130
> [  139.361939]  [<ffffffff813c7def>] cfg80211_pernet_exit+0x7f/0xa0
> [  139.361939]  [<ffffffff8135a83e>] cleanup_net+0x5e/0xb0
> [  139.361939]  [<ffffffff81067ae5>] run_workqueue+0x165/0x2a0
> [  139.361939]  [<ffffffff81067ccf>] worker_thread+0xaf/0x130
> [  139.361939]  [<ffffffff8106d136>] kthread+0xa6/0xb0
> [  139.361939]  [<ffffffff8100c99a>] child_rip+0xa/0x20
>
>
>
> It seems the problem is that during the netns removal notification I
> reparent interfaces to init_net? I suppose I could just rely on that
> happening automatically by unsetting only the NETNS_LOCAL flag for them
> at this point? Or is this maybe too late and I need to be doing this
> earlier, in some pre-removal callback?

>
> And ... should they actually be reparented to init_net anyway? It seems
> they should go to the parent of the ns if such a concept exists, since
> namespaces would seem to follow the task hierarchy? If I create a netns
> and from _within_ that create yet another netns it would seem that the
> outer netns would get its interfaces back when the inner done goes away,
> rather than its parent task's netns getting them.

Reparenting to init_net happens for real network devices because we
don't know what to do with them and there is no true hierarchy of
network namespaces.  Virtual network devices at least ones that implement
rtnl_link_ops->dellink we destroy automatically.


> Any help appreciated!

The code for moving a network device between namespaces during
exit is in default_device_exit.  If NETIF_F_NETNS_LOCAL is set
it shouldn't trigger.


It sounds like you have both network device and subsystem level
cleanup.

In which case you probably want to split the code and use both
register_pernet_device and register_pernet_subsystem.

As for the initial comment.  Things are setup so that all network
devices are removed from a network namespace before subsystem level
cleanup happens.  This prevents all sorts of nasty cleanup races
with packets flying while a network namespace is being destroyed.

Hope that helps. If not I will try and take a more indepth look
in a bit.

Eric
