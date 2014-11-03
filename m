From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Mon, 3 Nov 2014 17:39:06 +0000
Message-ID: <1415036346.1411.3.camel@citrix.com>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55752 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753571AbaKCR4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 12:56:12 -0500
In-Reply-To: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 17:23 +0000, David Vrabel wrote:
> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> 
> Unconditionally pulling 128 bytes into the linear buffer is not
> required. Netback has already grant copied up-to 128 bytes from the
> first slot of a packet into the linear buffer. The first slot normally
> contain all the IPv4/IPv6 and TCP/UDP headers.

What about when it doesn't? It sounds as if we now won't pull up, which
would be bad.

To avoid the pull up the code would need to grant copy up-to 128 bytes
from as many slots as needed, not only the first.

Also, if the grant copy has already placed 128 bytes in the linear area,
why is the pull up touching anything in the first place? Shouldn't it be
a nop in that case?

> The unconditional pull would often copy frag data unnecessarily.  This
> is a performance problem when running on a version of Xen where grant
> unmap avoids TLB flushes for pages which are not accessed.  TLB
> flushes can now be avoided for > 99% of unmaps (it was 0% before).
> 
> Grant unmap TLB flush avoidance will be available in a future version
> of Xen (probably 4.6).
> 
> Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |   26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 730252c..14e18bb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -82,6 +82,16 @@ MODULE_PARM_DESC(max_queues,
>  static unsigned int fatal_skb_slots = FATAL_SKB_SLOTS_DEFAULT;
>  module_param(fatal_skb_slots, uint, 0444);
>  
> +/* The amount to copy out of the first guest Tx slot into the skb's
> + * linear area.  If the first slot has more data, it will be mapped
> + * and put into the first frag.
> + *
> + * This is sized to avoid pulling headers from the frags for most
> + * TCP/IP packets.
> + */
> +#define XEN_NETBACK_TX_COPY_LEN 128

Was it strictly necessary to both move and rename this? I can see why
the comment needed to change.

>  static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
>  			       u8 status);
>  
> @@ -125,13 +135,6 @@ static inline struct xenvif_queue *ubuf_to_queue(const struct ubuf_info *ubuf)
>  			    pending_tx_info[0]);
>  }
>  
> -/* This is a miniumum size for the linear area to avoid lots of
> - * calls to __pskb_pull_tail() as we set up checksum offsets. The
> - * value 128 was chosen as it covers all IPv4 and most likely
> - * IPv6 headers.
> - */
> -#define PKT_PROT_LEN 128
> -
>  static u16 frag_get_pending_idx(skb_frag_t *frag)
>  {
>  	return (u16)frag->page_offset;
> @@ -1446,9 +1449,9 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
>  		index = pending_index(queue->pending_cons);
>  		pending_idx = queue->pending_ring[index];
>  
> -		data_len = (txreq.size > PKT_PROT_LEN &&
> +		data_len = (txreq.size > XEN_NETBACK_TX_COPY_LEN &&
>  			    ret < XEN_NETBK_LEGACY_SLOTS_MAX) ?
> -			PKT_PROT_LEN : txreq.size;
> +			XEN_NETBACK_TX_COPY_LEN : txreq.size;
>  
>  		skb = xenvif_alloc_skb(data_len);
>  		if (unlikely(skb == NULL)) {
> @@ -1653,11 +1656,6 @@ static int xenvif_tx_submit(struct xenvif_queue *queue)
>  			}
>  		}
>  
> -		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
> -			int target = min_t(int, skb->len, PKT_PROT_LEN);
> -			__pskb_pull_tail(skb, target - skb_headlen(skb));
> -		}
> -
>  		skb->dev      = queue->vif->dev;
>  		skb->protocol = eth_type_trans(skb, skb->dev);
>  		skb_reset_network_header(skb);
