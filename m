From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: dma_sync each RX frag before passing
 it to the stack
Date: Tue, 04 Mar 2014 16:19:55 -0500 (EST)
Message-ID: <20140304.161955.131076054982575581.davem@davemloft.net>
References: <1393915478-8433-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933329AbaCDVT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:19:57 -0500
In-Reply-To: <1393915478-8433-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 4 Mar 2014 12:14:38 +0530

> The driver currently maps a page for DMA, divides the page into multiple
> frags and posts them to the HW. It un-maps the page after data is received
> on all the frags of the page. This scheme doesn't work when bounce buffers
> are used for DMA (swiotlb=force kernel param).
> 
> This patch fixes this problem by calling dma_sync_single_for_cpu() for each
> frag (excepting the last one) so that the data is copied from the bounce
> buffers. The page is un-mapped only when DMA finishes on the last frag of
> the page.
> (Thanks Ben H. for suggesting the dma_sync API!)
> 
> This patch also renames the "last_page_user" field of be_rx_page_info{}
> struct to "last_frag" to improve readability of the fixed code.
> 
> Reported-by: Li Fengmao <li.fengmao@zte.com.cn>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
> 
> Dave, I'm guessing the swiotlb option is not used much(?). So, this patch
> is not a critical fix and is a better fit for the net-next tree. Thanks.

It matters on platforms where dma sync'ing is necessary to achieve
hardware coherence.

All of Sparc64 PCI implementations fall into this category, because
there is a prefetching cache that sits on the front end of the PCI
complex, working in concert with the IOMMU.

Some PowerPC embedded platforms need to do DMA synchronization flushes
too for a similar reason.

But yes these are uncommon configurations so I agree this should go
to net-next.

Applied, thanks.
