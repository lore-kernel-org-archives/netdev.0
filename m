From: James Morris <jmorris@redhat.com>
Subject: TCP crashes when cycling loopback interface.
Date: Thu, 7 Oct 2004 02:11:30 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0410070200270.2111-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On an FC2 system, kernel 2.6.9-rc3-mm2 (selinux=0), running this causes a 
often repeatable oopses:

$ set -x
$ while (true) ; do ifdown lo; ifup lo; done

KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at 
net/ipv4/tcp_timer.c (322)
Unable to handle kernel NULL pointer dereference at virtual address 
00000048
 printing eip:
c0306ef3
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP 
Modules linked in: ipv6 e1000 3c59x mii ac
CPU:    0
EIP:    0060:[<c0306ef3>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9-rc3-mm2) 
EIP is at tcp_retransmit_skb+0x50/0x333
eax: 00000000   ebx: 00000000   ecx: f4e04758   edx: 00000000
esi: f4c0d258   edi: f4c0d024   ebp: c0467f64   esp: c0467f48
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0467000 task=c03a3bc0)
Stack: f4c0d024 00000000 000005a8 f4c0d258 f4c0d024 f4c0d258 f4c0d0a8 c0467fa0 
       c030917f c038db34 c038ee9c c038bd55 00000142 f7f7636c c192b03c c1921580 
       f7f76370 c0467fa4 00000282 f4c0d024 f4c0d258 f4c0d044 c0467fb8 c0309585 
Call Trace:
 [<c0106b0f>] show_stack+0x7a/0x90
 [<c0106c94>] show_registers+0x156/0x1ce
 [<c0106e96>] die+0xfb/0x181
 [<c011496e>] do_page_fault+0x304/0x5f3
 [<c0106739>] error_code+0x2d/0x38
 [<c030917f>] tcp_retransmit_timer+0xf1/0x442
 [<c0309585>] tcp_write_timer+0xb5/0xd1
 [<c0127767>] run_timer_softirq+0xba/0x17a
 [<c0123c93>] __do_softirq+0x63/0xcf
 [<c010810d>] do_softirq+0x59/0x5d
 [<c013999d>] irq_exit+0x42/0x44
 [<c01116c9>] smp_apic_timer_interrupt+0xc4/0xc9
 [<c010669e>] apic_timer_interrupt+0x1a/0x20
 [<c0103e3e>] cpu_idle+0x3b/0x5f
 [<c043687a>] start_kernel+0x184/0x1c2
 [<c0100211>] 0xc0100211


(gdb) l *0xc0306ee3
0xc0306ee3 is in tcp_retransmit_skb (net/ipv4/tcp_output.c:1024).
1019
1020            /* Do not sent more than we queued. 1/4 is reserved for possible
1021             * copying overhead: frgagmentation, tunneling, mangling etc.
1022             */
1023            if (atomic_read(&sk->sk_wmem_alloc) >
1024                min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
1025                    return -EAGAIN;
1026
1027            if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
1028                    if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))


I _think_ the TCP traffic in question is over an ethernet interface 
(e1000), due the output of 'set -x' and running the test via ssh.

The ifup and ifdown scripts are complex, so I've also tried to reproduce 
the problem just using ifconfig.  No crash so far but several kernel 
messages 'retrans_out leaked.'

I initially saw something like this when cycling another ethernet
interface (3c59x), but did not have debugging in that kernel and switched
to loopback to see if it still happened.  So I'm guessing it could be
caused by cycling any interface and retransmitting tcp in general.

If anyone wants more info, let me know.


- James
-- 
James Morris
<jmorris@redhat.com>
