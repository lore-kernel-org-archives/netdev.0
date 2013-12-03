From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Tue, 03 Dec 2013 08:36:15 +0100
Message-ID: <529D89EF.1000507@samsung.com>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Fugang Duan <B38611@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:32172 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3LCHgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 02:36:17 -0500
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MX700FNSZSFQE10@mailout4.w1.samsung.com> for
 netdev@vger.kernel.org; Tue, 03 Dec 2013 07:36:15 +0000 (GMT)
In-reply-to: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 2013-11-27 13:44, Sebastian Andrzej Siewior wrote:
> On tx submit the driver always dma_map_single() FEC_ENET_TX_FRSIZE (=2048)
> bytes. This works because we don't overwrite any memory after the data buffer,
> we remove it from cache if it was there. So we hurt performace in case the
> mapping of a smaller area makes a difference.
> There is also a bug: If the data area starts shortly before the end of
> RAM say 0xc7fffa10 and the RAM ends at 0xc8000000 then we have enough
> space to fit the data area (according to skb->len) but we would map beyond
> end of ram if we are using 2048. In v2.6.31 (against which kernel this patch
> made) there is the following check in dma_cache_maint():
>
> |BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));
>
> Since the area starting at 0xc8000000 is no longer virt_addr_valid() we
> BUG() during dma_map_single(). The BUG() statement was removed in v3.5-rc1 as
> per 2dc6a016 ("ARM: dma-mapping: use asm-generic/dma-mapping-common.h").
>
> This patch was tested on v2.6.31 and then forward-ported and compile
> tested only against the net tree. I think it is still worth fixing
> mainline even after the BUG() statement is gone.
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> It would be nice if someone could test this on current kernel.
> Is this worth pushing stable?
>
> Marek: Was there a special reason why the check was removed? Would it make
> sense to bring it back say under CONFIG_DMA_DEBUG?

I'm sorry for a delay. The check has been removed during conversion to 
common,
generic dma_map_ops implementation. During those convesion 
dma_(un)map_single
calls have been implemented on top of dma_(un)map_page operation, what 
removed
those additional check (*_page based function didn't have such check). I 
agree
that it might be a good idea to bring them back conditionally under
CONFIG_DMA_DEBUG. Would you like to send a respective patch?

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
