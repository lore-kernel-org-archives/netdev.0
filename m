From: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>
Subject: softirqs are invoked while bottom halves are masked (was: Re: [PATCH]
 [PATCH] Fix deadlock in af_packet while stressing raw ethernet socket interface)
Date: Tue, 12 Jul 2011 11:23:28 +0200
Message-ID: <CAAXf6LXHeiCT+n=Wpdf=QfUXUHUSd7fmx9y3kB7te8N3ON1fTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ronny Meeus <ronny.meeus@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:56888 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab1GLJX3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 05:23:29 -0400
Received: by yia27 with SMTP id 27so1854759yia.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 02:23:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm adding the linuxppc-dev mailing list since this may be pointing to
an irq/softirq problem in the powerpc architecture-specific code...

On Tue, Jul 12, 2011 at 8:58 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 12 juillet 2011 =E0 08:38 +0200, Ronny Meeus a =E9crit :
>> On Tue, Jul 12, 2011 at 5:27 AM, David Miller <davem@davemloft.net> =
wrote:
>> > From: Ronny Meeus <ronny.meeus@gmail.com>
>> > Date: Sat, 11 Jun 2011 07:04:09 +0200
>> >
>> >> I was running a test: 1 application was sending raw Ethernet pack=
ets
>> >> on a physical looped interface while a second application was
>> >> receiving packets, so the latter application receives each packet=
 2
>> >> times (once while sending from the context of the first applicati=
on
>> >> and a second time while receiving from the hardware). =A0After so=
me
>> >> time, the test blocks due to a spinlock reentrance issue in
>> >> af_packet. Both the sending application and the softIRQ receiving
>> >> packets enter the spinlock code. After applying the patch below, =
the
>> >> issue is resolved.
>> >>
>> >> Signed-off-by: Ronny Meeus <ronny.meeus@gmail.com>
>> >
>> > The packet receive hooks should always be called with software
>> > interrupts disabled, it is a bug if this is not happening. =A0Your
>> > patch should not be necessary at all.
>> >
>> >
>>
>> Can you be a bit more specific on where the software interrupts shou=
ld
>> be disabled?
>>
>> Below you find the information I get after switching on the spin_loc=
k
>> issue detection in the kernel.
>> In this run also I-PIPE was active but this issue is also seen with
>> I-PIPE disabled.
>>
>
> This seems a bug, but in softirq handling in your arch
>
>> [ =A0 96.450034] BUG: spinlock recursion on CPU#0, send_eth_socket/1=
907
>> [ =A0 96.540451] =A0lock: eaeb8c9c, .magic: dead4ead, .owner:
>> send_eth_socket/1907, .owner_cpu: 0
>> [ =A0 96.656060] Call Trace: (unreliable)0161000 success=3D90] [c000=
789c]
>> show_stack+0x78/0x18c160001
>> [ =A0 96.827988] [efff3dd0] [c01e2a50] spin_bug+0xa8/0xc0=3D00001620=
00 succ
>> [ =A0 96.920712] [efff3df0] [c01e2b9c] do_raw_spin_lock+0x70/0x1c4ou=
nt=3D0000163000
>> [ =A0 97.022823] [efff3e20] [c0388d88] _raw_spin_lock+0x10/0x2001
>> [ =A0 97.121800] [efff3e30] [c03391a0] tpacket_rcv+0x274/0x61c164001
>> [ =A0 97.219733] [efff3e80] [c02d5970] __netif_receive_skb+0x1a8/0x3=
6c0000165001
>> [ =A0 97.326001] [efff3eb0] [c02d6234] netif_receive_skb+0x98/0xaces=
s=3D0000166001
>> [ =A0 97.427060] [efff3ee0] [c029e6c4] ingress_rx_default_dqrr+0x42c=
/0x4b8
>> [ =A0 97.504194] [efff3f10] [c02ba524] qman_poll_dqrr+0x1e0/0x284
>> [ =A0 97.571948] [efff3f50] [c029ff3c] dpaa_eth_poll+0x34/0xd0
>> [ =A0 97.636579] [efff3f70] [c02d6514] net_rx_action+0xc0/0x1e8
>> [ =A0 97.702256] [efff3fa0] [c0034d28] __do_softirq+0x138/0x210
>> [ =A0 97.767928] [efff3ff0] [c0010128] call_do_softirq+0x14/0x24
>> [ =A0 97.834641] [ec479a90] [c0004a00] do_softirq+0xb4/0xec
>
> We got an IRQ, and we start do_softirq() from irq_exit()
>
>> [ =A0 97.896148] [ec479ab0] [c0034a44] irq_exit+0x60/0xb8
>> [ =A0 97.955573] [ec479ac0] [c000a490] __ipipe_do_IRQ+0x88/0xc0
>> [ =A0 98.021253] [ec479ae0] [c0070214] __ipipe_sync_stage+0x1f0/0x27=
c
>> [ =A0 98.093176] [ec479b20] [c0009f28] __ipipe_handle_irq+0x1b8/0x1e=
8
>> [ =A0 98.165106] [ec479b50] [c000a210] __ipipe_grab_irq+0x18c/0x1bc
>> [ =A0 98.234947] [ec479b80] [c0011520] __ipipe_ret_from_except+0x0/0=
xc
>> [ =A0 98.307915] --- Exception: 501 at __packet_get_status+0x48/0x70
>> [ =A0 98.307920] =A0 =A0 LR =3D __packet_get_status+0x44/0x70
>> [ =A0 98.436082] [ec479c40] [00000578] 0x578 (unreliable)
>> [ =A0 98.495524] [ec479c50] [c0338360] packet_lookup_frame+0x48/0x70
>> [ =A0 98.566405] [ec479c60] [c03391b4] tpacket_rcv+0x288/0x61c
>
> Here we were in BH disabled section, since dev_queue_xmit() contains =
:
>
> =A0 =A0 =A0 =A0rcu_read_lock_bh()
>
>
>> [ =A0 98.631037] [ec479cb0] [c02d762c] dev_hard_start_xmit+0x164/0x5=
88
>> [ =A0 98.704003] [ec479cf0] [c0338d6c] packet_sendmsg+0x8c4/0x988
>> [ =A0 98.771758] [ec479d70] [c02c3838] sock_sendmsg+0x90/0xb4
>> [ =A0 98.835348] [ec479e40] [c02c4420] sys_sendto+0xdc/0x120
>> [ =A0 98.897891] [ec479f10] [c02c57d0] sys_socketcall+0x148/0x210
>> [ =A0 98.965648] [ec479f40] [c001084c] ret_from_syscall+0x0/0x3c
>> [ =A0 99.032361] --- Exception: c01 at 0x48051f00
>> [ =A0 99.032365] =A0 =A0 LR =3D 0x4808e030
>> [ =A0100.563009] BUG: spinlock lockup on CPU#0, send_eth_socket/1907=
, eaeb8c9c
>> [ =A0100.644283] Call Trace:
>> [ =A0100.673480] [efff3db0] [c000789c] show_stack+0x78/0x18c (unreli=
able)
>> [ =A0100.749589] [efff3df0] [c01e2c94] do_raw_spin_lock+0x168/0x1c4
>> [ =A0100.819430] [efff3e20] [c0388d88] _raw_spin_lock+0x10/0x20
>> [ =A0100.885102] [efff3e30] [c03391a0] tpacket_rcv+0x274/0x61c
>> [ =A0100.949733] [efff3e80] [c02d5970] __netif_receive_skb+0x1a8/0x3=
6c
>> [ =A0101.022699] [efff3eb0] [c02d6234] netif_receive_skb+0x98/0xac
>> [ =A0101.091497] [efff3ee0] [c029e6c4] ingress_rx_default_dqrr+0x42c=
/0x4b8
>> [ =A0101.168628] [efff3f10] [c02ba524] qman_poll_dqrr+0x1e0/0x284
>> [ =A0101.236385] [efff3f50] [c029ff3c] dpaa_eth_poll+0x34/0xd0
>> [ =A0101.301016] [efff3f70] [c02d6514] net_rx_action+0xc0/0x1e8
>> [ =A0101.366692] [efff3fa0] [c0034d28] __do_softirq+0x138/0x210
>> [ =A0101.432364] [efff3ff0] [c0010128] call_do_softirq+0x14/0x24
>> [ =A0101.499078] [ec479a90] [c0004a00] do_softirq+0xb4/0xec
>> [ =A0101.560585] [ec479ab0] [c0034a44] irq_exit+0x60/0xb8
>> [ =A0101.620003] [ec479ac0] [c000a490] __ipipe_do_IRQ+0x88/0xc0
>> [ =A0101.685678] [ec479ae0] [c0070214] __ipipe_sync_stage+0x1f0/0x27=
c
>> [ =A0101.757601] [ec479b20] [c0009f28] __ipipe_handle_irq+0x1b8/0x1e=
8
>> [ =A0101.829523] [ec479b50] [c000a210] __ipipe_grab_irq+0x18c/0x1bc
>> [ =A0101.899363] [ec479b80] [c0011520] __ipipe_ret_from_except+0x0/0=
xc
>> [ =A0101.972333] --- Exception: 501 at __packet_get_status+0x48/0x70
>> [ =A0101.972338] =A0 =A0 LR =3D __packet_get_status+0x44/0x70
>> [ =A0102.100490] [ec479c40] [00000578] 0x578 (unreliable)
>> [ =A0102.159929] [ec479c50] [c0338360] packet_lookup_frame+0x48/0x70
>> [ =A0102.230810] [ec479c60] [c03391b4] tpacket_rcv+0x288/0x61c
>> [ =A0102.295442] [ec479cb0] [c02d762c] dev_hard_start_xmit+0x164/0x5=
88
>> [ =A0102.368407] [ec479cf0] [c0338d6c] packet_sendmsg+0x8c4/0x988
>> [ =A0102.436162] [ec479d70] [c02c3838] sock_sendmsg+0x90/0xb4
>> [ =A0102.499747] [ec479e40] [c02c4420] sys_sendto+0xdc/0x120
>> [ =A0102.562296] [ec479f10] [c02c57d0] sys_socketcall+0x148/0x210
>> [ =A0102.630052] [ec479f40] [c001084c] ret_from_syscall+0x0/0x3c
>> [ =A0102.696773] --- Exception: c01 at 0x48051f00
>> [ =A0102.696777] =A0 =A0 LR =3D 0x4808e030
>>


Note that the reason we are seeing this problem, may be because the
kernel we are using contains some patches from Freescale.
Specifically, in dev_queue_xmit(), support is added for hardware queue
handling, just before entering the rcu_read_lock_bh():

        if (dev->features & NETIF_F_HW_QDISC) {
                txq =3D dev_pick_tx(dev, skb);
                return dev_hard_start_xmit(skb, dev, txq);
        }

        /* Disable soft irqs for various locks below. Also
         * stops preemption for RCU.
         */
        rcu_read_lock_bh();

We just tried moving the escaping to dev_hard_start_xmit() after
taking the lock, but this gives a large number of other problems, e.g.

[   78.662428] BUG: sleeping function called from invalid context at
mm/slab.c:3101
[   78.751004] in_atomic(): 1, irqs_disabled(): 0, pid: 1908, name:
send_eth_socket
[   78.839582] Call Trace:
[   78.868784] [ec537b70] [c000789c] show_stack+0x78/0x18c (unreliable)
[   78.944905] [ec537bb0] [c0022900] __might_sleep+0x100/0x118
[   79.011636] [ec537bc0] [c00facc4] kmem_cache_alloc+0x48/0x118
[   79.080446] [ec537be0] [c02cd0e8] __alloc_skb+0x50/0x130
[   79.144047] [ec537c00] [c02cdf5c] skb_copy+0x44/0xc8
[   79.203478] [ec537c20] [c029f904] dpa_tx+0x154/0x758
[   79.262907] [ec537c80] [c02d78ec] dev_hard_start_xmit+0x424/0x588
[   79.335878] [ec537cc0] [c02d7aac] dev_queue_xmit+0x5c/0x3a4
[   79.402602] [ec537cf0] [c0338d4c] packet_sendmsg+0x8c4/0x988
[   79.470363] [ec537d70] [c02c3838] sock_sendmsg+0x90/0xb4
[   79.533960] [ec537e40] [c02c4420] sys_sendto+0xdc/0x120
[   79.596514] [ec537f10] [c02c57d0] sys_socketcall+0x148/0x210
[   79.664287] [ec537f40] [c001084c] ret_from_syscall+0x0/0x3c
[   79.731015] --- Exception: c01 at 0x48051f00
[   79.731019]     LR =3D 0x4808e030


Note that this may just be the cause for us seeing this problem. If
indeed the main problem is irq_exit() invoking softirqs in a locked
context, then this patch adding hardware queue support is not really
relevant.

Any suggestions from the developers at linuxppc-dev are very welcome...

Thomas
