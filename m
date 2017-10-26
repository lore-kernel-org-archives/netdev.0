From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of
 net/ipv4/tcp_input.c
Date: Wed, 25 Oct 2017 19:07:26 -0700
Message-ID: <20171026020724.bgobtktvcpkhco4h@ast-mbp>
References: <20170921014620.GA20906@castle>
 <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
 <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com>
 <2325466.Xo6SG5M5hd@natalenko.name>
 <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>,
        Roman Gushchin <guro@fb.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>, brakmo@fb.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:47069 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZCHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 22:07:30 -0400
Received: by mail-pf0-f193.google.com with SMTP id p87so1368164pfj.3
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 19:07:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 04:36:58PM -0700, Yuchung Cheng wrote:
> On Thu, Sep 28, 2017 at 1:14 AM, Oleksandr Natalenko
> <oleksandr@natalenko.name> wrote:
> > Hi.
> >
> > Won't tell about panic in tcp_sacktag_walk() since I cannot trigger it
> > intentionally, but setting net.ipv4.tcp_retrans_collapse to 0 *does not* fix
> > warning in tcp_fastretrans_alert() for me.
> 
> Hi Oleksandr: no retrans_collapse should not matter for that warning
> in tcp_fstretrans_alert(). the warning as I explained earlier is
> likely false. Neal and I are more concerned the panic in
> tcp_sacktag_walk. This is just a blind shot but thx for retrying.
> 
> We can submit a one-liner to remove the fast retrans warning but want
> to nail the bigger issue first.

we're still seeing the warnings followed by crashes and it's very concerning.
We hoped that most recent Neal's patches from Sep 18 around this area may
magically fix the issue, but no. The panics are still there.
It's confirmed that net.ipv4.tcp_retrans_collapse=0 does not help
whereas net.ipv4.tcp_recovery=0 works, but obviously undesirable.
We're out of ideas on how to debug this.

Warning + panic:
[ 7678.309043] Call Trace:
[ 7678.313925]  <IRQ>
[ 7678.317955]  dump_stack+0x4d/0x70
[ 7678.324573]  __warn+0xd3/0xf0
[ 7678.330497]  warn_slowpath_null+0x1e/0x20
[ 7678.338510]  tcp_fastretrans_alert+0xacf/0xbd0
[ 7678.347380]  tcp_ack+0xbce/0x1390
[ 7678.354006]  tcp_rcv_established+0x1ce/0x740
[ 7678.362536]  tcp_v6_do_rcv+0x15b/0x400
[ 7678.370025]  tcp_v6_rcv+0x94c/0x9f0
[ 7678.376989]  ? tcp_rcv_established+0x42b/0x740
[ 7678.385866]  ip6_input_finish+0xea/0x430
[ 7678.393702]  ip6_input+0x32/0xa0
[ 7678.400155]  ? ip6_rcv_finish+0xa0/0xa0
[ 7678.407834]  ip6_rcv_finish+0x4b/0xa0
[ 7678.415164]  ipv6_rcv+0x2ec/0x4f0
[ 7678.421778]  ? ip6_make_skb+0x1c0/0x1c0
[ 7678.429447]  __netif_receive_skb_core+0x2d5/0x9a0
[ 7678.438845]  ? tcp6_gro_receive+0x11d/0x1c0
[ 7678.447211]  ? ipv6_gro_receive+0x1d0/0x380
[ 7678.455566]  __netif_receive_skb+0x16/0x70
[ 7678.463748]  netif_receive_skb_internal+0x32/0x3b0
[ 7678.473318]  ? dev_gro_receive+0x27c/0x470
[ 7678.481502]  napi_gro_receive+0x113/0x1d0
[ 7678.489510]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[ 7678.499077]  mlx5e_poll_rx_cq+0x79/0x830
[ 7678.506911]  mlx5e_napi_poll+0x8c/0x3d0
[ 7678.514579]  ? mlx5_cq_completion+0x54/0xb0
[ 7678.522950]  net_rx_action+0x22e/0x380
[ 7678.530450]  __do_softirq+0x106/0x2e8
[ 7678.537768]  irq_exit+0xb0/0xc0
[ 7678.544042]  do_IRQ+0x4f/0xd0
[ 7678.549970]  common_interrupt+0x86/0x86
...
[ 7685.690697] BUG: unable to handle kernel 
[ 7685.698737] NULL pointer dereference
[ 7685.705889]  at 0000000000000035
[ 7685.712357] IP: tcp_sacktag_walk+0xfd/0x460
[ 7685.720726] PGD 1002d75067 
[ 7685.726320] PUD 102c506067 
[ 7685.731902] PMD 0 
...
[ 7686.070541] task: ffff880ff5959b00 task.stack: ffffc90024708000
[ 7686.082363] RIP: 0010:tcp_sacktag_walk+0xfd/0x460
[ 7686.091754] RSP: 0000:ffff88203eec38b0 EFLAGS: 00010217
[ 7686.102188] RAX: ffff881953620a00 RBX: ffff881009273200 RCX: 00000000fbfa50ec
[ 7686.116439] RDX: 00000000fbfa54a0 RSI: 0000000000000000 RDI: ffff881009273200
[ 7686.130688] RBP: ffff88203eec3908 R08: 0000000000000048 R09: 00000000fbfa55fb
[ 7686.144936] R10: 0000000000000000 R11: 0000000000000000 R12: ffff881ec9ff98c0
[ 7686.159184] R13: ffff88203eec3a10 R14: 0000000000000000 R15: ffff881ec9ff9a18
[ 7686.173431] FS:  00007f2b235ff700(0000) GS:ffff88203eec0000(0000) knlGS:0000000000000000
[ 7686.189589] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7686.201062] CR2: 0000000000000035 CR3: 0000000fd8229000 CR4: 00000000003406e0
[ 7686.215310] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 7686.229560] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 7686.243807] Call Trace:
[ 7686.248696]  <IRQ>
[ 7686.252727]  tcp_sacktag_write_queue+0x5ff/0x9e0
[ 7686.261943]  tcp_ack+0x677/0x1390
[ 7686.268569]  ? select_task_rq_fair+0x9e3/0xf70
[ 7686.277437]  ? tcp_write_xmit+0x230/0x10a0
[ 7686.285619]  tcp_rcv_established+0x1ce/0x740
[ 7686.294151]  tcp_v6_do_rcv+0x15b/0x400
[ 7686.301636]  tcp_v6_rcv+0x94c/0x9f0
[ 7686.308606]  ? default_wake_function+0x12/0x20
[ 7686.317483]  ? __wake_up_common+0x53/0x90
[ 7686.325492]  ip6_input_finish+0xea/0x430
[ 7686.333329]  ip6_input+0x32/0xa0
[ 7686.339791]  ? ip6_rcv_finish+0xa0/0xa0
[ 7686.347451]  ip6_rcv_finish+0x4b/0xa0
[ 7686.354767]  ipv6_rcv+0x2ec/0x4f0
[ 7686.361389]  ? ip6_make_skb+0x1c0/0x1c0
[ 7686.369050]  __netif_receive_skb_core+0x2d5/0x9a0
[ 7686.378449]  ? tcp6_gro_receive+0x11d/0x1c0
[ 7686.386797]  ? ipv6_gro_receive+0x1d0/0x380
[ 7686.395160]  __netif_receive_skb+0x16/0x70
[ 7686.403342]  netif_receive_skb_internal+0x32/0x3b0
[ 7686.412931]  ? dev_gro_receive+0x27c/0x470
[ 7686.421110]  napi_gro_receive+0x113/0x1d0
[ 7686.429136]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[ 7686.438722]  mlx5e_poll_rx_cq+0x79/0x830
[ 7686.446572]  mlx5e_napi_poll+0x8c/0x3d0
[ 7686.454233]  ? mlx5_cq_completion+0x54/0xb0
[ 7686.462591]  net_rx_action+0x22e/0x380
[ 7686.470099]  __do_softirq+0x106/0x2e8
[ 7686.477431]  irq_exit+0xb0/0xc0
[ 7686.483700]  do_IRQ+0x4f/0xd0
[ 7686.489629]  common_interrupt+0x86/0x86

Sometimes soft lockup is also seen:

[2676627.345885] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:0]
[2676627.717771] RIP: 0010:queued_spin_lock_slowpath+0x15c/0x180
[2676627.729239] RSP: 0018:ffff88103f603e78 EFLAGS: 00000202
[2676627.740019]  ORIG_RAX: ffffffffffffff10
[2676627.748027] RAX: 0000000000000101 RBX: ffff8811181d8840 RCX: 0000000000000101
[2676627.762622] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffff8811181d88c8
[2676627.777217] RBP: ffff88103f603e88 R08: 0000000000000001 R09: ffff88103f95a800
[2676627.791811] R10: 0000000000037a13 R11: 000000001a37bb20 R12: 0000000000000100
[2676627.806405] R13: ffff8811181d8c18 R14: ffffffff81857270 R15: ffff8811181d8840
[2676627.821000] FS:  0000000000000000(0000) GS:ffff88103f600000(0000) knlGS:0000000000000000
[2676627.837500] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2676627.849318] CR2: 00007f6e44c1f000 CR3: 0000000001e09000 CR4: 00000000003406f0
[2676627.863916] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[2676627.878508] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[2676627.893103] Call Trace:
[2676627.898338]  <IRQ>
[2676627.902711]  ? _raw_spin_lock+0x21/0x30
[2676627.910715]  tcp_write_timer+0x19/0x70
[2676627.918548]  call_timer_fn+0x35/0x150
[2676627.926214]  run_timer_softirq+0x1be/0x3e0
[2676627.934742]  ? timerqueue_add+0x59/0xb0
[2676627.942745]  ? ktime_get+0x3c/0xb0
[2676627.949889]  __do_softirq+0x106/0x2e8
[2676627.957551]  irq_exit+0xb0/0xc0
[2676627.964174]  smp_apic_timer_interrupt+0x68/0x90
[2676627.973563]  apic_timer_interrupt+0x86/0x90
[2676628.084861] NMI watchdog: BUG: soft lockup - CPU#11 stuck for 21s! [swapper/11:0]
[2676628.084896] RIP: 0010:tcp_match_skb_to_sack+0x2d/0xb0
[2676628.084897] RSP: 0018:ffff88103f8c38a8 EFLAGS: 00000297
[2676628.084897]  ORIG_RAX: ffffffffffffff10
[2676628.084898] RAX: 0000000000000000 RBX: ffff88010f9dbb18 RCX: 000000002d5da350
[2676628.084899] RDX: 000000002d5da141 RSI: ffff88010f9dbb18 RDI: ffff8811181d8840
[2676628.084899] RBP: ffff88103f8c3908 R08: 00000000ffffffff R09: 00000000d2a25ebe
[2676628.084900] R10: 000000000000e323 R11: ffff8811181d8998 R12: ffff8811181d8840
[2676628.084900] R13: ffff88103f8c3a10 R14: 0000000000000000 R15: ffff8811181d8998
[2676628.084901] FS:  0000000000000000(0000) GS:ffff88103f8c0000(0000) knlGS:0000000000000000
[2676628.084902] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2676628.084903] CR2: 00007fbc07410000 CR3: 0000000001e09000 CR4: 00000000003406e0
[2676628.084903] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[2676628.084904] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[2676628.084904] Call Trace:
[2676628.084905]  <IRQ>
[2676628.084907]  ? tcp_sacktag_walk+0x270/0x460
[2676628.084909]  tcp_sacktag_write_queue+0x5ff/0x9e0
[2676628.084911]  tcp_ack+0x677/0x1390
[2676628.084913]  ? tcp_write_xmit+0x230/0x10a0
[2676628.084915]  tcp_rcv_established+0x1ce/0x740
[2676628.084919]  tcp_v6_do_rcv+0x15b/0x400
[2676628.084921]  tcp_v6_rcv+0x94c/0x9f0
[2676628.084924]  ? __dev_queue_xmit+0x251/0x650
[2676628.084928]  ip6_input_finish+0xea/0x430
[2676628.084930]  ip6_input+0x32/0xa0
[2676628.084932]  ? ip6_rcv_finish+0xa0/0xa0
[2676628.084933]  ip6_rcv_finish+0x4b/0xa0
[2676628.084935]  ipv6_rcv+0x2ec/0x4f0
[2676628.084937]  ? ip6_make_skb+0x1c0/0x1c0
[2676628.084938]  __netif_receive_skb_core+0x2d5/0x9a0
[2676628.084941]  ? tcp6_gro_receive+0x11d/0x1c0
[2676628.084943]  ? ipv6_gro_receive+0x1d0/0x380
[2676628.084944]  __netif_receive_skb+0x16/0x70
[2676628.084945]  netif_receive_skb_internal+0x32/0x3b0
[2676628.084947]  ? dev_gro_receive+0x27c/0x470
[2676628.084948]  napi_gro_receive+0x113/0x1d0
[2676628.084952]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[2676628.084954]  mlx5e_poll_rx_cq+0x79/0x830
[2676628.084956]  mlx5e_napi_poll+0x8c/0x3d0
[2676628.084959]  ? mlx5_cq_completion+0x54/0xb0
[2676628.084960]  net_rx_action+0x22e/0x380
[2676628.084962]  __do_softirq+0x106/0x2e8
[2676628.084965]  irq_exit+0xb0/0xc0
[2676628.084967]  do_IRQ+0x4f/0xd0
[2676656.083964] NMI watchdog: BUG: soft lockup - CPU#11 stuck for 23s! [swapper/11:0]
[2676656.083992] RIP: 0010:tcp_sacktag_walk+0x25f/0x460
[2676656.083993] RSP: 0018:ffff88103f8c38b0 EFLAGS: 00000207
[2676656.083993]  ORIG_RAX: ffffffffffffff10
[2676656.083994] RAX: 0000000000021500 RBX: ffff8810d84c3600 RCX: 000000002d5d9e41
[2676656.083994] RDX: 00000000f15de229 RSI: ffff8810d84c0200 RDI: ffff8811181d8840
[2676656.083995] RBP: ffff88103f8c3908 R08: 000000000000ff21 R09: 0000000000000000
[2676656.083996] R10: 000000000000e323 R11: ffff8811181d8998 R12: ffff8811181d8840
[2676656.083996] R13: ffff88103f8c3a10 R14: 0000000000000000 R15: ffff8811181d8998
[2676656.083997] FS:  0000000000000000(0000) GS:ffff88103f8c0000(0000) knlGS:0000000000000000
[2676656.083998] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2676656.083998] CR2: 00007fbc07410000 CR3: 0000000001e09000 CR4: 00000000003406e0
[2676656.083999] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[2676656.083999] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[2676656.084000] Call Trace:
[2676656.084001]  <IRQ>
[2676656.084003]  tcp_sacktag_write_queue+0x5ff/0x9e0
[2676656.084005]  tcp_ack+0x677/0x1390
[2676656.084007]  ? tcp_write_xmit+0x230/0x10a0
[2676656.084009]  tcp_rcv_established+0x1ce/0x740
[2676656.084013]  tcp_v6_do_rcv+0x15b/0x400
[2676656.084015]  tcp_v6_rcv+0x94c/0x9f0
[2676656.084018]  ? __dev_queue_xmit+0x251/0x650
[2676656.084022]  ip6_input_finish+0xea/0x430
[2676656.084024]  ip6_input+0x32/0xa0
[2676656.084026]  ? ip6_rcv_finish+0xa0/0xa0
[2676656.084027]  ip6_rcv_finish+0x4b/0xa0
[2676656.084029]  ipv6_rcv+0x2ec/0x4f0
[2676656.084031]  ? ip6_make_skb+0x1c0/0x1c0
[2676656.084032]  __netif_receive_skb_core+0x2d5/0x9a0
[2676656.084035]  ? tcp6_gro_receive+0x11d/0x1c0
[2676656.084037]  ? ipv6_gro_receive+0x1d0/0x380
[2676656.084038]  __netif_receive_skb+0x16/0x70
[2676656.084039]  netif_receive_skb_internal+0x32/0x3b0
[2676656.084041]  ? dev_gro_receive+0x27c/0x470
[2676656.084042]  napi_gro_receive+0x113/0x1d0
[2676656.084046]  mlx5e_handle_rx_cqe_mpwrq+0x5b6/0x8d0
[2676656.084048]  mlx5e_poll_rx_cq+0x79/0x830
[2676656.084050]  mlx5e_napi_poll+0x8c/0x3d0

Any help greatly appreciated.
