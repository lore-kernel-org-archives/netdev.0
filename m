From: george anzinger <george@mvista.com>
Subject: System crash in tcp_fragment()
Date: Mon, 20 May 2002 12:42:08 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <acbkpj$knv$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi
List-Id: netdev.vger.kernel.org

I wonder if you could help me squash a bug in the tcp code. 
Here is what we know thus far:

An SMP (x386 dual) 2.4.17 kernel crashes with an attempt to
deference NULL at the end of tcp_fragment() (in
net/ipv4/tcp_output.c) while attempting to link in the newly
created fragment.  
The bugzilla report is:


http://www.telecomlinux.org/bugzilla/show_bug.cgi?id=503

Incase you can not see this, it appears that the addresses
of each skb are alright, so the assumption is that the skb
passed to tcp_fragment() has been unlinked while
tcp_fragment() was doing its thing.  This implies a need for
locking at some higher level and we don't know enough about
the tcp code to divine where this might best be done.

Here is the call stack:

Panic screen:
    <1>Unable to handle kernel NULL pointer deference at
virtual address 
00000004
    <4> printing eip:
    <4>c0256fb2
    <1>*pde = 00000000
    <4>Oops: 0002
    <4>CPU:    1
    <4>EIP:    0010:[<c0256fb2>]    Not tainted
    <4>EFLAGS: 00010296
    <4>eax: 00000000   ebx: c4d3ada0   ecx: c4d3ada0   edx:
00000000
    <4>esi: c4e60780   edi: 000005a8   ebp: 00000610   esp:
c1219e78
    <4>ds: 0018   es: 0018   ss: 0018
    <4>Process swapper (pid: 0, stackpage=c1219000)
    <4>Stack: c4c84478 00000064 c88937cd 00006270 00000010
c4e60780 c4c84478 
000005a8 
    <4>       000005a8 c025787f c4c843a0 c4e60780 000005a8
c4c843a0 c4c84478 
c4c843a0 
    <4>       004bd6a9 c0259a32 c4c843a0 c4e60780 c4c843a0
00000000 c1219ee8 
00004050 
    <4>Call Trace: [<c88937cd>] [<c025787f>] [<c0259a32>]
[<c01bedc5>] 
[<c0259c36>] 
    <4>   [<c0128d6a>] [<c0259b50>] [<c0128e6d>]
[<c01246fb>] [<c0109604>] 
[<c0105490>] 
    <4>   [<c0105490>] [<c0105490>] [<c01054bc>]
[<c0105542>] [<c011d3db>] 
[<c011d76d>] 
    <4>
    <4>Code: 89 5a 04 89 1e 89 43 08 ff 40 08 31 c0 83 c4 14
5b 5e 5f 5d 
    <1>Dumping from interrupt handler !
    <1>Uncertain scenario - but will try my best
    <4>
    <4>dump: Dumping to device 0x806 [sd(8,6)] on CPU 1 ...
    <4>dump: Compression value is 0x0, Writing dump header 
    <4>
    <4>dump: Pass 1: Saving Reserved Pages: 
    <4>dump: Memory Bank[0]: 0 ... 7feffff: 
    [...]

lcrash backtrace:
>> bt
================================================================
STACK TRACE FOR TASK: 0xc1218000(swapper)

 0 tcp_fragment+674 [0xc0256fb2]
 1 tcp_retransmit_skb+170 [0xc025787a]
 2 tcp_retransmit_timer+493 [0xc0259a2d]
 3 tcp_write_timer+225 [0xc0259c31]
 4 timer_bh+710 [0xc0128d66]
 5 timer_softirq+40 [0xc0128e68]
 6 do_softirq+185 [0xc01246f9]
 7 do_IRQ+511 [0xc01095ff]
 8 do_IRQ+511 [0xc01095ff]
TRACE ERROR 0x1
================================================================

We assumed that this might be related to preempt code in the
kernel, however, this now appears unlikely.  The primary
reason for preempt related failures is the use of
unprotected "cpu ids" to access "per cpu" data structures. 
To this end we have made changes to the "skb" management
code to include the smp_processor_id() calls in the relevant
interrupt off areas, however, this problem does not seem to
have any such issues.

Is is possible for the other cpu (or even this one given the
ksoftirqd stuff) to remove or alter the skb that
tcp_fragment() is processing?  What locks, if any, are
needed to prevent this.
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
