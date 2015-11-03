From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Resource leak in unshare
Date: Tue, 3 Nov 2015 16:21:13 +0100
Message-ID: <CACT4Y+YCxrczt11jby9sSnomV3711DA2voRvnZK7qDtG9_i3ug@mail.gmail.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
 <87oafcrzsa.fsf@x220.int.ebiederm.org> <CACT4Y+arcDq=-kDn=y6oRFRSMApKKA7GrfAg_svTtLOVnnaVDA@mail.gmail.com>
 <1446554880.23275.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446554880.23275.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2015 at 1:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-11-03 at 09:48 +0100, Dmitry Vyukov wrote:
>> On Mon, Nov 2, 2015 at 8:01 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > Dmitry Vyukov <dvyukov@google.com> writes:
>> >
>> >> Hello,
>> >>
>> >> I am hitting the following warnings on
>> >> bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):
>> >
>> > Do you have any trace of the earlier failures?
>> >
>> > This appears to be something caused by an earlier failure (possibly
>> > whatever fails to allocate memory).  Having network devices present
>> > but being in the generic cleanup routines is wrong.
>> >
>> > If there is no additional information can you please rerun with the
>> > following change applied?  That should at least report which function is
>> > failing, and give us a good clue where to start debugging this.
>>
>>
>> So is it all fixed now? Or it is still clear how it can happen?
>> Eric (Dumazet), do you see how the WARNING can fire?
>> I don't have any logs at the moment, but I can run fuzzer for longer
>> to reproduce it again if necessary.
>
> No idea.
>
> I fixed a completely different bug I think, while simply looking at sit
> code, since your report mentioned a sit0 name.
>
> Namely a pure memory leak.
>
> We have hundred of old bugs yet to fix. Not counting the new ones that
> we'll add while fixing them.
>
> Feel free to run your fuzzer of course.


It is not easy to reproduce.
I've inserted WARN into snmp6_register_dev and it gives some stacks to
look at. We also know device names, so far I've seen it for "sit0" and
"lo".

The "lo" stack is:

[   67.298891] WARNING: CPU: 0 PID: 2673 at net/ipv6/proc.c:282
snmp6_register_dev+0xcc/0x1d0()
[   67.299454] snmp6_register_dev net=ffff88003ceb0000
[   67.299778] Modules linked in:
[   67.299996] CPU: 0 PID: 2673 Comm: a.out Tainted: G        W
4.3.0-rc2+ #22
[   67.300495] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[   67.301034]  00000000ffffffff ffff88003cea7800 ffffffff81a44e70
ffff88003cea7870
[   67.301559]  ffff88003cde3500 ffffffff83329d60 ffff88003cea7840
ffffffff810fa399
[   67.302106]  ffffffff82af053c ffffed00079d4f0a ffffffff83329d60
000000000000011a
[   67.302614] Call Trace:
[   67.302779]  [<ffffffff81a44e70>] dump_stack+0x68/0x88
[   67.303127]  [<ffffffff810fa399>] warn_slowpath_common+0xd9/0x140
[   67.303911]  [<ffffffff810fa4a9>] warn_slowpath_fmt+0xa9/0xd0
[   67.306673]  [<ffffffff82af053c>] snmp6_register_dev+0xcc/0x1d0
[   67.307064]  [<ffffffff82a4fee7>] ipv6_add_dev+0x5a7/0x10a0
[   67.307805]  [<ffffffff82a60cfc>] addrconf_notify+0x34c/0x18f0
[   67.312275]  [<ffffffff811583df>] notifier_call_chain+0xcf/0x160
[   67.312673]  [<ffffffff811589ed>] raw_notifier_call_chain+0x2d/0x40
[   67.313099]  [<ffffffff827394d1>] call_netdevice_notifiers_info+0x51/0x90
[   67.313549]  [<ffffffff8275aaf0>] register_netdevice+0x9d0/0xe40
[   67.315580]  [<ffffffff8275af7a>] register_netdev+0x1a/0x30
[   67.315971]  [<ffffffff82207a76>] loopback_net_init+0x76/0x150
[   67.316825]  [<ffffffff8272ce69>] ops_init+0xa9/0x330
[   67.317615]  [<ffffffff8272d2ea>] setup_net+0x1fa/0x4e0
[   67.319565]  [<ffffffff8272eb9e>] copy_net_ns+0xbe/0x1d0
[   67.319931]  [<ffffffff811577bf>] create_new_namespaces+0x2ff/0x620
[   67.320374]  [<ffffffff81157f0e>] unshare_nsproxy_namespaces+0xae/0x160
[   67.320832]  [<ffffffff810f943c>] SyS_unshare+0x37c/0x790
[   67.322481]  [<ffffffff82e3ad91>] entry_SYSCALL_64_fastpath+0x31/0x95
[   67.322923] ---[ end trace f00cf63d17e5205f ]---


Looking at loopback_net_init, it does register_netdev, but then there
is no exit callback that would unregister it at all:

221 struct pernet_operations __net_initdata loopback_net_ops = {
222        .init = loopback_net_init,
223 };

Can it be the reason for the bug?
Although, I am not sure why this bug does not fire all the time then...
