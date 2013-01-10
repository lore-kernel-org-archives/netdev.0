From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: NULL pointer dereference in netif_carrier_off
Date: Thu, 10 Jan 2013 09:56:30 -0800
Message-ID: <1357840590.27446.2331.camel@edumazet-glaptop>
References: <CACzvQmaj1_r4DHJjU7K4JN7jywX8y0_j_EQ_6tC8VkGryMmQPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Parkin <tom.parkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:50817 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753771Ab3AJR4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 12:56:32 -0500
Received: by mail-pb0-f54.google.com with SMTP id wz12so439255pbc.41
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 09:56:32 -0800 (PST)
In-Reply-To: <CACzvQmaj1_r4DHJjU7K4JN7jywX8y0_j_EQ_6tC8VkGryMmQPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 17:50 +0000, Tom Parkin wrote:
> Hi Eric,
> 
> I've just had a chance to try your fix for the veth oops I previously
> reported[1], but I still see some problems (please see oops below).
> 
> If I revert the original stats overhead fix (2681128f0ced8) and the
> subsequent NULL deref patch (d0e2c55e7c94) this problem goes away for
> me.
> 
> I've reproduced this bug using a script intended to stress test L2TP
> network namespace code, which uses veth tunnels to bridge namespaces.
> 
> Apologies for the late report!
> 
> Thanks,
> Tom
> 
> [1]
> http://www.spinics.net/lists/netdev/msg221284.html
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000002c
> IP: [<c151f5f8>] netif_carrier_off+0x8/0x30
> *pde = 00000000
> Oops: 0002 [#1] SMP
> Modules linked in: veth bridge stp llc l2tp_ip6 l2tp_ip l2tp_ppp pppox
> l2tp_eth l2tp_netlink l2tp_core kvm_amd 9
> Pid: 5778, comm: ip Tainted: G        W    3.8.0-rc1-tpdev-33-lockdep+
> #42 Gigabyte Technology Co., Ltd. GA-MA62
> EIP: 0060:[<c151f5f8>] EFLAGS: 00010202 CPU: 0
> EIP is at netif_carrier_off+0x8/0x30
> EAX: 00000000 EBX: ee422800 ECX: 00000001 EDX: c18e4b80
> ESI: efec7c44 EDI: ee422840 EBP: efec7b38 ESP: efec7b38
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> CR0: 80050033 CR2: 0000002c CR3: 2fdb2000 CR4: 000007d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Process ip (pid: 5778, ti=efec6000 task=f1d4bf00 task.ti=efec6000)
> Stack:
>  efec7b44 f810e23d ee422800 efec7b60 c14fc169 ffffffff ffffffff f594c210
>  ee422800 efec7c44 efec7b80 c14fc25e efec7b6c ee422040 ee422040 efec7c04
>  ee422800 efec7c44 efec7ba0 c14fc357 f180dd00 efec7c44 ee422000 efec7c44
> Call Trace:
>  [<f810e23d>] veth_close+0x2d/0x60 [veth]
>  [<c14fc169>] __dev_close_many+0x69/0xb0
>  [<c14fc25e>] dev_close_many+0x6e/0xc0
>  [<c14fc357>] rollback_registered_many+0xa7/0x1c0
>  [<c14fc484>] unregister_netdevice_many+0x14/0x60
>  [<c1510e0e>] rtnl_dellink+0x9e/0x100
>  [<c10461a8>] ? ns_capable+0x38/0x70
>  [<c1510d70>] ? rtnetlink_put_metrics+0xf0/0xf0
>  [<c1512ae3>] rtnetlink_rcv_msg+0x153/0x2a0
>  [<c160db1a>] ? mutex_lock_nested+0x21a/0x2e0
>  [<c150f924>] ? rtnl_lock+0x14/0x20
>  [<c1512990>] ? __rtnl_unlock+0x20/0x20
>  [<c152a31e>] netlink_rcv_skb+0x8e/0xb0
>  [<c150f94c>] rtnetlink_rcv+0x1c/0x30
>  [<c1529cdd>] netlink_unicast+0x17d/0x1f0
>  [<c1529f74>] netlink_sendmsg+0x224/0x390
>  [<c14e8791>] sock_sendmsg+0xd1/0xf0
>  [<c1135b89>] ? might_fault+0x89/0x90
>  [<c12fa932>] ? _copy_from_user+0x42/0x60
>  [<c14f5c64>] ? verify_iovec+0x44/0xb0
>  [<c14e96a2>] __sys_sendmsg+0x262/0x270
>  [<c1073e4f>] ? sched_clock_cpu+0xcf/0x150
>  [<c109c02b>] ? trace_hardirqs_off+0xb/0x10
>  [<c1073f35>] ? local_clock+0x65/0x70
>  [<c109c69c>] ? lock_release_holdtime.part.23+0xbc/0xf0
>  [<c10a15ed>] ? lock_release_non_nested+0x29d/0x2e0
>  [<c1073f35>] ? local_clock+0x65/0x70
>  [<c1178ab1>] ? fget_light+0x371/0x450
>  [<c14ead9b>] sys_sendmsg+0x3b/0x60
>  [<c14eb443>] sys_socketcall+0x283/0x2e0
>  [<c1611310>] ? restore_all+0xf/0xf
>  [<c1614bc0>] ? __do_page_fault+0x4e0/0x4e0
>  [<c12fa548>] ? trace_hardirqs_on_thunk+0xc/0x10
>  [<c1618acd>] sysenter_do_call+0x12/0x38
> Code: 00 00 00 e8 ab 2f fd ff 8b 75 f8 b8 01 00 00 00 83 83 9c 00 00
> 00 01 8b 5d f4 8b 7d fc 89 ec 5d c3 66 90 3
> EIP: [<c151f5f8>] netif_carrier_off+0x8/0x30 SS:ESP 0068:efec7b38
> CR2: 000000000000002c
> ---[ end trace e9f7b433da03329a ]---
> 

Hi Tom, thanks for the report, I'll take a look.
