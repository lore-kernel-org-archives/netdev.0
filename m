From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: Re: softirqs are invoked while bottom halves are masked (was: Re:
 [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw ethernet socket interface)
Date: Tue, 12 Jul 2011 14:03:04 +0200
Message-ID: <CAMJ=MEeC1hoqufs7AfFRn3yJoC8mdw7v+14N+7e=wQuJefm4_w@mail.gmail.com>
References: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
	<1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	afleming@freescale.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65040 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028Ab1GLMDF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 08:03:05 -0400
Received: by ywe9 with SMTP id 9so1885094ywe.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 05:03:04 -0700 (PDT)
In-Reply-To: <1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 12:10 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 12 juillet 2011 =E0 11:23 +0200, Thomas De Schampheleire a
> =E9crit :
>> Hi,
>>
>> I'm adding the linuxppc-dev mailing list since this may be pointing =
to
>> an irq/softirq problem in the powerpc architecture-specific code...
>
>>
>> Note that the reason we are seeing this problem, may be because the
>> kernel we are using contains some patches from Freescale.
>> Specifically, in dev_queue_xmit(), support is added for hardware que=
ue
>> handling, just before entering the rcu_read_lock_bh():
>>
>
> Oh well, what a mess.
>
>> =A0 =A0 =A0 =A0 if (dev->features & NETIF_F_HW_QDISC) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txq =3D dev_pick_tx(dev, skb);
>
>
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_hard_start_xmit(skb, dev,=
 txq);
> =A0 =A0 =A0 =A0This need to be :
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_bh_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D dev_hard_start_xmit(skb, dev, t=
xq);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_bh_enable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return rc;
>
>
>> =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 /* Disable soft irqs for various locks below. Also
>> =A0 =A0 =A0 =A0 =A0* stops preemption for RCU.
>> =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 rcu_read_lock_bh();
>>
>> We just tried moving the escaping to dev_hard_start_xmit() after
>> taking the lock, but this gives a large number of other problems, e.=
g.
>>
>> [ =A0 78.662428] BUG: sleeping function called from invalid context =
at
>> mm/slab.c:3101
>> [ =A0 78.751004] in_atomic(): 1, irqs_disabled(): 0, pid: 1908, name=
:
>> send_eth_socket
>> [ =A0 78.839582] Call Trace:
>> [ =A0 78.868784] [ec537b70] [c000789c] show_stack+0x78/0x18c (unreli=
able)
>> [ =A0 78.944905] [ec537bb0] [c0022900] __might_sleep+0x100/0x118
>> [ =A0 79.011636] [ec537bc0] [c00facc4] kmem_cache_alloc+0x48/0x118
>> [ =A0 79.080446] [ec537be0] [c02cd0e8] __alloc_skb+0x50/0x130
>> [ =A0 79.144047] [ec537c00] [c02cdf5c] skb_copy+0x44/0xc8
>> [ =A0 79.203478] [ec537c20] [c029f904] dpa_tx+0x154/0x758
>
> doing GFP_KERNEL allocations in dpa_tx() is wrong, for sure.
>
>
>> [ =A0 79.262907] [ec537c80] [c02d78ec] dev_hard_start_xmit+0x424/0x5=
88
>> [ =A0 79.335878] [ec537cc0] [c02d7aac] dev_queue_xmit+0x5c/0x3a4
>> [ =A0 79.402602] [ec537cf0] [c0338d4c] packet_sendmsg+0x8c4/0x988
>> [ =A0 79.470363] [ec537d70] [c02c3838] sock_sendmsg+0x90/0xb4
>> [ =A0 79.533960] [ec537e40] [c02c4420] sys_sendto+0xdc/0x120
>> [ =A0 79.596514] [ec537f10] [c02c57d0] sys_socketcall+0x148/0x210
>> [ =A0 79.664287] [ec537f40] [c001084c] ret_from_syscall+0x0/0x3c
>> [ =A0 79.731015] --- Exception: c01 at 0x48051f00
>> [ =A0 79.731019] =A0 =A0 LR =3D 0x4808e030
>>
>>
>> Note that this may just be the cause for us seeing this problem. If
>> indeed the main problem is irq_exit() invoking softirqs in a locked
>> context, then this patch adding hardware queue support is not really
>> relevant.
>
> irq_exit() is fine. This is because BH are not masked because of the
> Freescale patches.
>
> Really, suggesting an af_packet patch to solve a problem introduced i=
n
> an out of tree patch is insane.
>
> You guys hould have clearly stated you were using an alien kernel.
>
>
>
>

Sorry for not mentioning we were using a patched kernel.
I was not aware that the code involved was patched by the FreeScale
patches we applied. The code found in the stack dumps is not
implemented in FSL specific files.

While reading the code of af_packet I saw that the spin_lock_bh is
used in several places while this is not the case in the tpacket_rcv
function. Since we had a locking issue in that code, I thought that my
patch would be OK.
I was not aware that for that specific function (tpacket_rcv) a
different lock primitive must be used. A suggestion for improvement:
it would be better to document this pre-condition in the code.

After doing the change you proposed our code now looks like:

>---if (dev->features & NETIF_F_HW_QDISC) {
>--->---txq =3D dev_pick_tx(dev, skb);
>--->---local_bh_disable();
>--->---rc =3D dev_hard_start_xmit(skb, dev, txq);
>--->---local_bh_enable();
>--->---return rc;
>---}

>---/* Disable soft irqs for various locks below. Also
>--- * stops preemption for RCU.
>--- */
>---rcu_read_lock_bh();

but we still see the issue "BUG: sleeping function called from invalid =
context":

[   91.015989] BUG: sleeping function called from invalid context at
include/linux/skbuff.h:786
[   91.117096] in_atomic(): 1, irqs_disabled(): 0, pid: 1865, name: NMT=
X_T1842
[   91.200461] Call Trace:
[   91.229672] [ec58bbd0] [c000789c] show_stack+0x78/0x18c (unreliable)
[   91.305791] [ec58bc10] [c0022900] __might_sleep+0x100/0x118
[   91.372524] [ec58bc20] [c029f8d8] dpa_tx+0x128/0x758
[   91.431957] [ec58bc80] [c02d78ec] dev_hard_start_xmit+0x424/0x588
[   91.504952] [ec58bcc0] [c02d7ab0] dev_queue_xmit+0x60/0x3ac
[   91.571692] [ec58bcf0] [c0338d54] packet_sendmsg+0x8c4/0x988
[   91.639457] [ec58bd70] [c02c3838] sock_sendmsg+0x90/0xb4
[   91.703066] [ec58be40] [c02c4420] sys_sendto+0xdc/0x120
[   91.765646] [ec58bf10] [c02c57d0] sys_socketcall+0x148/0x210
[   91.833420] [ec58bf40] [c001084c] ret_from_syscall+0x0/0x3c
[   91.900153] --- Exception: c01 at 0x4824df00
[   91.900157]     LR =3D 0x4828a030


The FreeScale patch that introduced this code was created by Andy
=46leming <afleming@freescale.com> (Put in CC).

The purpose of the patch is:
"
Subject: [PATCH] net: Add support for handling queueing in hardware

The QDisc code does a bunch of locking which is unnecessary if
you have hardware which handles all of the queueing.  Add
support for this, and skip over all of the queueing code if
the feature is enabled on a given device.
"

Ronny
