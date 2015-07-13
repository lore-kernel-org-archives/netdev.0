From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 15:23:52 +0800
Message-ID: <20150713072352.GA8485@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57695 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbGMHX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 03:23:59 -0400
Content-Disposition: inline
In-Reply-To: <20150710115141.12980.88829.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 02:51:41PM +0300, Konstantin Khlebnikov wrote:
> This fixes race between non-atomic updates of adjacent bit-fields:
> skb->cloned could be lost because netlink broadcast clones skb after
> sending it to the first listener who sets skb->peeked at the same skb.
> As a result atomic refcounting of skb header stays disabled and
> skb_release_data() frees it twice. Race leads to double-free in kmalloc-xxx.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: b19372273164 ("net: reorganize sk_buff for faster __copy_skb_header()")
> ---
>  net/netlink/af_netlink.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index dea925388a5b..921e0d8dfe3a 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2028,6 +2028,12 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
>  	info.tx_filter = filter;
>  	info.tx_data = filter_data;
>  
> +	/* Enable atomic refcounting in skb_release_data() before first send:
> +	 * non-atomic set of that bit-field in __skb_clone() could race with
> +	 * __skb_recv_datagram() which touches the same set of bit-fields.
> +	 */
> +	skb->cloned = 1;
> +
>  	/* While we sleep in clone, do not allow to change socket list */
>  
>  	netlink_lock_table();

Your effort in finding this bug is wonderful.  However I think
the fix is a bit dirty.

The real issue here is that the recv path no longer handles shared
skbs.  So either we need to fix the recv path to not touch skbs
without cloning them, or we need to get rid of the use of shared
skbs in netlink.

In fact it looks I introduced the bug way back in

commit a59322be07c964e916d15be3df473fb7ba20c41e
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Wed Dec 5 01:53:40 2007 -0800

    [UDP]: Only increment counter on first peek/recv

I will try to mend this error :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
