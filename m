From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver code
Date: Wed, 20 Aug 2008 21:56:03 +0200
Message-ID: <19f34abd0808201256v563c81f6x79518d6e32b188d6@mail.gmail.com>
References: <20080813.033749.165504341.davem@davemloft.net>
	 <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
	 <Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
	 <20080814.151502.251134900.davem@davemloft.net>
	 <Pine.LNX.4.64.0808202051550.3501@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: "Pekka J Enberg" <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:37047 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbYHTT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 15:56:05 -0400
Received: by gxk9 with SMTP id 9so78652gxk.13
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 12:56:04 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808202051550.3501@melkki.cs.Helsinki.FI>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2008 at 7:54 PM, Pekka J Enberg <penberg@cs.helsinki.fi> wrote:
> Subject: [PATCH] 8139too: avoid deadlock with netconsole
> From: Pekka Enberg <penberg@cs.helsinki.fi>
>
> As explained by Vegard Nossum, the 8139too driver can deadlock with netconsole:
>
>  I encountered a hard-to-debug deadlock when I pulled out the plug of my
>  RealTek 8139 which was also running netconsole: The driver wants to print a
>  "link down" message. However, this triggers netconsole, which wants to print
>  the message using the same device. Here is a backtrace:
>
>     [<c05916b6>] _spin_lock_irqsave+0x76/0x90
>     [<c035b255>] rtl8139_start_xmit+0x65/0x130 <-- spin_lock(&tp->lock)
>     [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
>     [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
>     [<c037c70c>] write_msg+0x8c/0xc0
>     [<c0135883>] __call_console_drivers+0x53/0x60
>     [<c01358db>] _call_console_drivers+0x4b/0x90
>     [<c0135a25>] release_console_sem+0xc5/0x1f0
>     [<c0135f0b>] vprintk+0x1ab/0x3e0
>     [<c013615b>] printk+0x1b/0x20
>     [<c0349736>] mii_check_media+0x196/0x1e0
>     [<c03597f4>] rtl_check_media+0x24/0x30
>     [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0 <-- spin_lock(&tp->lock)
>     [<c01716d8>] handle_IRQ_event+0x28/0x70
>     [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
>     [<c0107128>] do_IRQ+0x48/0xa0
>
> To avoid the deadlock, use netif_tx_lock() for the TX paths and make sure we
> never call printk() while holding that lock as suggested by David Miller.
>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---

I'm sorry, but it doesn't help :-)

console [netcon0] enabled
=============================================
[ INFO: possible recursive locking detected ]
2.6.27-rc3-00468-g86f91c5 #19
---------------------------------------------
swapper/1 is trying to acquire lock:
 (_xmit_ETHER#2){....}, at: [<c0449210>] rtl8139_start_xmit+0xc0/0x230
but task is already holding lock:
 (_xmit_ETHER#2){....}, at: [<c05b515b>] netpoll_send_skb+0x13b/0x1a0
other info that might help us debug this:
3 locks held by swapper/1:
 #0:  (target_list_lock){....}, at: [<c046ab5d>] write_msg+0x2d/0xc0
 #1:  (_xmit_ETHER#2){....}, at: [<c05b515b>] netpoll_send_skb+0x13b/0x1a0
 #2:  (&dev->tx_global_lock){....}, at: [<c04491e1>] rtl8139_start_xmit+0x91/0x2
30
stack backtrace:
Pid: 1, comm: swapper Not tainted 2.6.27-rc3-00468-g86f91c5 #19
 [<c015fccb>] validate_chain+0xbbb/0xe90
 [<c010e45b>] ? save_stack_trace+0x2b/0x50
 [<c01601f9>] __lock_acquire+0x259/0xa00
 [<c0160a29>] lock_acquire+0x89/0xc0
 [<c0449210>] ? rtl8139_start_xmit+0xc0/0x230
 [<c0681720>] _spin_lock+0x40/0x70
 [<c0449210>] ? rtl8139_start_xmit+0xc0/0x230
 [<c0449210>] rtl8139_start_xmit+0xc0/0x230
 [<c05b515b>] ? netpoll_send_skb+0x13b/0x1a0
 [<c05b5178>] netpoll_send_skb+0x158/0x1a0
 [<c05b564b>] netpoll_send_udp+0x1db/0x1f0
 [<c046abbc>] write_msg+0x8c/0xc0
 [<c013ad13>] __call_console_drivers+0x53/0x60
 [<c013ad6b>] _call_console_drivers+0x4b/0x90
 [<c013aeb5>] release_console_sem+0xc5/0x1f0
 [<c013b698>] register_console+0x138/0x2c0
 [<c08bb860>] init_netconsole+0x1a0/0x1c0
 [<c01520b9>] ? ktime_get+0x19/0x40
 [<c0101120>] do_one_initcall+0x30/0x170
 [<c08bb6c0>] ? init_netconsole+0x0/0x1c0
 [<c017b583>] ? register_irq_proc+0xb3/0xd0
 [<c08916aa>] kernel_init+0x11a/0x180
 [<c0891590>] ? kernel_init+0x0/0x180
 [<c0105cf3>] kernel_thread_helper+0x7/0x14
 =======================

After that, I also got lots of kgdbts errors, don't know exactly how
it relates to your patch...

<3>kgdbts: BP mismatch c03763a0 expected c0139b80
<4>------------[ cut here ]------------
<4>WARNING: at /uio/arkimedes/s29/vegardno/git-working/linux-2.6/drivers/misc/kg
dbts.c:302 check_and_rewind_pc+0xb2/0xe0()
Pid: 1, comm: swapper Not tainted 2.6.27-rc3-00468-g86f91c5 #19
 [<c013a9cf>] warn_on_slowpath+0x4f/0x80
 [<c01670a2>] ? sprint_symbol+0x92/0xc0
 [<c013b25d>] ? vprintk+0x6d/0x350
 [<c013b25d>] ? vprintk+0x6d/0x350
 [<c01248e3>] ? __change_page_attr_set_clr+0x693/0xc30
 [<c0376917>] ? __copy_to_user_ll+0x57/0x60
 [<c0184e1a>] ? probe_kernel_write+0x4a/0x90
 [<c0139b80>] ? do_fork+0x0/0x2b0
 [<c013b55b>] ? printk+0x1b/0x20
 [<c0139b80>] ? do_fork+0x0/0x2b0
 [<c03fee62>] check_and_rewind_pc+0xb2/0xe0
 [<c03763a0>] ? delay_tsc+0x20/0xb8
 [<c0139b80>] ? do_fork+0x0/0x2b0
 [<c03fdc52>] validate_simple_test+0x22/0xa0
 [<c03fe407>] run_simple_test+0x107/0x260
 [<c0184eaa>] ? probe_kernel_read+0x4a/0x90
 [<c03fdd34>] kgdbts_put_char+0x14/0x20
 [<c0177476>] put_packet+0x86/0xe0
 [<c0178376>] kgdb_handle_exception+0x446/0xe40
 [<c013b25d>] ? vprintk+0x6d/0x350
 [<c011dd61>] kgdb_notify+0xa1/0x1d0
 [<c0153037>] notifier_call_chain+0x37/0x70
 [<c0153435>] __atomic_notifier_call_chain+0x35/0x50
 [<c015346a>] atomic_notifier_call_chain+0x1a/0x20
 [<c015349d>] notify_die+0x2d/0x30
 [<c0106d5a>] die_nmi+0x3a/0x100
 [<c011add5>] nmi_watchdog_tick+0x1d5/0x1e0
 [<c0107227>] do_nmi+0x97/0x2d0
 [<c06823f3>] nmi_stack_correct+0x26/0x2b
 [<c03763a0>] ? delay_tsc+0x20/0xb8
 [<c03762c9>] __delay+0x9/0x10
 [<c03857ec>] _raw_spin_lock+0xbc/0x150
 [<c015b73e>] ? get_lock_stats+0x1e/0x50
 [<c015b77d>] ? put_lock_stats+0xd/0x30
 [<c068173c>] _spin_lock+0x5c/0x70
 [<c0449210>] ? rtl8139_start_xmit+0xc0/0x230
 [<c0449210>] rtl8139_start_xmit+0xc0/0x230
 [<c05b515b>] ? netpoll_send_skb+0x13b/0x1a0
 [<c05b5178>] netpoll_send_skb+0x158/0x1a0
 [<c05b564b>] netpoll_send_udp+0x1db/0x1f0
 [<c046abbc>] write_msg+0x8c/0xc0
 [<c013ad13>] __call_console_drivers+0x53/0x60
 [<c013ad6b>] _call_console_drivers+0x4b/0x90
 [<c013aeb5>] release_console_sem+0xc5/0x1f0
 [<c013b698>] register_console+0x138/0x2c0
 [<c08bb860>] init_netconsole+0x1a0/0x1c0
 [<c01520b9>] ? ktime_get+0x19/0x40
 [<c0101120>] do_one_initcall+0x30/0x170
 [<c08bb6c0>] ? init_netconsole+0x0/0x1c0
 [<c017b583>] ? register_irq_proc+0xb3/0xd0
 [<c08916aa>] kernel_init+0x11a/0x180
 [<c0891590>] ? kernel_init+0x0/0x180
 [<c0105cf3>] kernel_thread_helper+0x7/0x14
 =======================
<4>---[ end trace 3a158aadebbe6259 ]---

(This repeats every few seconds.)

When pulling the cable, I get this:

<0>BUG: spinlock lockup on CPU#1, swapper/1, f58599ac
Pid: 1, comm: swapper Tainted: G        W 2.6.27-rc3-00468-g86f91c5 #19
 [<c0385840>] _raw_spin_lock+0x110/0x150
 [<c068173c>] _spin_lock+0x5c/0x70
 [<c0449210>] ? rtl8139_start_xmit+0xc0/0x230
 [<c0449210>] rtl8139_start_xmit+0xc0/0x230
 [<c05b515b>] ? netpoll_send_skb+0x13b/0x1a0
 [<c05b5178>] netpoll_send_skb+0x158/0x1a0
 [<c05b564b>] netpoll_send_udp+0x1db/0x1f0
 [<c046abbc>] write_msg+0x8c/0xc0
 [<c013ad13>] __call_console_drivers+0x53/0x60
 [<c013ad6b>] _call_console_drivers+0x4b/0x90
 [<c013aeb5>] release_console_sem+0xc5/0x1f0
 [<c013b698>] register_console+0x138/0x2c0
 [<c08bb860>] init_netconsole+0x1a0/0x1c0
 [<c01520b9>] ? ktime_get+0x19/0x40
 [<c0101120>] do_one_initcall+0x30/0x170
 [<c08bb6c0>] ? init_netconsole+0x0/0x1c0
 [<c017b583>] ? register_irq_proc+0xb3/0xd0
 [<c08916aa>] kernel_init+0x11a/0x180
 [<c0891590>] ? kernel_init+0x0/0x180
 [<c0105cf3>] kernel_thread_helper+0x7/0x14
 =======================

...and machine is unusable. Thanks for trying! :-D


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
