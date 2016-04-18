From: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 11:21:12 -0400
Message-ID: <5714FB68.3020604@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418065447.GA11539@x-vnc01.mtx.labs.mlnx>
 <20160418143255.GA15203@infradead.org>
 <DB5PR05MB1848424EC9DC8D4150EADB03C56B0@DB5PR05MB1848.eurprd05.prod.outlook.com>
 <20160418151702.GA26565@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160418151702.GA26565-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 11:17 AM, Christoph Hellwig wrote:
> On Mon, Apr 18, 2016 at 02:39:36PM +0000, Eli Cohen wrote:
>> Right, I did not suggest this as a patch but just wanted to pinpoint the problematic issue which is that virt_to_page does not give you the correct pointer to the page.
> 
> Removing both the virt_to_page + vmap calls would solve the issue
> indeed.
> 

I was looking at the code. I don't see how removing virt_to_page + vmap 
would solve the issue.

The code is trying to access the buffer space with direct.buf member
from the CPU side. This member would become NULL, when this code is 
removed and also in mlx4_en_map_buffer. 


                if (BITS_PER_LONG == 64) {
                        struct page **pages;
                        pages = kmalloc(sizeof *pages * buf->nbufs, gfp);
                        if (!pages)
                                goto err_free;
                        ...
                        ...
                        if (!buf->direct.buf)
                                goto err_free;
                }

drivers/net/ethernet/mellanox/mlx4/en_tx.c (2 hits)
Line 110: ring->buf = ring->wqres.buf.direct.buf;
Line 114: (unsigned long long) ring->wqres.buf.direct.map);

drivers/net/ethernet/mellanox/mlx4/en_rx.c (1 hit)
Line 404: ring->buf = ring->wqres.buf.direct.buf;

drivers/net/ethernet/mellanox/mlx4/en_cq.c (1 hit)
Line 85: cq->buf = (struct mlx4_cqe *)cq->wqres.buf.direct.buf;

What am I missing?

-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
