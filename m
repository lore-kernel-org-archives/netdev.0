From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: deadlock when unplugging rtl8192cu controller
Date: Sun, 27 Oct 2013 03:08:18 -0400
Message-ID: <CAKb7Uvj6U_KiMz54kYRs57jhYjqC-CHLNTRSQaOj47X2eyzkPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:65226 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3J0HIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 03:08:19 -0400
Received: by mail-ob0-f172.google.com with SMTP id gq1so2492651obb.3
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 00:08:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I pulled the network controller out, after trying to down the
controller (which failed at the script level, I didn't investigate the
details). Here is the output from echo w > /proc/sysrq-trigger. It
seems like khubd is stuck in schedule while holding rtnl_lock, which
in turn hangs everything else. Apologies for the linewrapping below.
Any other information I should collect should this happen again?
Anything I can do short of rebooting to get things going again?

Bus 002 Device 005: ID 0bda:8176 Realtek Semiconductor Corp.
RTL8188CUS 802.11n WLAN Adapter

[103822.129461] usb 2-2: USB disconnect, device number 5
[103895.563068] SysRq : Show Blocked State
[103895.563072]   task                        PC stack   pid father
[103895.563082] khubd           D ffff8801c8bf4138  3648   550      2 0x00000000
[103895.563086]  ffff8801c818faf8 0000000000000046 ffff8801c818fa98
ffff8801c8925490
[103895.563089]  ffff8801c818fb18 ffff8801c8bf3d80 ffff8801c818ffd8
ffff8801c818ffd8
[103895.563091]  0000000000013000 ffff8801c8bf3d80 ffff8801c8bf3d80
ffffffff81c872a0
[103895.563094] Call Trace:
[103895.563100]  [<ffffffff816d1599>] schedule+0x64/0x66
[103895.563103]  [<ffffffff816d1752>] schedule_preempt_disabled+0xe/0x10
[103895.563106]  [<ffffffff816d0688>] __mutex_lock_slowpath+0x13d/0x193
[103895.563110]  [<ffffffff81080303>] ? call_usermodehelper_setup+0x59/0x9c
[103895.563116]  [<ffffffff816cfbc4>] mutex_lock+0x23/0x37
[103895.563120]  [<ffffffff8153df7f>] rtnl_lock+0x15/0x17
[103895.563123]  [<ffffffff81689c32>] ieee80211_unregister_hw+0x55/0x10a
[103895.563128]  [<ffffffffa03c0b39>] rtl_usb_disconnect+0x47/0xcb [rtl_usb]
[103895.563132]  [<ffffffff81418677>] usb_unbind_interface+0x69/0x144
[103895.563135]  [<ffffffff813a2fa5>] __device_release_driver+0x89/0xdf
[103895.563137]  [<ffffffff813a301e>] device_release_driver+0x23/0x30
[103895.563140]  [<ffffffff813a2b2c>] bus_remove_device+0xe9/0xfe
[103895.563142]  [<ffffffff813a03a1>] device_del+0x130/0x18a
[103895.563145]  [<ffffffff81416817>] usb_disable_device+0x77/0x197
[103895.563149]  [<ffffffff8140f93f>] usb_disconnect+0x91/0x15e
[103895.563151]  [<ffffffff814110de>] hub_thread+0x652/0xf15
[103895.563154]  [<ffffffff8108928f>] ? add_wait_queue+0x49/0x49
[103895.563156]  [<ffffffff81410a8c>] ? hub_port_debounce+0xbf/0xbf
[103895.563159]  [<ffffffff81410a8c>] ? hub_port_debounce+0xbf/0xbf
[103895.563162]  [<ffffffff810889df>] kthread+0x8d/0x95
[103895.563164]  [<ffffffff81088952>] ? kthread_freezable_should_stop+0x43/0x43
[103895.563168]  [<ffffffff816d901c>] ret_from_fork+0x7c/0xb0
[103895.563170]  [<ffffffff81088952>] ? kthread_freezable_should_stop+0x43/0x43
[103895.563194] ntpd            D ffff8801c82c5ff8  4864  3211      1 0x00000004
[103895.563197]  ffff8801b8d8fcb8 0000000000000082 ffff8801b8d8fc78
ffff8801c8924ce0
[103895.563200]  000000000000d0a0 ffff8801c82c5c40 ffff8801b8d8ffd8
ffff8801b8d8ffd8
[103895.563202]  0000000000013000 ffff8801c82c5c40 ffff8801c085f400
ffffffff81c872a0
[103895.563205] Call Trace:
[103895.563207]  [<ffffffff816d1599>] schedule+0x64/0x66
[103895.563210]  [<ffffffff816d1752>] schedule_preempt_disabled+0xe/0x10
[103895.563212]  [<ffffffff816d0688>] __mutex_lock_slowpath+0x13d/0x193
[103895.563214]  [<ffffffff816cfbc4>] mutex_lock+0x23/0x37
[103895.563217]  [<ffffffff81079e06>] ? dequeue_signal+0x113/0x122
[103895.563219]  [<ffffffff8153df7f>] rtnl_lock+0x15/0x17
[103895.563222]  [<ffffffff81541960>] dev_ioctl+0x30/0x620
[103895.563225]  [<ffffffff8108fb4a>] ? should_resched+0x9/0x28
[103895.563227]  [<ffffffff816d12dc>] ? _cond_resched+0xe/0x22
[103895.563230]  [<ffffffff8113a275>] ? kmem_cache_alloc+0x31/0xfe
[103895.563234]  [<ffffffff8151dda4>] sock_do_ioctl+0x3b/0x46
[103895.563236]  [<ffffffff8151e1f2>] sock_ioctl+0x201/0x20e
[103895.563240]  [<ffffffff8114fc1f>] do_vfs_ioctl+0x407/0x448
[103895.563243]  [<ffffffff8114339f>] ? alloc_file+0x1e/0xc4
[103895.563245]  [<ffffffff816d2193>] ? _raw_spin_lock+0xe/0x10
[103895.563248]  [<ffffffff8114fcac>] SyS_ioctl+0x4c/0x70
[103895.563250]  [<ffffffff816d90c6>] system_call_fastpath+0x1a/0x1f
[103895.563275] ip              D ffff880070d8e7a8  5968 14224  14183 0x00000004
[103895.563278]  ffff880077ad9b28 0000000000000086 0000000000000000
ffff8801c826eba0
[103895.563280]  0000000000000000 ffff880070d8e3f0 ffff880077ad9fd8
ffff880077ad9fd8
[103895.563283]  0000000000013000 ffff880070d8e3f0 ffffffff8108ac3a
ffffffff81c872a0
[103895.563285] Call Trace:
[103895.563288]  [<ffffffff8108ac3a>] ? need_resched+0x11/0x1d
[103895.563291]  [<ffffffff816d1599>] schedule+0x64/0x66
[103895.563293]  [<ffffffff816d1752>] schedule_preempt_disabled+0xe/0x10
[103895.563295]  [<ffffffff816d0688>] __mutex_lock_slowpath+0x13d/0x193
[103895.563298]  [<ffffffff816cfbc4>] mutex_lock+0x23/0x37
[103895.563301]  [<ffffffff81527679>] ? __kmalloc_reserve.isra.47+0x2d/0x6d
[103895.563303]  [<ffffffff8153df7f>] rtnl_lock+0x15/0x17
[103895.563306]  [<ffffffff8153df97>] rtnetlink_rcv+0x16/0x2d
[103895.563309]  [<ffffffff8156d56c>] netlink_unicast+0xeb/0x16d
[103895.563312]  [<ffffffff8156d8c7>] netlink_sendmsg+0x2d9/0x31a
[103895.563314]  [<ffffffff8151fc08>] sock_sendmsg+0x69/0x8a
[103895.563318]  [<ffffffff81157665>] ? fget_light+0x38/0x88
[103895.563320]  [<ffffffff8152032b>] SYSC_sendto+0xeb/0x110
[103895.563323]  [<ffffffff8151f227>] ? move_addr_to_user+0x73/0x96
[103895.563325]  [<ffffffff8151f560>] ? SYSC_getsockname+0x74/0x86
[103895.563328]  [<ffffffff81520780>] SyS_sendto+0xe/0x10
[103895.563330]  [<ffffffff816d90c6>] system_call_fastpath+0x1a/0x1f
[103895.563332] ifconfig        D ffff8801b60d5848  5968 14237   3184 0x00000004
[103895.563335]  ffff88007b5d1cb8 0000000000000086 0000000000000202
ffff8801bec307b0
[103895.563338]  0000000000000010 ffff8801b60d5490 ffff88007b5d1fd8
ffff88007b5d1fd8
[103895.563340]  0000000000013000 ffff8801b60d5490 ffffffff81c872a0
ffffffff81c872a0
[103895.563342] Call Trace:
[103895.563345]  [<ffffffff816d1599>] schedule+0x64/0x66
[103895.563347]  [<ffffffff816d1752>] schedule_preempt_disabled+0xe/0x10
[103895.563349]  [<ffffffff816d0688>] __mutex_lock_slowpath+0x13d/0x193
[103895.563352]  [<ffffffff816cfbc4>] mutex_lock+0x23/0x37
[103895.563354]  [<ffffffff8153df7f>] rtnl_lock+0x15/0x17
[103895.563356]  [<ffffffff81541960>] dev_ioctl+0x30/0x620
[103895.563360]  [<ffffffff811232cf>] ? handle_mm_fault+0x1bd/0x1d7
[103895.563362]  [<ffffffff8151dda4>] sock_do_ioctl+0x3b/0x46
[103895.563364]  [<ffffffff8151e1f2>] sock_ioctl+0x201/0x20e
[103895.563367]  [<ffffffff8114fc1f>] do_vfs_ioctl+0x407/0x448
[103895.563369]  [<ffffffff8114fcac>] SyS_ioctl+0x4c/0x70
[103895.563372]  [<ffffffff816d90c6>] system_call_fastpath+0x1a/0x1f
