From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.12-rcx networking oops
Date: Wed, 1 Jun 2005 10:00:58 -0700
Message-ID: <20050601170058.GA20112@linuxace.com>
References: <20050531224012.GA16789@linuxace.com> <20050601054955.GA2625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050601054955.GA2625@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2005 at 03:49:55PM +1000, Herbert Xu wrote:
> This looks like stack overflow.  %esi is meant to be "res" which is
> a local variable.  As you can see, it's pointing below %esp and
> threadinfo.

Ok, so I enabled DEBUG_STACKOVERFLOW in addition to CONFIG_DEBUG_SLAB
and CONFIG_DEBUG_PAGEALLOC, and got the below today...so maybe it
is a slab issue?

0xc0238cdd is in dst_alloc (net/core/dst.c:124).
119             if (ops->gc && atomic_read(&ops->entries) > ops->gc_thresh) {
120                     if (ops->gc())
121                             return NULL;
122             }
123             dst = kmem_cache_alloc(ops->kmem_cachep, SLAB_ATOMIC);

0xc013912b is at mm/slab.c:3077.
3072                    size = kmem_cache_size(c);
3073                    local_irq_restore(flags);
3074            }
3075
3076            return size;
3077    }


Phil


invalid operand: 0000 [#1]
SMP DEBUG_PAGEALLOC
CPU:    1
EIP:    0060:[<c013912b>]    Not tainted VLI
EFLAGS: 00016292   (2.6.12-rc5-git5) 
EIP is at ksize+0x7b/0x100
eax: c0238cdd   ebx: f7ba9c20   ecx: f7babf78   edx: dcc59000
esi: 00000020   edi: 0000e3ba   ebp: c0338d98   esp: c0338d88
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0338000 task=c1989b00)
Stack: 00000000 04000000 c02d1a00 ffffff97 c0338db0 c0238cdd c0338e58 04000000 
       00000000 ffffff97 c0338eb4 c0245cb7 00000002 f7b01000 c0338dec c0338df0 
       f7318ef8 00000000 00000000 00000001 f72dbef8 0000a704 103c243b f27ceec0 
Call Trace:
 [<c010389a>] show_stack+0x7a/0x90
 [<c0103a1d>] show_registers+0x14d/0x1b0
 [<c0103c29>] die+0xf9/0x180
 [<c0103d50>] do_trap+0xa0/0xb0
 [<c0104039>] do_invalid_op+0xa9/0xc0
 [<c01034e3>] error_code+0x4f/0x54
 [<c0238cdd>] dst_alloc+0x2d/0xa0
 [<c0245cb7>] ip_route_input_slow+0x4a7/0x840
 [<c02460ea>] ip_route_input+0x9a/0x160
 [<c02481c0>] ip_rcv+0x3b0/0x4d0
 [<c02357aa>] netif_receive_skb+0x13a/0x1a0
 [<c01fa1d0>] e1000_clean_rx_irq+0x180/0x4d0
 [<c01f9a10>] e1000_clean+0x40/0xe0
 [<c02359c0>] net_rx_action+0x90/0x130
 [<c011a8c4>] __do_softirq+0xd4/0xf0
 [<c0104fc2>] do_softirq+0x52/0x70
 =======================
 [<c011a9aa>] irq_exit+0x3a/0x40
 [<c0104e98>] do_IRQ+0x68/0xa0
 [<c010338a>] common_interrupt+0x1a/0x20
 [<c0100a8b>] cpu_idle+0x7b/0x80
 [<c0305c13>] start_secondary+0x73/0x90
 [<00000000>] stext+0x3feffd6c/0xc
 [<c198afb4>] 0xc198afb4
Code: 8d 05 0c e2 34 c0 e8 e9 25 15 00 e9 96 dd ff ff 8d 05 0c e2 34 c0 e8 a9 25 15 00 e9 00 e2 ff 

ff 8d 05 0c e2 34 c0 e8 c9 25 15 00 <e9> 23 e2 ff ff 8d 05 0c e2 34 c0 e8 89 25 15 00 e9 84 e2 ff ff 
 <0>Kernel panic - not syncing: Fatal exception in interrupt
