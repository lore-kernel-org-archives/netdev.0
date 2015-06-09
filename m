From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: Force updating pcount after skb_pull()
 during mtu probing
Date: Tue, 09 Jun 2015 10:06:25 -0700
Message-ID: <1433869585.29864.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433551592-3596877-1-git-send-email-kafai@fb.com>
	 <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150608175833.GB390474@devbig242.prn2.facebook.com>
	 <1433787073.29864.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:35155 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbbFIRWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:22:54 -0400
Received: by yhak3 with SMTP id k3so10095399yha.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 10:22:53 -0700 (PDT)
In-Reply-To: <1433787073.29864.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-08 at 11:11 -0700, Eric Dumazet wrote:
> On Mon, 2015-06-08 at 10:58 -0700, Martin KaFai Lau wrote:
> 
> > It seems the invariant does not hold at this point also.
> > Should the invariant fix be something for net-next? or Would you like
> > to post a patch for it?
> 
> This patch definitely can target net-next, it is not a new regression.
> 
> Once fully tested, we can ask David to submit a stable version later.
> 
> Yes, I can provide a v3, probably at the end of today.

I've been working on this, but still can get the bug triggering in
tcp_fragment(), no matter what (Neal patch , yours, mine...)

I suspect a problem in skb_shift() or tcp_shifted_skb() and am doing
additional tests.

[ 1806.206345] ------------[ cut here ]------------
[ 1806.206359] WARNING: CPU: 19 PID: 0 at net/ipv4/tcp_output.c:1159 tcp_fragment+0x2b0/0x2d0()
[ 1806.206360] Modules linked in: ip_gre gre sit ip_tunnel tunnel4 bonding w1_therm wire cdc_acm ehci_pci ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid ib_uverbs mlx4_ib ib_sa ib_mad ib_core ib_addr ip6table_mangle ip6_tables ipv6
[ 1806.206376] CPU: 19 PID: 0 Comm: swapper/19 Tainted: G        W       4.1.0-smp-DEV #1762
[ 1806.206378]  ffffffff8196ba4b ffff88407fae38f8 ffffffff81643125 00000000000000dd
[ 1806.206380]  0000000000000000 ffff88407fae3938 ffffffff810a8c97 ffff88407fae3998
[ 1806.206382]  ffff883f75498200 ffff881fe1d5f800 000000000000000d 0000000000004802
[ 1806.206384] Call Trace:
[ 1806.206385]  <IRQ>  [<ffffffff81643125>] dump_stack+0x45/0x57
[ 1806.206395]  [<ffffffff810a8c97>] warn_slowpath_common+0x97/0xe0
[ 1806.206396]  [<ffffffff810a8cfa>] warn_slowpath_null+0x1a/0x20
[ 1806.206398]  [<ffffffff815df0c0>] tcp_fragment+0x2b0/0x2d0
[ 1806.206400]  [<ffffffff815d62e1>] tcp_mark_head_lost+0x191/0x280
[ 1806.206402]  [<ffffffff815d641d>] tcp_update_scoreboard+0x4d/0x80
[ 1806.206404]  [<ffffffff815daa24>] tcp_fastretrans_alert+0x6e4/0xc20
[ 1806.206406]  [<ffffffff815dbcef>] tcp_ack+0xb0f/0x13c0
[ 1806.206408]  [<ffffffff815dcc31>] tcp_rcv_established+0x311/0x820
[ 1806.206410]  [<ffffffff815e79cb>] tcp_v4_do_rcv+0x14b/0x3d0
[ 1806.206414]  [<ffffffff812f15e6>] ? security_sock_rcv_skb+0x16/0x20
[ 1806.206415]  [<ffffffff815e8e46>] tcp_v4_rcv+0x8c6/0x9d0
[ 1806.206418]  [<ffffffff815c1dec>] ip_local_deliver_finish+0xac/0x230
[ 1806.206419]  [<ffffffff815c216a>] ip_local_deliver+0xaa/0xc0
[ 1806.206421]  [<ffffffff815c1d40>] ? ip_rcv_finish+0x380/0x380
[ 1806.206422]  [<ffffffff815c1a48>] ip_rcv_finish+0x88/0x380
[ 1806.206423]  [<ffffffff815c2487>] ip_rcv+0x307/0x420
[ 1806.206426]  [<ffffffff815c19c0>] ? inet_add_protocol+0x50/0x50
[ 1806.206431]  [<ffffffff8157cc0c>] __netif_receive_skb_core+0x5bc/0xa30
[ 1806.206432]  [<ffffffff8157d0a6>] __netif_receive_skb+0x26/0x70
[ 1806.206434]  [<ffffffff8157d180>] process_backlog+0x90/0x130
[ 1806.206436]  [<ffffffff8157d9a7>] net_rx_action+0x157/0x330
[ 1806.206439]  [<ffffffff810ac9c7>] __do_softirq+0xe7/0x270
[ 1806.206441]  [<ffffffff810acd85>] irq_exit+0xa5/0xb0
[ 1806.206445]  [<ffffffff8108aa65>] smp_call_function_single_interrupt+0x35/0x40
[ 1806.206448]  [<ffffffff8164ae2b>] call_function_single_interrupt+0x6b/0x70
