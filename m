From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug#251215: kernel-image-2.6.6-1-k7: pppd locks up, cannot be  killed, during ppp shutdown
Date: Sat, 29 May 2004 15:17:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529051736.GA11303@gondor.apana.org.au>
References: <E1BTLVa-000Ezb-FC@johnnybravo.uk.clara.net> <20040528124355.GA2391@gondor.apana.org.au> <40B744DC.9956BF50@kepier.clara.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Neil Pilgrim <debian.bugs@kepier.clara.net>, 251215@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <40B744DC.9956BF50@kepier.clara.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 28, 2004 at 02:55:40PM +0100, Neil Pilgrim wrote:
>
> May 26 16:15:53 localhost kernel: kernel BUG at net/core/dev.c:3038!
> May 26 16:15:53 localhost kernel: invalid operand: 0000 [#1]
> May 26 16:15:53 localhost kernel: PREEMPT 
> May 26 16:15:53 localhost kernel: CPU:    0
> May 26 16:15:53 localhost kernel: EIP:    0060:[free_netdev+43/80]    Not tainted
> May 26 16:15:53 localhost kernel: EFLAGS: 00010297   (2.6.6-1-k7) 
> May 26 16:15:53 localhost kernel: EIP is at free_netdev+0x2b/0x50
> May 26 16:15:53 localhost kernel: eax: df236400   ebx: da638000   ecx: c02eada0   edx: 00000003
> May 26 16:15:53 localhost kernel: esi: df236400   edi: ddf3b400   ebp: e0b542c0   esp: da639f48
> May 26 16:15:53 localhost kernel: ds: 007b   es: 007b   ss: 0068
> May 26 16:15:53 localhost kernel: Process pppd (pid: 3852, threadinfo=da638000 task=da5f06b0)
> May 26 16:15:53 localhost kernel: Stack: e0b5094f df236400 00000282 da5ed780 ddf3b400 e0b4d020 dffe4840 d921309c 
> May 26 16:15:53 localhost kernel:        e0b4d07f ddf3b400 da5ed9c0 c0152d24 d921309c da5ed9c0 d81c3c10 da5ed9c0 
> May 26 16:15:53 localhost kernel:        00000000 df689900 da638000 c01513e9 da5ed9c0 df689900 df689900 da5ed9c0 
> May 26 16:15:53 localhost kernel: Call Trace:
> May 26 16:15:53 localhost kernel:  [__crc___netdev_watchdog_up+1116592/2857393] ppp_shutdown_interface+0x7f/0xf0 [ppp_generic]
> May 26 16:15:53 localhost kernel:  [__crc___netdev_watchdog_up+1101953/2857393] ppp_release+0x0/0x70 [ppp_generic]
> May 26 16:15:53 localhost kernel:  [__crc___netdev_watchdog_up+1102048/2857393] ppp_release+0x5f/0x70 [ppp_generic]
> May 26 16:15:53 localhost kernel:  [__fput+276/304] __fput+0x114/0x130
> May 26 16:15:53 localhost kernel:  [filp_close+89/144] filp_close+0x59/0x90
> May 26 16:15:53 localhost kernel:  [sys_close+97/160] sys_close+0x61/0xa0
> May 26 16:15:53 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
> May 26 16:15:53 localhost kernel: 
> May 26 16:15:53 localhost kernel: Code: 0f 0b de 0b e0 75 29 c0 eb de 2b 80 04 02 00 00 89 44 24 04 

OK, I've had a look and it looks like the free_netdev call in
ppp_shutdown_inteface is the problem.  What's happening is that
the todo list is being processed either on another CPU or by
preemption in another context.  As a result when the subsequent
free_netdev is called the device hasn't yet been processed and
is still in state UNREGISTERING.

Why do we need to call free_netdev after unregistering the netdev
from the drivers at all? What's wrong with calling it from run_todo
itself?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
