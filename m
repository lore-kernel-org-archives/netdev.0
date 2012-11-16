From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Fri, 16 Nov 2012 10:18:40 -0500
Message-ID: <20121116151840.GE22320@phenom.dumpdata.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27147 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073Ab2KPPSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 10:18:50 -0500
Content-Disposition: inline
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
> This patch implements persistent grants for xen-netfront/netback. This
> mechanism maintains page pools in netback/netfront, these page pools is used to
> save grant pages which are mapped. This way improve performance which is wasted
> when doing grant operations.
> 
> Current netback/netfront does map/unmap grant operations frequently when
> transmitting/receiving packets, and grant operations costs much cpu clock. In
> this patch, netfront/netback maps grant pages when needed and then saves them
> into a page pool for future use. All these pages will be unmapped when
> removing/releasing the net device.
> 
> In netfront, two pools are maintained for transmitting and receiving packets.
> When new grant pages are needed, the driver gets grant pages from this pool
> first. If no free grant page exists, it allocates new page, maps it and then
> saves it into the pool. The pool size for transmit/receive is exactly tx/rx
> ring size. The driver uses memcpy(not grantcopy) to copy data grant pages.
> Here, memcpy is copying the whole page size data. I tried to copy len size data
> from offset, but network does not seem work well. I am trying to find the root
> cause now.
> 
> In netback, it also maintains two page pools for tx/rx. When netback gets a
> request, it does a search first to find out whether the grant reference of
> this request is already mapped into its page pool. If the grant ref is mapped,
> the address of this mapped page is gotten and memcpy is used to copy data
> between grant pages. However, if the grant ref is not mapped, a new page is
> allocated, mapped with this grant ref, and then saved into page pool for
> future use. Similarly, memcpy replaces grant copy to copy data between grant
> pages. In this implementation, two arrays(gnttab_tx_vif,gnttab_rx_vif) are
> used to save vif pointer for every request because current netback is not
> per-vif based. This would be changed after implementing 1:1 model in netback.
> 
> This patch supports both persistent-grant and non persistent grant. A new
> xenstore key "feature-persistent-grants" is used to represent this feature.
> 
> This patch is based on linux3.4-rc3. I hit netperf/netserver failure on
> linux latest version v3.7-rc1, v3.7-rc2 and v3.7-rc4. Not sure whether this
> netperf/netserver failure connects compound page commit in v3.7-rc1, but I did
> hit BUG_ON with debug patch from thread
> http://lists.xen.org/archives/html/xen-devel/2012-10/msg00893.html

FYI, I get this:

 477.814511] BUG: sleeping function called from invalid context at /home/konrad/ssd/linux/mm/page_alloc.c:2487
[  477.815281] in_atomic(): 1, irqs_disabled(): 1, pid: 3017, name: netperf
[  477.815281] Pid: 3017, comm: netperf Not tainted 3.5.0upstream-00004-g69047bb #1
[  477.815281] Call Trace:
[  477.815281]  [<ffffffff810b990a>] __might_sleep+0xda/0x100
[  477.815281]  [<ffffffff81142e93>] __alloc_pages_nodemask+0x223/0x920
[  477.815281]  [<ffffffff81158439>] ? zone_statistics+0x99/0xc0
[  477.815281]  [<ffffffff81076e79>] ? default_spin_lock_flags+0x9/0x10
[  477.815281]  [<ffffffff81615e3a>] ? _raw_spin_lock_irqsave+0x3a/0x50
[  477.815281]  [<ffffffff81076e79>] ? default_spin_lock_flags+0x9/0x10
[  477.815281]  [<ffffffff81098977>] ? lock_timer_base+0x37/0x70
[  477.815281]  [<ffffffff8109a03d>] ? mod_timer_pending+0x11d/0x230
[  477.815281]  [<ffffffff81616144>] ? _raw_spin_unlock_bh+0x24/0x30
[  477.815281]  [<ffffffff8117e7e1>] alloc_pages_current+0xb1/0x110
[  477.815281]  [<ffffffffa0034238>] xennet_alloc_tx_ref+0x78/0x1c0 [xen_netfront]
[  477.815281]  [<ffffffffa00344eb>] xennet_start_xmit+0x16b/0x9f0 [xen_netfront]
[  477.815281]  [<ffffffff814c69eb>] dev_hard_start_xmit+0x2fb/0x6f0
[  477.815281]  [<ffffffff814e4566>] sch_direct_xmit+0x116/0x1e0
[  477.815281]  [<ffffffff814c6f6a>] dev_queue_xmit+0x18a/0x6b0
[  477.815281]  [<ffffffff8151264e>] ip_finish_output+0x18e/0x300
[  477.815281]  [<ffffffff81512821>] ip_output+0x61/0xa0
[  477.815281]  [<ffffffff81511b82>] ? __ip_local_out+0xa2/0xb0
[  477.815281]  [<ffffffff81511bb4>] ip_local_out+0x24/0x30
[  477.815281]  [<ffffffff81511ffe>] ip_queue_xmit+0x15e/0x410
[  477.815281]  [<ffffffff81528354>] tcp_transmit_skb+0x424/0x8f0
[  477.815281]  [<ffffffff8152a8c2>] tcp_write_xmit+0x1f2/0x9c0
[  477.815281]  [<ffffffff81182194>] ? ksize+0x14/0x70
[  477.815281]  [<ffffffff8152b711>] __tcp_push_pending_frames+0x21/0x90
[  477.815281]  [<ffffffff8151db23>] tcp_sendmsg+0x983/0xcd0
[  477.815281]  [<ffffffff81540daf>] inet_sendmsg+0x7f/0xd0
[  477.815281]  [<ffffffff81290dde>] ? selinux_socket_sendmsg+0x1e/0x20
[  477.815281]  [<ffffffff814aed13>] sock_sendmsg+0xf3/0x120
[  477.815281]  [<ffffffff81076f48>] ? pvclock_clocksource_read+0x58/0xd0
[  477.815281]  [<ffffffff812de7c0>] ? timerqueue_add+0x60/0xb0
[  477.815281]  [<ffffffff810b0b85>] ? enqueue_hrtimer+0x25/0xb0
[  477.815281]  [<ffffffff814af4d4>] sys_sendto+0x104/0x140
[  477.815281]  [<ffffffff81041279>] ? xen_clocksource_read+0x39/0x50
[  477.815281]  [<ffffffff81041419>] ? xen_clocksource_get_cycles+0x9/0x10
[  477.815281]  [<ffffffff810d3242>] ? getnstimeofday+0x52/0xe0
[  477.815281]  [<ffffffff8161dfb9>] system_call_fastpath+0x16/0x1b

> 
> 
> Annie Li (4):
>   xen/netback: implements persistent grant with one page pool.
>   xen/netback: Split one page pool into two(tx/rx) page pool.
>   Xen/netfront: Implement persistent grant in netfront.
>   fix code indent issue in xen-netfront.
> 
>  drivers/net/xen-netback/common.h    |   24 ++-
>  drivers/net/xen-netback/interface.c |   26 +++
>  drivers/net/xen-netback/netback.c   |  215 ++++++++++++++++++--
>  drivers/net/xen-netback/xenbus.c    |   14 ++-
>  drivers/net/xen-netfront.c          |  378 +++++++++++++++++++++++++++++------
>  5 files changed, 570 insertions(+), 87 deletions(-)
> 
> -- 
> 1.7.3.4
