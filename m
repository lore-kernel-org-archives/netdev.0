From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mwifiex: add __GFP_REPEAT to skb allocation call
Date: Tue, 29 Mar 2016 05:58:40 -0700
Message-ID: <1459256320.6473.160.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
	 <87vb45brxc.fsf@kamboji.qca.qualcomm.com>
	 <CABicQ-UJ1kniq6m86QcyVZBPznvNexfrUrTk3A_=GmZy69hvCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Linux Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Sameer Nanda <snanda@google.com>, netdev@vger.kernel.org,
	Sonny Rao <sonnyrao@chromium.org>,
	Douglas Anderson <dianders@chromium.org>
To: Wei-Ning Huang <wnhuang@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34956 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbcC2M6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 08:58:42 -0400
In-Reply-To: <CABicQ-UJ1kniq6m86QcyVZBPznvNexfrUrTk3A_=GmZy69hvCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-29 at 17:27 +0800, Wei-Ning Huang wrote:
> Adding some chromium devs to the thread.
> 
> In, http://lxr.free-electrons.com/source/mm/page_alloc.c#L3152
> 
> The default mm retry allocation when 'order <=
> PAGE_ALLOC_COSTLY_ORDER' of gfp_mask contains __GFP_REPEAT.
> PAGE_ALLOC_COSTLY_ORDER is defined to be 3. On systems with page size
> = 4K, this means memory compaction and retry is only done when the
> size of allocation is <= 32K
> In mwifiex, the allocation size is 64K.



>  When we have system with
> memory fragmentation and allocation failed, there will be no retry.
> This is why we need to add __GFP_REPEAT here to allow the system to
> perform memory compaction and retry allocation.
> 
> Maybe Amit@marvell can comment on if this is a good fix on this issue.
> I'm also aware that marvell is the progress of implementing
> scatter/gatter for mwifiex, which can also fix the issue.

Before SG is implemented, you really need to copy incoming frames into
smallest chunks (to get lowest skb->truesize) and leave the 64KB
allocated stuff forever in the driver.

__GFP_REPEAT wont really solve the issue.

It seems the problem comes from the fact that the drivers calls
dev_kfree_skb_any() after calling mwifiex_deaggr_sdio_pkt(), instead of
recycling this very precious 64KB skb once memory gets fragmented.

Another problem is that mwifiex_deaggr_sdio_pkt() uses
mwifiex_alloc_dma_align_buf() with GFP_KERNEL | GFP_DMA

Really GFP_DMA makes no sense here, since the skb is going to be
processed by the stack, which has no such requirement.

Please use normal skb allocations there.

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index b2c839a..8404db5 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -1123,8 +1123,8 @@ static void mwifiex_deaggr_sdio_pkt(struct mwifiex_adapter *adapter,
 				    __func__, pkt_len, blk_size);
 			break;
 		}
-		skb_deaggr = mwifiex_alloc_dma_align_buf(pkt_len,
-							 GFP_KERNEL | GFP_DMA);
+		skb_deaggr = __netdev_alloc_skb_ip_align(NULL, pkt_len,
+							 GFP_KERNEL);
 		if (!skb_deaggr)
 			break;
 		skb_put(skb_deaggr, pkt_len);
