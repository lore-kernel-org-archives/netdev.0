From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen/netback: Wake dealloc thread after completing
 zerocopy work
Date: Tue, 4 Aug 2015 14:11:49 +0100
Message-ID: <20150804131149.GA26074@zion.uk.xensource.com>
References: <1438692658-22311-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Ross Lagerwall <ross.lagerwall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39868 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933140AbbHDNNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 09:13:19 -0400
Content-Disposition: inline
In-Reply-To: <1438692658-22311-1-git-send-email-ross.lagerwall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 01:50:58PM +0100, Ross Lagerwall wrote:
> Waking the dealloc thread before decrementing inflight_packets is racy
> because it means the thread may go to sleep before inflight_packets is
> decremented. If kthread_stop() has already been called, the dealloc
> thread may wait forever with nothing to wake it. Instead, wake the
> thread only after decrementing inflight_packets.
> 
> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 7d50711..e95ee20 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1536,7 +1536,6 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
>  		smp_wmb();
>  		queue->dealloc_prod++;
>  	} while (ubuf);
> -	wake_up(&queue->dealloc_wq);
>  	spin_unlock_irqrestore(&queue->callback_lock, flags);
>  
>  	if (likely(zerocopy_success))
> @@ -1544,6 +1543,7 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
>  	else
>  		queue->stats.tx_zerocopy_fail++;
>  	xenvif_skb_zerocopy_complete(queue);
> +	wake_up(&queue->dealloc_wq);

Can you move this wake_up into xenvif_skb_zerocopy_complete and have a
comment there saying wake_up must be called after decrementing inflight
counters (possibly with some of the commit message)? That way we don't
trip over this in the future if we're to refactor the callback function.

Wei.

>  }
>  
>  static inline void xenvif_tx_dealloc_action(struct xenvif_queue *queue)
> -- 
> 2.1.0
