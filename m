From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 4/6] 6lowpan: fix
 fragmentation
Date: Wed, 14 May 2014 17:56:57 +0200
Message-ID: <20140514155503.GA14689@omega>
References: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1400082191-16493-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:55624 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbaENP5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 11:57:04 -0400
Received: by mail-ee0-f49.google.com with SMTP id e53so1498687eek.22
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 08:57:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1400082191-16493-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phoebe,

that's a nice solution for the DSN increment on fragmentation. This
stands long time on my ToDo list and you did a very nice solution.

Thanks. :-)

On Wed, May 14, 2014 at 05:43:09PM +0200, Phoebe Buckheister wrote:
> Currently, 6lowpan creates one 802.15.4 MAC header for the original
> packet the device was given by upper layers and reuses this header for
> all fragments, if fragmentation is required. This also reuses frame
> sequence numbers, which must not happen. 6lowpan also has issues with
> fragmentation in the presence of security headers, since those may imply
> the presence of trailing fields that are not accounted for by the
> fragmentation code right now.
> 
> Fix both of these issues by properly allocating fragment skbs with
> headromm and tailroom as specified by the underlying device, create one
> header for each skb instead of reusing the original header, let the
> underlying device do the rest.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> ---
>  net/ieee802154/6lowpan_rtnl.c |  198 ++++++++++++++++++++++-------------------
>  1 file changed, 104 insertions(+), 94 deletions(-)
> 
> diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
> index d0191c5..1ae8a56 100644
> --- a/net/ieee802154/6lowpan_rtnl.c
> +++ b/net/ieee802154/6lowpan_rtnl.c
> @@ -220,139 +220,149 @@ static int lowpan_set_address(struct net_device *dev, void *p)
>  	return 0;
>  }
>  
> -static int
> -lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
> -		     int mlen, int plen, int offset, int type)
> +static struct sk_buff*
> +lowpan_alloc_frag(struct sk_buff *skb, int size,
> +		  const struct ieee802154_hdr *master_hdr)
>  {
> +	struct net_device *real_dev = lowpan_dev_info(skb->dev)->real_dev;
>  	struct sk_buff *frag;
> -	int hlen;
> -
> -	hlen = (type == LOWPAN_DISPATCH_FRAG1) ?
> -			LOWPAN_FRAG1_HEAD_SIZE : LOWPAN_FRAGN_HEAD_SIZE;
> -
> -	raw_dump_inline(__func__, "6lowpan fragment header", head, hlen);
> +	int rc;
> +
> +	frag = alloc_skb(real_dev->hard_header_len +
> +			 real_dev->needed_tailroom + size,
> +			 GFP_ATOMIC);

Why not keep netdev_alloc_skb for the real_dev?

But then we need to use dev_kfree_skb.

- Alex
