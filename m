From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: sctp_close/sk_free: kernel BUG at arch/x86/mm/physaddr.c:18!
Date: Wed, 5 Sep 2012 22:55:08 +0800
Message-ID: <20120905145508.GA9450@localhost>
References: <20120904140411.GB15068@localhost>
 <5046361C.5070602@pengutronix.de>
 <87mx15zfze.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	networking <netdev@vger.kernel.org>, linux-can@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mx15zfze.fsf@xmission.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2012 at 01:32:21PM -0700, Eric W. Biederman wrote:
> Marc Kleine-Budde <mkl@pengutronix.de> writes:
> 
> > On 09/04/2012 04:04 PM, Fengguang Wu wrote:
> >> FYI, another kconfig triggering a slightly different oops on tree
> >> 
> >>         git://gitorious.org/linux-can/linux-can-next led-trigger
> >
> > This in turn means the problem doesn't come from the CAN patches, as
> > both trees have different CAN patches. I'm adding Eric W. Biederman on
> > Cc as he contributed some sctp patches between v3.6 and net-next/master.
> 
> Anything is possible, but this seems unlikely as I don't think I touched
> anything close to that part of the code.

You are both right.  The bad commit turns out to be one of:

1bed966cc3bd4042110129f0fc51aeeb59c5b200 Merge branch 'tcp_fastopen_server'
168a8f58059a22feb9e9a2dcc1b8053dbbbc12ef tcp: TCP Fast Open Server - main code path
8336886f786fdacbc19b719c1f7ea91eb70706d4 tcp: TCP Fast Open Server - support TFO listeners

Thanks,
Fengguang

> This most definitely looks like a memory stomp somewhere.
> 
> sk->inet_sk->inet_opt has a bad value.
> 
> I am puzzled though what are we doing with both ipv4 and ipv6 release
> state doing on the same socket path?    Is this some crazy ipv6 socket
> doing sctp with only ipv4 addresses?
>
> >> [   96.267311] ------------[ cut here ]------------
> >> [   96.268294] kernel BUG at /c/kernel-tests/src/stable/arch/x86/mm/physaddr.c:18!
> >> [   96.269988] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> >> [   96.270636] Modules linked in:
> >> [   96.270636] CPU 0 
> >> [   96.270636] Pid: 2116, comm: trinity Not tainted 3.6.0-rc3+ #2679 Bochs Bochs
> >> [   96.270636] RIP: 0010:[<ffffffff8102b22b>]  [<ffffffff8102b22b>] __phys_addr+0x46/0x6b
> >> [   96.270636] RSP: 0018:ffff880019585c98  EFLAGS: 00010213
> >> [   96.270636] RAX: ffff87ffffffffff RBX: 0000ea6000000bb8 RCX: 0000000000000000
> >> [   96.270636] RDX: 0000000000000000 RSI: 0000000000000296 RDI: 0000ea6000000bb8
> >> [   96.270636] RBP: ffff880019585c98 R08: 0000000000000058 R09: 0000000000000008
> >> [   96.270636] R10: 000000000000000a R11: 0000000000000058 R12: ffff8800195f7718
> >> [   96.270636] R13: ffffffff816521cf R14: ffffea0000000000 R15: 0000000000000000
> >> [   96.270636] FS:  00007fa19b534700(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
> >> [   96.270636] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> [   96.270636] CR2: 00007fa19b03eba0 CR3: 000000001957b000 CR4: 00000000000006f0
> >> [   96.270636] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >> [   96.270636] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >> [   96.270636] Process trinity (pid: 2116, threadinfo ffff880019584000, task ffff88001af2c680)
> >> [   96.270636] Stack:
> >> [   96.270636]  ffff880019585cd8 ffffffff811091d7 0000000000000000 ffff88001b1ef200
> >> [   96.270636]  ffff88001b1ef4d0 0000000000000000 ffff88001b1617b0 0000000000000000
> >> [   96.270636]  ffff880019585cf8 ffffffff816521cf ffff88001b1ef200 ffff88001b1ef248
> >> [   96.270636] Call Trace:
> >> [   96.270636]  [<ffffffff811091d7>] kfree+0x63/0x162
> >> [   96.270636]  [<ffffffff816521cf>] inet_sock_destruct+0x112/0x1ca
> >> [   96.270636]  [<ffffffff815f6fa4>] __sk_free+0x1d/0x114
> >> [   96.270636]  [<ffffffff815f710b>] sk_free+0x1c/0x1e
> >> [   96.270636]  [<ffffffff816d59d5>] sctp_close+0x21a/0x229
> >> [   96.270636]  [<ffffffff810810f6>] ? lock_release_holdtime.part.6+0xb2/0xb7
> >> [   96.270636]  [<ffffffff81651b3e>] ? inet_release+0x65/0xc3
> >> [   96.270636]  [<ffffffff81651b93>] inet_release+0xba/0xc3
> >> [   96.270636]  [<ffffffff81651af9>] ? inet_release+0x20/0xc3
> >> [   96.270636]  [<ffffffff81674134>] inet6_release+0x30/0x3c
> >> [   96.270636]  [<ffffffff815f2317>] sock_release+0x1f/0x77
> >> [   96.270636]  [<ffffffff815f2396>] sock_close+0x27/0x2b
> >> [   96.270636]  [<ffffffff8110ec22>] __fput+0xf0/0x24b
> >> [   96.270636]  [<ffffffff8110ed8b>] ____fput+0xe/0x10
> >> [   96.270636]  [<ffffffff8104f370>] task_work_run+0x5d/0x75
> >> [   96.270636]  [<ffffffff81038a66>] do_exit+0x26b/0x7d7
> >> [   96.270636]  [<ffffffff81725a95>] ? retint_swapgs+0x13/0x1b
> >> [   96.270636]  [<ffffffff8103925b>] do_group_exit+0x7b/0xba
> >> [   96.270636]  [<ffffffff810392b1>] sys_exit_group+0x17/0x17
> >> [   96.270636]  [<ffffffff8172c78e>] tracesys+0xd0/0xd5
> >> [   96.270636] Code: 00 80 48 01 c7 48 81 ff ff ff ff 1f 76 02 0f 0b 48 89 f8 48 03 05 f6 bd ae 00 eb 32 48 b8 ff ff ff ff ff 87 ff ff 48 39 c7 77 02 <0f> 0b 0f b6 0d 55 57 ba 00 48 b8 00 00 00 00 00 78 00 00 48 01 
> >> [   96.270636] RIP  [<ffffffff8102b22b>] __phys_addr+0x46/0x6b
> >> [   96.270636]  RSP <ffff880019585c98>
