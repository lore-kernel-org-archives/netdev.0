From: Russell King <rmk@arm.linux.org.uk>
Subject: Badness in cache_free_debugcheck at linux/mm/slab.c:1909
Date: Wed, 27 Apr 2005 15:05:18 +0100
Message-ID: <20050427150518.A15989@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This pretty much sums up the problem:

Badness in cache_free_debugcheck at linux/mm/slab.c:1909
[<c0067d50>] (cache_free_debugcheck+0x0/0x24c) from [<c00689c4>] (kmem_cache_free+0x3c/0xb0)
 r8 = A0000013  r7 = C0A5E198  r6 = C7C9A220  r5 = C7C995C0
 r4 = C018435C
[<c0068988>] (kmem_cache_free+0x0/0xb0) from [<c018435c>] (sk_free+0xc0/0x114)
 r8 = C002A4C4  r7 = C64690C4  r6 = C03F6494  r5 = 00000000
 r4 = C0A5E198
[<c018429c>] (sk_free+0x0/0x114) from [<c01cc27c>] (inet_release+0x60/0x68)
 r5 = C474370C  r4 = C0A5E198
[<c01cc21c>] (inet_release+0x0/0x68) from [<c01816ac>] (sock_release+0x28/0xb0)
 r5 = C474370C  r4 = 00000000
[<c0181684>] (sock_release+0x0/0xb0) from [<c01822ac>] (sock_close+0x38/0x44)
 r5 = C4743730  r4 = C4743730
[<c0182274>] (sock_close+0x0/0x44) from [<c007e404>] (__fput+0x58/0x140)
 r4 = C4EFEEC4
[<c007e3ac>] (__fput+0x0/0x140) from [<c007cc74>] (filp_close+0x84/0x90)
 r7 = 00000006  r6 = C3E96DA0  r5 = 00000000  r4 = C4EFEEC4
[<c007cbf0>] (filp_close+0x0/0x90) from [<c002a340>] (ret_fast_syscall+0x0/0x2c) r6 = 00000006  r5 = FFFFFFFF  r4 = 00000006
mismatch in kmem_cache_free: expected cache c7d57820, got c7c995c0
c7c995c0 is TCP.
c7d57820 is TCPv6.

At a guess, what's happening is that the socket is initially owned by
tcpv6, so the struct sock is allocated in the TCPv6 slab.

A userspace program is probably doing an ADDRFORM sockopt, converting
it to a TCP socket.  At a later time, we free the socket using the
new sk->sk_prot slabs - which would be the TCP slab.

The above messages are from 2.6.12-rc2, but the above diagnosis came
from a quick look at the 2.6.12-rc3 sources.

-- 
Russell King
