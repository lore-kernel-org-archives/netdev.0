From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Fri, 18 Jan 2008 01:58:10 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801180154570.4570@bizon.gios.gov.pl>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl>
 <20080114144754.29a448ad.akpm@linux-foundation.org> <16796.1200351673@death>
 <20080117154243.9ee4265c.akpm@linux-foundation.org> <24607.1200616005@death>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1738103207-1200617890=:4570"
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41673 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756719AbYARA7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 19:59:04 -0500
In-Reply-To: <24607.1200616005@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1738103207-1200617890=:4570
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 17 Jan 2008, Jay Vosburgh wrote:

>
> Andrew Morton <akpm@linux-foundation.org> wrote:
> [...]
>> Can we get this bug fixed please?  Today?  It has been known about for m=
ore
>> than two months.
>
> =09I just reposted the complete fix; it's #1 of the series of 7.

Bad news. :( 2.6.24-rc7 + patch #1 (bonding: fix locking in sysfs=20
primary/active selection):

bonding: bond0: setting mode to active-backup (1).
bonding: bond0: Setting MII monitoring interval to 100.
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: Adding slave eth0.
e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Con=
trol: RX/TX
bonding: bond0: making interface eth0 the new active one.
bonding: bond0: first active interface up!
bonding: bond0: enslaving eth0 as an active interface with an up link.
bonding: bond0: Adding slave eth1.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[ INFO: possible irq lock inversion dependency detected ]
2.6.24-rc7 #1
---------------------------------------------------------
events/0/9 just changed the state of lock:
  (&mc->mca_lock){-+..}, at: [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
but this lock took another, soft-read-irq-unsafe lock in the past:
  (&bond->lock){-.--}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
4 locks held by events/0/9:
  #0:  (events){--..}, at: [<c0133d33>] run_workqueue+0x87/0x1b6
  #1:  ((linkwatch_work).work){--..}, at: [<c0133d33>] run_workqueue+0x87/0=
x1b6
  #2:  (rtnl_mutex){--..}, at: [<c03ac644>] linkwatch_event+0x5/0x22
  #3:  (&ndev->lock){-.-+}, at: [<c0412441>] mld_ifc_timer_expire+0x17/0x1f=
b

the first lock's dependencies:
-> (&mc->mca_lock){-+..} ops: 10 {
    initial-use  at:
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c0142890>] __lock_acquire+0x4ba/0xc07
                         [<c0109ef2>] save_stack_trace+0x20/0x3a
                         [<c0142f95>] __lock_acquire+0xbbf/0xc07
                         [<c0412d32>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c043a872>] _spin_lock_bh+0x3b/0x64
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                         [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                         [<c0412d32>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                         [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                         [<c0402134>] ipv6_add_dev+0x21c/0x24b
                         [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
                         [<c05c5ae9>] addrconf_init+0x13/0x193
                         [<c019a04b>] proc_net_fops_create+0x10/0x21
                         [<c041a418>] ip6_flowlabel_init+0x1e/0x20
                         [<c05c59c9>] inet6_init+0x1f0/0x2ad
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    in-softirq-W at:
                         [<c0142816>] __lock_acquire+0x440/0xc07
                         [<c013fdfe>] get_lock_stats+0xd/0x2e
                         [<c013fe29>] put_lock_stats+0xa/0x1e
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c043a872>] _spin_lock_bh+0x3b/0x64
                         [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
                         [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c012e02e>] run_timer_softirq+0xfa/0x15d
                         [<c012a982>] __do_softirq+0x56/0xdb
                         [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
                         [<c012a994>] __do_softirq+0x68/0xdb
                         [<c012aa3d>] do_softirq+0x36/0x51
                         [<c012af26>] local_bh_enable_ip+0xad/0xed
                         [<c03bfa03>] rt_run_flush+0x64/0x8b
                         [<c03e9b8a>] fib_netdev_event+0x61/0x65
                         [<c013ac34>] notifier_call_chain+0x2a/0x52
                         [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a33d9>] netdev_state_change+0x18/0x29
                         [<c03ac611>] __linkwatch_run_queue+0x150/0x17e
                         [<c03ac65c>] linkwatch_event+0x1d/0x22
                         [<c0133d87>] run_workqueue+0xdb/0x1b6
                         [<c0133d33>] run_workqueue+0x87/0x1b6
                         [<c03ac63f>] linkwatch_event+0x0/0x22
                         [<c01347a7>] worker_thread+0x0/0x85
                         [<c0134820>] worker_thread+0x79/0x85
                         [<c0137255>] autoremove_wake_function+0x0/0x35
                         [<c013719e>] kthread+0x38/0x5e
                         [<c0137166>] kthread+0x0/0x5e
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                         [<c01417e2>] find_usage_backwards+0xbb/0xe2
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c014285e>] __lock_acquire+0x488/0xc07
                         [<c0109ef2>] save_stack_trace+0x20/0x3a
                         [<c0142f95>] __lock_acquire+0xbbf/0xc07
                         [<c0412d32>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c043a872>] _spin_lock_bh+0x3b/0x64
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c04129b6>] igmp6_group_added+0x18/0x11d
                         [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                         [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                         [<c0412d32>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                         [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                         [<c0402134>] ipv6_add_dev+0x21c/0x24b
                         [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
                         [<c05c5ae9>] addrconf_init+0x13/0x193
                         [<c019a04b>] proc_net_fops_create+0x10/0x21
                         [<c041a418>] ip6_flowlabel_init+0x1e/0x20
                         [<c05c59c9>] inet6_init+0x1f0/0x2ad
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c087e2d8>] __key.30803+0x0/0x8
  -> (_xmit_ETHER){-...} ops: 8 {
     initial-use  at:
                           [<c0142890>] __lock_acquire+0x4ba/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c014197a>] mark_lock+0x64/0x451
                           [<c014285e>] __lock_acquire+0x488/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
   -> (&on_slab_l3_key){....} ops: 859 {
      initial-use  at:
                             [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0142890>] __lock_acquire+0x4ba/0xc07
                             [<c013ae98>] __atomic_notifier_call_chain+0x0/=
0x94
                             [<c013af43>] atomic_notifier_call_chain+0x17/0=
x1a
                             [<c015023d>] get_page_from_freelist+0x25c/0x3e=
6
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c043a80e>] _spin_lock+0x36/0x5f
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c0155ccf>] mod_zone_page_state+0x35/0x3c
                             [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                             [<c01659cf>] kmem_cache_alloc+0x38/0x88
                             [<c0165d3f>] cache_alloc_refill+0x320/0x469
                             [<c01659cf>] kmem_cache_alloc+0x38/0x88
                             [<c05b31ca>] pidmap_init+0x15/0x149
                             [<c05a9872>] start_kernel+0x272/0x2cf
                             [<c05a90e0>] unknown_bootoption+0x0/0x195
                             [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c086574c>] on_slab_l3_key+0x0/0x8
   ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0143056>] lock_acquire+0x79/0x93
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c043a80e>] _spin_lock+0x36/0x5f
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c01659cf>] kmem_cache_alloc+0x38/0x88
    [<c03a2666>] __dev_addr_add+0x61/0xb4
    [<c03a63be>] dev_mc_add+0x43/0x6a
    [<c04129f4>] igmp6_group_added+0x56/0x11d
    [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] icmpv6_rcv+0x6d8/0x828
    [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0402134>] ipv6_add_dev+0x21c/0x24b
    [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0402717>] addrconf_notify+0x60/0x7b7
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0141da0>] mark_held_locks+0x39/0x53
    [<c0439946>] mutex_lock_nested+0x286/0x2ac
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a487c>] register_netdevice_notifier+0x49/0x126
    [<c05c5b83>] addrconf_init+0xad/0x193
    [<c05c5af1>] addrconf_init+0x1b/0x193
    [<c05c59c9>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

  ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043a872>] _spin_lock_bh+0x3b/0x64
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c04129f4>] igmp6_group_added+0x56/0x11d
    [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] icmpv6_rcv+0x6d8/0x828
    [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0402134>] ipv6_add_dev+0x21c/0x24b
    [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0402717>] addrconf_notify+0x60/0x7b7
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0141da0>] mark_held_locks+0x39/0x53
    [<c0439946>] mutex_lock_nested+0x286/0x2ac
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a487c>] register_netdevice_notifier+0x49/0x126
    [<c05c5b83>] addrconf_init+0xad/0x193
    [<c05c5af1>] addrconf_init+0x1b/0x193
    [<c05c59c9>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

  -> (&bonding_netdev_xmit_lock_key){-...} ops: 6 {
     initial-use  at:
                           [<c0142890>] __lock_acquire+0x4ba/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c014197a>] mark_lock+0x64/0x451
                           [<c014285e>] __lock_acquire+0x488/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0877804>] bonding_netdev_xmit_lock_key+0x0/0x8
   -> (&bond->lock){-.--} ops: 99 {
      initial-use  at:
                             [<c013fe29>] put_lock_stats+0xa/0x1e
                             [<c0142890>] __lock_acquire+0x4ba/0xc07
                             [<c0141da0>] mark_held_locks+0x39/0x53
                             [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c043a9fe>] _read_lock_bh+0x3b/0x64
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c03aacdb>] rtnl_fill_ifinfo+0x2bf/0x563
                             [<c03ab259>] rtmsg_ifinfo+0x5d/0xdf
                             [<c03ab31a>] rtnetlink_event+0x3f/0x42
                             [<c013ac34>] notifier_call_chain+0x2a/0x52
                             [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
                             [<c03a3ad2>] register_netdevice+0x2a7/0x2e7
                             [<c02ed842>] bond_create+0x1f2/0x26a
                             [<c05bed76>] bonding_init+0x761/0x7ea
                             [<c05be5de>] e1000_init_module+0x45/0x7c
                             [<c05a9499>] kernel_init+0x150/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
      hardirq-on-W at:
                             [<c014285e>] __lock_acquire+0x488/0xc07
                             [<c01208c9>] try_to_wake_up+0x2ce/0x2d8
                             [<c0142f95>] __lock_acquire+0xbbf/0xc07
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c02eda55>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c043a935>] _write_lock_bh+0x3b/0x64
                             [<c02eda55>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c02eda55>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c013fe29>] put_lock_stats+0xa/0x1e
                             [<c03a1dcf>] __dev_set_rx_mode+0x7b/0x7d
                             [<c03a1f69>] dev_set_rx_mode+0x23/0x36
                             [<c03a4644>] dev_open+0x5e/0x77
                             [<c03a3313>] dev_change_flags+0x9d/0x14b
                             [<c03a2117>] __dev_get_by_name+0x68/0x73
                             [<c03e4142>] devinet_ioctl+0x22b/0x536
                             [<c03a4439>] dev_ioctl+0x46f/0x5b7
                             [<c039a564>] sock_ioctl+0x167/0x18b
                             [<c039a3fd>] sock_ioctl+0x0/0x18b
                             [<c0172677>] do_ioctl+0x1f/0x62
                             [<c01728e7>] vfs_ioctl+0x22d/0x23f
                             [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                             [<c017292c>] sys_ioctl+0x33/0x4b
                             [<c0103e92>] sysenter_past_esp+0x5f/0xa5
                             [<ffffffff>] 0xffffffff
      softirq-on-R at:
                             [<c014197a>] mark_lock+0x64/0x451
                             [<c013583a>] __kernel_text_address+0x5/0xe
                             [<c0104ee2>] dump_trace+0x83/0x8d
                             [<c014287d>] __lock_acquire+0x4a7/0xc07
                             [<c013fc6a>] save_trace+0x37/0x89
                             [<c0133d33>] run_workqueue+0x87/0x1b6
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c02eee43>] bond_mii_monitor+0x19/0x85
                             [<c043aa5d>] _read_lock+0x36/0x5f
                             [<c02eee43>] bond_mii_monitor+0x19/0x85
                             [<c02eee43>] bond_mii_monitor+0x19/0x85
                             [<c0133d87>] run_workqueue+0xdb/0x1b6
                             [<c0133d33>] run_workqueue+0x87/0x1b6
                             [<c02eee2a>] bond_mii_monitor+0x0/0x85
                             [<c01347a7>] worker_thread+0x0/0x85
                             [<c0134820>] worker_thread+0x79/0x85
                             [<c0137255>] autoremove_wake_function+0x0/0x35
                             [<c013719e>] kthread+0x38/0x5e
                             [<c0137166>] kthread+0x0/0x5e
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
      hardirq-on-R at:
                             [<c013fdfe>] get_lock_stats+0xd/0x2e
                             [<c013fe29>] put_lock_stats+0xa/0x1e
                             [<c0142838>] __lock_acquire+0x462/0xc07
                             [<c0141da0>] mark_held_locks+0x39/0x53
                             [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c043a9fe>] _read_lock_bh+0x3b/0x64
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c02edca1>] bond_get_stats+0x28/0xd0
                             [<c03aacdb>] rtnl_fill_ifinfo+0x2bf/0x563
                             [<c03ab259>] rtmsg_ifinfo+0x5d/0xdf
                             [<c03ab31a>] rtnetlink_event+0x3f/0x42
                             [<c013ac34>] notifier_call_chain+0x2a/0x52
                             [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
                             [<c03a3ad2>] register_netdevice+0x2a7/0x2e7
                             [<c02ed842>] bond_create+0x1f2/0x26a
                             [<c05bed76>] bonding_init+0x761/0x7ea
                             [<c05be5de>] e1000_init_module+0x45/0x7c
                             [<c05a9499>] kernel_init+0x150/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c08777d0>] __key.32976+0x0/0x8
    -> (_xmit_ETHER){-...} ops: 8 {
       initial-use  at:
                               [<c0142890>] __lock_acquire+0x4ba/0xc07
                               [<c0143056>] lock_acquire+0x79/0x93
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c043a872>] _spin_lock_bh+0x3b/0x64
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c04129f4>] igmp6_group_added+0x56/0x11d
                               [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                               [<c0410100>] icmpv6_rcv+0x6d8/0x828
                               [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                               [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                               [<c0402134>] ipv6_add_dev+0x21c/0x24b
                               [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/=
0x1ef
                               [<c0402717>] addrconf_notify+0x60/0x7b7
                               [<c0142f95>] __lock_acquire+0xbbf/0xc07
                               [<c0141da0>] mark_held_locks+0x39/0x53
                               [<c0439946>] mutex_lock_nested+0x286/0x2ac
                               [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                               [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                               [<c03a4841>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a4841>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a487c>] register_netdevice_notifier+0x4=
9/0x126
                               [<c05c5b83>] addrconf_init+0xad/0x193
                               [<c05c5af1>] addrconf_init+0x1b/0x193
                               [<c05c59c9>] inet6_init+0x1f0/0x2ad
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
       hardirq-on-W at:
                               [<c014197a>] mark_lock+0x64/0x451
                               [<c014285e>] __lock_acquire+0x488/0xc07
                               [<c0143056>] lock_acquire+0x79/0x93
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c043a872>] _spin_lock_bh+0x3b/0x64
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c03a6395>] dev_mc_add+0x1a/0x6a
                               [<c04129f4>] igmp6_group_added+0x56/0x11d
                               [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                               [<c0410100>] icmpv6_rcv+0x6d8/0x828
                               [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                               [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                               [<c0402134>] ipv6_add_dev+0x21c/0x24b
                               [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/=
0x1ef
                               [<c0402717>] addrconf_notify+0x60/0x7b7
                               [<c0142f95>] __lock_acquire+0xbbf/0xc07
                               [<c0141da0>] mark_held_locks+0x39/0x53
                               [<c0439946>] mutex_lock_nested+0x286/0x2ac
                               [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                               [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                               [<c03a4841>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a4841>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a487c>] register_netdevice_notifier+0x4=
9/0x126
                               [<c05c5b83>] addrconf_init+0xad/0x193
                               [<c05c5af1>] addrconf_init+0x1b/0x193
                               [<c05c59c9>] inet6_init+0x1f0/0x2ad
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
     }
     ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
     -> (&on_slab_l3_key){....} ops: 859 {
        initial-use  at:
                                 [<c043aed5>] _spin_unlock_irqrestore+0x40/=
0x58
                                 [<c0142890>] __lock_acquire+0x4ba/0xc07
                                 [<c013ae98>] __atomic_notifier_call_chain+=
0x0/0x94
                                 [<c013af43>] atomic_notifier_call_chain+0x=
17/0x1a
                                 [<c015023d>] get_page_from_freelist+0x25c/=
0x3e6
                                 [<c0143056>] lock_acquire+0x79/0x93
                                 [<c0165a73>] cache_alloc_refill+0x54/0x469
                                 [<c043a80e>] _spin_lock+0x36/0x5f
                                 [<c0165a73>] cache_alloc_refill+0x54/0x469
                                 [<c0165a73>] cache_alloc_refill+0x54/0x469
                                 [<c0155ccf>] mod_zone_page_state+0x35/0x3c
                                 [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                                 [<c01659cf>] kmem_cache_alloc+0x38/0x88
                                 [<c0165d3f>] cache_alloc_refill+0x320/0x46=
9
                                 [<c01659cf>] kmem_cache_alloc+0x38/0x88
                                 [<c05b31ca>] pidmap_init+0x15/0x149
                                 [<c05a9872>] start_kernel+0x272/0x2cf
                                 [<c05a90e0>] unknown_bootoption+0x0/0x195
                                 [<ffffffff>] 0xffffffff
      }
      ... key      at: [<c086574c>] on_slab_l3_key+0x0/0x8
     ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0143056>] lock_acquire+0x79/0x93
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c043a80e>] _spin_lock+0x36/0x5f
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c01659cf>] kmem_cache_alloc+0x38/0x88
    [<c03a2666>] __dev_addr_add+0x61/0xb4
    [<c03a63be>] dev_mc_add+0x43/0x6a
    [<c04129f4>] igmp6_group_added+0x56/0x11d
    [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] icmpv6_rcv+0x6d8/0x828
    [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0402134>] ipv6_add_dev+0x21c/0x24b
    [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0402717>] addrconf_notify+0x60/0x7b7
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0141da0>] mark_held_locks+0x39/0x53
    [<c0439946>] mutex_lock_nested+0x286/0x2ac
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a487c>] register_netdevice_notifier+0x49/0x126
    [<c05c5b83>] addrconf_init+0xad/0x193
    [<c05c5af1>] addrconf_init+0x1b/0x193
    [<c05c59c9>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

    ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
    [<c0109ef2>] save_stack_trace+0x20/0x3a
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043a872>] _spin_lock_bh+0x3b/0x64
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c02ee472>] bond_change_active_slave+0x1a9/0x3bf
    [<c02ec7a3>] bond_update_speed_duplex+0x26/0x65
    [<c02ee991>] bond_select_active_slave+0x97/0xd3
    [<c02ed20b>] bond_compute_features+0x45/0x84
    [<c02ef9a4>] bond_enslave+0x6a7/0x884
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f617b>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fcd>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8b7>] dev_attr_store+0x27/0x2c
    [<c019bda1>] sysfs_write_file+0xad/0xe0
    [<c019bcf4>] sysfs_write_file+0x0/0xe0
    [<c0168e5c>] vfs_write+0x8a/0x10c
    [<c0118562>] do_page_fault+0x0/0x54a
    [<c01693e1>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

    -> (lweventlist_lock){.+..} ops: 10 {
       initial-use  at:
                               [<c014197a>] mark_lock+0x64/0x451
                               [<c0142890>] __lock_acquire+0x4ba/0xc07
                               [<c02e363c>] e1000_read_phy_reg+0x1c7/0x1d3
                               [<c02e346b>] e1000_write_phy_reg+0xb9/0xc3
                               [<c024a82e>] delay_tsc+0x25/0x3b
                               [<c0143056>] lock_acquire+0x79/0x93
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c03ac4af>] linkwatch_fire_event+0x25/0x37
                               [<c02e1c23>] e1000_probe+0xad1/0xbe8
                               [<c0257f1b>] pci_device_probe+0x36/0x57
                               [<c02d0e3f>] driver_probe_device+0xe1/0x15f
                               [<c043ae09>] _spin_unlock+0x25/0x3b
                               [<c0437e92>] klist_next+0x58/0x6d
                               [<c02d0f4f>] __driver_attach+0x0/0x7f
                               [<c02d0f98>] __driver_attach+0x49/0x7f
                               [<c02d03e3>] bus_for_each_dev+0x36/0x58
                               [<c02d0c97>] driver_attach+0x16/0x18
                               [<c02d0f4f>] __driver_attach+0x0/0x7f
                               [<c02d06da>] bus_add_driver+0x6d/0x18d
                               [<c0258065>] __pci_register_driver+0x53/0x7f
                               [<c05be5de>] e1000_init_module+0x45/0x7c
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
       in-softirq-W at:
                               [<c011d1c0>] __wake_up_common+0x32/0x5c
                               [<c0142816>] __lock_acquire+0x440/0xc07
                               [<c043aed5>] _spin_unlock_irqrestore+0x40/0x=
58
                               [<c0143056>] lock_acquire+0x79/0x93
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c02dfee1>] e1000_watchdog+0x0/0x5c9
                               [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                               [<c03ac4af>] linkwatch_fire_event+0x25/0x37
                               [<c03af436>] netif_carrier_on+0x16/0x27
                               [<c02e0136>] e1000_watchdog+0x255/0x5c9
                               [<c02dfee1>] e1000_watchdog+0x0/0x5c9
                               [<c012e02e>] run_timer_softirq+0xfa/0x15d
                               [<c012a982>] __do_softirq+0x56/0xdb
                               [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
                               [<c012a994>] __do_softirq+0x68/0xdb
                               [<c012aa3d>] do_softirq+0x36/0x51
                               [<c012abe3>] irq_exit+0x43/0x4e
                               [<c0114122>] smp_apic_timer_interrupt+0x74/0=
x80
                               [<c0104a01>] apic_timer_interrupt+0x29/0x38
                               [<c0104a0b>] apic_timer_interrupt+0x33/0x38
                               [<c01600d8>] sys_swapon+0x254/0x9aa
                               [<c01021a6>] mwait_idle_with_hints+0x3b/0x3f
                               [<c0102447>] mwait_idle+0x0/0xf
                               [<c0102581>] cpu_idle+0x99/0xc6
                               [<c05a98c7>] start_kernel+0x2c7/0x2cf
                               [<c05a90e0>] unknown_bootoption+0x0/0x195
                               [<ffffffff>] 0xffffffff
     }
     ... key      at: [<c058a194>] lweventlist_lock+0x14/0x40
    ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c03ac4af>] linkwatch_fire_event+0x25/0x37
    [<c03af436>] netif_carrier_on+0x16/0x27
    [<c02ede0c>] bond_set_carrier+0x31/0x55
    [<c02ee998>] bond_select_active_slave+0x9e/0xd3
    [<c02ed20b>] bond_compute_features+0x45/0x84
    [<c02ef9a4>] bond_enslave+0x6a7/0x884
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f617b>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fcd>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8b7>] dev_attr_store+0x27/0x2c
    [<c019bda1>] sysfs_write_file+0xad/0xe0
    [<c019bcf4>] sysfs_write_file+0x0/0xe0
    [<c0168e5c>] vfs_write+0x8a/0x10c
    [<c0118562>] do_page_fault+0x0/0x54a
    [<c01693e1>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

   ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c02eda55>] bond_set_multicast_list+0x1d/0x241
    [<c0143056>] lock_acquire+0x79/0x93
    [<c02eda55>] bond_set_multicast_list+0x1d/0x241
    [<c043a935>] _write_lock_bh+0x3b/0x64
    [<c02eda55>] bond_set_multicast_list+0x1d/0x241
    [<c02eda55>] bond_set_multicast_list+0x1d/0x241
    [<c013fe29>] put_lock_stats+0xa/0x1e
    [<c03a1dcf>] __dev_set_rx_mode+0x7b/0x7d
    [<c03a1f69>] dev_set_rx_mode+0x23/0x36
    [<c03a4644>] dev_open+0x5e/0x77
    [<c03a3313>] dev_change_flags+0x9d/0x14b
    [<c03a2117>] __dev_get_by_name+0x68/0x73
    [<c03e4142>] devinet_ioctl+0x22b/0x536
    [<c03a4439>] dev_ioctl+0x46f/0x5b7
    [<c039a564>] sock_ioctl+0x167/0x18b
    [<c039a3fd>] sock_ioctl+0x0/0x18b
    [<c0172677>] do_ioctl+0x1f/0x62
    [<c01728e7>] vfs_ioctl+0x22d/0x23f
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c017292c>] sys_ioctl+0x33/0x4b
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

  ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043a872>] _spin_lock_bh+0x3b/0x64
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c04129f4>] igmp6_group_added+0x56/0x11d
    [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] icmpv6_rcv+0x6d8/0x828
    [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0402134>] ipv6_add_dev+0x21c/0x24b
    [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0402717>] addrconf_notify+0x60/0x7b7
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0141da0>] mark_held_locks+0x39/0x53
    [<c0439946>] mutex_lock_nested+0x286/0x2ac
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a487c>] register_netdevice_notifier+0x49/0x126
    [<c05c5b83>] addrconf_init+0xad/0x193
    [<c05c5af1>] addrconf_init+0x1b/0x193
    [<c05c59c9>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff


the second lock's dependencies:
-> (&bond->lock){-.--} ops: 99 {
    initial-use  at:
                         [<c013fe29>] put_lock_stats+0xa/0x1e
                         [<c0142890>] __lock_acquire+0x4ba/0xc07
                         [<c0141da0>] mark_held_locks+0x39/0x53
                         [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c043a9fe>] _read_lock_bh+0x3b/0x64
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c03aacdb>] rtnl_fill_ifinfo+0x2bf/0x563
                         [<c03ab259>] rtmsg_ifinfo+0x5d/0xdf
                         [<c03ab31a>] rtnetlink_event+0x3f/0x42
                         [<c013ac34>] notifier_call_chain+0x2a/0x52
                         [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a3ad2>] register_netdevice+0x2a7/0x2e7
                         [<c02ed842>] bond_create+0x1f2/0x26a
                         [<c05bed76>] bonding_init+0x761/0x7ea
                         [<c05be5de>] e1000_init_module+0x45/0x7c
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                         [<c014285e>] __lock_acquire+0x488/0xc07
                         [<c01208c9>] try_to_wake_up+0x2ce/0x2d8
                         [<c0142f95>] __lock_acquire+0xbbf/0xc07
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c02eda55>] bond_set_multicast_list+0x1d/0x241
                         [<c043a935>] _write_lock_bh+0x3b/0x64
                         [<c02eda55>] bond_set_multicast_list+0x1d/0x241
                         [<c02eda55>] bond_set_multicast_list+0x1d/0x241
                         [<c013fe29>] put_lock_stats+0xa/0x1e
                         [<c03a1dcf>] __dev_set_rx_mode+0x7b/0x7d
                         [<c03a1f69>] dev_set_rx_mode+0x23/0x36
                         [<c03a4644>] dev_open+0x5e/0x77
                         [<c03a3313>] dev_change_flags+0x9d/0x14b
                         [<c03a2117>] __dev_get_by_name+0x68/0x73
                         [<c03e4142>] devinet_ioctl+0x22b/0x536
                         [<c03a4439>] dev_ioctl+0x46f/0x5b7
                         [<c039a564>] sock_ioctl+0x167/0x18b
                         [<c039a3fd>] sock_ioctl+0x0/0x18b
                         [<c0172677>] do_ioctl+0x1f/0x62
                         [<c01728e7>] vfs_ioctl+0x22d/0x23f
                         [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                         [<c017292c>] sys_ioctl+0x33/0x4b
                         [<c0103e92>] sysenter_past_esp+0x5f/0xa5
                         [<ffffffff>] 0xffffffff
    softirq-on-R at:
                         [<c014197a>] mark_lock+0x64/0x451
                         [<c013583a>] __kernel_text_address+0x5/0xe
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c014287d>] __lock_acquire+0x4a7/0xc07
                         [<c013fc6a>] save_trace+0x37/0x89
                         [<c0133d33>] run_workqueue+0x87/0x1b6
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c02eee43>] bond_mii_monitor+0x19/0x85
                         [<c043aa5d>] _read_lock+0x36/0x5f
                         [<c02eee43>] bond_mii_monitor+0x19/0x85
                         [<c02eee43>] bond_mii_monitor+0x19/0x85
                         [<c0133d87>] run_workqueue+0xdb/0x1b6
                         [<c0133d33>] run_workqueue+0x87/0x1b6
                         [<c02eee2a>] bond_mii_monitor+0x0/0x85
                         [<c01347a7>] worker_thread+0x0/0x85
                         [<c0134820>] worker_thread+0x79/0x85
                         [<c0137255>] autoremove_wake_function+0x0/0x35
                         [<c013719e>] kthread+0x38/0x5e
                         [<c0137166>] kthread+0x0/0x5e
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-R at:
                         [<c013fdfe>] get_lock_stats+0xd/0x2e
                         [<c013fe29>] put_lock_stats+0xa/0x1e
                         [<c0142838>] __lock_acquire+0x462/0xc07
                         [<c0141da0>] mark_held_locks+0x39/0x53
                         [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                         [<c0143056>] lock_acquire+0x79/0x93
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c043a9fe>] _read_lock_bh+0x3b/0x64
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c02edca1>] bond_get_stats+0x28/0xd0
                         [<c03aacdb>] rtnl_fill_ifinfo+0x2bf/0x563
                         [<c03ab259>] rtmsg_ifinfo+0x5d/0xdf
                         [<c03ab31a>] rtnetlink_event+0x3f/0x42
                         [<c013ac34>] notifier_call_chain+0x2a/0x52
                         [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a3ad2>] register_netdevice+0x2a7/0x2e7
                         [<c02ed842>] bond_create+0x1f2/0x26a
                         [<c05bed76>] bonding_init+0x761/0x7ea
                         [<c05be5de>] e1000_init_module+0x45/0x7c
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c08777d0>] __key.32976+0x0/0x8
  -> (_xmit_ETHER){-...} ops: 8 {
     initial-use  at:
                           [<c0142890>] __lock_acquire+0x4ba/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c014197a>] mark_lock+0x64/0x451
                           [<c014285e>] __lock_acquire+0x488/0xc07
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c043a872>] _spin_lock_bh+0x3b/0x64
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c03a6395>] dev_mc_add+0x1a/0x6a
                           [<c04129f4>] igmp6_group_added+0x56/0x11d
                           [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] icmpv6_rcv+0x6d8/0x828
                           [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0402134>] ipv6_add_dev+0x21c/0x24b
                           [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0402717>] addrconf_notify+0x60/0x7b7
                           [<c0142f95>] __lock_acquire+0xbbf/0xc07
                           [<c0141da0>] mark_held_locks+0x39/0x53
                           [<c0439946>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                           [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a4841>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a487c>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5b83>] addrconf_init+0xad/0x193
                           [<c05c5af1>] addrconf_init+0x1b/0x193
                           [<c05c59c9>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
   -> (&on_slab_l3_key){....} ops: 859 {
      initial-use  at:
                             [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0142890>] __lock_acquire+0x4ba/0xc07
                             [<c013ae98>] __atomic_notifier_call_chain+0x0/=
0x94
                             [<c013af43>] atomic_notifier_call_chain+0x17/0=
x1a
                             [<c015023d>] get_page_from_freelist+0x25c/0x3e=
6
                             [<c0143056>] lock_acquire+0x79/0x93
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c043a80e>] _spin_lock+0x36/0x5f
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c0165a73>] cache_alloc_refill+0x54/0x469
                             [<c0155ccf>] mod_zone_page_state+0x35/0x3c
                             [<c0141f93>] trace_hardirqs_on+0x122/0x14c
                             [<c01659cf>] kmem_cache_alloc+0x38/0x88
                             [<c0165d3f>] cache_alloc_refill+0x320/0x469
                             [<c01659cf>] kmem_cache_alloc+0x38/0x88
                             [<c05b31ca>] pidmap_init+0x15/0x149
                             [<c05a9872>] start_kernel+0x272/0x2cf
                             [<c05a90e0>] unknown_bootoption+0x0/0x195
                             [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c086574c>] on_slab_l3_key+0x0/0x8
   ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0143056>] lock_acquire+0x79/0x93
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c043a80e>] _spin_lock+0x36/0x5f
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c0165a73>] cache_alloc_refill+0x54/0x469
    [<c01659cf>] kmem_cache_alloc+0x38/0x88
    [<c03a2666>] __dev_addr_add+0x61/0xb4
    [<c03a63be>] dev_mc_add+0x43/0x6a
    [<c04129f4>] igmp6_group_added+0x56/0x11d
    [<c0412d88>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] icmpv6_rcv+0x6d8/0x828
    [<c0412dbd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412ae5>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0402134>] ipv6_add_dev+0x21c/0x24b
    [<c040b95d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0402717>] addrconf_notify+0x60/0x7b7
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0141da0>] mark_held_locks+0x39/0x53
    [<c0439946>] mutex_lock_nested+0x286/0x2ac
    [<c0141f93>] trace_hardirqs_on+0x122/0x14c
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a4841>] register_netdevice_notifier+0xe/0x126
    [<c03a487c>] register_netdevice_notifier+0x49/0x126
    [<c05c5b83>] addrconf_init+0xad/0x193
    [<c05c5af1>] addrconf_init+0x1b/0x193
    [<c05c59c9>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

  ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
    [<c0109ef2>] save_stack_trace+0x20/0x3a
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c043a872>] _spin_lock_bh+0x3b/0x64
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c03a6395>] dev_mc_add+0x1a/0x6a
    [<c02ee472>] bond_change_active_slave+0x1a9/0x3bf
    [<c02ec7a3>] bond_update_speed_duplex+0x26/0x65
    [<c02ee991>] bond_select_active_slave+0x97/0xd3
    [<c02ed20b>] bond_compute_features+0x45/0x84
    [<c02ef9a4>] bond_enslave+0x6a7/0x884
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f617b>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fcd>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8b7>] dev_attr_store+0x27/0x2c
    [<c019bda1>] sysfs_write_file+0xad/0xe0
    [<c019bcf4>] sysfs_write_file+0x0/0xe0
    [<c0168e5c>] vfs_write+0x8a/0x10c
    [<c0118562>] do_page_fault+0x0/0x54a
    [<c01693e1>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

  -> (lweventlist_lock){.+..} ops: 10 {
     initial-use  at:
                           [<c014197a>] mark_lock+0x64/0x451
                           [<c0142890>] __lock_acquire+0x4ba/0xc07
                           [<c02e363c>] e1000_read_phy_reg+0x1c7/0x1d3
                           [<c02e346b>] e1000_write_phy_reg+0xb9/0xc3
                           [<c024a82e>] delay_tsc+0x25/0x3b
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c03ac4af>] linkwatch_fire_event+0x25/0x37
                           [<c02e1c23>] e1000_probe+0xad1/0xbe8
                           [<c0257f1b>] pci_device_probe+0x36/0x57
                           [<c02d0e3f>] driver_probe_device+0xe1/0x15f
                           [<c043ae09>] _spin_unlock+0x25/0x3b
                           [<c0437e92>] klist_next+0x58/0x6d
                           [<c02d0f4f>] __driver_attach+0x0/0x7f
                           [<c02d0f98>] __driver_attach+0x49/0x7f
                           [<c02d03e3>] bus_for_each_dev+0x36/0x58
                           [<c02d0c97>] driver_attach+0x16/0x18
                           [<c02d0f4f>] __driver_attach+0x0/0x7f
                           [<c02d06da>] bus_add_driver+0x6d/0x18d
                           [<c0258065>] __pci_register_driver+0x53/0x7f
                           [<c05be5de>] e1000_init_module+0x45/0x7c
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     in-softirq-W at:
                           [<c011d1c0>] __wake_up_common+0x32/0x5c
                           [<c0142816>] __lock_acquire+0x440/0xc07
                           [<c043aed5>] _spin_unlock_irqrestore+0x40/0x58
                           [<c0143056>] lock_acquire+0x79/0x93
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c02dfee1>] e1000_watchdog+0x0/0x5c9
                           [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
                           [<c03ac4af>] linkwatch_fire_event+0x25/0x37
                           [<c03af436>] netif_carrier_on+0x16/0x27
                           [<c02e0136>] e1000_watchdog+0x255/0x5c9
                           [<c02dfee1>] e1000_watchdog+0x0/0x5c9
                           [<c012e02e>] run_timer_softirq+0xfa/0x15d
                           [<c012a982>] __do_softirq+0x56/0xdb
                           [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
                           [<c012a994>] __do_softirq+0x68/0xdb
                           [<c012aa3d>] do_softirq+0x36/0x51
                           [<c012abe3>] irq_exit+0x43/0x4e
                           [<c0114122>] smp_apic_timer_interrupt+0x74/0x80
                           [<c0104a01>] apic_timer_interrupt+0x29/0x38
                           [<c0104a0b>] apic_timer_interrupt+0x33/0x38
                           [<c01600d8>] sys_swapon+0x254/0x9aa
                           [<c01021a6>] mwait_idle_with_hints+0x3b/0x3f
                           [<c0102447>] mwait_idle+0x0/0xf
                           [<c0102581>] cpu_idle+0x99/0xc6
                           [<c05a98c7>] start_kernel+0x2c7/0x2cf
                           [<c05a90e0>] unknown_bootoption+0x0/0x195
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c058a194>] lweventlist_lock+0x14/0x40
  ... acquired at:
    [<c0142df3>] __lock_acquire+0xa1d/0xc07
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c0142f95>] __lock_acquire+0xbbf/0xc07
    [<c0143056>] lock_acquire+0x79/0x93
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c043ab8f>] _spin_lock_irqsave+0x3f/0x6c
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c03ac3eb>] linkwatch_add_event+0xd/0x2c
    [<c03ac4af>] linkwatch_fire_event+0x25/0x37
    [<c03af436>] netif_carrier_on+0x16/0x27
    [<c02ede0c>] bond_set_carrier+0x31/0x55
    [<c02ee998>] bond_select_active_slave+0x9e/0xd3
    [<c02ed20b>] bond_compute_features+0x45/0x84
    [<c02ef9a4>] bond_enslave+0x6a7/0x884
    [<c0439964>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f617b>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fcd>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8b7>] dev_attr_store+0x27/0x2c
    [<c019bda1>] sysfs_write_file+0xad/0xe0
    [<c019bcf4>] sysfs_write_file+0x0/0xe0
    [<c0168e5c>] vfs_write+0x8a/0x10c
    [<c0118562>] do_page_fault+0x0/0x54a
    [<c01693e1>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff


stack backtrace:
Pid: 9, comm: events/0 Not tainted 2.6.24-rc7 #1
  [<c0140b2c>] print_irq_inversion_bug+0x108/0x112
  [<c0141911>] check_usage_forwards+0x3c/0x41
  [<c0141afd>] mark_lock+0x1e7/0x451
  [<c0142816>] __lock_acquire+0x440/0xc07
  [<c013fdfe>] get_lock_stats+0xd/0x2e
  [<c013fe29>] put_lock_stats+0xa/0x1e
  [<c0143056>] lock_acquire+0x79/0x93
  [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c043a872>] _spin_lock_bh+0x3b/0x64
  [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
  [<c041242a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c012e02e>] run_timer_softirq+0xfa/0x15d
  [<c012a982>] __do_softirq+0x56/0xdb
  [<c0141f7d>] trace_hardirqs_on+0x10c/0x14c
  [<c012a994>] __do_softirq+0x68/0xdb
  [<c012aa3d>] do_softirq+0x36/0x51
  [<c012af26>] local_bh_enable_ip+0xad/0xed
  [<c03bfa03>] rt_run_flush+0x64/0x8b
  [<c03e9b8a>] fib_netdev_event+0x61/0x65
  [<c013ac34>] notifier_call_chain+0x2a/0x52
  [<c013ac7e>] raw_notifier_call_chain+0x17/0x1a
  [<c03a33d9>] netdev_state_change+0x18/0x29
  [<c03ac611>] __linkwatch_run_queue+0x150/0x17e
  [<c03ac65c>] linkwatch_event+0x1d/0x22
  [<c0133d87>] run_workqueue+0xdb/0x1b6
  [<c0133d33>] run_workqueue+0x87/0x1b6
  [<c03ac63f>] linkwatch_event+0x0/0x22
  [<c01347a7>] worker_thread+0x0/0x85
  [<c0134820>] worker_thread+0x79/0x85
  [<c0137255>] autoremove_wake_function+0x0/0x35
  [<c013719e>] kthread+0x38/0x5e
  [<c0137166>] kthread+0x0/0x5e
  [<c0104baf>] kernel_thread_helper+0x7/0x10
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
bonding: bond0: enslaving eth1 as a backup interface with a down link.
bond0: no IPv6 routers present

No other patches were applied.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1738103207-1200617890=:4570--
