From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 11:03:20 -0700
Message-ID: <1369764200.3301.551.camel@edumazet-glaptop>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
	 <20130527224149.GA4384@electric-eye.fr.zoreil.com>
	 <51A4D4AD.2010507@candelatech.com>
	 <20130528161518.GC11614@optiplex.redhat.com>
	 <1369758577.3301.543.camel@edumazet-glaptop>
	 <20130528174304.GD11614@optiplex.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Francois Romieu <romieu@fr.zoreil.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Rafael Aquini <aquini@redhat.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130528174304.GD11614@optiplex.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-28 at 14:43 -0300, Rafael Aquini wrote:

> Perhaps the explanation is because we're looking into old stuff bad effects,
> then. But just to list a few for your appreciation:
> --------------------------------------------------------
> Apr 23 11:25:31 217-IDC kernel: httpd: page allocation failure. order:1,
> mode:0x20 Apr 23 11:25:31 217-IDC kernel: Pid: 19747, comm: httpd Not tainted
> 2.6.32-358.2.1.el6.x86_64 #1 Apr 23 11:25:31 217-IDC kernel: Call Trace: Apr 23
> 11:25:31 217-IDC kernel: <IRQ> [<ffffffff8112c207>] ?
> __alloc_pages_nodemask+0x757/0x8d0 Apr 23 11:25:31 217-IDC kernel:
> [<ffffffffa0337361>] ? bond_start_xmit+0x2f1/0x5d0 [bonding]
> ....
> --------------------------------------------------------
> Apr  4 18:51:32 exton kernel: swapper: page allocation failure. order:1,
> mode:0x20
> Apr  4 18:51:32 exton kernel: Pid: 0, comm: swapper Not tainted
> 2.6.32-279.19.1.el6.x86_64 #1
> Apr  4 18:51:32 exton kernel: Call Trace:
> Apr  4 18:51:32 exton kernel: <IRQ>  [<ffffffff811231ff>] ?
> __alloc_pages_nodemask+0x77f/0x940
> Apr  4 18:51:32 exton kernel: [<ffffffff8115d1a2>] ? kmem_getpages+0x62/0x170
> Apr  4 18:51:32 exton kernel: [<ffffffff8115ddba>] ? fallback_alloc+0x1ba/0x270
> Apr  4 18:51:32 exton kernel: [<ffffffff8115d80f>] ? cache_grow+0x2cf/0x320
> Apr  4 18:51:32 exton kernel: [<ffffffff8115db39>] ?
> ____cache_alloc_node+0x99/0x160
> Apr  4 18:51:32 exton kernel: [<ffffffff8115ed00>] ?
> kmem_cache_alloc_node_trace+0x90/0x200
> Apr  4 18:51:32 exton kernel: [<ffffffff8115ef1d>] ? __kmalloc_node+0x4d/0x60
> Apr  4 18:51:32 exton kernel: [<ffffffff8141ea1d>] ? __alloc_skb+0x6d/0x190
> Apr  4 18:51:32 exton kernel: [<ffffffff8141eb5d>] ? dev_alloc_skb+0x1d/0x40
> Apr  4 18:51:32 exton kernel: [<ffffffffa04f5f50>] ?
> ipoib_cm_alloc_rx_skb+0x30/0x430 [ib_ipoib]
> Apr  4 18:51:32 exton kernel: [<ffffffffa04f71ef>] ?
> ipoib_cm_handle_rx_wc+0x29f/0x770 [ib_ipoib]
> Apr  4 18:51:32 exton kernel: [<ffffffffa03c6a46>] ? mlx4_ib_poll_cq+0x2c6/0x7f0
> [mlx4_ib]
> ....
> ----


This one seems a real bug/problem in
drivers/infiniband/ulp/ipoib/ipoib_cm.c

It uses :

IPOIB_CM_HEAD_SIZE    = IPOIB_CM_BUF_SIZE % PAGE_SIZE, 
IPOIB_CM_RX_SG        = ALIGN(IPOIB_CM_BUF_SIZE, PAGE_SIZE) /
PAGE_SIZE, 

but then, ipoib_cm_alloc_rx_skb() does :

skb = dev_alloc_skb(IPOIB_CM_HEAD_SIZE + 12);

so really asking more than one page for the first frag (skb->head),
while the intent of the code was to use order-0 allocations.

 for (i = 0; i < frags; i++) {
    struct page *page = alloc_page(GFP_ATOMIC);
....

Ideally, IPOIB_CM_HEAD_SIZE  should be redefined to use

SKB_MAX_HEAD(NET_SKB_PAD + 12)

so that skb->head would use exactly oder-0 page, not order-1 one.


Do you know understand why we should not hide allocation errors ?
