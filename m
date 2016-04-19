From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Tue, 19 Apr 2016 03:50:47 -0400
Message-ID: <5715E357.3040407@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
 <20160418143255.GA15203@infradead.org>
 <DB5PR05MB1848424EC9DC8D4150EADB03C56B0@DB5PR05MB1848.eurprd05.prod.outlook.com>
 <20160418151702.GA26565@infradead.org> <5714FB68.3020604@codeaurora.org>
 <20160418154058.GA4228@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"timur@codeaurora.org" <timur@codeaurora.org>,
	"cov@codeaurora.org" <cov@codeaurora.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418154058.GA4228@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 11:40 AM, Christoph Hellwig wrote:
> On Mon, Apr 18, 2016 at 11:21:12AM -0400, Sinan Kaya wrote:
>> I was looking at the code. I don't see how removing virt_to_page + vmap 
>> would solve the issue.
>>
>> The code is trying to access the buffer space with direct.buf member
>> from the CPU side. This member would become NULL, when this code is 
>> removed and also in mlx4_en_map_buffer. 
>>
>> ...
>>
>> What am I missing?
> 
> As mentioned before you'll also need to enforce you hit the nbufs = 1
> case for these.  In fact most callers should simply switch to a plain
> dma_zalloc_coherent call without all these wrappers.  If we have a case
> where we really want multiple buffers that don't have to be contiguous
> (maybe the MTT case) I'd rather opencode that instead of building this
> confusing interface on top of it.
> 

So, I did my fair share of investigation. As I pointed out in my previous email, 
the code is allocating a bunch of page sized arrays and using them for receive,
transmit and control descriptors. 

I'm unable to limit nbufs to 1 because, none of these allocations make a single
contiguous allocation by default. They all go to multiple page approach due to 
2 * PAGE_SIZE max_direct parameter passed. 

I tried changing the code to handle page_list vs. single allocation. I was able
to do this for CQE and receive queue since both of them allocate fixed size chunks. 
However, I couldn't do this for the transmit queue. 

The transmit code uses the array of descriptors for variable sized transfers and 
it also assumes that the descriptors are contiguous.

When used with pages, one tx data can spill beyond the first page and do illegal
writes.

In the end, my proposed code in this patch is much simpler than what I tried to 
achieve by removing vmap API. 

Another alternative is to force code use single DMA alloc for all 64 bit architectures.

Something like this:

-- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -588,7 +588,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 {
        dma_addr_t t;

-       if (size <= max_direct) {
+       if ((size <= max_direct) || (BITS_PER_LONG == 64)){
                buf->nbufs        = 1;
                buf->npages       = 1;
                buf->page_shift   = get_order(size) + PAGE_SHIFT;

This also works on arm64. My proposal is more scalable for memory consumption compared
to this one.

-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
