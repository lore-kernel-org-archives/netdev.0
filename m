From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: softirqs are invoked while bottom halves are masked (was: Re:
 [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw ethernet
 socket interface)
Date: Tue, 12 Jul 2011 12:10:11 +0200
Message-ID: <1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>,
	Ronny Meeus <ronny.meeus@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43251 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1GLKKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 06:10:23 -0400
Received: by wyg8 with SMTP id 8so3142701wyg.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 03:10:21 -0700 (PDT)
In-Reply-To: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 juillet 2011 =C3=A0 11:23 +0200, Thomas De Schampheleire a
=C3=A9crit :
> Hi,
>=20
> I'm adding the linuxppc-dev mailing list since this may be pointing t=
o
> an irq/softirq problem in the powerpc architecture-specific code...

>=20
> Note that the reason we are seeing this problem, may be because the
> kernel we are using contains some patches from Freescale.
> Specifically, in dev_queue_xmit(), support is added for hardware queu=
e
> handling, just before entering the rcu_read_lock_bh():
>=20

Oh well, what a mess.

>         if (dev->features & NETIF_F_HW_QDISC) {
>                 txq =3D dev_pick_tx(dev, skb);



>                 return dev_hard_start_xmit(skb, dev, txq);
	This need to be :
		local_bh_disable();
		rc =3D dev_hard_start_xmit(skb, dev, txq);
		local_bh_enable();
		return rc;


>         }
>=20
>         /* Disable soft irqs for various locks below. Also
>          * stops preemption for RCU.
>          */
>         rcu_read_lock_bh();
>=20
> We just tried moving the escaping to dev_hard_start_xmit() after
> taking the lock, but this gives a large number of other problems, e.g=
=2E
>=20
> [   78.662428] BUG: sleeping function called from invalid context at
> mm/slab.c:3101
> [   78.751004] in_atomic(): 1, irqs_disabled(): 0, pid: 1908, name:
> send_eth_socket
> [   78.839582] Call Trace:
> [   78.868784] [ec537b70] [c000789c] show_stack+0x78/0x18c (unreliabl=
e)
> [   78.944905] [ec537bb0] [c0022900] __might_sleep+0x100/0x118
> [   79.011636] [ec537bc0] [c00facc4] kmem_cache_alloc+0x48/0x118
> [   79.080446] [ec537be0] [c02cd0e8] __alloc_skb+0x50/0x130
> [   79.144047] [ec537c00] [c02cdf5c] skb_copy+0x44/0xc8
> [   79.203478] [ec537c20] [c029f904] dpa_tx+0x154/0x758

doing GFP_KERNEL allocations in dpa_tx() is wrong, for sure.


> [   79.262907] [ec537c80] [c02d78ec] dev_hard_start_xmit+0x424/0x588
> [   79.335878] [ec537cc0] [c02d7aac] dev_queue_xmit+0x5c/0x3a4
> [   79.402602] [ec537cf0] [c0338d4c] packet_sendmsg+0x8c4/0x988
> [   79.470363] [ec537d70] [c02c3838] sock_sendmsg+0x90/0xb4
> [   79.533960] [ec537e40] [c02c4420] sys_sendto+0xdc/0x120
> [   79.596514] [ec537f10] [c02c57d0] sys_socketcall+0x148/0x210
> [   79.664287] [ec537f40] [c001084c] ret_from_syscall+0x0/0x3c
> [   79.731015] --- Exception: c01 at 0x48051f00
> [   79.731019]     LR =3D 0x4808e030
>=20
>=20
> Note that this may just be the cause for us seeing this problem. If
> indeed the main problem is irq_exit() invoking softirqs in a locked
> context, then this patch adding hardware queue support is not really
> relevant.

irq_exit() is fine. This is because BH are not masked because of the
=46reescale patches.

Really, suggesting an af_packet patch to solve a problem introduced in
an out of tree patch is insane.

You guys hould have clearly stated you were using an alien kernel.



