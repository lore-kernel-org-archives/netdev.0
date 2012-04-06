From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: net: kernel BUG() in net/netns/generic.h:45
Date: Fri, 6 Apr 2012 11:04:25 +0200
Message-ID: <CA+1xoqdi4QOhRJvBA64pxiN3EphhThjPkf4eLRkYM8jxcJjh=w@mail.gmail.com>
References: <1333664446.3538.12.camel@lappy> <m1aa2pwxap.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Dave Jones <davej@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1aa2pwxap.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 1:53 AM, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
>
>> Hi all,
>>
>> When an initialization of a network namespace in setup_net() fails, =
we
>> try to undo everything by executing each of the exit callbacks of ev=
ery
>> namespace in the network.
>>
>> The problem is, it might be possible that the net_generic array wasn=
't
>> initialized before we fail and try to undo everything. At that point=
,
>> some of the networks assume that since we're already calling the exi=
t
>> callback, the net_generic structure is initialized and we hit the BU=
G()
>> in net/netns/generic.h:45 .
>>
>> I'm not quite sure whether the right fix from the following three
>> options is, and would be happy to figure it out before fixing it:
>>
>> =A01. Don't assume net_generic was initialized in the exit callback,=
 which
>> is a bit problematic since we can't query that nicely anyway (a
>> sub-option here would be adding an API to query whether the net_gene=
ric
>> structure is initialized.
>>
>> =A02. Remove the BUG(), switch it to a WARN() and let each subsystem
>> handle the case of NULL on it's own. While it sounds a bit wrong, it=
's
>> worth mentioning that that BUG() was initially added in an attempt t=
o
>> fix an issue in CAIF, which was fixed in a completely different way
>> afterwards, so it's not strictly necessary here.
>>
>> =A03. Only call the exit callback for subsystems we have called the =
init
>> callback for.
>
> Your option 3 only calling the exit callbacks for subsystems we have
> initialized should be what is implemented. =A0Certainly it looks like=
 we
> are attempting to only call the exit callbacks for code whose init
> callback has succeeded.
>
> What problem are you seeing?
>
> This smells suspiciously like a problem we had a little while ago cai=
f
> was registering as a pernet device instead of a pernet subsystem,
> and because of that we had packets flying around after it had been
> unregistered and was trying access it's net_generic data.

It looks different from the caif problem a bit, here is a sample stackt=
race:

[  163.733755] ------------[ cut here ]------------
[  163.734501] kernel BUG at include/net/netns/generic.h:45!
[  163.734501] invalid opcode: 0000 [#1] PREEMPT SMP
[  163.734501] CPU 2
[  163.734501] Pid: 19145, comm: trinity Tainted: G        W
3.4.0-rc1-next-20120405-sasha-dirty #57
[  163.734501] RIP: 0010:[<ffffffff824d6062>]  [<ffffffff824d6062>]
phonet_pernet+0x182/0x1a0
[  163.734501] RSP: 0018:ffff8800674d5ca8  EFLAGS: 00010246
[  163.734501] RAX: 000000003fffffff RBX: 0000000000000000 RCX: ffff880=
0678c88d8
[  163.734501] RDX: 00000000003f4000 RSI: ffff8800678c8910 RDI: 0000000=
000000282
[  163.734501] RBP: ffff8800674d5cc8 R08: 0000000000000000 R09: 0000000=
000000000
[  163.734501] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880=
068bec920
[  163.734501] R13: ffffffff836b90c0 R14: 0000000000000000 R15: 0000000=
000000000
[  163.734501] FS:  00007f055e8de700(0000) GS:ffff88007d000000(0000)
knlGS:0000000000000000
[  163.734501] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  163.734501] CR2: 00007f055e6bb518 CR3: 0000000070c16000 CR4: 0000000=
0000406e0
[  163.734501] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  163.734501] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  163.734501] Process trinity (pid: 19145, threadinfo
ffff8800674d4000, task ffff8800678c8000)
[  163.734501] Stack:
[  163.734501]  ffffffff824d5f00 ffffffff810e2ec1 ffff880067ae0000
00000000ffffffd4
[  163.734501]  ffff8800674d5cf8 ffffffff824d667a ffff880067ae0000
00000000ffffffd4
[  163.734501]  ffffffff836b90c0 0000000000000000 ffff8800674d5d18
ffffffff824d707d
[  163.734501] Call Trace:
[  163.734501]  [<ffffffff824d5f00>] ? phonet_pernet+0x20/0x1a0
[  163.734501]  [<ffffffff810e2ec1>] ? get_parent_ip+0x11/0x50
[  163.734501]  [<ffffffff824d667a>] phonet_device_destroy+0x1a/0x100
[  163.734501]  [<ffffffff824d707d>] phonet_device_notify+0x3d/0x50
[  163.734501]  [<ffffffff810dd96e>] notifier_call_chain+0xee/0x130
[  163.734501]  [<ffffffff810dd9d1>] raw_notifier_call_chain+0x11/0x20
[  163.734501]  [<ffffffff821cce12>] call_netdevice_notifiers+0x52/0x60
[  163.734501]  [<ffffffff821cd235>] rollback_registered_many+0x185/0x2=
70
[  163.734501]  [<ffffffff821cd334>] unregister_netdevice_many+0x14/0x6=
0
[  163.734501]  [<ffffffff823123e3>] ipip_exit_net+0x1b3/0x1d0
[  163.734501]  [<ffffffff82312230>] ? ipip_rcv+0x420/0x420
[  163.734501]  [<ffffffff821c8515>] ops_exit_list+0x35/0x70
[  163.734501]  [<ffffffff821c911b>] setup_net+0xab/0xe0
[  163.734501]  [<ffffffff821c9416>] copy_net_ns+0x76/0x100
[  163.734501]  [<ffffffff810dc92b>] create_new_namespaces+0xfb/0x190
[  163.734501]  [<ffffffff810dca21>] unshare_nsproxy_namespaces+0x61/0x=
80
[  163.734501]  [<ffffffff810afd1f>] sys_unshare+0xff/0x290
[  163.734501]  [<ffffffff8187622e>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
[  163.734501]  [<ffffffff82665539>] system_call_fastpath+0x16/0x1b
[  163.734501] Code: e0 c3 fe 66 0f 1f 44 00 00 48 c7 c2 40 60 4d 82
be 01 00 00 00 48 c7 c7 80 d1 23 83 e8 48 2a c4 fe e8 73 06 c8 fe 48
85 db 75 0e <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 48 83 c4 10 48
89 d8
[  163.734501] RIP  [<ffffffff824d6062>] phonet_pernet+0x182/0x1a0
[  163.734501]  RSP <ffff8800674d5ca8>
[  163.861289] ---[ end trace fb5615826c548066 ]---

It would appear that there's at least a one-off problem with the
reverse iteration.
