From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sfc: allocate rx pages on the same node as the
 interrupt
Date: Tue, 10 May 2016 07:55:06 -0700
Message-ID: <1462892106.23934.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5731EE51.2090908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Pieczko <dpieczko@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35120 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbcEJOzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 10:55:09 -0400
Received: by mail-pf0-f177.google.com with SMTP id 77so6720524pfv.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 07:55:08 -0700 (PDT)
In-Reply-To: <5731EE51.2090908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 15:21 +0100, Edward Cree wrote:
> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> When the interrupt servicing a channel is on a NUMA node that is
> not local to the device, performance is improved by allocating
> rx pages on the node local to the interrupt (remote to the device)
> 
> The performance-optimal case, where interrupts and applications
> are pinned to CPUs on the same node as the device, is not altered
> by this change.
> 
> This change gave a 1% improvement in transaction rate using Nginx
> with all interrupts and Nginx threads on the node remote to the
> device. It also gave a small reduction in round-trip latency,
> again with the interrupt and application on a different node to
> the device.

Yes, I advocated for such changes in the past for mlx4 NIC.

But your patch makes no sense to me.

alloc_pages() by default would run on the cpu servicing the IRQ, so
would automatically provide pages on the local node.

If you care only of the initial pages allocated with GFP_KERNEL at
device start, really that is a small detail as they should be consumed
and replaced quite fast.

If you worry that "wrong" pages would be reused over and over,
you could make sure that efx_reuse_page() wont reuse a page on the wrong
node.

page_to_nid(page) != numa_mem_id() 

Note that this could happen even if IRQ are not changed since
alloc_pages() could in stress situations give you a page from a remote
node.
