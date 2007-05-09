From: "Yuriy N. Shkandybin" <jura@netams.com>
Subject: Re: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Thu, 10 May 2007 00:06:09 +0400
Message-ID: <001801c79275$80cd5e00$0701010a@note>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local> <20070509093536.GA2436@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<paulus@samba.org>, <greearb@candelatech.com>,
	<mostrows@speakeasy.net>, <davem@davemloft.net>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.netams.com ([212.192.245.10]:60978 "EHLO mail.netams.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755785AbXEIUGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 16:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After applying this patch i've got this:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.21-gentoo #2
-------------------------------------------------------
ospfd/3984 is trying to acquire lock:
 (&ppp->wlock){-...}, at: [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0

but task is already holding lock:
 (&dev->_xmit_lock){-+..}, at: [<ffffffff8038d778>] __qdisc_run+0x88/0x1c3

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (&dev->_xmit_lock){-+..}:
       [<ffffffff80288f49>] __lock_acquire+0xca9/0xf31
       [<ffffffff8028921a>] lock_acquire+0x49/0x6f
       [<ffffffff8038663c>] dev_mc_add+0x3c/0x148
       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
       [<ffffffff8038663c>] dev_mc_add+0x3c/0x148
       [<ffffffff803bf0fc>] vlan_dev_set_multicast_list+0xfc/0x2a0
       [<ffffffff80386707>] dev_mc_add+0x107/0x148
       [<ffffffff803b1406>] igmp_group_added+0x44/0x4b
       [<ffffffff803b15aa>] ip_mc_inc_group+0x12a/0x150
       [<ffffffff803b15b2>] ip_mc_inc_group+0x132/0x150
       [<ffffffff803b160e>] ip_mc_up+0x3e/0x5a
       [<ffffffff803aeb77>] inetdev_event+0x137/0x2d0
       [<ffffffff8038b67e>] rtmsg_ifinfo+0xae/0xe0
       [<ffffffff8027bb24>] notifier_call_chain+0x24/0x36
       [<ffffffff80384cb6>] dev_open+0x66/0x70
       [<ffffffff803830c2>] dev_change_flags+0x5c/0x12a
       [<ffffffff803af5fd>] devinet_ioctl+0x2ad/0x6b0
       [<ffffffff8037b5e6>] sock_ioctl+0x1e6/0x202
       [<ffffffff8023eaa1>] do_ioctl+0x21/0x79
       [<ffffffff8022e5bd>] vfs_ioctl+0x28d/0x2b0
       [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
       [<ffffffff80248f89>] sys_ioctl+0x3b/0x5b
       [<ffffffff8025811e>] system_call+0x7e/0x83
       [<ffffffffffffffff>] 0xffffffffffffffff

-> #2 (&vlan_netdev_xmit_lock_key){-...}:
       [<ffffffff80288f49>] __lock_acquire+0xca9/0xf31
       [<ffffffff8028921a>] lock_acquire+0x49/0x6f
       [<ffffffff8022de38>] dev_queue_xmit+0x178/0x263
       [<ffffffff8025e120>] _spin_lock+0x1e/0x27
       [<ffffffff8022de38>] dev_queue_xmit+0x178/0x263
       [<ffffffff80354f57>] __pppoe_xmit+0x217/0x23b
       [<ffffffff803523e3>] ppp_channel_push+0x43/0xb9
       [<ffffffff8035331a>] ppp_write+0x10a/0x120
       [<ffffffff80215895>] vfs_write+0xa5/0xf0
       [<ffffffff80216238>] sys_write+0x45/0x7d
       [<ffffffff8025811e>] system_call+0x7e/0x83
       [<ffffffffffffffff>] 0xffffffffffffffff

-> #1 (&pch->downl){-...}:
       [<ffffffff80288f49>] __lock_acquire+0xca9/0xf31
       [<ffffffff8028921a>] lock_acquire+0x49/0x6f
       [<ffffffff803509d5>] ppp_push+0x45/0xaf
       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
       [<ffffffff803509d5>] ppp_push+0x45/0xaf
       [<ffffffff803516e7>] ppp_xmit_process+0x467/0x4f0
       [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
       [<ffffffff8035330a>] ppp_write+0xfa/0x120
       [<ffffffff80215895>] vfs_write+0xa5/0xf0
       [<ffffffff80216238>] sys_write+0x45/0x7d
       [<ffffffff8025811e>] system_call+0x7e/0x83
       [<ffffffffffffffff>] 0xffffffffffffffff

-> #0 (&ppp->wlock){-...}:
       [<ffffffff8028483b>] print_stack_trace+0x6d/0x8a
       [<ffffffff80288e08>] __lock_acquire+0xb68/0xf31
       [<ffffffff8028921a>] lock_acquire+0x49/0x6f
       [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
       [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
       [<ffffffff80287daf>] trace_hardirqs_on+0x113/0x164
       [<ffffffff803531bc>] ppp_start_xmit+0x1dc/0x230
       [<ffffffff8038d7f5>] __qdisc_run+0x105/0x1c3
       [<ffffffff8022dddf>] dev_queue_xmit+0x11f/0x263
       [<ffffffff80237533>] ip_mc_output+0x333/0x370
       [<ffffffff803a9460>] raw_sendmsg+0x560/0x729
       [<ffffffff8025045b>] sock_sendmsg+0xcb/0xe3
       [<ffffffff80281bbc>] autoremove_wake_function+0x0/0x34
       [<ffffffff802754bf>] local_bh_enable_ip+0xeb/0xfc
       [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
       [<ffffffff8039c20c>] ip_setsockopt+0xb1c/0xb3f
       [<ffffffff8039c20c>] ip_setsockopt+0xb1c/0xb3f
       [<ffffffff803813e6>] verify_iovec+0x46/0x94
       [<ffffffff8037bde0>] sys_sendmsg+0x1de/0x249
       [<ffffffff8025e3c9>] _spin_unlock_irqrestore+0x41/0x4a
       [<ffffffff8027bd6f>] getrusage+0x19f/0x1ba
       [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
       [<ffffffff8025dbc9>] trace_hardirqs_on_thunk+0x35/0x37
       [<ffffffff803a8650>] raw_setsockopt+0x0/0x54
       [<ffffffff8025811e>] system_call+0x7e/0x83
       [<ffffffffffffffff>] 0xffffffffffffffff

other info that might help us debug this:

1 lock held by ospfd/3984:
 #0:  (&dev->_xmit_lock){-+..}, at: [<ffffffff8038d778>] 
__qdisc_run+0x88/0x1c3

stack backtrace:

Call Trace:
 [<ffffffff80286f9d>] print_circular_bug_tail+0x6a/0x7d
 [<ffffffff8028483b>] print_stack_trace+0x6d/0x8a
 [<ffffffff80288e08>] __lock_acquire+0xb68/0xf31
 [<ffffffff8028921a>] lock_acquire+0x49/0x6f
 [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
 [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
 [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
 [<ffffffff80287daf>] trace_hardirqs_on+0x113/0x164
 [<ffffffff803531bc>] ppp_start_xmit+0x1dc/0x230
 [<ffffffff8038d7f5>] __qdisc_run+0x105/0x1c3
 [<ffffffff8022dddf>] dev_queue_xmit+0x11f/0x263
 [<ffffffff80237533>] ip_mc_output+0x333/0x370
 [<ffffffff803a9460>] raw_sendmsg+0x560/0x729
 [<ffffffff8025045b>] sock_sendmsg+0xcb/0xe3
 [<ffffffff80281bbc>] autoremove_wake_function+0x0/0x34
 [<ffffffff802754bf>] local_bh_enable_ip+0xeb/0xfc
 [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
 [<ffffffff8039c20c>] ip_setsockopt+0xb1c/0xb3f
 [<ffffffff8039c20c>] ip_setsockopt+0xb1c/0xb3f
 [<ffffffff803813e6>] verify_iovec+0x46/0x94
 [<ffffffff8037bde0>] sys_sendmsg+0x1de/0x249
 [<ffffffff8025e3c9>] _spin_unlock_irqrestore+0x41/0x4a
 [<ffffffff8027bd6f>] getrusage+0x19f/0x1ba
 [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
 [<ffffffff8025dbc9>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff803a8650>] raw_setsockopt+0x0/0x54
 [<ffffffff8025811e>] system_call+0x7e/0x83

Jura

----- Original Message ----- 
From: "Jarek Poplawski" <jarkao2@o2.pl>
To: "Yuriy N. Shkandybin" <jura@netams.com>
Cc: <akpm@linux-foundation.org>; <netdev@vger.kernel.org>; 
<jura@netams.com>; <paulus@samba.org>; <greearb@candelatech.com>; 
<mostrows@speakeasy.net>; <davem@davemloft.net>
Sent: Wednesday, May 09, 2007 1:35 PM
Subject: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: ppp_generic: 
fix lockdep warning


> On Thu, Apr 26, 2007 at 12:49:50PM +0200, Jarek Poplawski wrote:
> ...
>> But there is also a second, very similar lockdep report,
>> probably also false (lockdep cannot see the difference
>> between locks of two different, I hope, vlan devices),
>> which needs more work:
>> a) vlan should use different lockdep lock subclasses or
>> classes for each device, which would require quite a lot
>> of static memory reserved, probably only to silence
>> lockdep,
>> b) pppoe could change the way of sending packets, so
>> the locks of ppp_generic were not seen by lockdep
>> with so many variants; I'm not sure the maintainer of
>> pppoe likes this idea;
>>
>> Doing a) should be enough, I guess; doing b) is easier
>> but, probably, the similar is possible elsewhere, too.
> ...
>> Currently I think about some change in lockdep, to track
>> something like different vlans with less memory, but I'm
>> not sure it'll work, yet.
>
> After rethinking there is the 3-rd way (as usual):
>
> c) vlan should use different lockdep lock subclasses or
> classes for different types of devices, used at the same
> time.
>
> This patch is intended for testing, so should be applied
> after some confirmation. (It should be safe anyway.)
>
> If this works, the previous lockdep patch on ppp_generic
> should be really superfluous.
>
> Yuriy, could you try this patch, please?
> This is done on 2.6.21, but could be applied to current -mm
> or -git, too. If you prefere some other version, let me know.
>
> Regards,
> Jarek P.
> --->
>
> This patch's aim is to let lockdep see ppp devs as different
> from others (default), and it's OK to take: _xmit_lock of vlan
> and _xmit_lock of ppp with reverse order provided vlan _xmit_locks
> are bound to different devs (ppp and e.g. eth).
>
>> =======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 2.6.21-rc6-mm1 #4
>> -------------------------------------------------------
>> pppd/14305 is trying to acquire lock:
>>  (&vlan_netdev_xmit_lock_key){-...}, at: [<ffffffff8022f90b>]
>> dev_queue_xmit+0x26b/0x300
>>
>> but task is already holding lock:
>>  (&pch->downl#2){-+..}, at: [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
>>
>> which lock already depends on the new lock.
>
> Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michal Ostrowski <mostrows@speakeasy.net>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
>
> ---
>
> diff -Nurp 2.6.21-/net/8021q/vlan.c 2.6.21/net/8021q/vlan.c
> --- 2.6.21-/net/8021q/vlan.c 2007-05-01 12:43:39.000000000 +0200
> +++ 2.6.21/net/8021q/vlan.c 2007-05-07 21:09:30.000000000 +0200
> @@ -535,7 +535,13 @@ static struct net_device *register_vlan_
>  if (register_netdevice(new_dev))
>  goto out_free_newdev;
>
> - lockdep_set_class(&new_dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
> + if (unlikely(real_dev->type == ARPHRD_PPP))
> + /* pppoe uses two different kinds of _xmit_lock for ppp & eth */
> + lockdep_set_class_and_subclass(&new_dev->_xmit_lock,
> +        &vlan_netdev_xmit_lock_key, 1);
> + else
> + lockdep_set_class(&new_dev->_xmit_lock,
> +   &vlan_netdev_xmit_lock_key);
>
>  new_dev->iflink = real_dev->ifindex;
>  vlan_transfer_operstate(real_dev, new_dev);
> 

