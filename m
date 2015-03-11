From: Martin Lau <kafai@fb.com>
Subject: [Question] net/mlx4_en: Memory consumption issue with mlx4_en driver
Date: Wed, 11 Mar 2015 11:51:47 -0700
Message-ID: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Amir Vadai <amirv@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:64373 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750770AbbCKSwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 14:52:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have seen a memory consumption issue related to the mlx4 driver.
We suspect it is related to the page order used to do the alloc_pages().
The order starts by 3 and then try the next lower value in case of failure.
I have copy and paste the alloc_pages() call site at the end of the email.

Is it a must to get order 3 pages?  Based on the code and its comment,
it seems it is a little bit of functional and/or performance reason.
Can you share some perf test numbers on different page order allocation,
like 3 vs 2 vs 1?

It can be reproduced by:
1. At netserver (receiver), sysctl net.ipv4.tcp_rmem ='4096 125000  67108864'
   and net.core.rmem_max=67108864.
2. Start two netservers listening on 2 different ports:
   - One for taking 1000 background netperf flows
   - Another netserver for taking 200 netperf flows.  It will be
     suspended (ctrl-z) in the middle of the test.
2. Start 1000 background netperf TCP_STREAM flows
3. Start another 200 netperf TCP_STREAM flows
4. Suspend the netserver taking the 200 flows.
5. Observe the socket memory usage of the suspended netserver by 'ss -t -m'.
   200 of them will eventually reach 64MB rmem.

We observed the total socket rmem usage reported by 'ss -t -m'
has a huge difference from /proc/meminfo. We have seen ~6x-10x difference.

Any of the fragment queued in the suspended socket will
hold a refcount to page->_count and stop 8 pages from freeing.
The net.ipv4.tcp_mem seems not saving us here since it only
counts the skb->truesize which is 1536 in our setup.

Thanks,
--Martin

static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
			    struct mlx4_en_rx_alloc *page_alloc,
			    const struct mlx4_en_frag_info *frag_info,
			    gfp_t _gfp)
{
	int order;
	struct page *page;
	dma_addr_t dma;

	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
		gfp_t gfp = _gfp;

		if (order)
			gfp |= __GFP_COMP | __GFP_NOWARN;
		page = alloc_pages(gfp, order);
		if (likely(page))
			break;
		if (--order < 0 ||
		    ((PAGE_SIZE << order) < frag_info->frag_size))
			return -ENOMEM;
	}
	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
			   PCI_DMA_FROMDEVICE);
	if (dma_mapping_error(priv->ddev, dma)) {
		put_page(page);
		return -ENOMEM;
	}
	page_alloc->page_size = PAGE_SIZE << order;
	page_alloc->page = page;
	page_alloc->dma = dma;
	page_alloc->page_offset = 0;
	/* Not doing get_page() for each frag is a big win
	 * on asymetric workloads. Note we can not use atomic_set().
	 */
	atomic_add(page_alloc->page_size / frag_info->frag_stride - 1,
		   &page->_count);
	return 0;
}
