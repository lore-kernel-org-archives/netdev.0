From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 14:18:34 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CE9682A.2CC13644@mvista.com>
References: <3CE95190.75C52E2D@mvista.com> <20020520222937.A1467@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> 
> > Incase you can not see this, it appears that the addresses
> > of each skb are alright, so the assumption is that the skb
> > passed to tcp_fragment() has been unlinked while
> > tcp_fragment() was doing its thing.  This implies a need for
> > locking at some higher level and we don't know enough about
> > the tcp code to divine where this might best be done.
> 
> 2.4 TCP should in theory already have enough locking to prevent this
> (the socket lock that is aquired by timers and user context socket users)
> 
> -Andi
Here is another oops, not quite the same, AND with an assert
failure ahead of it.  I append the whole report and some and
some observations:


We had two more panics over the weekend.
Here is the analysis from one of them.

---------comments from Dave Howell--------------
Looking at the sysint4l dump, some observations:
- Panic was due to an Oops (Null pointer dereference kernel
incident)
- Full system configuration is in kernel startup logs
(memory, disks, chipsets, 
etc)
- Last part of kernel log has oops info, follows kernel
assertion failed 
warning:
<4>KERNRL: assertion (atomic_read(&sk->wmem_alloc) == 0)
failed at af_inet.c  <==============
(174):inet_sock_destruct
<1>Unable to handle kernel NULL pointer dereference at
virtual address 00000049
<4> printing eip:
<4>c0255196
<1>*pde = 00000000
<4>Oops: 0000
<4>CPU:    1
<4>EIP:    0010:[<c0255196>]    Not tainted
<4>EFLAGS: 00010213
<4>eax: c6ace4c8   ebx: 00000000   ecx: 00000004   edx:
00000000
<4>esi: c6ace538   edi: c6ace460   ebp: 00000026   esp:
c1219eb4
<4>ds: 0018   es: 0018   ss: 0018
<4>Process swapper (pid: 0, stackpage=c1219000)
<4>Stack: c6ace460 c6ace538 c6ace460 004ec3ef c025de3e
c6ace460 00000000 
c72011a0 
<4>       c1218050 004ec2d2 c02395b2 c6ace460 c6ace538
c1218000 004ec3ef 
c025e056 
<4>       c6ace460 c1218000 00000046 004ebfe7 00000000
c1218000 00cf70a0 
c0128eaa 
<4>Call Trace: [<c025de3e>] [<c02395b2>] [<c025e056>]
[<c0128eaa>] [<c025df70>] 
<4>   [<c0128fad>] [<c012483b>] [<c0109704>] [<c0105490>]
[<c0105490>] 
[<c0105490>] 
<4>   [<c01054bc>] [<c0105542>] [<c011d51b>] [<c011d8ad>] 
<4>
<4>Code: 0f b6 4b 49 45 f6 c1 82 74 0c 31 d2 89 96 78 01 00
00 0f b6 

- Finally at the bottom of the trace the active backtrace, a
bit suspect 
because it's on the interrupt 
  side (not trace but process it's attributed to).
===========================
STACK TRACE OF FAILING TASK
===========================

================================================================
STACK TRACE FOR TASK: 0xc1218000 (swapper)

 0 tcp_enter_loss+198 [0xc0255196]
 1 tcp_retransmit_timer+473 [0xc025de39]
 2 tcp_write_timer+225 [0xc025e051]
 3 timer_bh+710 [0xc0128ea6]
 4 timer_softirq+40 [0xc0128fa8]
 5 do_softirq+185 [0xc0124839]
 6 do_IRQ+511 [0xc01096ff]
 7 do_IRQ+511 [0xc01096ff]
TRACE ERROR 0x1
================================================================

- In comparison with previous dump looks like the same
upstream event occured, 
with a timer bottom half running and invoking the
tcp_retransmit_timer. Last 
one caught it oopsing in the tcp_fragment code, this is a
bit different but the 
upstream path there is the same.

- Same pile of unknown symbol references bringing up dump
manually in lcrash, 
must be corrupt or wrong system.0 or kerntypes.0. Needs a
look.

- Dumped tcp_enter_loss+0 to tcp_enter_loss+200 to see site
at 
tcp_enter_loss+198. 
  Code at this site is:
        movzbl 0x49(%ebx),%ecx
  %ebx is NULL at this point (see above), hence the oops at
00000049. 
  Code for function is in net/ipv4/tcp_input.c starting at
line 987.

- The failure is in the loop starting at line 1002:
        
    for_retrans_queue(skb, sk, tp) {
                cnt++;
                if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
                        tp->undo_marker = 0;
                TCP_SKB_CB(skb)->sacked &=
(~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
                if
(!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
                        TCP_SKB_CB(skb)->sacked &=
~TCPCB_SACKED_ACKED;
                        TCP_SKB_CB(skb)->sacked |=
TCPCB_LOST;
                        tp->lost_out++;
                } else {
                        tp->sacked_out++;
                        tp->fackets_out = cnt;
                }
        }
I didn't fully map the code but think that the expansion of:
           if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
is where the zeroed pointer is used. Looks like the intent
is that skp is the 
iterater variable to loop through the retrans_queue and it
got the zero value
set on some iteration, not the first. So my guess is a
corrupted queue element
pointer being picked up and used.

- I still would look upstream at the timer bottom half
invocation as in both 
  of the dumps this upstream trace is present, and it seems
like an exception 
  path for a timeout that leads to a retransmit. 
  
- Also needs a look is the kernel assertion that failed and
likely led to the 
  oops, looks a lot like an allocation failed and returned a
NULL value, this
  would be my top culprit to pursue.
  Code from af_net.c at line 174:

void inet_sock_destruct(struct sock *sk)
{
        __skb_queue_purge(&sk->receive_queue);
        __skb_queue_purge(&sk->error_queue);

        if (sk->type == SOCK_STREAM && sk->state !=
TCP_CLOSE) {
                printk("Attempt to release TCP socket in
state %d %p\n",
                       sk->state,
                       sk);
                return;
        }
        if (!sk->dead) {
                printk("Attempt to release alive inet socket
%p\n", sk);
                return;
        }

        BUG_TRAP(atomic_read(&sk->rmem_alloc) == 0);
        BUG_TRAP(atomic_read(&sk->wmem_alloc) == 0);    <<--
assert reported 
here
        BUG_TRAP(sk->wmem_queued == 0);
        BUG_TRAP(sk->forward_alloc == 0);

        if (sk->protinfo.af_inet.opt)
                kfree(sk->protinfo.af_inet.opt);

  Continuing on after this likely led to the oops that
killed us.


-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
