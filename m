From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 937] New: Oops in raw_rcv_skb while ping
 flooding
Date: Mon, 28 Jul 2003 20:46:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728204615.7c92d413.akpm@osdl.org>
References: <20030727202514.5b4b2ba9.akpm@osdl.org>
	<Pine.LNX.4.43.0307281817070.3284-100000@morpheus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Burton Windle <bwindle@fint.org>
In-Reply-To: <Pine.LNX.4.43.0307281817070.3284-100000@morpheus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Burton Windle <bwindle@fint.org> wrote:
>
> Still happens with 2.6.0-test2.
> 
> CONFIG_DEBUG_KERNEL=y
> CONFIG_DEBUG_STACKOVERFLOW=y
> CONFIG_DEBUG_SLAB=y
> CONFIG_DEBUG_IOVIRT=y
> CONFIG_MAGIC_SYSRQ=y
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_PAGEALLOC=y
> CONFIG_DEBUG_SPINLOCK_SLEEP=y
> CONFIG_FRAME_POINTER=y

yeah, me too.

The sending machine is a 4-way x86.  I run

	ping -f otherhost &
	ping -f otherhost &

and it oopses immediately:

Program received signal SIGEMT, Emulation trap.
0xc036f40d in raw_rcv_skb (sk=0xf57cc004, skb=0xf3772004) at include/net/sock.h:942
942                     sk->sk_data_ready(sk, skb->len);
(gdb) p skb->len
Cannot access memory at address 0xf3772068
(gdb) bt
#0  0xc036f40d in raw_rcv_skb (sk=0xf57cc004, skb=0xf3772004) at include/net/sock.h:942
#1  0xc036f515 in raw_rcv (sk=0xf57cc004, skb=0xf3772004) at net/ipv4/raw.c:255
#2  0xc036f0bc in raw_v4_input (skb=0xf377b004, iph=0xf6a99024, hash=0) at net/ipv4/raw.c:169
#3  0xc034d9b9 in ip_local_deliver_finish (skb=0xf377b004) at net/ipv4/ip_input.c:234
#4  0xc0344968 in nf_hook_slow (pf=2, hook=1, skb=0xf377b004, indev=0xf70b7004, outdev=0x0, 
    okfn=0xc034d914 <ip_local_deliver_finish>, hook_thresh=-2147483648) at net/core/netfilter.c:539
#5  0xc034d48a in ip_local_deliver (skb=0xf377b004) at net/ipv4/ip_input.c:285
#6  0xc034dcee in ip_rcv_finish (skb=0xf377b004) at net/ipv4/ip_input.c:349
#7  0xc0344968 in nf_hook_slow (pf=2, hook=0, skb=0xf377b004, indev=0xf70b7004, outdev=0x0, 
    okfn=0xc034daf4 <ip_rcv_finish>, hook_thresh=-2147483648) at net/core/netfilter.c:539
#8  0xc034d8c0 in ip_rcv (skb=0xf377b004, dev=0x0, pt=0xc04afd60) at net/ipv4/ip_input.c:424
#9  0xc033c19b in netif_receive_skb (skb=0xf377b004) at net/core/dev.c:1596
#10 0xc033c27f in process_backlog (backlog_dev=0xc3857a50, budget=0xc05bbf40) at net/core/dev.c:1630
#11 0xc033c3be in net_rx_action (h=0xc05b7d98) at net/core/dev.c:1695
#12 0xc01289cb in do_softirq () at kernel/softirq.c:100
#13 0xc010d516 in do_IRQ (regs=
      {ebx = -1067737088, ecx = -1067737088, edx = -1067737088, esi = -1072657448, edi = -1072672768, ebp = -1067728960, eax = 16, xds = -1072693125, xes = 123, orig_eax = -218, eip = -1072657404, xcs = 96, eflags = 582, esp = -1067728944, xss = -1072657306}) at arch/i386/kernel/irq.c:500
#14 0xc010b8fc in common_interrupt ()
#15 0xc0108c66 in cpu_idle () at arch/i386/kernel/process.c:146
#16 0xc010507c in rest_init () at init/main.c:374
#17 0xc05bc7dc in start_kernel () at init/main.c:466

The critical thing here is CONFIG_DEBUG_PAGEALLOC (I have all debug options
turned on).

The memory at *skb has been freed and unmapped.   Looks like a use-after-free bug.

Now it _might_ be a bug in CONFIG_DEBUG_PAGEALLOC.  I'm not sure that I'm
100% confident in it yet.  But it hits so quickly that I rather doubt it.
