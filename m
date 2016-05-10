From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sfc: allocate rx pages on the same node as the
 interrupt
Date: Tue, 10 May 2016 07:57:03 -0700
Message-ID: <1462892223.23934.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5731EE51.2090908@solarflare.com>
	 <1462892106.23934.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Pieczko <dpieczko@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33786 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025AbcEJO5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 10:57:05 -0400
Received: by mail-pf0-f176.google.com with SMTP id 206so6817574pfu.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 07:57:05 -0700 (PDT)
In-Reply-To: <1462892106.23934.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 07:55 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 15:21 +0100, Edward Cree wrote:
> > From: Daniel Pieczko <dpieczko@solarflare.com>
> > 
> > When the interrupt servicing a channel is on a NUMA node that is
> > not local to the device, performance is improved by allocating
> > rx pages on the node local to the interrupt (remote to the device)
> > 
> > The performance-optimal case, where interrupts and applications
> > are pinned to CPUs on the same node as the device, is not altered
> > by this change.
> > 
> > This change gave a 1% improvement in transaction rate using Nginx
> > with all interrupts and Nginx threads on the node remote to the
> > device. It also gave a small reduction in round-trip latency,
> > again with the interrupt and application on a different node to
> > the device.
> 
> Yes, I advocated for such changes in the past for mlx4 NIC.
> 
> But your patch makes no sense to me.
> 
> alloc_pages() by default would run on the cpu servicing the IRQ, so
> would automatically provide pages on the local node.
> 
> If you care only of the initial pages allocated with GFP_KERNEL at
> device start, really that is a small detail as they should be consumed
> and replaced quite fast.
> 
> If you worry that "wrong" pages would be reused over and over,
> you could make sure that efx_reuse_page() wont reuse a page on the wrong
> node.
> 
> page_to_nid(page) != numa_mem_id() 
> 
> Note that this could happen even if IRQ are not changed since
> alloc_pages() could in stress situations give you a page from a remote
> node.

Something like this (untested) ?

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8956995b2fe713b377f205a55fada36c8a04253a..90665a8992e29cceb29dd465b52f934dff3b3d4e 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -124,7 +124,7 @@ static struct page *efx_reuse_page(struct efx_rx_queue *rx_queue)
 		++rx_queue->page_remove;
 
 	/* If page_count is 1 then we hold the only reference to this page. */
-	if (page_count(page) == 1) {
+	if (page_count(page) == 1 && page_to_nid(page) == numa_mem_id()) {
 		++rx_queue->page_recycle_count;
 		return page;
 	} else {
