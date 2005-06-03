From: Phil Oester <kernel@linuxace.com>
Subject: Unitialized queue_lock oops?
Date: Fri, 3 Jun 2005 16:24:13 -0700
Message-ID: <20050603232413.GA29308@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In my ongoing attempts to migrate to anything higher than 2.6.10,
I decided to retest 2.6.11-rc2 but backout the problematic LLTX
patch.  I also enabled spinlock debugging, and hit an odd BUG.

Full oops output below, but the summary is:
	kernel BUG at include/asm/spinlock.h:92!

which is here:
	BUG_ON(lock->magic != SPINLOCK_MAGIC);

And we got there via dev_queue_xmit:
                /* Grab device queue */
                spin_lock(&dev->queue_lock);
-- no complaints yet, so queue_lock must be initialized here
                rc = q->enqueue(skb, q);

                qdisc_run(dev);
-- qdisc_run drops queue_lock briefly - it get mangled while it's dropped?
                spin_unlock(&dev->queue_lock); 
-- now we hit the BUG - queue_lock->magic != SPINLOCK_MAGIC.


I know the proposed LLTX changes were meant to address a race while
the queue_lock was dropped - is the above another illustration of the
race potential?

Phil

kernel BUG at include/asm/spinlock.h:92!
invalid operand: 0000 [#1]
SMP DEBUG_PAGEALLOC
CPU:    1
EIP:    0060:[<c0289dc4>]    Not tainted VLI
EFLAGS: 00010217   (2.6.11-rc2) 
EIP is at _spin_unlock+0x24/0x30
eax: f7ae7ec0   ebx: f6d5ff00   ecx: f6d5ffbc   edx: f7ae7ec0
esi: f7ae3800   edi: c4a45f50   ebp: c0333d64   esp: c0333d64
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0333000 task=c198aaf0)
Stack: c0333d88 c023168a c0272eea f7ae3800 f7ae35bc 00000000 f590c89c f590c888 
       c63cc020 c0333da8 c0249873 c02497c0 f590c888 c4a45f50 00000000 00000004 
       00000002 c0333ddc c023b61e 00000000 f7ae3800 c0333dcc c02497c0 80000000 
Call Trace:
 [<c010322a>] show_stack+0x7a/0x90
 [<c01033ad>] show_registers+0x14d/0x1b0
 [<c01035b9>] die+0xf9/0x180
 [<c01039e9>] do_invalid_op+0xa9/0xc0
 [<c0102ebb>] error_code+0x2b/0x30
 [<c023168a>] dev_queue_xmit+0x20a/0x290
 [<c0249873>] ip_finish_output2+0xb3/0x1c0
 [<c023b61e>] nf_hook_slow+0xae/0xe0
 [<c024734e>] ip_finish_output+0x1ee/0x200
 [<c0245d3c>] ip_forward_finish+0x2c/0x50
 [<c023b61e>] nf_hook_slow+0xae/0xe0
 [<c0245c7c>] ip_forward+0x19c/0x230
 [<c0244ad8>] ip_rcv_finish+0x1b8/0x230
 [<c023b61e>] nf_hook_slow+0xae/0xe0
 [<c0244715>] ip_rcv+0x3b5/0x470
 [<c0231bea>] netif_receive_skb+0x13a/0x190
 [<c01f9ca6>] e1000_clean_rx_irq+0x156/0x480
 [<c01f9895>] e1000_clean+0x45/0xf0
 [<c0231df0>] net_rx_action+0x90/0x130
 [<c011a878>] __do_softirq+0xb8/0xd0
 [<c010478d>] do_softirq+0x4d/0x60
 =======================
 [<c0104668>] do_IRQ+0x68/0xa0
 [<c0102d86>] common_interrupt+0x1a/0x20
 [<c010059f>] cpu_idle+0x5f/0x70
 [<00000000>] 0x0
 [<c198bfbc>] 0xc198bfbc
Code: 8d bc 27 00 00 00 00 55 89 c2 89 e5 81 78 04 ad 4e ad de 75 16 0f b6 02 84 c0 7f 05 c6 02 01 
5d c3 0f 0b 5d 00 08 9b 29 c0 eb f1 <0f> 0b 5c 00 08 9b 29 c0 eb e0 89 f6 55 89 e5 f0 81 00 00 00 00 
