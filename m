From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 18:04:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524080431.GD27177@sgi.com>
References: <20040524072657.GC27177@sgi.com> <20040524004045.58b3eb44.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040524004045.58b3eb44.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 24, 2004 at 12:40:45AM -0700, David S. Miller wrote:
> On Mon, 24 May 2004 17:26:58 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > The tg3 transmit code assumes that tg3_tx() will never have to clean
> > up part of an skb queued for transmit.  This assumption is wrong;
> 
> Greg, perhaps my reading of the tg3 chip docs is different
> from yours.  The hardware is NEVER supposed to do this.

I'd like to know where you read that, because neither I nor any of
the other SGI engineers who have read the Broadcom docs can find any
such guarantee.  The consensus here is that there is no guarantee
about where the transmit ring consumer index is when the card DMAs
a status block update.

We've seen that BUG() trip many times both on 2.4 and 2.6.  SGI ProPack
for Linux has been shipping for a year now with a workaround for this
bug (the BUG() is changed to a break).

> Or is there an errata in some chip versions?

We've seen this on both 5701 and 5704 hardware.  The SGI cards ship
have slightly different firmware from stock Broadcom cards, I don't
know if that's a factor.  It might also be something to do with the
Altix IO architecture.  I don't know why the card chooses to do this,
but it most certainly does.

The IRIX driver guys tells me this same behaviour happens on the
Origin hardware, and the IRIX driver had an equivalent fix applied
about 18 months ago.

> I've never triggered that BUG() assertion on any of my
> hardware, ever.

Ok, here's one of several mostly identical stack traces reported by
various people inside SGI on 2.6 kernels.  If you want to wait for
a day or so I can probably make a 2.4 kernel do this also (I did
that during testing a coupld of days ago but didn't save the stack
trace, doh!)

[root@budgie root]# swapper[0]: bugcheck! 0 [1]

Pid: 0, CPU 0, comm:              swapper
psr : 0000101009022018 ifs : 8000000000000d1e ip  : [<a000000200165980>]
Not tainted
ip is at tg3_tx+0x5a0/0x5c0 [tg3]
unat: 0000000000000000 pfs : 0000000000000d1e rsc : 0000000000000003
rnat: 800000025da66955 bsps: a0000001000fdec0 pr  : 80000000ff7669a5
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000200165980 b6  : a000000100003320 b7  : a0000001000cc200
f6  : 1003e0fc0fc0fc0fc0fc1 f7  : 0ffdaa200000000000000
f8  : 1003e0000000000000240 f9  : 1003e0000000000002490
f10 : 1003e000000000ea00000 f11 : 1003e00000000367b7ad0
r1  : a0000001009ec7f0 r2  : 0000000000000000 r3  : 0000000000004000
r8  : 0000000000000026 r9  : 0000000000000002 r10 : 0000000000000001
r11 : 0000000000000004 r12 : e0000030146a3c50 r13 : e00000301469c000
r14 : 0000000000004000 r15 : a000000100734fb0 r16 : e00000b004a147a8
r17 : e00000b07ba88060 r18 : e000003007ba0000 r19 : 0000000000180000
r20 : 0000000000000014 r21 : 0000000000080000 r22 : 0000000000100000
r23 : e00000b004a150e4 r24 : e00000b004a150d8 r25 : e0000030146a3bf0
r26 : e00000b004a15810 r27 : 0000000000000074 r28 : 0000000000000074
r29 : e000003007ba002c r30 : e00000b07ba8802c r31 : 0000000000000002

Call Trace:
 [<a000000100015180>] show_stack+0x80/0xa0
                                sp=e0000030146a3820 bsp=e00000301469d2c8
 [<a0000001000384f0>] die+0x1b0/0x280
                                sp=e0000030146a39f0 bsp=e00000301469d2a0
 [<a000000100038960>] ia64_bad_break+0x340/0x480
                                sp=e0000030146a39f0 bsp=e00000301469d280
 [<a00000010000de20>] ia64_leave_kernel+0x0/0x260
                                sp=e0000030146a3a80 bsp=e00000301469d280
 [<a000000200165980>] tg3_tx+0x5a0/0x5c0 [tg3]
                                sp=e0000030146a3c50 bsp=e00000301469d188
 [<a000000200166cf0>] tg3_interrupt_main_work+0x150/0x280 [tg3]
                                sp=e0000030146a3c50 bsp=e00000301469d158
 [<a000000200166f20>] tg3_interrupt+0x100/0x1c0 [tg3]
                                sp=e0000030146a3c50 bsp=e00000301469d110
 [<a000000100011640>] handle_IRQ_event+0xa0/0x120
                                sp=e0000030146a3c50 bsp=e00000301469d0c8
 [<a000000100012170>] do_IRQ+0x390/0x4a0
                                sp=e0000030146a3c50 bsp=e00000301469d078
 [<a000000100014160>] ia64_handle_irq+0xc0/0x1a0
                                sp=e0000030146a3c50 bsp=e00000301469d040
 [<a00000010000de20>] ia64_leave_kernel+0x0/0x260
                                sp=e0000030146a3c50 bsp=e00000301469d040
 [<a000000100084010>] snidle+0xb0/0x180
                                sp=e0000030146a3e20 bsp=e00000301469d038
 [<a000000100015cb0>] cpu_idle+0x130/0x220
                                sp=e0000030146a3e20 bsp=e00000301469cfa8
 [<a000000100630fa0>] start_kernel+0x460/0x4e0
                                sp=e0000030146a3e20 bsp=e00000301469cf50
 [<a000000100008600>] _start+0x2c0/0x0
                                sp=e0000030146a3e30 bsp=e00000301469cf50
 3 out of 4 cpus in kdb, waiting for the rest
1 cpu are not in kdb, their state is unknown

Entering kdb (current=0xe00000301469c000, pid 0) on processor 0 Oops: <NULL>
due to oops @ 0xa000000200165980
 psr: 0x0000101009022018   ifs: 0x8000000000000d1e    ip: 0xa000000200165980  
unat: 0x0000000000000000   pfs: 0x0000000000000d1e   rsc: 0x0000000000000003  
rnat: 0x800000025da66955  bsps: 0xa0000001000fdec0    pr: 0x80000000ff7669a5  
ldrs: 0x0000000000000000   ccv: 0x0000000000000000  fpsr: 0x0009804c8a70033f  
  b0: 0xa000000200165980    b6: 0xa000000100003320    b7: 0xa0000001000cc200  
  r1: 0xa0000001009ec7f0    r2: 0x0000000000000000    r3: 0x0000000000004000  
  r8: 0x0000000000000026    r9: 0x0000000000000002   r10: 0x0000000000000001  
 r11: 0x0000000000000004   r12: 0xe0000030146a3c50   r13: 0xe00000301469c000  
 r14: 0x0000000000004000   r15: 0xa000000100734fb0   r16: 0xe00000b004a147a8  
 r17: 0xe00000b07ba88060   r18: 0xe000003007ba0000   r19: 0x0000000000180000  
 r20: 0x0000000000000014   r21: 0x0000000000080000   r22: 0x0000000000100000  
 r23: 0xe00000b004a150e4   r24: 0xe00000b004a150d8   r25: 0xe0000030146a3bf0  
 r26: 0xe00000b004a15810   r27: 0x0000000000000074   r28: 0x0000000000000074  
 r29: 0xe000003007ba002c   r30: 0xe00000b07ba8802c   r31: 0x0000000000000002  
&regs = e0000030146a3a90
[0]kdb>



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
