From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2 net-next] fix rtnl notification in atomic context
Date: Thu, 24 Oct 2013 18:28:30 +0200
Message-ID: <52694AAE.5010703@6wind.com>
References: <1382569362-4820-1-git-send-email-ast@plumgrid.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:63495 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202Ab3JXQ2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 12:28:37 -0400
Received: by mail-we0-f173.google.com with SMTP id u57so2614435wes.32
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 09:28:36 -0700 (PDT)
In-Reply-To: <1382569362-4820-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/10/2013 01:02, Alexei Starovoitov a =C3=A9crit :
> commit 991fb3f74c "dev: always advertise rx_flags changes via netlink=
"
> introduced rtnl notification from __dev_set_promiscuity(),
> which can be called in atomic context.
>
> Steps to reproduce:
> ip tuntap add dev tap1 mode tap
> ifconfig tap1 up
> tcpdump -nei tap1 &
> ip tuntap del dev tap1 mode tap
>
> [  271.627994] device tap1 left promiscuous mode
> [  271.639897] BUG: sleeping function called from invalid context at =
mm/slub.c:940
> [  271.664491] in_atomic(): 1, irqs_disabled(): 0, pid: 3394, name: i=
p
> [  271.677525] INFO: lockdep is turned off.
> [  271.690503] CPU: 0 PID: 3394 Comm: ip Tainted: G        W    3.12.=
0-rc3+ #73
> [  271.703996] Hardware name: System manufacturer System Product Name=
/P8Z77 WS, BIOS 3007 07/26/2012
> [  271.731254]  ffffffff81a58506 ffff8807f0d57a58 ffffffff817544e5 ff=
ff88082fa0f428
> [  271.760261]  ffff8808071f5f40 ffff8807f0d57a88 ffffffff8108bad1 ff=
ffffff81110ff8
> [  271.790683]  0000000000000010 00000000000000d0 00000000000000d0 ff=
ff8807f0d57af8
> [  271.822332] Call Trace:
> [  271.838234]  [<ffffffff817544e5>] dump_stack+0x55/0x76
> [  271.854446]  [<ffffffff8108bad1>] __might_sleep+0x181/0x240
> [  271.870836]  [<ffffffff81110ff8>] ? rcu_irq_exit+0x68/0xb0
> [  271.887076]  [<ffffffff811a80be>] kmem_cache_alloc_node+0x4e/0x2a0
> [  271.903368]  [<ffffffff810b4ddc>] ? vprintk_emit+0x1dc/0x5a0
> [  271.919716]  [<ffffffff81614d67>] ? __alloc_skb+0x57/0x2a0
> [  271.936088]  [<ffffffff810b4de0>] ? vprintk_emit+0x1e0/0x5a0
> [  271.952504]  [<ffffffff81614d67>] __alloc_skb+0x57/0x2a0
> [  271.968902]  [<ffffffff8163a0b2>] rtmsg_ifinfo+0x52/0x100
> [  271.985302]  [<ffffffff8162ac6d>] __dev_notify_flags+0xad/0xc0
> [  272.001642]  [<ffffffff8162ad0c>] __dev_set_promiscuity+0x8c/0x1c0
> [  272.017917]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
> [  272.033961]  [<ffffffff8162b109>] dev_set_promiscuity+0x29/0x50
> [  272.049855]  [<ffffffff8172e937>] packet_dev_mc+0x87/0xc0
> [  272.065494]  [<ffffffff81732052>] packet_notifier+0x1b2/0x380
> [  272.080915]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
> [  272.096009]  [<ffffffff81761c66>] notifier_call_chain+0x66/0x150
> [  272.110803]  [<ffffffff8108503e>] __raw_notifier_call_chain+0xe/0x=
10
> [  272.125468]  [<ffffffff81085056>] raw_notifier_call_chain+0x16/0x2=
0
> [  272.139984]  [<ffffffff81620190>] call_netdevice_notifiers_info+0x=
40/0x70
> [  272.154523]  [<ffffffff816201d6>] call_netdevice_notifiers+0x16/0x=
20
> [  272.168552]  [<ffffffff816224c5>] rollback_registered_many+0x145/0=
x240
> [  272.182263]  [<ffffffff81622641>] rollback_registered+0x31/0x40
> [  272.195369]  [<ffffffff816229c8>] unregister_netdevice_queue+0x58/=
0x90
> [  272.208230]  [<ffffffff81547ca0>] __tun_detach+0x140/0x340
> [  272.220686]  [<ffffffff81547ed6>] tun_chr_close+0x36/0x60
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
