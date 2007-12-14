From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Fri, 14 Dec 2007 19:57:42 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death>
 <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl>
 <20071214182638.GC25879@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-595068131-1197658662=:12202"
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:58465 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758175AbXLNS64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 13:58:56 -0500
In-Reply-To: <20071214182638.GC25879@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-595068131-1197658662=:12202
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 14 Dec 2007, Andy Gospodarek wrote:

> On Fri, Dec 14, 2007 at 05:14:57PM +0100, Krzysztof Oledzki wrote:
>>
>>
>> On Wed, 12 Dec 2007, Jay Vosburgh wrote:
>>
>>> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>>
>>>>> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>> drivers/net/bonding/bond_sysfs.c
>>>>> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>> +++ a/drivers/net/bonding/bond_sysfs.c
>>>>> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
>>>>> out:
>>>>>       write_unlock_bh(&bond->lock);
>>>>>
>>>>> -       rtnl_unlock();
>>>>> -
>>>>
>>>> Looking at the changeset that added this perhaps the intention
>>>> is to hold the lock? If so we should add an rtnl_lock to the start
>>>> of the function.
>>>
>>> =09Yes, this function needs to hold locks, and more than just
>>> what's there now.  I believe the following should be correct; I haven't
>>> tested it, though (I'm supposedly on vacation right now).
>>>
>>> =09The following change should be correct for the
>>> bonding_store_primary case discussed in this thread, and also corrects
>>> the bonding_store_active case which performs similar functions.
>>>
>>> =09The bond_change_active_slave and bond_select_active_slave
>>> functions both require rtnl, bond->lock for read and curr_slave_lock fo=
r
>>> write_bh, and no other locks.  This is so that the lower level
>>> mode-specific functions can release locks down to just rtnl in order to
>>> call, e.g., dev_set_mac_address with the locks it expects (rtnl only).
>>>
>>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>>>
>>> diff --git a/drivers/net/bonding/bond_sysfs.c
>>> b/drivers/net/bonding/bond_sysfs.c
>>> index 11b76b3..28a2d80 100644
>>> --- a/drivers/net/bonding/bond_sysfs.c
>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>> @@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct devi=
ce
>>> *d,
>>> =09struct slave *slave;
>>> =09struct bonding *bond =3D to_bond(d);
>>>
>>> -=09write_lock_bh(&bond->lock);
>>> +=09rtnl_lock();
>>> +=09read_lock(&bond->lock);
>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>> +
>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>> =09=09printk(KERN_INFO DRV_NAME
>>> =09=09       ": %s: Unable to set primary slave; %s is in mode
>>> =09=09       %d\n",
>>> @@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct devic=
e
>>> *d,
>>> =09=09}
>>> =09}
>>> out:
>>> -=09write_unlock_bh(&bond->lock);
>>> -
>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>> +=09read_unlock(&bond->lock);
>>> =09rtnl_unlock();
>>>
>>> =09return count;
>>> @@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(struct
>>> device *d,
>>> =09struct bonding *bond =3D to_bond(d);
>>>
>>> =09rtnl_lock();
>>> -=09write_lock_bh(&bond->lock);
>>> +=09read_lock(&bond->lock);
>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>>
>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>> =09=09printk(KERN_INFO DRV_NAME
>>> @@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(struct
>>> device *d,
>>> =09=09}
>>> =09}
>>> out:
>>> -=09write_unlock_bh(&bond->lock);
>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>> +=09read_unlock(&bond->lock);
>>> =09rtnl_unlock();
>>>
>>> =09return count;
>>
>> Vanilla 2.6.24-rc5 plus this patch:
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
>> [ INFO: possible irq lock inversion dependency detected ]
>> 2.6.24-rc5 #1
>> ---------------------------------------------------------
>> events/0/9 just changed the state of lock:
>>  (&mc->mca_lock){-+..}, at: [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1f=
b
>> but this lock took another, soft-read-irq-unsafe lock in the past:
>>  (&bond->lock){-.--}
>>
>> and interrupts could create inverse lock ordering between them.
>>
>>
>
> Grrr, I should have seen that -- sorry.  Try your luck with this instead:
<CUT>

No luck.

bonding: bond0: setting mode to active-backup (1).
bonding: bond0: Setting MII monitoring interval to 100.
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: Adding slave eth0.
e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX/TX
bonding: bond0: making interface eth0 the new active one.
bonding: bond0: first active interface up!
bonding: bond0: enslaving eth0 as an active interface with an up link.
bonding: bond0: Adding slave eth1.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[ INFO: possible irq lock inversion dependency detected ]
2.6.24-rc5 #1
---------------------------------------------------------
events/0/9 just changed the state of lock:
  (&mc->mca_lock){-+..}, at: [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
but this lock took another, soft-read-irq-unsafe lock in the past:
  (&bond->lock){-.--}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
4 locks held by events/0/9:
  #0:  (events){--..}, at: [<c0133c57>] run_workqueue+0x87/0x1b6
  #1:  ((linkwatch_work).work){--..}, at: [<c0133c57>] run_workqueue+0x87/0=
x1b6
  #2:  (rtnl_mutex){--..}, at: [<c03abd50>] linkwatch_event+0x5/0x22
  #3:  (&ndev->lock){-.-+}, at: [<c0411b61>] mld_ifc_timer_expire+0x17/0x1f=
b

the first lock's dependencies:
-> (&mc->mca_lock){-+..} ops: 10 {
    initial-use  at:
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c014289c>] __lock_acquire+0x4ba/0xc07
                         [<c0109ef2>] save_stack_trace+0x20/0x3a
                         [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                         [<c0412452>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c0439d62>] _spin_lock_bh+0x3b/0x64
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                         [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                         [<c0412452>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                         [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                         [<c0401834>] ipv6_add_dev+0x21c/0x24b
                         [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
                         [<c05c5b40>] addrconf_init+0x13/0x193
                         [<c0199f63>] proc_net_fops_create+0x10/0x21
                         [<c0419b38>] ip6_flowlabel_init+0x1e/0x20
                         [<c05c5a20>] inet6_init+0x1f0/0x2ad
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    in-softirq-W at:
                         [<c0142822>] __lock_acquire+0x440/0xc07
                         [<c013fe0a>] get_lock_stats+0xd/0x2e
                         [<c013fe35>] put_lock_stats+0xa/0x1e
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c0439d62>] _spin_lock_bh+0x3b/0x64
                         [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
                         [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
                         [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
                         [<c012df52>] run_timer_softirq+0xfa/0x15d
                         [<c012a8a6>] __do_softirq+0x56/0xdb
                         [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
                         [<c012a8b8>] __do_softirq+0x68/0xdb
                         [<c012a961>] do_softirq+0x36/0x51
                         [<c012ae4a>] local_bh_enable_ip+0xad/0xed
                         [<c03bf107>] rt_run_flush+0x64/0x8b
                         [<c03e9296>] fib_netdev_event+0x61/0x65
                         [<c013ac20>] notifier_call_chain+0x2a/0x52
                         [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a2ae5>] netdev_state_change+0x18/0x29
                         [<c03abd1d>] __linkwatch_run_queue+0x150/0x17e
                         [<c03abd68>] linkwatch_event+0x1d/0x22
                         [<c0133cab>] run_workqueue+0xdb/0x1b6
                         [<c0133c57>] run_workqueue+0x87/0x1b6
                         [<c03abd4b>] linkwatch_event+0x0/0x22
                         [<c01346cb>] worker_thread+0x0/0x85
                         [<c0134744>] worker_thread+0x79/0x85
                         [<c0137179>] autoremove_wake_function+0x0/0x35
                         [<c01370c2>] kthread+0x38/0x5e
                         [<c013708a>] kthread+0x0/0x5e
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                         [<c01417ee>] find_usage_backwards+0xbb/0xe2
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c014286a>] __lock_acquire+0x488/0xc07
                         [<c0109ef2>] save_stack_trace+0x20/0x3a
                         [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                         [<c0412452>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c0439d62>] _spin_lock_bh+0x3b/0x64
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c04120d6>] igmp6_group_added+0x18/0x11d
                         [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                         [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                         [<c0412452>] ipv6_dev_mc_inc+0x24d/0x31c
                         [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                         [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                         [<c0401834>] ipv6_add_dev+0x21c/0x24b
                         [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
                         [<c05c5b40>] addrconf_init+0x13/0x193
                         [<c0199f63>] proc_net_fops_create+0x10/0x21
                         [<c0419b38>] ip6_flowlabel_init+0x1e/0x20
                         [<c05c5a20>] inet6_init+0x1f0/0x2ad
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c087e2d8>] __key.30798+0x0/0x8
  -> (_xmit_ETHER){-...} ops: 8 {
     initial-use  at:
                           [<c014289c>] __lock_acquire+0x4ba/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>]=20
ndisc_ifinfo_sysctl_change+0x0/0x1ef
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c0141986>] mark_lock+0x64/0x451
                           [<c014286a>] __lock_acquire+0x488/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
  ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0439d62>] _spin_lock_bh+0x3b/0x64
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0412114>] igmp6_group_added+0x56/0x11d
    [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] igmp6_mc_seq_start+0xde/0x138
    [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0401834>] ipv6_add_dev+0x21c/0x24b
    [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0401e17>] addrconf_notify+0x60/0x7b7
    [<c0142fa1>] __lock_acquire+0xbbf/0xc07
    [<c0141dac>] mark_held_locks+0x39/0x53
    [<c0439066>] mutex_lock_nested+0x286/0x2ac
    [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a3f4d>] register_netdevice_notifier+0xe/0x126
    [<c03a3f4d>] register_netdevice_notifier+0xe/0x126
    [<c03a3f88>] register_netdevice_notifier+0x49/0x126
    [<c05c5bda>] addrconf_init+0xad/0x193
    [<c05c5b48>] addrconf_init+0x1b/0x193
    [<c05c5a20>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff

  -> (&bonding_netdev_xmit_lock_key){-...} ops: 6 {
     initial-use  at:
                           [<c014289c>] __lock_acquire+0x4ba/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c0141986>] mark_lock+0x64/0x451
                           [<c014286a>] __lock_acquire+0x488/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0877804>] bonding_netdev_xmit_lock_key+0x0/0x8
   -> (&bond->lock){-.--} ops: 98 {
      initial-use  at:
                             [<c013fe35>] put_lock_stats+0xa/0x1e
                             [<c014289c>] __lock_acquire+0x4ba/0xc07
                             [<c0141dac>] mark_held_locks+0x39/0x53
                             [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0143062>] lock_acquire+0x79/0x93
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c0439eee>] _read_lock_bh+0x3b/0x64
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c03aa3e7>] rtnl_fill_ifinfo+0x2bf/0x563
                             [<c03aa965>] rtmsg_ifinfo+0x5d/0xdf
                             [<c03aaa26>] rtnetlink_event+0x3f/0x42
                             [<c013ac20>] notifier_call_chain+0x2a/0x52
                             [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
                             [<c03a31de>] register_netdevice+0x2a7/0x2e7
                             [<c02ed862>] bond_create+0x1f2/0x26a
                             [<c05bedcd>] bonding_init+0x761/0x7ea
                             [<c05be635>] e1000_init_module+0x45/0x7c
                             [<c05a9499>] kernel_init+0x150/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
      hardirq-on-W at:
                             [<c014286a>] __lock_acquire+0x488/0xc07
                             [<c012093c>] try_to_wake_up+0x2ce/0x2d8
                             [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                             [<c0143062>] lock_acquire+0x79/0x93
                             [<c02eda75>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c0439e25>] _write_lock_bh+0x3b/0x64
                             [<c02eda75>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c02eda75>] bond_set_multicast_list+0x1d/0x24=
1
                             [<c013fe35>] put_lock_stats+0xa/0x1e
                             [<c03a14db>] __dev_set_rx_mode+0x7b/0x7d
                             [<c03a1675>] dev_set_rx_mode+0x23/0x36
                             [<c03a3d50>] dev_open+0x5e/0x77
                             [<c03a2a1f>] dev_change_flags+0x9d/0x14b
                             [<c03a1823>] __dev_get_by_name+0x68/0x73
                             [<c03e3850>] devinet_ioctl+0x22b/0x536
                             [<c03a3b45>] dev_ioctl+0x46f/0x5b7
                             [<c0399c78>] sock_ioctl+0x167/0x18b
                             [<c0399b11>] sock_ioctl+0x0/0x18b
                             [<c01725f7>] do_ioctl+0x1f/0x62
                             [<c0172867>] vfs_ioctl+0x22d/0x23f
                             [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                             [<c01728ac>] sys_ioctl+0x33/0x4b
                             [<c0103e92>] sysenter_past_esp+0x5f/0xa5
                             [<ffffffff>] 0xffffffff
      softirq-on-R at:
                             [<c0141986>] mark_lock+0x64/0x451
                             [<c013575e>] __kernel_text_address+0x5/0xe
                             [<c0104ee2>] dump_trace+0x83/0x8d
                             [<c0142889>] __lock_acquire+0x4a7/0xc07
                             [<c013fc76>] save_trace+0x37/0x89
                             [<c0133c57>] run_workqueue+0x87/0x1b6
                             [<c0143062>] lock_acquire+0x79/0x93
                             [<c02eee5d>] bond_mii_monitor+0x19/0x85
                             [<c0439f4d>] _read_lock+0x36/0x5f
                             [<c02eee5d>] bond_mii_monitor+0x19/0x85
                             [<c02eee5d>] bond_mii_monitor+0x19/0x85
                             [<c0133cab>] run_workqueue+0xdb/0x1b6
                             [<c0133c57>] run_workqueue+0x87/0x1b6
                             [<c02eee44>] bond_mii_monitor+0x0/0x85
                             [<c01346cb>] worker_thread+0x0/0x85
                             [<c0134744>] worker_thread+0x79/0x85
                             [<c0137179>] autoremove_wake_function+0x0/0x35
                             [<c01370c2>] kthread+0x38/0x5e
                             [<c013708a>] kthread+0x0/0x5e
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
      hardirq-on-R at:
                             [<c013fe0a>] get_lock_stats+0xd/0x2e
                             [<c013fe35>] put_lock_stats+0xa/0x1e
                             [<c0142844>] __lock_acquire+0x462/0xc07
                             [<c0141dac>] mark_held_locks+0x39/0x53
                             [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
                             [<c0143062>] lock_acquire+0x79/0x93
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c0439eee>] _read_lock_bh+0x3b/0x64
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c02edcc1>] bond_get_stats+0x28/0xd0
                             [<c03aa3e7>] rtnl_fill_ifinfo+0x2bf/0x563
                             [<c03aa965>] rtmsg_ifinfo+0x5d/0xdf
                             [<c03aaa26>] rtnetlink_event+0x3f/0x42
                             [<c013ac20>] notifier_call_chain+0x2a/0x52
                             [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
                             [<c03a31de>] register_netdevice+0x2a7/0x2e7
                             [<c02ed862>] bond_create+0x1f2/0x26a
                             [<c05bedcd>] bonding_init+0x761/0x7ea
                             [<c05be635>] e1000_init_module+0x45/0x7c
                             [<c05a9499>] kernel_init+0x150/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c05a9349>] kernel_init+0x0/0x2b7
                             [<c0104baf>] kernel_thread_helper+0x7/0x10
                             [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c08777d0>] __key.32969+0x0/0x8
    -> (_xmit_ETHER){-...} ops: 8 {
       initial-use  at:
                               [<c014289c>] __lock_acquire+0x4ba/0xc07
                               [<c0143062>] lock_acquire+0x79/0x93
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c0439d62>] _spin_lock_bh+0x3b/0x64
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c0412114>] igmp6_group_added+0x56/0x11d
                               [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                               [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                               [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                               [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                               [<c0401834>] ipv6_add_dev+0x21c/0x24b
                               [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/=
0x1ef
                               [<c0401e17>] addrconf_notify+0x60/0x7b7
                               [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                               [<c0141dac>] mark_held_locks+0x39/0x53
                               [<c0439066>] mutex_lock_nested+0x286/0x2ac
                               [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                               [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                               [<c03a3f4d>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a3f4d>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a3f88>] register_netdevice_notifier+0x4=
9/0x126
                               [<c05c5bda>] addrconf_init+0xad/0x193
                               [<c05c5b48>] addrconf_init+0x1b/0x193
                               [<c05c5a20>] inet6_init+0x1f0/0x2ad
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
       hardirq-on-W at:
                               [<c0141986>] mark_lock+0x64/0x451
                               [<c014286a>] __lock_acquire+0x488/0xc07
                               [<c0143062>] lock_acquire+0x79/0x93
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c0439d62>] _spin_lock_bh+0x3b/0x64
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                               [<c0412114>] igmp6_group_added+0x56/0x11d
                               [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                               [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                               [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                               [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                               [<c0401834>] ipv6_add_dev+0x21c/0x24b
                               [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/=
0x1ef
                               [<c0401e17>] addrconf_notify+0x60/0x7b7
                               [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                               [<c0141dac>] mark_held_locks+0x39/0x53
                               [<c0439066>] mutex_lock_nested+0x286/0x2ac
                               [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                               [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                               [<c03a3f4d>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a3f4d>] register_netdevice_notifier+0xe=
/0x126
                               [<c03a3f88>] register_netdevice_notifier+0x4=
9/0x126
                               [<c05c5bda>] addrconf_init+0xad/0x193
                               [<c05c5b48>] addrconf_init+0x1b/0x193
                               [<c05c5a20>] inet6_init+0x1f0/0x2ad
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
     }
     ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
    ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
    [<c0109ef2>] save_stack_trace+0x20/0x3a
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0439d62>] _spin_lock_bh+0x3b/0x64
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c02ee492>] bond_change_active_slave+0x1a9/0x3bf
    [<c02ec7c3>] bond_update_speed_duplex+0x26/0x65
    [<c02ee9af>] bond_select_active_slave+0x95/0xcd
    [<c02ed22b>] bond_compute_features+0x45/0x84
    [<c02ef9be>] bond_enslave+0x6a7/0x884
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f6197>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fe9>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8d7>] dev_attr_store+0x27/0x2c
    [<c019bcb9>] sysfs_write_file+0xad/0xe0
    [<c019bc0c>] sysfs_write_file+0x0/0xe0
    [<c0168ddc>] vfs_write+0x8a/0x10c
    [<c0118566>] do_page_fault+0x0/0x54a
    [<c0169361>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

    -> (lweventlist_lock){.+..} ops: 10 {
       initial-use  at:
                               [<c0141986>] mark_lock+0x64/0x451
                               [<c014289c>] __lock_acquire+0x4ba/0xc07
                               [<c02e365c>] e1000_read_phy_reg+0x1c7/0x1d3
                               [<c02e348b>] e1000_write_phy_reg+0xb9/0xc3
                               [<c024a7de>] delay_tsc+0x25/0x3b
                               [<c0143062>] lock_acquire+0x79/0x93
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c03abbbb>] linkwatch_fire_event+0x25/0x37
                               [<c02e1c43>] e1000_probe+0xad1/0xbe8
                               [<c0257f3f>] pci_device_probe+0x36/0x57
                               [<c02d0e5f>] driver_probe_device+0xe1/0x15f
                               [<c043a2f9>] _spin_unlock+0x25/0x3b
                               [<c04375b2>] klist_next+0x58/0x6d
                               [<c02d0f6f>] __driver_attach+0x0/0x7f
                               [<c02d0fb8>] __driver_attach+0x49/0x7f
                               [<c02d0403>] bus_for_each_dev+0x36/0x58
                               [<c02d0cb7>] driver_attach+0x16/0x18
                               [<c02d0f6f>] __driver_attach+0x0/0x7f
                               [<c02d06fa>] bus_add_driver+0x6d/0x18d
                               [<c0258089>] __pci_register_driver+0x53/0x7f
                               [<c05be635>] e1000_init_module+0x45/0x7c
                               [<c05a9499>] kernel_init+0x150/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c05a9349>] kernel_init+0x0/0x2b7
                               [<c0104baf>] kernel_thread_helper+0x7/0x10
                               [<ffffffff>] 0xffffffff
       in-softirq-W at:
                               [<c011d20a>] __wake_up_common+0x32/0x5c
                               [<c0142822>] __lock_acquire+0x440/0xc07
                               [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x=
58
                               [<c0143062>] lock_acquire+0x79/0x93
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c02dff01>] e1000_watchdog+0x0/0x5c9
                               [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                               [<c03abbbb>] linkwatch_fire_event+0x25/0x37
                               [<c03aeb42>] netif_carrier_on+0x16/0x27
                               [<c02e0156>] e1000_watchdog+0x255/0x5c9
                               [<c02dff01>] e1000_watchdog+0x0/0x5c9
                               [<c012df52>] run_timer_softirq+0xfa/0x15d
                               [<c012a8a6>] __do_softirq+0x56/0xdb
                               [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
                               [<c012a8b8>] __do_softirq+0x68/0xdb
                               [<c012a961>] do_softirq+0x36/0x51
                               [<c012ab07>] irq_exit+0x43/0x4e
                               [<c0114122>] smp_apic_timer_interrupt+0x74/0=
x80
                               [<c0104a01>] apic_timer_interrupt+0x29/0x38
                               [<c0104a0b>] apic_timer_interrupt+0x33/0x38
                               [<c01600d8>] sys_swapon+0x29c/0x9aa
                               [<c01021a6>] mwait_idle_with_hints+0x3b/0x3f
                               [<c0102447>] mwait_idle+0x0/0xf
                               [<c0102581>] cpu_idle+0x99/0xc6
                               [<c05a98c7>] start_kernel+0x2c7/0x2cf
                               [<c05a90e0>] unknown_bootoption+0x0/0x195
                               [<ffffffff>] 0xffffffff
     }
     ... key      at: [<c058a194>] lweventlist_lock+0x14/0x40
    ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c0142fa1>] __lock_acquire+0xbbf/0xc07
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c03abbbb>] linkwatch_fire_event+0x25/0x37
    [<c03aeb42>] netif_carrier_on+0x16/0x27
    [<c02ede2c>] bond_set_carrier+0x31/0x55
    [<c02ee9b6>] bond_select_active_slave+0x9c/0xcd
    [<c02ed22b>] bond_compute_features+0x45/0x84
    [<c02ef9be>] bond_enslave+0x6a7/0x884
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f6197>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fe9>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8d7>] dev_attr_store+0x27/0x2c
    [<c019bcb9>] sysfs_write_file+0xad/0xe0
    [<c019bc0c>] sysfs_write_file+0x0/0xe0
    [<c0168ddc>] vfs_write+0x8a/0x10c
    [<c0118566>] do_page_fault+0x0/0x54a
    [<c0169361>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

   ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c02eda75>] bond_set_multicast_list+0x1d/0x241
    [<c0143062>] lock_acquire+0x79/0x93
    [<c02eda75>] bond_set_multicast_list+0x1d/0x241
    [<c0439e25>] _write_lock_bh+0x3b/0x64
    [<c02eda75>] bond_set_multicast_list+0x1d/0x241
    [<c02eda75>] bond_set_multicast_list+0x1d/0x241
    [<c013fe35>] put_lock_stats+0xa/0x1e
    [<c03a14db>] __dev_set_rx_mode+0x7b/0x7d
    [<c03a1675>] dev_set_rx_mode+0x23/0x36
    [<c03a3d50>] dev_open+0x5e/0x77
    [<c03a2a1f>] dev_change_flags+0x9d/0x14b
    [<c03a1823>] __dev_get_by_name+0x68/0x73
    [<c03e3850>] devinet_ioctl+0x22b/0x536
    [<c03a3b45>] dev_ioctl+0x46f/0x5b7
    [<c0399c78>] sock_ioctl+0x167/0x18b
    [<c0399b11>] sock_ioctl+0x0/0x18b
    [<c01725f7>] do_ioctl+0x1f/0x62
    [<c0172867>] vfs_ioctl+0x22d/0x23f
    [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
    [<c01728ac>] sys_ioctl+0x33/0x4b
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

  ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0439d62>] _spin_lock_bh+0x3b/0x64
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0412114>] igmp6_group_added+0x56/0x11d
    [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
    [<c0410100>] igmp6_mc_seq_start+0xde/0x138
    [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
    [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
    [<c0401834>] ipv6_add_dev+0x21c/0x24b
    [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1ef
    [<c0401e17>] addrconf_notify+0x60/0x7b7
    [<c0142fa1>] __lock_acquire+0xbbf/0xc07
    [<c0141dac>] mark_held_locks+0x39/0x53
    [<c0439066>] mutex_lock_nested+0x286/0x2ac
    [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c03a3f4d>] register_netdevice_notifier+0xe/0x126
    [<c03a3f4d>] register_netdevice_notifier+0xe/0x126
    [<c03a3f88>] register_netdevice_notifier+0x49/0x126
    [<c05c5bda>] addrconf_init+0xad/0x193
    [<c05c5b48>] addrconf_init+0x1b/0x193
    [<c05c5a20>] inet6_init+0x1f0/0x2ad
    [<c05a9499>] kernel_init+0x150/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c05a9349>] kernel_init+0x0/0x2b7
    [<c0104baf>] kernel_thread_helper+0x7/0x10
    [<ffffffff>] 0xffffffff


the second lock's dependencies:
-> (&bond->lock){-.--} ops: 98 {
    initial-use  at:
                         [<c013fe35>] put_lock_stats+0xa/0x1e
                         [<c014289c>] __lock_acquire+0x4ba/0xc07
                         [<c0141dac>] mark_held_locks+0x39/0x53
                         [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c0439eee>] _read_lock_bh+0x3b/0x64
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c03aa3e7>] rtnl_fill_ifinfo+0x2bf/0x563
                         [<c03aa965>] rtmsg_ifinfo+0x5d/0xdf
                         [<c03aaa26>] rtnetlink_event+0x3f/0x42
                         [<c013ac20>] notifier_call_chain+0x2a/0x52
                         [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a31de>] register_netdevice+0x2a7/0x2e7
                         [<c02ed862>] bond_create+0x1f2/0x26a
                         [<c05bedcd>] bonding_init+0x761/0x7ea
                         [<c05be635>] e1000_init_module+0x45/0x7c
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                         [<c014286a>] __lock_acquire+0x488/0xc07
                         [<c012093c>] try_to_wake_up+0x2ce/0x2d8
                         [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c02eda75>] bond_set_multicast_list+0x1d/0x241
                         [<c0439e25>] _write_lock_bh+0x3b/0x64
                         [<c02eda75>] bond_set_multicast_list+0x1d/0x241
                         [<c02eda75>] bond_set_multicast_list+0x1d/0x241
                         [<c013fe35>] put_lock_stats+0xa/0x1e
                         [<c03a14db>] __dev_set_rx_mode+0x7b/0x7d
                         [<c03a1675>] dev_set_rx_mode+0x23/0x36
                         [<c03a3d50>] dev_open+0x5e/0x77
                         [<c03a2a1f>] dev_change_flags+0x9d/0x14b
                         [<c03a1823>] __dev_get_by_name+0x68/0x73
                         [<c03e3850>] devinet_ioctl+0x22b/0x536
                         [<c03a3b45>] dev_ioctl+0x46f/0x5b7
                         [<c0399c78>] sock_ioctl+0x167/0x18b
                         [<c0399b11>] sock_ioctl+0x0/0x18b
                         [<c01725f7>] do_ioctl+0x1f/0x62
                         [<c0172867>] vfs_ioctl+0x22d/0x23f
                         [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                         [<c01728ac>] sys_ioctl+0x33/0x4b
                         [<c0103e92>] sysenter_past_esp+0x5f/0xa5
                         [<ffffffff>] 0xffffffff
    softirq-on-R at:
                         [<c0141986>] mark_lock+0x64/0x451
                         [<c013575e>] __kernel_text_address+0x5/0xe
                         [<c0104ee2>] dump_trace+0x83/0x8d
                         [<c0142889>] __lock_acquire+0x4a7/0xc07
                         [<c013fc76>] save_trace+0x37/0x89
                         [<c0133c57>] run_workqueue+0x87/0x1b6
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c02eee5d>] bond_mii_monitor+0x19/0x85
                         [<c0439f4d>] _read_lock+0x36/0x5f
                         [<c02eee5d>] bond_mii_monitor+0x19/0x85
                         [<c02eee5d>] bond_mii_monitor+0x19/0x85
                         [<c0133cab>] run_workqueue+0xdb/0x1b6
                         [<c0133c57>] run_workqueue+0x87/0x1b6
                         [<c02eee44>] bond_mii_monitor+0x0/0x85
                         [<c01346cb>] worker_thread+0x0/0x85
                         [<c0134744>] worker_thread+0x79/0x85
                         [<c0137179>] autoremove_wake_function+0x0/0x35
                         [<c01370c2>] kthread+0x38/0x5e
                         [<c013708a>] kthread+0x0/0x5e
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
    hardirq-on-R at:
                         [<c013fe0a>] get_lock_stats+0xd/0x2e
                         [<c013fe35>] put_lock_stats+0xa/0x1e
                         [<c0142844>] __lock_acquire+0x462/0xc07
                         [<c0141dac>] mark_held_locks+0x39/0x53
                         [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
                         [<c0143062>] lock_acquire+0x79/0x93
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c0439eee>] _read_lock_bh+0x3b/0x64
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c02edcc1>] bond_get_stats+0x28/0xd0
                         [<c03aa3e7>] rtnl_fill_ifinfo+0x2bf/0x563
                         [<c03aa965>] rtmsg_ifinfo+0x5d/0xdf
                         [<c03aaa26>] rtnetlink_event+0x3f/0x42
                         [<c013ac20>] notifier_call_chain+0x2a/0x52
                         [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
                         [<c03a31de>] register_netdevice+0x2a7/0x2e7
                         [<c02ed862>] bond_create+0x1f2/0x26a
                         [<c05bedcd>] bonding_init+0x761/0x7ea
                         [<c05be635>] e1000_init_module+0x45/0x7c
                         [<c05a9499>] kernel_init+0x150/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c05a9349>] kernel_init+0x0/0x2b7
                         [<c0104baf>] kernel_thread_helper+0x7/0x10
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c08777d0>] __key.32969+0x0/0x8
  -> (_xmit_ETHER){-...} ops: 8 {
     initial-use  at:
                           [<c014289c>] __lock_acquire+0x4ba/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>] ndisc_ifinfo_sysctl_change+0x0/0x1e=
f
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     hardirq-on-W at:
                           [<c0141986>] mark_lock+0x64/0x451
                           [<c014286a>] __lock_acquire+0x488/0xc07
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0439d62>] _spin_lock_bh+0x3b/0x64
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c03a5aa1>] dev_mc_add+0x1a/0x6a
                           [<c0412114>] igmp6_group_added+0x56/0x11d
                           [<c04124a8>] ipv6_dev_mc_inc+0x2a3/0x31c
                           [<c0410100>] igmp6_mc_seq_start+0xde/0x138
                           [<c04124dd>] ipv6_dev_mc_inc+0x2d8/0x31c
                           [<c0412205>] ipv6_dev_mc_inc+0x0/0x31c
                           [<c0401834>] ipv6_add_dev+0x21c/0x24b
                           [<c040b07d>]=20
ndisc_ifinfo_sysctl_change+0x0/0x1ef
                           [<c0401e17>] addrconf_notify+0x60/0x7b7
                           [<c0142fa1>] __lock_acquire+0xbbf/0xc07
                           [<c0141dac>] mark_held_locks+0x39/0x53
                           [<c0439066>] mutex_lock_nested+0x286/0x2ac
                           [<c0141f9f>] trace_hardirqs_on+0x122/0x14c
                           [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f4d>] register_netdevice_notifier+0xe/0x1=
26
                           [<c03a3f88>] register_netdevice_notifier+0x49/0x=
126
                           [<c05c5bda>] addrconf_init+0xad/0x193
                           [<c05c5b48>] addrconf_init+0x1b/0x193
                           [<c05c5a20>] inet6_init+0x1f0/0x2ad
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c087adc8>] netdev_xmit_lock_key+0x8/0x1c0
  ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
    [<c0109ef2>] save_stack_trace+0x20/0x3a
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c0439d62>] _spin_lock_bh+0x3b/0x64
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c03a5aa1>] dev_mc_add+0x1a/0x6a
    [<c02ee492>] bond_change_active_slave+0x1a9/0x3bf
    [<c02ec7c3>] bond_update_speed_duplex+0x26/0x65
    [<c02ee9af>] bond_select_active_slave+0x95/0xcd
    [<c02ed22b>] bond_compute_features+0x45/0x84
    [<c02ef9be>] bond_enslave+0x6a7/0x884
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f6197>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fe9>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8d7>] dev_attr_store+0x27/0x2c
    [<c019bcb9>] sysfs_write_file+0xad/0xe0
    [<c019bc0c>] sysfs_write_file+0x0/0xe0
    [<c0168ddc>] vfs_write+0x8a/0x10c
    [<c0118566>] do_page_fault+0x0/0x54a
    [<c0169361>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff

  -> (lweventlist_lock){.+..} ops: 10 {
     initial-use  at:
                           [<c0141986>] mark_lock+0x64/0x451
                           [<c014289c>] __lock_acquire+0x4ba/0xc07
                           [<c02e365c>] e1000_read_phy_reg+0x1c7/0x1d3
                           [<c02e348b>] e1000_write_phy_reg+0xb9/0xc3
                           [<c024a7de>] delay_tsc+0x25/0x3b
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c03abbbb>] linkwatch_fire_event+0x25/0x37
                           [<c02e1c43>] e1000_probe+0xad1/0xbe8
                           [<c0257f3f>] pci_device_probe+0x36/0x57
                           [<c02d0e5f>] driver_probe_device+0xe1/0x15f
                           [<c043a2f9>] _spin_unlock+0x25/0x3b
                           [<c04375b2>] klist_next+0x58/0x6d
                           [<c02d0f6f>] __driver_attach+0x0/0x7f
                           [<c02d0fb8>] __driver_attach+0x49/0x7f
                           [<c02d0403>] bus_for_each_dev+0x36/0x58
                           [<c02d0cb7>] driver_attach+0x16/0x18
                           [<c02d0f6f>] __driver_attach+0x0/0x7f
                           [<c02d06fa>] bus_add_driver+0x6d/0x18d
                           [<c0258089>] __pci_register_driver+0x53/0x7f
                           [<c05be635>] e1000_init_module+0x45/0x7c
                           [<c05a9499>] kernel_init+0x150/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c05a9349>] kernel_init+0x0/0x2b7
                           [<c0104baf>] kernel_thread_helper+0x7/0x10
                           [<ffffffff>] 0xffffffff
     in-softirq-W at:
                           [<c011d20a>] __wake_up_common+0x32/0x5c
                           [<c0142822>] __lock_acquire+0x440/0xc07
                           [<c043a3c5>] _spin_unlock_irqrestore+0x40/0x58
                           [<c0143062>] lock_acquire+0x79/0x93
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c02dff01>] e1000_watchdog+0x0/0x5c9
                           [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c03abaf7>] linkwatch_add_event+0xd/0x2c
                           [<c03abbbb>] linkwatch_fire_event+0x25/0x37
                           [<c03aeb42>] netif_carrier_on+0x16/0x27
                           [<c02e0156>] e1000_watchdog+0x255/0x5c9
                           [<c02dff01>] e1000_watchdog+0x0/0x5c9
                           [<c012df52>] run_timer_softirq+0xfa/0x15d
                           [<c012a8a6>] __do_softirq+0x56/0xdb
                           [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
                           [<c012a8b8>] __do_softirq+0x68/0xdb
                           [<c012a961>] do_softirq+0x36/0x51
                           [<c012ab07>] irq_exit+0x43/0x4e
                           [<c0114122>] smp_apic_timer_interrupt+0x74/0x80
                           [<c0104a01>] apic_timer_interrupt+0x29/0x38
                           [<c0104a0b>] apic_timer_interrupt+0x33/0x38
                           [<c01600d8>] sys_swapon+0x29c/0x9aa
                           [<c01021a6>] mwait_idle_with_hints+0x3b/0x3f
                           [<c0102447>] mwait_idle+0x0/0xf
                           [<c0102581>] cpu_idle+0x99/0xc6
                           [<c05a98c7>] start_kernel+0x2c7/0x2cf
                           [<c05a90e0>] unknown_bootoption+0x0/0x195
                           [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c058a194>] lweventlist_lock+0x14/0x40
  ... acquired at:
    [<c0142dff>] __lock_acquire+0xa1d/0xc07
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c0142fa1>] __lock_acquire+0xbbf/0xc07
    [<c0143062>] lock_acquire+0x79/0x93
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c043a07f>] _spin_lock_irqsave+0x3f/0x6c
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c03abaf7>] linkwatch_add_event+0xd/0x2c
    [<c03abbbb>] linkwatch_fire_event+0x25/0x37
    [<c03aeb42>] netif_carrier_on+0x16/0x27
    [<c02ede2c>] bond_set_carrier+0x31/0x55
    [<c02ee9b6>] bond_select_active_slave+0x9c/0xcd
    [<c02ed22b>] bond_compute_features+0x45/0x84
    [<c02ef9be>] bond_enslave+0x6a7/0x884
    [<c0439084>] mutex_lock_nested+0x2a4/0x2ac
    [<c02f6197>] bonding_store_slaves+0x1ae/0x2fb
    [<c02f5fe9>] bonding_store_slaves+0x0/0x2fb
    [<c02ce8d7>] dev_attr_store+0x27/0x2c
    [<c019bcb9>] sysfs_write_file+0xad/0xe0
    [<c019bc0c>] sysfs_write_file+0x0/0xe0
    [<c0168ddc>] vfs_write+0x8a/0x10c
    [<c0118566>] do_page_fault+0x0/0x54a
    [<c0169361>] sys_write+0x41/0x67
    [<c0103e92>] sysenter_past_esp+0x5f/0xa5
    [<ffffffff>] 0xffffffff


stack backtrace:
Pid: 9, comm: events/0 Not tainted 2.6.24-rc5 #1
  [<c0140b38>] print_irq_inversion_bug+0x108/0x112
  [<c014191d>] check_usage_forwards+0x3c/0x41
  [<c0141b09>] mark_lock+0x1e7/0x451
  [<c0142822>] __lock_acquire+0x440/0xc07
  [<c013fe0a>] get_lock_stats+0xd/0x2e
  [<c013fe35>] put_lock_stats+0xa/0x1e
  [<c0143062>] lock_acquire+0x79/0x93
  [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c0439d62>] _spin_lock_bh+0x3b/0x64
  [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
  [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
  [<c0411b4a>] mld_ifc_timer_expire+0x0/0x1fb
  [<c012df52>] run_timer_softirq+0xfa/0x15d
  [<c012a8a6>] __do_softirq+0x56/0xdb
  [<c0141f89>] trace_hardirqs_on+0x10c/0x14c
  [<c012a8b8>] __do_softirq+0x68/0xdb
  [<c012a961>] do_softirq+0x36/0x51
  [<c012ae4a>] local_bh_enable_ip+0xad/0xed
  [<c03bf107>] rt_run_flush+0x64/0x8b
  [<c03e9296>] fib_netdev_event+0x61/0x65
  [<c013ac20>] notifier_call_chain+0x2a/0x52
  [<c013ac6a>] raw_notifier_call_chain+0x17/0x1a
  [<c03a2ae5>] netdev_state_change+0x18/0x29
  [<c03abd1d>] __linkwatch_run_queue+0x150/0x17e
  [<c03abd68>] linkwatch_event+0x1d/0x22
  [<c0133cab>] run_workqueue+0xdb/0x1b6
  [<c0133c57>] run_workqueue+0x87/0x1b6
  [<c03abd4b>] linkwatch_event+0x0/0x22
  [<c01346cb>] worker_thread+0x0/0x85
  [<c0134744>] worker_thread+0x79/0x85
  [<c0137179>] autoremove_wake_function+0x0/0x35
  [<c01370c2>] kthread+0x38/0x5e
  [<c013708a>] kthread+0x0/0x5e
  [<c0104baf>] kernel_thread_helper+0x7/0x10
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
bonding: bond0: enslaving eth1 as a backup interface with a down link.
bonding: bond0: Setting eth0 as primary slave.
bond0: no IPv6 routers present

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-595068131-1197658662=:12202--
