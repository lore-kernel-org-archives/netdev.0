From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 14:43:05 -0300
Message-ID: <20130528174304.GD11614@optiplex.redhat.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
 <20130527224149.GA4384@electric-eye.fr.zoreil.com>
 <51A4D4AD.2010507@candelatech.com>
 <20130528161518.GC11614@optiplex.redhat.com>
 <1369758577.3301.543.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Francois Romieu <romieu@fr.zoreil.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369758577.3301.543.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 09:29:37AM -0700, Eric Dumazet wrote:
> On Tue, 2013-05-28 at 13:15 -0300, Rafael Aquini wrote:
> 
> > The real problem seems to be that more and more the network stack (drivers, perhaps)
> > is relying on chunks of contiguous page-blocks without a fallback mechanism to
> > order-0 page allocations. When memory gets fragmented, these alloc failures
> > start to pop up more often and they scare ordinary sysadmins out of their paints.
> > 
> 
> Where do you see that ?
>
> I see exactly the opposite trend. 
> 
> We have less and less buggy drivers, and we want to catch last
> offenders.
> 

Perhaps the explanation is because we're looking into old stuff bad effects,
then. But just to list a few for your appreciation:
--------------------------------------------------------
Apr 23 11:25:31 217-IDC kernel: httpd: page allocation failure. order:1,
mode:0x20 Apr 23 11:25:31 217-IDC kernel: Pid: 19747, comm: httpd Not tainted
2.6.32-358.2.1.el6.x86_64 #1 Apr 23 11:25:31 217-IDC kernel: Call Trace: Apr 23
11:25:31 217-IDC kernel: <IRQ> [<ffffffff8112c207>] ?
__alloc_pages_nodemask+0x757/0x8d0 Apr 23 11:25:31 217-IDC kernel:
[<ffffffffa0337361>] ? bond_start_xmit+0x2f1/0x5d0 [bonding]
....
--------------------------------------------------------
Apr  4 18:51:32 exton kernel: swapper: page allocation failure. order:1,
mode:0x20
Apr  4 18:51:32 exton kernel: Pid: 0, comm: swapper Not tainted
2.6.32-279.19.1.el6.x86_64 #1
Apr  4 18:51:32 exton kernel: Call Trace:
Apr  4 18:51:32 exton kernel: <IRQ>  [<ffffffff811231ff>] ?
__alloc_pages_nodemask+0x77f/0x940
Apr  4 18:51:32 exton kernel: [<ffffffff8115d1a2>] ? kmem_getpages+0x62/0x170
Apr  4 18:51:32 exton kernel: [<ffffffff8115ddba>] ? fallback_alloc+0x1ba/0x270
Apr  4 18:51:32 exton kernel: [<ffffffff8115d80f>] ? cache_grow+0x2cf/0x320
Apr  4 18:51:32 exton kernel: [<ffffffff8115db39>] ?
____cache_alloc_node+0x99/0x160
Apr  4 18:51:32 exton kernel: [<ffffffff8115ed00>] ?
kmem_cache_alloc_node_trace+0x90/0x200
Apr  4 18:51:32 exton kernel: [<ffffffff8115ef1d>] ? __kmalloc_node+0x4d/0x60
Apr  4 18:51:32 exton kernel: [<ffffffff8141ea1d>] ? __alloc_skb+0x6d/0x190
Apr  4 18:51:32 exton kernel: [<ffffffff8141eb5d>] ? dev_alloc_skb+0x1d/0x40
Apr  4 18:51:32 exton kernel: [<ffffffffa04f5f50>] ?
ipoib_cm_alloc_rx_skb+0x30/0x430 [ib_ipoib]
Apr  4 18:51:32 exton kernel: [<ffffffffa04f71ef>] ?
ipoib_cm_handle_rx_wc+0x29f/0x770 [ib_ipoib]
Apr  4 18:51:32 exton kernel: [<ffffffffa03c6a46>] ? mlx4_ib_poll_cq+0x2c6/0x7f0
[mlx4_ib]
....
--------------------------------------------------------
May 14 09:00:34 ifil03 kernel: swapper: page allocation failure. order:1,
mode:0x20
May 14 09:00:34 ifil03 kernel: Pid: 0, comm: swapper Not tainted
2.6.32-220.el6.x86_64 #1
May 14 09:00:34 ifil03 kernel: Call Trace:
May 14 09:00:34 ifil03 kernel: <IRQ>  [<ffffffff81123f0f>] ?
__alloc_pages_nodemask+0x77f/0x940
May 14 09:00:34 ifil03 kernel: [<ffffffff8115ddc2>] ? kmem_getpages+0x62/0x170
May 14 09:00:34 ifil03 kernel: [<ffffffff8115e9da>] ? fallback_alloc+0x1ba/0x270
May 14 09:00:34 ifil03 kernel: [<ffffffff8115e42f>] ? cache_grow+0x2cf/0x320
May 14 09:00:34 ifil03 kernel: [<ffffffff8115e759>] ?
____cache_alloc_node+0x99/0x160
May 14 09:00:34 ifil03 kernel: [<ffffffff8115f53b>] ?
kmem_cache_alloc+0x11b/0x190
May 14 09:00:34 ifil03 kernel: [<ffffffff8141f528>] ? sk_prot_alloc+0x48/0x1c0
May 14 09:00:34 ifil03 kernel: [<ffffffff8141f7b2>] ? sk_clone+0x22/0x2e0
May 14 09:00:34 ifil03 kernel: [<ffffffff8146ca26>] ? inet_csk_clone+0x16/0xd0
May 14 09:00:34 ifil03 kernel: [<ffffffff814858f3>] ?
tcp_create_openreq_child+0x23/0x450
May 14 09:00:34 ifil03 kernel: [<ffffffff814832dd>] ?
tcp_v4_syn_recv_sock+0x4d/0x2a0
May 14 09:00:34 ifil03 kernel: [<ffffffff814856b1>] ? tcp_check_req+0x201/0x420
May 14 09:00:34 ifil03 kernel: [<ffffffff8147b166>] ?
tcp_rcv_state_process+0x116/0xa30
May 14 09:00:34 ifil03 kernel: [<ffffffff81482cfb>] ? tcp_v4_do_rcv+0x35b/0x430
May 14 09:00:34 ifil03 kernel: [<ffffffff81484471>] ? tcp_v4_rcv+0x4e1/0x860
May 14 09:00:34 ifil03 kernel: [<ffffffff814621fd>] ?
ip_local_deliver_finish+0xdd/0x2d0
May 14 09:00:34 ifil03 kernel: [<ffffffff81462488>] ? ip_local_deliver+0x98/0xa0
May 14 09:00:34 ifil03 kernel: [<ffffffff8146194d>] ? ip_rcv_finish+0x12d/0x440
May 14 09:00:34 ifil03 kernel: [<ffffffff8101bd86>] ?
intel_pmu_enable_all+0xa6/0x150
May 14 09:00:34 ifil03 kernel: [<ffffffff81461ed5>] ? ip_rcv+0x275/0x350
May 14 09:00:34 ifil03 kernel: [<ffffffff8142bedb>] ?
__netif_receive_skb+0x49b/0x6e0
May 14 09:00:34 ifil03 kernel: [<ffffffff8142df88>] ?
netif_receive_skb+0x58/0x60
May 14 09:00:34 ifil03 kernel: [<ffffffffa00a0a9e>] ?
vmxnet3_rq_rx_complete+0x36e/0x880 [vmxnet3]
....
--------------------------------------------------------


 
> > The big point of this change was to attempt to relief some of these warnings 
> > which we believed as being useless, since the net stack would recover from it
> > by re-transmissions.
> > We might have misjudged the scenario, though. Perhaps a better approach would be
> > making the warning less verbose for all page-alloc failures. We could, perhaps,
> > only print a stack-dump out, if some debug flag is passed along, either as
> > reference, or by some CONFIG_DEBUG_ preprocessor directive.
> 
> 
> warn_alloc_failed() uses the standard DEFAULT_RATELIMIT_INTERVAL which
> is very small (5 * HZ)
> 
> I would bump nopage_rs to somethin more reasonable, like one hour or one
> day.
>

Neat! Worth to try, no doubts about that. Aaron?

Cheers!
-- Rafael 
