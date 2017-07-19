From: David Ahern <dsahern@gmail.com>
Subject: out-of-bounds access with virtio-net
Date: Wed, 19 Jul 2017 10:59:09 -0600
Message-ID: <b3c684fd-72eb-f67b-90f3-bc1185d8b576@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36191 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753094AbdGSQ7L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:59:11 -0400
Received: by mail-pf0-f182.google.com with SMTP id o88so2269386pfk.3
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 09:59:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the mac address on a virtio-net based nic is triggering an
out-of-bounds access. Nothing fancy with the command:

ip li set dev eth2 addr 01:02:34:56:78:9a

virtnet_set_mac_address is calling kmemdup for sizeof sockaddr, yet only
ETH_ALEN + sizeof(sa_family_t) bytes were malloc'ed.


Full KASAN dump:

[  236.863289]
==================================================================
[  236.864790] BUG: KASAN: slab-out-of-bounds in kmemdup+0x35/0x55
[  236.865928] Read of size 16 at addr ffff880035df3540 by task ip/770

[  236.867441] CPU: 0 PID: 770 Comm: ip Not tainted 4.12.0+ #308
[  236.868549] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  236.870298] Call Trace:
[  236.870665]  dump_stack+0x81/0xb6
[  236.871146]  print_address_description+0x76/0x225
[  236.871818]  ? kmemdup+0x35/0x55
[  236.872286]  kasan_report+0x23e/0x269
[  236.872820]  ? _free_receive_bufs+0x127/0x127
[  236.873439]  check_memory_region+0x2d/0x13e
[  236.874060]  __asan_loadN+0xf/0x11
[  236.874551]  kmemdup+0x35/0x55
[  236.875005]  virtnet_set_mac_address+0x47/0x1a0
[  236.875653]  ? rcu_read_lock_sched_held+0x6b/0x75
[  236.876321]  ? trace_kmalloc+0xad/0x146
[  236.876870]  ? do_setlink+0x267/0x127f
[  236.877420]  ? _free_receive_bufs+0x127/0x127
[  236.878052]  dev_set_mac_address+0x8c/0xf0
[  236.878641]  do_setlink+0x300/0x127f
[  236.879160]  ? paravirt_sched_clock+0x9/0xd
[  236.879760]  ? sched_clock+0x9/0xb
[  236.880276]  ? lock_release+0x27f/0x444
[  236.880841]  ? validate_nla+0x127/0x1cf
[  236.881404]  ? nla_parse+0x124/0x145
[  236.881950]  rtnl_newlink+0x4cf/0x93f
[  236.882479]  ? __asan_storeN+0x12/0x14
[  236.883017]  ? rtnl_newlink+0x193/0x93f
[  236.883582]  ? paravirt_sched_clock+0x9/0xd
[  236.884179]  ? trace_event_raw_event_lock+0xc0/0xeb
[  236.884882]  ? hlock_class+0x67/0x85
[  236.885400]  ? __lock_acquire+0x1306/0x1534
[  236.886013]  ? paravirt_sched_clock+0x9/0xd
[  236.886705]  rtnetlink_rcv_msg+0x268/0x277
[  236.887312]  ? rtnl_newlink+0x93f/0x93f
[  236.887869]  netlink_rcv_skb+0xaf/0x123
[  236.888442]  rtnetlink_rcv+0x23/0x2a
[  236.888956]  netlink_unicast+0x1b5/0x240
[  236.889532]  netlink_sendmsg+0x42e/0x464
[  236.890124]  ? netlink_unicast+0x240/0x240
[  236.890709]  sock_sendmsg_nosec+0x47/0x57
[  236.891290]  ___sys_sendmsg+0x2c4/0x393
[  236.891860]  ? lock_release+0x27f/0x444
[  236.892430]  ? rcu_read_unlock+0x5d/0x5f
[  236.892998]  ? mntput_no_expire+0x4b/0x226
[  236.893601]  ? lock_is_held_type+0x104/0x113
[  236.894226]  ? __fget_light+0x91/0xb9
[  236.894773]  __sys_sendmsg+0x45/0x70
[  236.895291]  ? __sys_sendmsg+0x45/0x70
[  236.895858]  SyS_sendmsg+0x19/0x1b
[  236.896352]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  236.897007] RIP: 0033:0x7fdce38e30b0
[  236.897517] RSP: 002b:00007ffc0d6625c8 EFLAGS: 00000246 ORIG_RAX:
000000000000002e
[  236.898574] RAX: ffffffffffffffda RBX: 00000000596f8dc9 RCX:
00007fdce38e30b0
[  236.899560] RDX: 0000000000000000 RSI: 00007ffc0d662610 RDI:
0000000000000003
[  236.900544] RBP: ffffffff810c7b92 R08: 0000000000000001 R09:
0000000000000003
[  236.901529] R10: ffffffffffff7e60 R11: 0000000000000246 R12:
ffff88002e8aff98
[  236.902527] R13: 0000000000000046 R14: ffffffff810012e0 R15:
ffffffff811673a3
[  236.903520]  ? time_hardirqs_off+0x15/0x28
[  236.904099]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  236.904771]  ? trace_hardirqs_off_caller+0x123/0x131

[  236.905726] Allocated by task 770:
[  236.906224]  save_stack_trace+0x1b/0x1d
[  236.906770]  save_stack+0x46/0xce
[  236.907245]  kasan_kmalloc+0x97/0xa6
[  236.907754]  __kmalloc+0xf7/0x11f
[  236.908222]  do_setlink+0x267/0x127f
[  236.908728]  rtnl_newlink+0x4cf/0x93f
[  236.909249]  rtnetlink_rcv_msg+0x268/0x277
[  236.909819]  netlink_rcv_skb+0xaf/0x123
[  236.910359]  rtnetlink_rcv+0x23/0x2a
[  236.910863]  netlink_unicast+0x1b5/0x240
[  236.911417]  netlink_sendmsg+0x42e/0x464
[  236.911970]  sock_sendmsg_nosec+0x47/0x57
[  236.912541]  ___sys_sendmsg+0x2c4/0x393
[  236.913082]  __sys_sendmsg+0x45/0x70
[  236.913582]  SyS_sendmsg+0x19/0x1b
[  236.914092]  entry_SYSCALL_64_fastpath+0x1f/0xbe

[  236.914964] Freed by task 117:
[  236.915408]  save_stack_trace+0x1b/0x1d
[  236.915956]  save_stack+0x46/0xce
[  236.916422]  kasan_slab_free+0x87/0xa9
[  236.916952]  __cache_free+0x17/0x30
[  236.917450]  kfree+0x10b/0x18c
[  236.917904]  single_release+0x53/0x5e
[  236.918423]  __fput+0x1c1/0x2f4
[  236.918870]  ____fput+0xe/0x10
[  236.919309]  task_work_run+0x8d/0xbb
[  236.919814]  prepare_exit_to_usermode+0xe7/0x10b
[  236.920464]  syscall_return_slowpath+0x1a8/0x22b
[  236.921108]  entry_SYSCALL_64_fastpath+0xbc/0xbe

[  236.921994] The buggy address belongs to the object at ffff880035df3540
 which belongs to the cache kmalloc-32 of size 32
[  236.923659] The buggy address is located 0 bytes inside of
 32-byte region [ffff880035df3540, ffff880035df3560)
[  236.925210] The buggy address belongs to the page:
[  236.925884] page:ffffea0000bc8d28 count:1 mapcount:0
mapping:ffff880035df3000 index:0xffff880035df3fc1
[  236.927170] flags: 0x4000000000000100(slab)
[  236.927760] raw: 4000000000000100 ffff880035df3000 ffff880035df3fc1
0000000100000022
[  236.928826] raw: ffffea0000bc8728 ffffea0000bc9870 ffff880035c00100
[  236.929694] page dumped because: kasan: bad access detected

[  236.930708] Memory state around the buggy address:
[  236.931364]  ffff880035df3400: fb fb fb fb fc fc fc fc fb fb fb fb fc
fc fc fc
[  236.932353]  ffff880035df3480: fb fb fb fb fc fc fc fc fb fb fb fb fc
fc fc fc
[  236.933342] >ffff880035df3500: 00 00 fc fc fc fc fc fc 00 fc fc fc fc
fc fc fc
[  236.934338]                                               ^
[  236.935108]  ffff880035df3580: fb fb fb fb fc fc fc fc fb fb fb fb fc
fc fc fc
[  236.936098]  ffff880035df3600: fb fb fb fb fc fc fc fc fb fb fb fb fc
fc fc fc
[  236.937084]
==================================================================
