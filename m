From: Ronny Meeus <ronny.meeus@gmail.com>
Subject: Re: [PATCH] [PATCH] Fix deadlock in af_packet while stressing raw
 ethernet socket interface
Date: Tue, 12 Jul 2011 08:38:57 +0200
Message-ID: <CAMJ=MEf8KkNNSvHy-pepg_GfkrnquKo+zW3GyB7RDAYO2H+SVA@mail.gmail.com>
References: <78567a0a1d2999f06d8f.1307768649@meeusr-laptop>
	<20110711.202717.1764669415135298036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64933 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab1GLGi6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 02:38:58 -0400
Received: by gxk21 with SMTP id 21so1808998gxk.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 23:38:57 -0700 (PDT)
In-Reply-To: <20110711.202717.1764669415135298036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 5:27 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Ronny Meeus <ronny.meeus@gmail.com>
> Date: Sat, 11 Jun 2011 07:04:09 +0200
>
>> I was running a test: 1 application was sending raw Ethernet packets
>> on a physical looped interface while a second application was
>> receiving packets, so the latter application receives each packet 2
>> times (once while sending from the context of the first application
>> and a second time while receiving from the hardware). =A0After some
>> time, the test blocks due to a spinlock reentrance issue in
>> af_packet. Both the sending application and the softIRQ receiving
>> packets enter the spinlock code. After applying the patch below, the
>> issue is resolved.
>>
>> Signed-off-by: Ronny Meeus <ronny.meeus@gmail.com>
>
> The packet receive hooks should always be called with software
> interrupts disabled, it is a bug if this is not happening. =A0Your
> patch should not be necessary at all.
>
>

Can you be a bit more specific on where the software interrupts should
be disabled?

Below you find the information I get after switching on the spin_lock
issue detection in the kernel.
In this run also I-PIPE was active but this issue is also seen with
I-PIPE disabled.

[   96.450034] BUG: spinlock recursion on CPU#0, send_eth_socket/1907
[   96.540451]  lock: eaeb8c9c, .magic: dead4ead, .owner:
send_eth_socket/1907, .owner_cpu: 0
[   96.656060] Call Trace: (unreliable)0161000 success=3D90] [c000789c]
show_stack+0x78/0x18c160001
[   96.827988] [efff3dd0] [c01e2a50] spin_bug+0xa8/0xc0=3D0000162000 su=
cc
[   96.920712] [efff3df0] [c01e2b9c] do_raw_spin_lock+0x70/0x1c4ount=3D=
0000163000
[   97.022823] [efff3e20] [c0388d88] _raw_spin_lock+0x10/0x2001
[   97.121800] [efff3e30] [c03391a0] tpacket_rcv+0x274/0x61c164001
[   97.219733] [efff3e80] [c02d5970] __netif_receive_skb+0x1a8/0x36c000=
0165001
[   97.326001] [efff3eb0] [c02d6234] netif_receive_skb+0x98/0xacess=3D0=
000166001
[   97.427060] [efff3ee0] [c029e6c4] ingress_rx_default_dqrr+0x42c/0x4b=
8
[   97.504194] [efff3f10] [c02ba524] qman_poll_dqrr+0x1e0/0x284
[   97.571948] [efff3f50] [c029ff3c] dpaa_eth_poll+0x34/0xd0
[   97.636579] [efff3f70] [c02d6514] net_rx_action+0xc0/0x1e8
[   97.702256] [efff3fa0] [c0034d28] __do_softirq+0x138/0x210
[   97.767928] [efff3ff0] [c0010128] call_do_softirq+0x14/0x24
[   97.834641] [ec479a90] [c0004a00] do_softirq+0xb4/0xec
[   97.896148] [ec479ab0] [c0034a44] irq_exit+0x60/0xb8
[   97.955573] [ec479ac0] [c000a490] __ipipe_do_IRQ+0x88/0xc0
[   98.021253] [ec479ae0] [c0070214] __ipipe_sync_stage+0x1f0/0x27c
[   98.093176] [ec479b20] [c0009f28] __ipipe_handle_irq+0x1b8/0x1e8
[   98.165106] [ec479b50] [c000a210] __ipipe_grab_irq+0x18c/0x1bc
[   98.234947] [ec479b80] [c0011520] __ipipe_ret_from_except+0x0/0xc
[   98.307915] --- Exception: 501 at __packet_get_status+0x48/0x70
[   98.307920]     LR =3D __packet_get_status+0x44/0x70
[   98.436082] [ec479c40] [00000578] 0x578 (unreliable)
[   98.495524] [ec479c50] [c0338360] packet_lookup_frame+0x48/0x70
[   98.566405] [ec479c60] [c03391b4] tpacket_rcv+0x288/0x61c
[   98.631037] [ec479cb0] [c02d762c] dev_hard_start_xmit+0x164/0x588
[   98.704003] [ec479cf0] [c0338d6c] packet_sendmsg+0x8c4/0x988
[   98.771758] [ec479d70] [c02c3838] sock_sendmsg+0x90/0xb4
[   98.835348] [ec479e40] [c02c4420] sys_sendto+0xdc/0x120
[   98.897891] [ec479f10] [c02c57d0] sys_socketcall+0x148/0x210
[   98.965648] [ec479f40] [c001084c] ret_from_syscall+0x0/0x3c
[   99.032361] --- Exception: c01 at 0x48051f00
[   99.032365]     LR =3D 0x4808e030
[  100.563009] BUG: spinlock lockup on CPU#0, send_eth_socket/1907, eae=
b8c9c
[  100.644283] Call Trace:
[  100.673480] [efff3db0] [c000789c] show_stack+0x78/0x18c (unreliable)
[  100.749589] [efff3df0] [c01e2c94] do_raw_spin_lock+0x168/0x1c4
[  100.819430] [efff3e20] [c0388d88] _raw_spin_lock+0x10/0x20
[  100.885102] [efff3e30] [c03391a0] tpacket_rcv+0x274/0x61c
[  100.949733] [efff3e80] [c02d5970] __netif_receive_skb+0x1a8/0x36c
[  101.022699] [efff3eb0] [c02d6234] netif_receive_skb+0x98/0xac
[  101.091497] [efff3ee0] [c029e6c4] ingress_rx_default_dqrr+0x42c/0x4b=
8
[  101.168628] [efff3f10] [c02ba524] qman_poll_dqrr+0x1e0/0x284
[  101.236385] [efff3f50] [c029ff3c] dpaa_eth_poll+0x34/0xd0
[  101.301016] [efff3f70] [c02d6514] net_rx_action+0xc0/0x1e8
[  101.366692] [efff3fa0] [c0034d28] __do_softirq+0x138/0x210
[  101.432364] [efff3ff0] [c0010128] call_do_softirq+0x14/0x24
[  101.499078] [ec479a90] [c0004a00] do_softirq+0xb4/0xec
[  101.560585] [ec479ab0] [c0034a44] irq_exit+0x60/0xb8
[  101.620003] [ec479ac0] [c000a490] __ipipe_do_IRQ+0x88/0xc0
[  101.685678] [ec479ae0] [c0070214] __ipipe_sync_stage+0x1f0/0x27c
[  101.757601] [ec479b20] [c0009f28] __ipipe_handle_irq+0x1b8/0x1e8
[  101.829523] [ec479b50] [c000a210] __ipipe_grab_irq+0x18c/0x1bc
[  101.899363] [ec479b80] [c0011520] __ipipe_ret_from_except+0x0/0xc
[  101.972333] --- Exception: 501 at __packet_get_status+0x48/0x70
[  101.972338]     LR =3D __packet_get_status+0x44/0x70
[  102.100490] [ec479c40] [00000578] 0x578 (unreliable)
[  102.159929] [ec479c50] [c0338360] packet_lookup_frame+0x48/0x70
[  102.230810] [ec479c60] [c03391b4] tpacket_rcv+0x288/0x61c
[  102.295442] [ec479cb0] [c02d762c] dev_hard_start_xmit+0x164/0x588
[  102.368407] [ec479cf0] [c0338d6c] packet_sendmsg+0x8c4/0x988
[  102.436162] [ec479d70] [c02c3838] sock_sendmsg+0x90/0xb4
[  102.499747] [ec479e40] [c02c4420] sys_sendto+0xdc/0x120
[  102.562296] [ec479f10] [c02c57d0] sys_socketcall+0x148/0x210
[  102.630052] [ec479f40] [c001084c] ret_from_syscall+0x0/0x3c
[  102.696773] --- Exception: c01 at 0x48051f00
[  102.696777]     LR =3D 0x4808e030

Ronny
