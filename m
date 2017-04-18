From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next 2/5] bonding: initialize work-queues during creation
 of bond
Date: Tue, 18 Apr 2017 14:37:29 -0700
Message-ID: <CAF2d9ji+wg_ExvS6f6zekZVMder1Mz5bwKM+TaJofBbC5jGcBQ@mail.gmail.com>
References: <20170308185554.23001-1-mahesh@bandewar.net> <CAPWQB7EarzSockC2pQrzSB=8m19VzkNnaQobZE8cVY=aTzfREA@mail.gmail.com>
 <20170418212322.GI4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joe@ovn.org>, Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35388 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754942AbdDRVhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 17:37:51 -0400
Received: by mail-io0-f180.google.com with SMTP id r16so9896175ioi.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 14:37:51 -0700 (PDT)
In-Reply-To: <20170418212322.GI4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 2:23 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> On Fri, Apr 14, 2017 at 03:44:53PM -0700, Joe Stringer wrote:
>> On 8 March 2017 at 10:55, Mahesh Bandewar <mahesh@bandewar.net> wrote:
>> > From: Mahesh Bandewar <maheshb@google.com>
>> >
>> > Initializing work-queues every time ifup operation performed is unnecessary
>> > and can be performed only once when the port is created.
>> >
>> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> > ---
>> >  drivers/net/bonding/bond_main.c | 4 ++--
>> >  1 file changed, 2 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> > index 619f0c65f18a..1329110ed85f 100644
>> > --- a/drivers/net/bonding/bond_main.c
>> > +++ b/drivers/net/bonding/bond_main.c
>> > @@ -3270,8 +3270,6 @@ static int bond_open(struct net_device *bond_dev)
>> >                 }
>> >         }
>> >
>> > -       bond_work_init_all(bond);
>> > -
>> >         if (bond_is_lb(bond)) {
>> >                 /* bond_alb_initialize must be called before the timer
>> >                  * is started.
>> > @@ -4691,6 +4689,8 @@ int bond_create(struct net *net, const char *name)
>> >
>> >         netif_carrier_off(bond_dev);
>> >
>> > +       bond_work_init_all(bond);
>> > +
>> >         rtnl_unlock();
>> >         if (res < 0)
>> >                 bond_destructor(bond_dev);
>> > --
>>
>> Hi Mahesh,
>>
>> I've noticed that this patch breaks bonding within namespaces if
>> you're not careful to perform device cleanup correctly.
>>
Oops, I didn't see this msg until now :(
I'll take a look at this now and see if I can cook a fix soon.

Thanks,
--mahesh..

>> Here's my repro script, you can run on any net-next with this patch
>> and you'll start seeing some weird behaviour:
>>
>> ip netns add foo
>> ip li add veth0 type veth peer name veth0+ netns foo
>> ip li add veth1 type veth peer name veth1+ netns foo
>> ip netns exec foo ip li add bond0 type bond
>> ip netns exec foo ip li set dev veth0+ master bond0
>> ip netns exec foo ip li set dev veth1+ master bond0
>> ip netns exec foo ip addr add dev bond0 192.168.0.1/24
>> ip netns exec foo ip li set dev bond0 up
>> ip li del dev veth0
>> ip li del dev veth1
>>
>> The second to last command segfaults, last command hangs. rtnl is now
>> permanently locked. It's not a problem if you take bond0 down before
>> deleting veths, or delete bond0 before deleting veths. If you delete
>> either end of the veth pair as per above, either inside or outside the
>> namespace, it hits this problem.
>>
>> Here's some kernel logs:
>> [ 1221.801610] bond0: Enslaving veth0+ as an active interface with an up link
>> [ 1224.449581] bond0: Enslaving veth1+ as an active interface with an up link
>> [ 1281.193863] bond0: Releasing backup interface veth0+
>> [ 1281.193866] bond0: the permanent HWaddr of veth0+ -
>> 16:bf:fb:e0:b8:43 - is still in use by bond0 - set the HWaddr of
>> veth0+ to a different address to avoid conflicts
>> [ 1281.193867] ------------[ cut here ]------------
>> [ 1281.193873] WARNING: CPU: 0 PID: 2024 at kernel/workqueue.c:1511
>> __queue_delayed_work+0x13f/0x150
>> [ 1281.193873] Modules linked in: bonding veth openvswitch nf_nat_ipv6
>> nf_nat_ipv4 nf_nat autofs4 nfsd auth_rpcgss nfs_acl binfmt_misc nfs
>> lockd grace sunrpc fscache ppdev vmw_balloon coretemp psmouse
>> serio_raw vmwgfx ttm drm_kms_helper vmw_vmci netconsole parport_pc
>> configfs drm i2c_piix4 fb_sys_fops syscopyarea sysfillrect sysimgblt
>> shpchp mac_hid nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4
>> nf_defrag_ipv4 nf_conntrack libcrc32c lp parport hid_generic usbhid
>> hid mptspi mptscsih e1000 mptbase ahci libahci
>> [ 1281.193905] CPU: 0 PID: 2024 Comm: ip Tainted: G        W
>> 4.10.0-bisect-bond-v0.14 #37
>> [ 1281.193906] Hardware name: VMware, Inc. VMware Virtual
>> Platform/440BX Desktop Reference Platform, BIOS 6.00 09/30/2014
>> [ 1281.193906] Call Trace:
>> [ 1281.193912]  dump_stack+0x63/0x89
>> [ 1281.193915]  __warn+0xd1/0xf0
>> [ 1281.193917]  warn_slowpath_null+0x1d/0x20
>> [ 1281.193918]  __queue_delayed_work+0x13f/0x150
>> [ 1281.193920]  queue_delayed_work_on+0x27/0x40
>> [ 1281.193929]  bond_change_active_slave+0x25b/0x670 [bonding]
>> [ 1281.193932]  ? synchronize_rcu_expedited+0x27/0x30
>> [ 1281.193935]  __bond_release_one+0x489/0x510 [bonding]
>> [ 1281.193939]  ? addrconf_notify+0x1b7/0xab0
>> [ 1281.193942]  bond_netdev_event+0x2c5/0x2e0 [bonding]
>> [ 1281.193944]  ? netconsole_netdev_event+0x124/0x190 [netconsole]
>> [ 1281.193947]  notifier_call_chain+0x49/0x70
>> [ 1281.193948]  raw_notifier_call_chain+0x16/0x20
>> [ 1281.193950]  call_netdevice_notifiers_info+0x35/0x60
>> [ 1281.193951]  rollback_registered_many+0x23b/0x3e0
>> [ 1281.193953]  unregister_netdevice_many+0x24/0xd0
>> [ 1281.193955]  rtnl_delete_link+0x3c/0x50
>> [ 1281.193956]  rtnl_dellink+0x8d/0x1b0
>> [ 1281.193960]  rtnetlink_rcv_msg+0x95/0x220
>> [ 1281.193962]  ? __kmalloc_node_track_caller+0x35/0x280
>> [ 1281.193964]  ? __netlink_lookup+0xf1/0x110
>> [ 1281.193966]  ? rtnl_newlink+0x830/0x830
>> [ 1281.193967]  netlink_rcv_skb+0xa7/0xc0
>> [ 1281.193969]  rtnetlink_rcv+0x28/0x30
>> [ 1281.193970]  netlink_unicast+0x15b/0x210
>> [ 1281.193971]  netlink_sendmsg+0x319/0x390
>> [ 1281.193974]  sock_sendmsg+0x38/0x50
>> [ 1281.193975]  ___sys_sendmsg+0x25c/0x270
>> [ 1281.193978]  ? mem_cgroup_commit_charge+0x76/0xf0
>> [ 1281.193981]  ? page_add_new_anon_rmap+0x89/0xc0
>> [ 1281.193984]  ? lru_cache_add_active_or_unevictable+0x35/0xb0
>> [ 1281.193985]  ? __handle_mm_fault+0x4e9/0x1170
>> [ 1281.193987]  __sys_sendmsg+0x45/0x80
>> [ 1281.193989]  SyS_sendmsg+0x12/0x20
>> [ 1281.193991]  do_syscall_64+0x6e/0x180
>> [ 1281.193993]  entry_SYSCALL64_slow_path+0x25/0x25
>> [ 1281.193995] RIP: 0033:0x7f6ec122f5a0
>> [ 1281.193995] RSP: 002b:00007ffe69e89c48 EFLAGS: 00000246 ORIG_RAX:
>> 000000000000002e
>> [ 1281.193997] RAX: ffffffffffffffda RBX: 00007ffe69e8dd60 RCX: 00007f6ec122f5a0
>> [ 1281.193997] RDX: 0000000000000000 RSI: 00007ffe69e89c90 RDI: 0000000000000003
>> [ 1281.193998] RBP: 00007ffe69e89c90 R08: 0000000000000000 R09: 0000000000000003
>> [ 1281.193999] R10: 00007ffe69e89a10 R11: 0000000000000246 R12: 0000000058f14b9f
>> [ 1281.193999] R13: 0000000000000000 R14: 00000000006473a0 R15: 00007ffe69e8e450
>> [ 1281.194001] ---[ end trace 713a77486cbfbfa3 ]---
>> [ 1281.194002] ------------[ cut here ]------------
>> [ 1281.194004] WARNING: CPU: 0 PID: 2024 at kernel/workqueue.c:1513
>> __queue_delayed_work+0x103/0x150
>> [ 1281.194004] Modules linked in: bonding veth openvswitch nf_nat_ipv6
>> nf_nat_ipv4 nf_nat autofs4 nfsd auth_rpcgss nfs_acl binfmt_misc nfs
>> lockd grace sunrpc fscache ppdev vmw_balloon coretemp psmouse
>> serio_raw vmwgfx ttm drm_kms_helper vmw_vmci netconsole parport_pc
>> configfs drm i2c_piix4 fb_sys_fops syscopyarea sysfillrect sysimgblt
>> shpchp mac_hid nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4
>> nf_defrag_ipv4 nf_conntrack libcrc32c lp parport hid_generic usbhid
>> hid mptspi mptscsih e1000 mptbase ahci libahci
>> [ 1281.194022] CPU: 0 PID: 2024 Comm: ip Tainted: G        W
>> 4.10.0-bisect-bond-v0.14 #37
>> [ 1281.194023] Hardware name: VMware, Inc. VMware Virtual
>> Platform/440BX Desktop Reference Platform, BIOS 6.00 09/30/2014
>> [ 1281.194023] Call Trace:
>> [ 1281.194025]  dump_stack+0x63/0x89
>> [ 1281.194027]  __warn+0xd1/0xf0
>> [ 1281.194028]  warn_slowpath_null+0x1d/0x20
>> [ 1281.194030]  __queue_delayed_work+0x103/0x150
>> [ 1281.194031]  queue_delayed_work_on+0x27/0x40
>> [ 1281.194034]  bond_change_active_slave+0x25b/0x670 [bonding]
>> [ 1281.194035]  ? synchronize_rcu_expedited+0x27/0x30
>> [ 1281.194039]  __bond_release_one+0x489/0x510 [bonding]
>> [ 1281.194043]  ? addrconf_notify+0x1b7/0xab0
>> [ 1281.194047]  bond_netdev_event+0x2c5/0x2e0 [bonding]
>> [ 1281.194048]  ? netconsole_netdev_event+0x124/0x190 [netconsole]
>> [ 1281.194050]  notifier_call_chain+0x49/0x70
>> [ 1281.194052]  raw_notifier_call_chain+0x16/0x20
>> [ 1281.194053]  call_netdevice_notifiers_info+0x35/0x60
>> [ 1281.194054]  rollback_registered_many+0x23b/0x3e0
>> [ 1281.194056]  unregister_netdevice_many+0x24/0xd0
>> [ 1281.194057]  rtnl_delete_link+0x3c/0x50
>> [ 1281.194059]  rtnl_dellink+0x8d/0x1b0
>> [ 1281.194062]  rtnetlink_rcv_msg+0x95/0x220
>> [ 1281.194064]  ? __kmalloc_node_track_caller+0x35/0x280
>> [ 1281.194065]  ? __netlink_lookup+0xf1/0x110
>> [ 1281.194066]  ? rtnl_newlink+0x830/0x830
>> [ 1281.194068]  netlink_rcv_skb+0xa7/0xc0
>> [ 1281.194069]  rtnetlink_rcv+0x28/0x30
>> [ 1281.194070]  netlink_unicast+0x15b/0x210
>> [ 1281.194071]  netlink_sendmsg+0x319/0x390
>> [ 1281.194073]  sock_sendmsg+0x38/0x50
>> [ 1281.194074]  ___sys_sendmsg+0x25c/0x270
>> [ 1281.194076]  ? mem_cgroup_commit_charge+0x76/0xf0
>> [ 1281.194077]  ? page_add_new_anon_rmap+0x89/0xc0
>> [ 1281.194079]  ? lru_cache_add_active_or_unevictable+0x35/0xb0
>> [ 1281.194080]  ? __handle_mm_fault+0x4e9/0x1170
>> [ 1281.194082]  __sys_sendmsg+0x45/0x80
>> [ 1281.194084]  SyS_sendmsg+0x12/0x20
>> [ 1281.194085]  do_syscall_64+0x6e/0x180
>> [ 1281.194087]  entry_SYSCALL64_slow_path+0x25/0x25
>> [ 1281.194087] RIP: 0033:0x7f6ec122f5a0
>> [ 1281.194088] RSP: 002b:00007ffe69e89c48 EFLAGS: 00000246 ORIG_RAX:
>> 000000000000002e
>> [ 1281.194089] RAX: ffffffffffffffda RBX: 00007ffe69e8dd60 RCX: 00007f6ec122f5a0
>> [ 1281.194090] RDX: 0000000000000000 RSI: 00007ffe69e89c90 RDI: 0000000000000003
>> [ 1281.194090] RBP: 00007ffe69e89c90 R08: 0000000000000000 R09: 0000000000000003
>> [ 1281.194091] R10: 00007ffe69e89a10 R11: 0000000000000246 R12: 0000000058f14b9f
>> [ 1281.194092] R13: 0000000000000000 R14: 00000000006473a0 R15: 00007ffe69e8e450
>> [ 1281.194093] ---[ end trace 713a77486cbfbfa4 ]---
>> [ 1281.194103] ------------[ cut here ]------------
>> [ 1281.194148] kernel BUG at kernel/time/timer.c:933!
>> [ 1281.194173] invalid opcode: 0000 [#1] PREEMPT SMP
>> [ 1281.194197] Modules linked in: bonding veth openvswitch nf_nat_ipv6
>> nf_nat_ipv4 nf_nat autofs4 nfsd auth_rpcgss nfs_acl binfmt_misc nfs
>> lockd grace sunrpc fscache ppdev vmw_balloon coretemp psmouse
>> serio_raw vmwgfx ttm drm_kms_helper vmw_vmci netconsole parport_pc
>> configfs drm i2c_piix4 fb_sys_fops syscopyarea sysfillrect sysimgblt
>> shpchp mac_hid nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4
>> nf_defrag_ipv4 nf_conntrack libcrc32c lp parport hid_generic usbhid
>> hid mptspi mptscsih e1000 mptbase ahci libahci
>> [ 1281.194436] CPU: 0 PID: 2024 Comm: ip Tainted: G        W
>> 4.10.0-bisect-bond-v0.14 #37
>> [ 1281.194475] Hardware name: VMware, Inc. VMware Virtual
>> Platform/440BX Desktop Reference Platform, BIOS 6.00 09/30/2014
>> [ 1281.194523] task: ffff945934df8000 task.stack: ffffb3da03030000
>> [ 1281.194553] RIP: 0010:__mod_timer.part.35+0x4/0x6
>> [ 1281.194578] RSP: 0018:ffffb3da03033748 EFLAGS: 00010046
>> [ 1281.194604] RAX: 00000001000ef8bc RBX: ffff9459379ccbf0 RCX: 00000001000ef8bd
>> [ 1281.194656] RDX: ffff9459379ccbd0 RSI: 0000000000000000 RDI: ffff9459379ccbf0
>> [ 1281.194690] RBP: ffffb3da03033748 R08: 0000000000000000 R09: 0000000000000706
>> [ 1281.194722] R10: 0000000000000004 R11: 0000000000000000 R12: ffff945939575800
>> [ 1281.194755] R13: 00000001000ef8bd R14: ffff945934362000 R15: ffff9459379cc000
>> [ 1281.194788] FS:  00007f6ec190f740(0000) GS:ffff94593b600000(0000)
>> knlGS:0000000000000000
>> [ 1281.194825] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 1281.194852] CR2: 00007ffe69e89c70 CR3: 000000007680f000 CR4: 00000000000006f0
>> [ 1281.194930] Call Trace:
>> [ 1281.194952]  add_timer+0x1ee/0x1f0
>> [ 1281.194973]  __queue_delayed_work+0x78/0x150
>> [ 1281.194995]  queue_delayed_work_on+0x27/0x40
>> [ 1281.195021]  bond_change_active_slave+0x25b/0x670 [bonding]
>> [ 1281.195049]  ? synchronize_rcu_expedited+0x27/0x30
>> [ 1281.195076]  __bond_release_one+0x489/0x510 [bonding]
>> [ 1281.195107]  ? addrconf_notify+0x1b7/0xab0
>> [ 1281.195133]  bond_netdev_event+0x2c5/0x2e0 [bonding]
>> [ 1281.195159]  ? netconsole_netdev_event+0x124/0x190 [netconsole]
>> [ 1281.195189]  notifier_call_chain+0x49/0x70
>> [ 1281.195945]  raw_notifier_call_chain+0x16/0x20
>> [ 1281.196690]  call_netdevice_notifiers_info+0x35/0x60
>> [ 1281.197439]  rollback_registered_many+0x23b/0x3e0
>> [ 1281.198178]  unregister_netdevice_many+0x24/0xd0
>> [ 1281.198908]  rtnl_delete_link+0x3c/0x50
>> [ 1281.199641]  rtnl_dellink+0x8d/0x1b0
>> [ 1281.200355]  rtnetlink_rcv_msg+0x95/0x220
>> [ 1281.201043]  ? __kmalloc_node_track_caller+0x35/0x280
>> [ 1281.201717]  ? __netlink_lookup+0xf1/0x110
>> [ 1281.202369]  ? rtnl_newlink+0x830/0x830
>> [ 1281.203000]  netlink_rcv_skb+0xa7/0xc0
>> [ 1281.203609]  rtnetlink_rcv+0x28/0x30
>> [ 1281.204202]  netlink_unicast+0x15b/0x210
>> [ 1281.204779]  netlink_sendmsg+0x319/0x390
>> [ 1281.205332]  sock_sendmsg+0x38/0x50
>> [ 1281.205875]  ___sys_sendmsg+0x25c/0x270
>> [ 1281.206411]  ? mem_cgroup_commit_charge+0x76/0xf0
>> [ 1281.206949]  ? page_add_new_anon_rmap+0x89/0xc0
>> [ 1281.207480]  ? lru_cache_add_active_or_unevictable+0x35/0xb0
>> [ 1281.208011]  ? __handle_mm_fault+0x4e9/0x1170
>> [ 1281.208540]  __sys_sendmsg+0x45/0x80
>> [ 1281.209064]  SyS_sendmsg+0x12/0x20
>> [ 1281.209585]  do_syscall_64+0x6e/0x180
>> [ 1281.210093]  entry_SYSCALL64_slow_path+0x25/0x25
>> [ 1281.210596] RIP: 0033:0x7f6ec122f5a0
>> [ 1281.211085] RSP: 002b:00007ffe69e89c48 EFLAGS: 00000246 ORIG_RAX:
>> 000000000000002e
>> [ 1281.211591] RAX: ffffffffffffffda RBX: 00007ffe69e8dd60 RCX: 00007f6ec122f5a0
>> [ 1281.212108] RDX: 0000000000000000 RSI: 00007ffe69e89c90 RDI: 0000000000000003
>> [ 1281.212630] RBP: 00007ffe69e89c90 R08: 0000000000000000 R09: 0000000000000003
>> [ 1281.213151] R10: 00007ffe69e89a10 R11: 0000000000000246 R12: 0000000058f14b9f
>> [ 1281.213665] R13: 0000000000000000 R14: 00000000006473a0 R15: 00007ffe69e8e450
>> [ 1281.214178] Code: 07 27 00 89 c3 eb aa 4c 89 e7 4c 89 ee 49 81 c4
>> 40 02 00 00 e8 7b 58 69 00 e9 56 ff ff ff 5b 41 5c 41 5d 41 5e 5d c3
>> 55 48 89 e5 <0f> 0b 55 31 c0 b9 14 00 00 00 48 89 e5 48 83 ec 50 48 8d
>> 7d b0
>> [ 1281.215859] RIP: __mod_timer.part.35+0x4/0x6 RSP: ffffb3da03033748
>> [ 1281.217612] ---[ end trace 713a77486cbfbfa5 ]---
>>
>> Any ideas how to fix this?
>
>
> I'm a bit surprised that a simple revert of that patch fixes this, but I
> do not question that it does.
>
> I think the best option at this point is to revert this if a fix is not
> found in the next day or two.
