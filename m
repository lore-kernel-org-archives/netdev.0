From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: softirqs are invoked while bottom halves are masked (was: Re:
 [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw ethernet
 socket interface)
Date: Tue, 12 Jul 2011 17:27:54 +0200
Message-ID: <1310484474.2871.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
	 <1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAMJ=MEeC1hoqufs7AfFRn3yJoC8mdw7v+14N+7e=wQuJefm4_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	afleming@freescale.com
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64687 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823Ab1GLP2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 11:28:06 -0400
Received: by wyg8 with SMTP id 8so109433wyg.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 08:28:05 -0700 (PDT)
In-Reply-To: <CAMJ=MEeC1hoqufs7AfFRn3yJoC8mdw7v+14N+7e=wQuJefm4_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 juillet 2011 =C3=A0 14:03 +0200, Ronny Meeus a =C3=A9crit :

> Sorry for not mentioning we were using a patched kernel.
> I was not aware that the code involved was patched by the FreeScale
> patches we applied. The code found in the stack dumps is not
> implemented in FSL specific files.
>=20
> While reading the code of af_packet I saw that the spin_lock_bh is
> used in several places while this is not the case in the tpacket_rcv
> function. Since we had a locking issue in that code, I thought that m=
y
> patch would be OK.
> I was not aware that for that specific function (tpacket_rcv) a
> different lock primitive must be used. A suggestion for improvement:
> it would be better to document this pre-condition in the code.
>=20
> After doing the change you proposed our code now looks like:
>=20
> >---if (dev->features & NETIF_F_HW_QDISC) {
> >--->---txq =3D dev_pick_tx(dev, skb);
> >--->---local_bh_disable();
> >--->---rc =3D dev_hard_start_xmit(skb, dev, txq);
> >--->---local_bh_enable();
> >--->---return rc;
> >---}
>=20
> >---/* Disable soft irqs for various locks below. Also
> >--- * stops preemption for RCU.
> >--- */
> >---rcu_read_lock_bh();
>=20
> but we still see the issue "BUG: sleeping function called from invali=
d context":

Of course you are if this is the only change you did.

>=20
> [   91.015989] BUG: sleeping function called from invalid context at
> include/linux/skbuff.h:786
> [   91.117096] in_atomic(): 1, irqs_disabled(): 0, pid: 1865, name: N=
MTX_T1842
> [   91.200461] Call Trace:
> [   91.229672] [ec58bbd0] [c000789c] show_stack+0x78/0x18c (unreliabl=
e)
> [   91.305791] [ec58bc10] [c0022900] __might_sleep+0x100/0x118
> [   91.372524] [ec58bc20] [c029f8d8] dpa_tx+0x128/0x758


Please read again my mail :=20

I said : "doing GFP_KERNEL allocations in dpa_tx() is wrong, for sure."

I dont have this code, but I suspect it's using : skb_copy(skb,
GFP_KERNEL)

Just say no, use GFP_ATOMIC instead.

Real question is : why skb_copy() is done, since its slow as hell.

> [   91.431957] [ec58bc80] [c02d78ec] dev_hard_start_xmit+0x424/0x588
> [   91.504952] [ec58bcc0] [c02d7ab0] dev_queue_xmit+0x60/0x3ac
> [   91.571692] [ec58bcf0] [c0338d54] packet_sendmsg+0x8c4/0x988
> [   91.639457] [ec58bd70] [c02c3838] sock_sendmsg+0x90/0xb4
> [   91.703066] [ec58be40] [c02c4420] sys_sendto+0xdc/0x120
> [   91.765646] [ec58bf10] [c02c57d0] sys_socketcall+0x148/0x210
> [   91.833420] [ec58bf40] [c001084c] ret_from_syscall+0x0/0x3c
> [   91.900153] --- Exception: c01 at 0x4824df00
> [   91.900157]     LR =3D 0x4828a030
>=20


