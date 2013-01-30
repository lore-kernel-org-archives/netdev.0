From: Ben Greear <greearb@candelatech.com>
Subject: 3.7.5:  lockdep disabled, then crash in skb_queue_tail.
Date: Tue, 29 Jan 2013 21:35:27 -0800
Message-ID: <5108B11F.2080803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59944 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab3A3Ffb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 00:35:31 -0500
Received: from [50.54.140.2] (50-54-140-2.evrt.wa.frontiernet.net [50.54.140.2])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0U5ZRlQ029146
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 21:35:30 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is from a slightly modified 3.7.5 kernel.

Test case is 2 VAPs, 10 wifi stations, some 'veth' interfaces, etc.  This
appeared to happen during configuration of the interfaces, right after
system boot.

It seems impossible that the skb is null, but maybe it's some general
corrupted memory bug or something...gah!


[   54.470499] INFO: trying to register non-static key.
[   54.471037] the code is fine but needs lockdep annotation.
[   54.471037] turning off the locking correctness validator.
[   54.471037] Pid: 3623, comm: ip Tainted: G        WC   3.7.5+ #39
[   54.471037] Call Trace:
[   54.471037]  [<c049b646>] register_lock_class+0x186/0x380
[   54.471037]  [<c04741f0>] ? try_to_wake_up+0x20/0x260
[   54.471037]  [<c049d94a>] __lock_acquire+0x6a/0x1450
[   54.471037]  [<c09747bf>] ? _raw_spin_unlock_irqrestore+0x3f/0x80
[   54.471037]  [<c049da83>] ? __lock_acquire+0x1a3/0x1450
[   54.471037]  [<c049eda9>] lock_acquire+0x79/0xa0
[   54.471037]  [<c0854fcf>] ? skb_queue_tail+0x1f/0x50
[   54.471037]  [<c09741d1>] _raw_spin_lock_irqsave+0x51/0x70
[   54.471037]  [<c0854fcf>] ? skb_queue_tail+0x1f/0x50
[   54.471037]  [<c0854fcf>] skb_queue_tail+0x1f/0x50
[   54.471037]  [<c0885e0d>] __netlink_sendskb+0x1d/0x40
[   54.471037]  [<c08873b0>] netlink_broadcast_filtered+0x310/0x340
[   54.471037]  [<c0887409>] netlink_broadcast+0x29/0x30
[   54.471037]  [<c0887bac>] nlmsg_notify+0x3c/0xb0
[   54.471037]  [<c087161c>] rtnl_notify+0x3c/0x50
[   54.471037]  [<c0918dbe>] inet6_rt_notify+0xde/0x130
[   54.471037]  [<c091e3fd>] fib6_del+0x1bd/0x2f0
[   54.471037]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[   54.471037]  [<c091e582>] fib6_clean_node+0x52/0xc0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[   54.471037]  [<c091dc2c>] ? fib6_walk+0x3c/0x90
[   54.471037]  [<c091cfb5>] fib6_walk_continue+0x145/0x170
[   54.471037]  [<c091dc33>] fib6_walk+0x43/0x90
[   54.471037]  [<c091e2f6>] fib6_del+0xb6/0x2f0
[   54.471037]  [<c091e530>] ? fib6_del+0x2f0/0x2f0
[   54.471037]  [<c091cd70>] ? rt6_route_rcv+0x240/0x240
[   54.471037]  [<c091e582>] fib6_clean_node+0x52/0xc0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[   54.471037]  [<c091dc2c>] ? fib6_walk+0x3c/0x90
[   54.471037]  [<c091cfb5>] fib6_walk_continue+0x145/0x170
[   54.471037]  [<c091dc33>] fib6_walk+0x43/0x90
[   54.471037]  [<c091e6c3>] fib6_clean_all+0xd3/0x1c0
[   54.471037]  [<c091e5f0>] ? fib6_clean_node+0xc0/0xc0
[   54.471037]  [<c0917030>] ? fib6_remove_prefsrc+0x70/0x70
[   54.471037]  [<c091e530>] ? fib6_del+0x2f0/0x2f0
[   54.471037]  [<c0917030>] ? fib6_remove_prefsrc+0x70/0x70
[   54.471037]  [<c0919864>] rt6_ifdown+0x24/0xa0
[   54.471037]  [<c091206c>] addrconf_ifdown+0x2c/0x480
[   54.471037]  [<c0915241>] addrconf_notify+0x111/0xba0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[   54.471037]  [<c091e817>] ? fib6_run_gc+0x67/0xe0
[   54.471037]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c09745cf>] ? _raw_spin_unlock_bh+0x2f/0x40
[   54.471037]  [<c091e817>] ? fib6_run_gc+0x67/0xe0
[   54.471037]  [<c09229d8>] ? ndisc_netdev_event+0x68/0x290
[   54.471037]  [<c0605b7e>] ? rcu_read_unlock+0x2e/0x60
[   54.471037]  [<c0605d2a>] ? sel_netif_netdev_notifier_handler+0xfa/0x1b0
[   54.471037]  [<c0977ec2>] notifier_call_chain+0x42/0xf0
[   54.471037]  [<c046c06a>] raw_notifier_call_chain+0x1a/0x20
[   54.471037]  [<c085fd47>] call_netdevice_notifiers+0x27/0x60
[   54.471037]  [<c086070c>] __dev_notify_flags+0x5c/0x80
[   54.471037]  [<c0860767>] dev_change_flags+0x37/0x60
[   54.471037]  [<c0872070>] do_setlink+0x190/0x8f0
[   54.471037]  [<c066d562>] ? nla_parse+0x22/0xd0
[   54.471037]  [<c087448e>] rtnl_newlink+0x52e/0x5b0
[   54.471037]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[   54.471037]  [<c05f6ed7>] ? security_capable+0x17/0x20
[   54.471037]  [<c0450b00>] ? sys_sysctl+0x130/0x1a0
[   54.471037]  [<c0873f60>] ? rtnl_configure_link+0xa0/0xa0
[   54.471037]  [<c08719c7>] rtnetlink_rcv_msg+0x267/0x2c0
[   54.471037]  [<c0871760>] ? rtnetlink_rcv+0x20/0x20
[   54.471037]  [<c0887da6>] netlink_rcv_skb+0x86/0xb0
[   54.471037]  [<c0871757>] rtnetlink_rcv+0x17/0x20
[   54.471037]  [<c0887af5>] netlink_unicast+0x175/0x1f0
[   54.471037]  [<c0888764>] netlink_sendmsg+0x204/0x310
[   54.471037]  [<c084d88d>] sock_sendmsg+0xbd/0xf0
[   54.471037]  [<c05005c4>] ? might_fault+0x74/0x80
[   54.471037]  [<c0657ce8>] ? _copy_from_user+0x38/0x130
[   54.471037]  [<c0858a33>] ? verify_iovec+0x53/0xb0
[   54.471037]  [<c084e4d5>] __sys_sendmsg+0x2c5/0x2e0
[   54.471037]  [<c084dd70>] ? sock_aio_write+0x170/0x170
[   54.471037]  [<c049ee29>] ? lock_release_non_nested+0x59/0x2e0
[   54.471037]  [<c0547355>] ? fget_light+0x335/0x3f0
[   54.471037]  [<c050057e>] ? might_fault+0x2e/0x80
[   54.471037]  [<c050057e>] ? might_fault+0x2e/0x80
[   54.471037]  [<c084e666>] sys_sendmsg+0x36/0x60
[   54.471037]  [<c084ed77>] sys_socketcall+0x107/0x2d0
[   54.471037]  [<c097a282>] ? sysenter_exit+0xf/0x1e
[   54.471037]  [<c097a24d>] sysenter_do_call+0x12/0x38


(gdb) l *(skb_queue_tail+0x27)
0xc0854fd7 is in skb_queue_tail (/home/greearb/git/linux-3.7.dev.y/include/linux/skbuff.h:1018).
1013					struct sk_buff *prev, struct sk_buff *next,
1014					struct sk_buff_head *list)
1015	{
1016		newsk->next = next;
1017		newsk->prev = prev;
1018		next->prev  = prev->next = newsk;
1019		list->qlen++;
1020	}
1021	
1022	static inline void __skb_queue_splice(const struct sk_buff_head *list,
(gdb)

(gdb) l *(__netlink_sendskb+0x1d)
0xc0885e0d is in __netlink_sendskb (/home/greearb/git/linux-3.7.dev.y/net/netlink/af_netlink.c:878).
873	static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
874	{
875		int len = skb->len;
876	
877		skb_queue_tail(&sk->sk_receive_queue, skb);
878		sk->sk_data_ready(sk, len);
879		return len;
880	}
881	
882	int netlink_sendskb(struct sock *sk, struct sk_buff *skb)


[   54.471037] BUG: unable to handle kernel NULL pointer dereference at   (null)
[   54.471037] IP: [<c0854fd7>] skb_queue_tail+0x27/0x50
[   54.471037] *pdpt = 0000000030039001 *pde = 0000000000000000
[   54.471037] Oops: 0002 [#1] PREEMPT SMP
[   54.471037] Modules linked in: bridge veth ip_gre gre 8021q garp stp llc fuse macvlan pktgen nfsv3 nfs_acl nfsv4 auth_rpcgss nfs fscache lockd sunrpc 
binfmt_misc uinput arc4 ath9k mac80211 iTCO_wdt coretemp ath9k_common iTCO_vendor_support snd_hda_codec_realtek gpio_ich ath9k_hw snd_hda_intel snd_hda_codec 
snd_hwdep ath snd_seq cfg80211 snd_seq_device microcode lpc_ich i2c_i801 rfkill snd_pcm serio_raw pcspkr snd_timer snd soundcore r8169 snd_page_alloc mii i915 
drm_kms_helper drm i2c_algo_bit i2c_core video
[   54.471037] Pid: 3623, comm: ip Tainted: G        WC   3.7.5+ #39 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
[   54.471037] EIP: 0060:[<c0854fd7>] EFLAGS: 00010086 CPU: 0
[   54.471037] EIP is at skb_queue_tail+0x27/0x50
[   54.471037] EAX: 00000282 EBX: f7490890 ECX: 00000000 EDX: 00000000
[   54.471037] ESI: f749089c EDI: f0063c00 EBP: f006d6f0 ESP: f006d6e4
[   54.471037]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   54.471037] CR0: 8005003b CR2: 00000000 CR3: 313f5000 CR4: 000007e0
[   54.471037] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   54.471037] DR6: ffff0ff0 DR7: 00000400
[   54.471037] Process ip (pid: 3623, ti=f006c000 task=f1378000 task.ti=f006c000)
[   54.471037] Stack:
[   54.471037]  f7490800 00000080 0000000a f006d700 c0885e0d f7490800 f7490814 f006d744
[   54.471037]  c08873b0 f006d744 f0063cb8 00000000 00000000 00000000 f7490830 00000000
[   54.471037]  f0063c00 c0bd3680 f0063c00 00000000 f5c0e000 0000000b f0063c00 f5c0e000
[   54.471037] Call Trace:
[   54.471037]  [<c0885e0d>] __netlink_sendskb+0x1d/0x40
[   54.471037]  [<c08873b0>] netlink_broadcast_filtered+0x310/0x340
[   54.471037]  [<c0887409>] netlink_broadcast+0x29/0x30
[   54.471037]  [<c0887bac>] nlmsg_notify+0x3c/0xb0
[   54.471037]  [<c087161c>] rtnl_notify+0x3c/0x50
[   54.471037]  [<c0918dbe>] inet6_rt_notify+0xde/0x130
[   54.471037]  [<c091e3fd>] fib6_del+0x1bd/0x2f0
[   54.471037]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[   54.471037]  [<c091e582>] fib6_clean_node+0x52/0xc0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[   54.471037]  [<c091dc2c>] ? fib6_walk+0x3c/0x90
[   54.471037]  [<c091cfb5>] fib6_walk_continue+0x145/0x170
[   54.471037]  [<c091dc33>] fib6_walk+0x43/0x90
[   54.471037]  [<c091e2f6>] fib6_del+0xb6/0x2f0
[   54.471037]  [<c091e530>] ? fib6_del+0x2f0/0x2f0
[   54.471037]  [<c091cd70>] ? rt6_route_rcv+0x240/0x240
[   54.471037]  [<c091e582>] fib6_clean_node+0x52/0xc0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d561>] ? trace_hardirqs_on_caller+0xa1/0x180
[   54.471037]  [<c091dc2c>] ? fib6_walk+0x3c/0x90
[   54.471037]  [<c091cfb5>] fib6_walk_continue+0x145/0x170
[   54.471037]  [<c091dc33>] fib6_walk+0x43/0x90
[   54.471037]  [<c091e6c3>] fib6_clean_all+0xd3/0x1c0
[   54.471037]  [<c091e5f0>] ? fib6_clean_node+0xc0/0xc0
[   54.471037]  [<c0917030>] ? fib6_remove_prefsrc+0x70/0x70
[   54.471037]  [<c091e530>] ? fib6_del+0x2f0/0x2f0
[   54.471037]  [<c0917030>] ? fib6_remove_prefsrc+0x70/0x70
[   54.471037]  [<c0919864>] rt6_ifdown+0x24/0xa0
[   54.471037]  [<c091206c>] addrconf_ifdown+0x2c/0x480
[   54.471037]  [<c0915241>] addrconf_notify+0x111/0xba0
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c049d5b4>] ? trace_hardirqs_on_caller+0xf4/0x180
[   54.471037]  [<c091e817>] ? fib6_run_gc+0x67/0xe0
[   54.471037]  [<c049d64b>] ? trace_hardirqs_on+0xb/0x10
[   54.471037]  [<c044da7b>] ? local_bh_enable_ip+0x6b/0xe0
[   54.471037]  [<c09745cf>] ? _raw_spin_unlock_bh+0x2f/0x40
[   54.471037]  [<c091e817>] ? fib6_run_gc+0x67/0xe0
[   54.471037]  [<c09229d8>] ? ndisc_netdev_event+0x68/0x290
[   54.471037]  [<c0605b7e>] ? rcu_read_unlock+0x2e/0x60
[   54.471037]  [<c0605d2a>] ? sel_netif_netdev_notifier_handler+0xfa/0x1b0
[   54.471037]  [<c0977ec2>] notifier_call_chain+0x42/0xf0
[   54.471037]  [<c046c06a>] raw_notifier_call_chain+0x1a/0x20
[   54.471037]  [<c085fd47>] call_netdevice_notifiers+0x27/0x60
[   54.471037]  [<c086070c>] __dev_notify_flags+0x5c/0x80
[   54.471037]  [<c0860767>] dev_change_flags+0x37/0x60
[   54.471037]  [<c0872070>] do_setlink+0x190/0x8f0
[   54.471037]  [<c066d562>] ? nla_parse+0x22/0xd0
[   54.471037]  [<c087448e>] rtnl_newlink+0x52e/0x5b0
[   54.471037]  [<c049d294>] ? mark_held_locks+0x64/0xf0
[   54.471037]  [<c05f6ed7>] ? security_capable+0x17/0x20
[   54.471037]  [<c0450b00>] ? sys_sysctl+0x130/0x1a0
[   54.471037]  [<c0873f60>] ? rtnl_configure_link+0xa0/0xa0
[   54.471037]  [<c08719c7>] rtnetlink_rcv_msg+0x267/0x2c0
[   54.471037]  [<c0871760>] ? rtnetlink_rcv+0x20/0x20
[   54.471037]  [<c0887da6>] netlink_rcv_skb+0x86/0xb0
[   54.471037]  [<c0871757>] rtnetlink_rcv+0x17/0x20
[   54.471037]  [<c0887af5>] netlink_unicast+0x175/0x1f0
[   54.471037]  [<c0888764>] netlink_sendmsg+0x204/0x310
[   54.471037]  [<c084d88d>] sock_sendmsg+0xbd/0xf0
[   54.471037]  [<c05005c4>] ? might_fault+0x74/0x80
[   54.471037]  [<c0657ce8>] ? _copy_from_user+0x38/0x130
[   54.471037]  [<c0858a33>] ? verify_iovec+0x53/0xb0
[   54.471037]  [<c084e4d5>] __sys_sendmsg+0x2c5/0x2e0
[   54.471037]  [<c084dd70>] ? sock_aio_write+0x170/0x170
[   54.471037]  [<c049ee29>] ? lock_release_non_nested+0x59/0x2e0
[   54.471037]  [<c0547355>] ? fget_light+0x335/0x3f0
[   54.471037]  [<c050057e>] ? might_fault+0x2e/0x80
[   54.471037]  [<c050057e>] ? might_fault+0x2e/0x80
[   54.471037]  [<c084e666>] sys_sendmsg+0x36/0x60
[   54.471037]  [<c084ed77>] sys_socketcall+0x107/0x2d0
[   54.471037]  [<c097a282>] ? sysenter_exit+0xf/0x1e
[   54.471037]  [<c097a24d>] sysenter_do_call+0x12/0x38
[   54.471037] Code: 00 00 00 00 55 89 e5 83 ec 0c 89 74 24 04 8d 70 0c 89 1c 24 89 c3 89 f0 89 7c 24 08 89 d7 e8 b1 f1 11 00 8b 4b 04 89 1f 89 4f 04 <89> 39 83 
43 08 01 89 c2 89 f0 89 7b 04 e8 97 f7 11 00 8b 1c 24
[   54.471037] EIP: [<c0854fd7>] skb_queue_tail+0x27/0x50 SS:ESP 0068:f006d6e4
[   54.471037] CR2: 0000000000000000
[   54.471037] ---[ end trace fbfaaa6758c4d964 ]---
[   54.471037] Kernel panic - not syncing: Fatal exception in interrupt

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
