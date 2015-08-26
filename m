From: Michael Marineau <michael.marineau@coreos.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Wed, 26 Aug 2015 13:54:33 -0700
Message-ID: <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
	<20150826074959.48aea34c@as>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shaun Crampton <Shaun.Crampton@metaswitch.com>,
	linux-kernel@vger.kernel.org,
	Peter White <Peter.White@metaswitch.com>,
	netdev@vger.kernel.org
To: Chuck Ebbert <cebbert.lkml@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150826074959.48aea34c@as>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 26, 2015 at 4:49 AM, Chuck Ebbert <cebbert.lkml@gmail.com> =
wrote:
> On Wed, 26 Aug 2015 08:46:59 +0000
> Shaun Crampton <Shaun.Crampton@metaswitch.com> wrote:
>
>> Testing our app at scale on Google=C2=B9s GCE, running ~1000 CoreOS =
hosts: over
>> approximately 1 hour, I see about 1 in 50 hosts hit one of the Oopse=
s
>> below and then reboot (I=C2=B9m not sure if the different oopses are=
 related to
>> each other).
>>
>> The app is Project Calico, which is a datacenter networking fabric.
>> calico-felix, the process named below, is our per-host agent.  The
>> per-host agent is responsible for reading the network information fr=
om a
>> central server and applying "ip route=C2=B2 and "iptables" updates t=
o the
>> kernel.  We=C2=B9re running on CoreOS, with about 100  docker contai=
ners/veths
>> pairs running on each host.  calico-felix is running inside one of t=
hose
>> containers. We also run the BIRD BGP stack to redistribute routes ar=
ound
>> the datacenter.  The errors happen more frequently while Calico is u=
nder
>> load.
>>
>> I=C2=B9m not sure where to go from here.  I can reproduce these issu=
es easily
>> at that scale but I haven=C2=B9t managed to boil it down to a small-=
scale repro
>> scenario for further investigation (yet).
>>
>
> What in the world is going on with those call traces? E.g.:
>
>> [ 4513.712008]  <IRQ>
>> [ 4513.712008]  [<ffffffff81486751>] ? ip_rcv_finish+0x81/0x360
>> [ 4513.712008]  [<ffffffff814870e4>] ip_rcv+0x2a4/0x400
>> [ 4513.712008]  [<ffffffff814866d0>] ? inet_del_offload+0x40/0x40
>> [ 4513.712008]  [<ffffffff814491b3>] __netif_receive_skb_core+0x6c3/=
0x9a0
>> [ 4513.712008]  [<ffffffff8143b667>] ? build_skb+0x17/0x90
>> [ 4513.712008]  [<ffffffff814494a8>] __netif_receive_skb+0x18/0x60
>> [ 4513.712008]  [<ffffffff81449523>] netif_receive_skb_internal+0x33=
/0xa0
>> [ 4513.712008]  [<ffffffff814495ac>] netif_receive_skb_sk+0x1c/0x70
>> [ 4513.712008]  [<ffffffffa00f772b>] 0xffffffffa00f772b
>> [ 4513.712008]  [<ffffffff814491b3>] ? __netif_receive_skb_core+0x6c=
3/0x9a0
>> [ 4513.712008]  [<ffffffffa00f7d81>] 0xffffffffa00f7d81
>> [ 4513.712008]  [<ffffffff81449979>] net_rx_action+0x159/0x340
>> [ 4513.712008]  [<ffffffff810715f4>] __do_softirq+0xf4/0x290
>> [ 4513.712008]  [<ffffffff810719fd>] irq_exit+0xad/0xc0
>> [ 4513.712008]  [<ffffffff815528ba>] do_IRQ+0x5a/0xf0
>> [ 4513.712008]  [<ffffffff815507ae>] common_interrupt+0x6e/0x6e
>> [ 4513.712008]  <EOI>
>
> There are two functions in the call trace that the kernel knows
> nothing about. How did they get in there?
>
> And there is really executable code in there, as can be seen from a
> later trace:
>
>> [ 4123.003006]  <IRQ>
>> [ 4123.003006]  [<ffffffff8147d477>] nf_iterate+0x57/0x80
>> [ 4123.003006]  [<ffffffff8147d537>] nf_hook_slow+0x97/0x100
>> [ 4123.003006]  [<ffffffff81486e32>] ip_local_deliver+0x92/0xa0
>> [ 4123.003006]  [<ffffffff81486a30>] ? ip_rcv_finish+0x360/0x360
>> [ 4123.003006]  [<ffffffff81486751>] ip_rcv_finish+0x81/0x360
>> [ 4123.003006]  [<ffffffff814870e4>] ip_rcv+0x2a4/0x400
>> [ 4123.003006]  [<ffffffff814866d0>] ? inet_del_offload+0x40/0x40
>> [ 4123.003006]  [<ffffffff814491b3>] __netif_receive_skb_core+0x6c3/=
0x9a0
>> [ 4123.003006]  [<ffffffff8143b667>] ? build_skb+0x17/0x90
>> [ 4123.003006]  [<ffffffff814494a8>] __netif_receive_skb+0x18/0x60
>> [ 4123.003006]  [<ffffffff81449523>] netif_receive_skb_internal+0x33=
/0xa0
>> [ 4123.003006]  [<ffffffff814495ac>] netif_receive_skb_sk+0x1c/0x70
>> [ 4123.003006]  [<ffffffffa00d472b>] 0xffffffffa00d472b
>> [ 4123.003006]  [<ffffffffa00d4d81>] 0xffffffffa00d4d81
>> [ 4123.003006]  [<ffffffff81449979>] net_rx_action+0x159/0x340
>> [ 4123.003006]  [<ffffffff810715f4>] __do_softirq+0xf4/0x290
>> [ 4123.003006]  [<ffffffff810719fd>] irq_exit+0xad/0xc0
>> [ 4123.003006]  [<ffffffff815528ba>] do_IRQ+0x5a/0xf0
>> [ 4123.003006]  [<ffffffff815507ae>] common_interrupt+0x6e/0x6e
>> [ 4123.003006]  <EOI>
>> [ 4123.003006]  [<ffffffff81483a3d>] ? __ip_route_output_key+0x31d/0=
x860
>> [ 4123.003006]  [<ffffffff814e2e95>] ? xfrm_lookup_route+0x5/0x70
>> [ 4123.003006]  [<ffffffff81484224>] ? ip_route_output_flow+0x54/0x6=
0
>> [ 4123.003006]  [<ffffffff8148ca6a>] ip_queue_xmit+0x36a/0x3d0
>> [ 4123.003006]  [<ffffffff814a4799>] tcp_transmit_skb+0x4b9/0x990
>> [ 4123.003006]  [<ffffffff814a4d85>] tcp_write_xmit+0x115/0xe90
>> [ 4123.003006]  [<ffffffff814a5d72>] __tcp_push_pending_frames+0x32/=
0xd0
>> [ 4123.003006]  [<ffffffff8149443f>] tcp_push+0xef/0x120
>> [ 4123.003006]  [<ffffffff81497cb5>] tcp_sendmsg+0xc5/0xb20
>> [ 4123.003006]  [<ffffffff810d74c9>] ? lock_hrtimer_base.isra.22+0x2=
9/0x50
>> [ 4123.003006]  [<ffffffff814c2d04>] inet_sendmsg+0x64/0xa0
>> [ 4123.003006]  [<ffffffff811e94b5>] ? __fget_light+0x25/0x70
>> [ 4123.003006]  [<ffffffff8142d74d>] sock_sendmsg+0x3d/0x50
>> [ 4123.003006]  [<ffffffff8142dc12>] SYSC_sendto+0x102/0x1a0
>> [ 4123.003006]  [<ffffffff8110f864>] ? __audit_syscall_entry+0xb4/0x=
110
>> [ 4123.003006]  [<ffffffff810224fc>] ? do_audit_syscall_entry+0x6c/0=
x70
>> [ 4123.003006]  [<ffffffff81023cf3>] ?
>> syscall_trace_enter_phase1+0x103/0x160
>> [ 4123.003006]  [<ffffffff8142e75e>] SyS_sendto+0xe/0x10
>> [ 4123.003006]  [<ffffffff8154fc6e>] system_call_fastpath+0x12/0x71
>> [ 4123.003006] Code: <48> 8b 88 40 03 00 00 e8 1d dd dd ff 5d c3 0f =
1f 00
>> 41 83 b9 80 00
>> [ 4123.003006] RIP  [<ffffffffa0233027>] 0xffffffffa0233027
>> [ 4123.003006]  RSP <ffff88021fc03b58>
>
> Presumably the same two functions as before (loaded at a different
> base address but same offsets, 0xd81 and 0x72b). And then nf_iterate
> call into another unknown function, and there really is code there
> and it's consistent with the oops. And the kernel thinks it's
> outside of any normal text section, so it does not try to dump any
> code from before the instruction pointer.
>
>    0:   48 8b 88 40 03 00 00    mov    0x340(%rax),%rcx
>    7:   e8 1d dd dd ff          callq  0xffffffffffdddd29
>    c:   5d                      pop    %rbp
>    d:   c3                      retq
>
> Did you write your own module loader or something?

These are stock kernels, with the exception that we include the secure
boot patch set:
https://github.com/coreos/coreos-overlay/tree/master/sys-kernel/coreos-=
sources/files/4.1
Been a while since kmod got updated so CoreOS is currently shipping
with kmod-15 but beyond being a bit old there isn't anything special
about the module loader.

So nothing particularly magical going on here that I know of.

=46or reference the original bug report includes a few more varieties o=
f
stack traces: https://github.com/coreos/bugs/issues/435
