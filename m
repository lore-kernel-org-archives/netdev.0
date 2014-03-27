From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net 2/3] xen-netback: worse-case estimate in
 xenvif_rx_action is underestimating
Date: Thu, 27 Mar 2014 12:27:33 +0000
Message-ID: <1395923253.22909.106.camel@kazak.uk.xensource.com>
References: <1395922988-37702-1-git-send-email-paul.durrant@citrix.com>
	 <1395922988-37702-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24276 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbaC0M1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:27:35 -0400
In-Reply-To: <1395922988-37702-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 12:23 +0000, Paul Durrant wrote:
> The worse-case estimate for skb ring slot usage in xenvif_rx_action()
> fails to take fragment page_offset into account. The page_offset does,
> however, affect the number of times the fragmentation code calls
> start_new_rx_buffer() (i.e. consume another slot) and the worse-case
> should assume that will always return true. This patch adds the page_offset
> into the DIV_ROUND_UP for each frag.

At least for the copying mode wasn't the idea that you would copy to the
start of the page, so the offset wasn't relevant? IOW is the real issue
that start_new_rx_buffer is/was too aggressive?

Now that we do mapping though I suspect the offset becomes relevant
again here and there is a 1:1 mapping from slots to frags again.

(I could have sworn David V got rid of all this precalculating stuff.)

> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>  drivers/net/xen-netback/netback.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index befc413..ac35489 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -492,8 +492,18 @@ static void xenvif_rx_action(struct xenvif *vif)
>  						PAGE_SIZE);
>  		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  			unsigned int size;
> +			unsigned int offset;
> +
>  			size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> -			max_slots_needed += DIV_ROUND_UP(size, PAGE_SIZE);
> +			offset = skb_shinfo(skb)->frags[i].page_offset;
> +
> +			/* For a worse-case estimate we need to factor in
> +			 * the fragment page offset as this will affect the
> +			 * number of times xenvif_gop_frag_copy() will
> +			 * call start_new_rx_buffer().
> +			 */
> +			max_slots_needed += DIV_ROUND_UP(offset + size,
> +							 PAGE_SIZE);
>  		}
>  		if (skb_is_gso(skb) &&
>  		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
