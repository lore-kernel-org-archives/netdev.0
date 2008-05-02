From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [SC92031] [BUG-FIX] [Patch 1/1]: Revert use of skb_padto
Date: Fri, 2 May 2008 14:45:03 -0700
Message-ID: <20080502144503.4ef2a430@extreme>
References: <20080502202940.GA5116@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47775 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932779AbYEBVpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 17:45:10 -0400
In-Reply-To: <20080502202940.GA5116@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008 21:29:40 +0100
Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:

> [SC92031]: Revert use of skb_padto (does not update skb->len)
> 
> This reverts use of skb_padto() introduced in 
> 
>  commit 26a17b7bbb36a8552d531bc1ad08472fb5aa3007
>  Date:   Wed Apr 2 10:11:11 2008 -0700
>  sc92031: start transmit return value bugfix
> 
> The padto does not work because the driver code evaluates `len' later on
> and there are cases where skb->len is not updated accordingly.
> 
> This was observed with ARP frames (skb->len = 42 bytes, !skb_cloned(),
> skb_tailroom = 84 bytes). Then in skb_pad(), the first condition is true,
> where skb->len is not updated. As a consequence, the driver uses 42 bytes
> instead of the 60 bytes, and the ARP frame never makes it onto the wire.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  sc92031.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> --- a/drivers/net/sc92031.c
> +++ b/drivers/net/sc92031.c
> @@ -953,9 +953,6 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	unsigned entry;
>  	u32 tx_status;
>  
> -	if (skb_padto(skb, ETH_ZLEN))
> -		return NETDEV_TX_OK;
> -
>  	if (unlikely(skb->len > TX_BUF_SIZE)) {
>  		dev->stats.tx_dropped++;
>  		goto out;
> @@ -975,6 +972,11 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
>  
>  	len = skb->len;
> +	if (unlikely(len < ETH_ZLEN)) {
> +		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
> +				0, ETH_ZLEN - len);
> +		len = ETH_ZLEN;
> +	}
>  

Yes, this also works better in the out of memory case since it doesn't
need to reallocate the skb.

