From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Mon, 18 Jan 2016 13:33:54 -0500
Message-ID: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 17, 2016 at 10:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-15 at 23:29 -0800, Eric Dumazet wrote:
>> On Fri, 2016-01-15 at 19:20 -0500, Craig Gallek wrote:
>>
>> > I wasn't able to reproduce this exact stack trace, but I was able to
>> > cause soft lockup messages with a fork bomb of your test program.  It
>> > is certainly related to my recent SO_REUSEPORT change (reverting it
>> > seems to fix the problem).  I haven't completely figured out the exact
>> > cause yet, though.  Could you please post your configuration and
>> > exactly how you are running this 'parallel loop'?
>>
>> There is a problem in the lookup functions (udp4_lib_lookup2() &
>> __udp4_lib_lookup())
>>
>> Because of RCU SLAB_DESTROY_BY_RCU semantics (check
>> Documentation/RCU/rculist_nulls.txt for some details), you should not
>> call reuseport_select_sock(sk, ...) without taking a stable reference on
>> the sk socket. (and checking the lookup keys again)
>>
>> This is because sk could be freed, re-used by a totally different UDP
>> socket on a different port, and the incoming frame(s) could be delivered
>> on the wrong socket/channel/application :(
>>
>> Note that we discussed some time ago to remove SLAB_DESTROY_BY_RCU for
>> UDP sockets (and freeing them after rcu grace period instead), so make
>> UDP rx path faster, as we would no longer need to increment/decrement
>> the socket refcount. This also would remove the added false sharing on
>> sk_refcnt for the case the UDP socket serves as a tunnel (up->encap_rcv
>> being non NULL)
>
> Hmm... not it looks you do the lookup , refcnt change, re-lookup just
> fine.
>
> The problem here is that UDP connected sockets update the
> sk->sk_incoming_cpu from __udp_queue_rcv_skb()
>
> This means that we can find the first socket in hash table with a
> matching incoming cpu, and badness == high_score + 1
>
> Then, the reuseport_select_sock() can selects another socket from the
> array (using bpf or the hash )
>
> We do the atomic_inc_not_zero_hint() to update sk_refcnt on the new
> socket, then compute_score2() returns high_score (< badness)
>
> So we loop back to the beginning of udp4_lib_lookup2(), and we loop
> forever (as long as the first socket in hash table has still this match
> about incoming cpu)
>
> In short, the recent SO_REUSE_PORT changes are not compatible with the
> SO_INCOMING_CPU ones, if connected UDP sockets are used.
>
> A fix could be to not check sk_incoming_cpu on connected sockets (this
> makes really little sense, as this option was meant to spread traffic on
> UDP _servers_ ). Also it collides with SO_REUSEPORT notion of a group of
> sockets having the same score.
>
> Dmitry, could you test it ? I could not get the trace you reported.

Thanks Eric, I'm still scratching my head over this one.  Your patches
make sense, but I don't think they solve this particular issue.  I was
still able to trigger the soft lockup with them applied.

I thought it has something to do with relying on RCU to dereference
the sk_reuseport_cb pointer from a soft interrupt.  As far as I can
tell, though, the only difference between rcu_dereference and
rcu_dereference_bh (and rcu_read_lock and rcu_read_lock_bh) is the
lock analysis code that gets compiled in in debug mode (in which case
we should almost certainly be using the bh versions of the rcu
functions).  However, I can still trigger the soft lookup even when I
completely remove the RCU functions and use the (racy) raw pointer.

Below is a stack with your patches applied and the RCU functions
completely removed.  I'm able to trigger it using a bunch of parallel
instances of Dmitry's test program running on separate CPU sockets (eg
for i in `seq 100`; do taskset -c 10,40 /tmp/rcu_stall & done)

[  508.633008] NMI watchdog: BUG: soft lockup - CPU#40 stuck for 22s!
[rcu_stall:179\
92]
[  508.633010] NMI watchdog: BUG: soft lockup - CPU#10 stuck for 22s!
[rcu_stall:147\
74]
[  508.633022] Modules linked in: w1_therm wire cdc_acm ehci_pci
ehci_hcd i2c_i801 m\
lx4_en ib_uverbs mlx4_ib ib_sa ib_mad ib_core ib_addr mlx4_core
xt_TCPMSS xt_tcpmss
[  508.633023] irq event stamp: 162291
[  508.633029] hardirqs last  enabled at (162290):
[<ffffffff817263d2>] restore_regs\
_and_iret+0x0/0x1d
[  508.633031] hardirqs last disabled at (162291):
[<ffffffff81726644>] apic_timer_i\
nterrupt+0x84/0x90
[  508.633034] softirqs last  enabled at (32): [<ffffffff8164a5e4>]
ip_finish_output\
2+0x214/0x570
[  508.633037] softirqs last disabled at (33): [<ffffffff8172754c>]
do_softirq_own_s\
tack+0x1c/0x30
[  508.633039] CPU: 10 PID: 14774 Comm: rcu_stall Tainted: G
  L  4.4.0-db\
x-DEV #44
[  508.633040] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.32.0 07/01/2015
[  508.633041] task: ffff880f375b8100 ti: ffff880f375bc000 task.ti:
ffff880f375bc000
[  508.633044] RIP: 0010:[<ffffffff81676c20>]  [<ffffffff81676c20>]
sock_put+0x0/0x2\
0
[  508.633045] RSP: 0018:ffff88103fb43aa0  EFLAGS: 00000217
[  508.633045] RAX: 00000000ffffffff RBX: 0000000000000002 RCX: ffff882023056b40
[  508.633046] RDX: 000000000000d933 RSI: 0000000000000003 RDI: ffff882023056ac0
[  508.633047] RBP: ffff88103fb43b18 R08: 000000000000caf3 R09: 0000000000000002
[  508.633048] R10: ffff88201bb8bac0 R11: 0000000000000002 R12: ffff88201bb8bad8
[  508.633048] R13: ffff882023056ac0 R14: ffffffff81ce7140 R15: 000000000100007f
[  508.633050] FS:  00007f79628c5700(0000) GS:ffff88103fb40000(0000)
knlGS:000000000\
0000000
[  508.633051] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  508.633052] CR2: 0000000020011b08 CR3: 0000000f3ec9e000 CR4: 00000000001406e0
[  508.633052] Stack:
[  508.633054]  ffffffff81679996 0000000000000002 ffff88201bb8bac0
000000000000562f
[  508.633056]  000033d900000000 000000010000caf3 0100007fcaf30246
000033d900000001
[  508.633058]  21da457200000000 ffff88103fb43b08 03fffffffe0739c5
ffffffff81ce7140
[  508.633059] Call Trace:
[  508.633061]  <IRQ>
[  508.633062]  [<ffffffff81679996>] ? udp4_lib_lookup2+0x246/0x320
[  508.633063]  [<ffffffff81679fab>] __udp4_lib_lookup+0x14b/0x5e0
[  508.633065]  [<ffffffff8167b3dd>] __udp4_lib_rcv+0x44d/0x860
[  508.633066]  [<ffffffff81644c3e>] ? ip_local_deliver_finish+0x3e/0x240
[  508.633067]  [<ffffffff8167bf5a>] udp_rcv+0x1a/0x20
[  508.633068]  [<ffffffff81644ca7>] ip_local_deliver_finish+0xa7/0x240
[  508.633069]  [<ffffffff81644c3e>] ? ip_local_deliver_finish+0x3e/0x240
[  508.633071]  [<ffffffff816455d0>] ip_local_deliver+0x60/0xd0
[  508.633072]  [<ffffffff81644c00>] ? inet_add_protocol+0x50/0x50
[  508.633073]  [<ffffffff81644f1d>] ip_rcv_finish+0xdd/0x550
[  508.633074]  [<ffffffff816458b9>] ip_rcv+0x279/0x3d0
[  508.633075]  [<ffffffff81644e40>] ? ip_local_deliver_finish+0x240/0x240
[  508.633079]  [<ffffffff815efa0e>] __netif_receive_skb_core+0x23e/0xae0
[  508.633080]  [<ffffffff815f0400>] ? process_backlog+0xe0/0x230
[  508.633081]  [<ffffffff815f02d1>] __netif_receive_skb+0x21/0x70
[  508.633082]  [<ffffffff815f039b>] process_backlog+0x7b/0x230
[  508.633083]  [<ffffffff815f0400>] ? process_backlog+0xe0/0x230
[  508.633085]  [<ffffffff815f2382>] ? net_rx_action+0xa2/0x3f0
[  508.633086]  [<ffffffff815f2439>] net_rx_action+0x159/0x3f0
[  508.633089]  [<ffffffff810c9b66>] __do_softirq+0xd6/0x420
[  508.633090]  [<ffffffff8164a5e4>] ? ip_finish_output2+0x214/0x570
[  508.633092]  [<ffffffff8172754c>] do_softirq_own_stack+0x1c/0x30
[  508.633093]  <EOI>
[  508.633093]  [<ffffffff810c9f65>] do_softirq+0x55/0x60
[  508.633094]  [<ffffffff810ca018>] __local_bh_enable_ip+0xa8/0xb0

[  508.633095]  [<ffffffff8164a60d>] ip_finish_output2+0x23d/0x570
[  508.633096]  [<ffffffff8164aa79>] ? ip_finish_output+0x139/0x250
[  508.633098]  [<ffffffff8164aa79>] ip_finish_output+0x139/0x250
[  508.633100]  [<ffffffff81637c95>] ? nf_hook_slow+0x5/0x190
[  508.633101]  [<ffffffff8164b7b6>] ip_output+0x76/0x120
[  508.633102]  [<ffffffff8164a940>] ? ip_finish_output2+0x570/0x570
[  508.633104]  [<ffffffff8164acd4>] ip_local_out+0x44/0x90
[  508.633105]  [<ffffffff8164c24d>] ip_send_skb+0x1d/0x50
[  508.633106]  [<ffffffff816774f3>] udp_send_skb+0x183/0x280
[  508.633108]  [<ffffffff815d79fe>] ? sk_dst_check+0x15e/0x1e0
[  508.633108]  [<ffffffff815d78a5>] ? sk_dst_check+0x5/0x1e0
[  508.633110]  [<ffffffff81648c90>] ? ip_setup_cork+0x130/0x130
[  508.633110]  [<ffffffff81678350>] udp_sendmsg+0x2d0/0xac0
[  508.633113]  [<ffffffff816879e5>] ? inet_sendmsg+0xd5/0x1e0
[  508.633114]  [<ffffffff81687915>] ? inet_sendmsg+0x5/0x1e0
[  508.633116]  [<ffffffff81687a28>] inet_sendmsg+0x118/0x1e0
[  508.633117]  [<ffffffff81687915>] ? inet_sendmsg+0x5/0x1e0
[  508.633119]  [<ffffffff815d2e76>] sock_sendmsg+0x46/0x50
[  508.633120]  [<ffffffff815d2f38>] sock_write_iter+0x78/0xd0
[  508.633123]  [<ffffffff8124270a>] __vfs_write+0xaa/0xe0
[  508.633124]  [<ffffffff81243c6a>] vfs_write+0xaa/0x1a0
[  508.633125]  [<ffffffff81243f92>] SyS_write+0x52/0xa0
[  508.633127]  [<ffffffff817258d7>] entry_SYSCALL_64_fastpath+0x12/0x6f
[  508.633140] Code: 55 81 fe 88 00 00 00 48 89 e5 74 10 83 fe 11 74
0b e8 05 69 fd \
ff 5d 0f 1f 40 00 c3 e8 5a fe ff ff 5d c3 0f 1f 84 00 00 00 00 00 <f0>
ff 8f 80 00 0\
0 00 74 01 c3 55 48 89 e5 e8 6d 2d f6 ff 5d c3
[  508.633141] Kernel panic - not syncing: softlockup: hung tasks
[  508.633142] CPU: 10 PID: 14774 Comm: rcu_stall Tainted: G
  L  4.4.0-db\
x-DEV #44
[  508.633143] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.32.0 07/01/2015
[  508.633144]  00000000000001c3 ffff88103fb43810 ffffffff8171a684
0000000000000001
[  508.633145]  ffffffff81a46e80 ffff88103fb43890 ffffffff8171595c
0000000000000001
[  508.633146]  0000000000000008 ffff88103fb438a0 ffff88103fb43840
ffff88103fb43890
[  508.633146] Call Trace:
[  508.633149]  <IRQ>  [<ffffffff8171a684>] dump_stack+0x4c/0x65
[  508.633152]  [<ffffffff8171595c>] panic+0xca/0x215
[  508.633155]  [<ffffffff8117fdd0>] watchdog_timer_fn+0x1d0/0x1d0
[  508.633157]  [<ffffffff8117fc00>] ? proc_watchdog_common+0x110/0x110
[  508.633159]  [<ffffffff8113ae73>] __hrtimer_run_queues+0x113/0x480
[  508.633160]  [<ffffffff8113b7bb>] hrtimer_interrupt+0xab/0x1c0
[  508.633161]  [<ffffffff817263d2>] ? retint_kernel+0x10/0x10
[  508.633164]  [<ffffffff810a5659>] local_apic_timer_interrupt+0x39/0x60
[  508.633165]  [<ffffffff81728075>] smp_apic_timer_interrupt+0x45/0x60
[  508.633166]  [<ffffffff81726649>] apic_timer_interrupt+0x89/0x90
[  508.633167]  [<ffffffff81676c20>] ? udp_getsockopt+0x30/0x30
[  508.633168]  [<ffffffff81679996>] ? udp4_lib_lookup2+0x246/0x320
[  508.633170]  [<ffffffff81679fab>] __udp4_lib_lookup+0x14b/0x5e0
[  508.633171]  [<ffffffff8167b3dd>] __udp4_lib_rcv+0x44d/0x860
[  508.633172]  [<ffffffff81644c3e>] ? ip_local_deliver_finish+0x3e/0x240
[  508.633173]  [<ffffffff8167bf5a>] udp_rcv+0x1a/0x20
[  508.633174]  [<ffffffff81644ca7>] ip_local_deliver_finish+0xa7/0x240
[  508.633175]  [<ffffffff81644c3e>] ? ip_local_deliver_finish+0x3e/0x240
[  508.633176]  [<ffffffff816455d0>] ip_local_deliver+0x60/0xd0
[  508.633177]  [<ffffffff81644c00>] ? inet_add_protocol+0x50/0x50
[  508.633178]  [<ffffffff81644f1d>] ip_rcv_finish+0xdd/0x550
[  508.633179]  [<ffffffff816458b9>] ip_rcv+0x279/0x3d0
[  508.633180]  [<ffffffff81644e40>] ? ip_local_deliver_finish+0x240/0x240
[  508.633182]  [<ffffffff815efa0e>] __netif_receive_skb_core+0x23e/0xae0
[  508.633183]  [<ffffffff815f0400>] ? process_backlog+0xe0/0x230
[  508.633184]  [<ffffffff815f02d1>] __netif_receive_skb+0x21/0x70
[  508.633185]  [<ffffffff815f039b>] process_backlog+0x7b/0x230
