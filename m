From: Blaschka <frank.blaschka@de.ibm.com>
Subject: Re: [PATCH]: net: Unexport napi_gro_flush().
Date: Wed, 20 Jan 2010 07:56:54 +0100
Message-ID: <20100120065654.GA7826@tuxmaker.boeblingen.de.ibm.com>
References: <20100119.141255.90146762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:44316 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab0ATG44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 01:56:56 -0500
Content-Disposition: inline
In-Reply-To: <20100119.141255.90146762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2010 at 02:12:55PM -0800, David Miller wrote:
> 
> Nothing outside of net/core/dev.c uses it.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/netdevice.h |    1 -
>  net/core/dev.c            |    3 +--
>  2 files changed, 1 insertions(+), 3 deletions(-)
>

Hi Dave,

I have a qeth patch which uses napi_gro_flush (not posted yet).
There is following idea:

The inbound processing of the qeth driver is already in bottomhalf
(qdio input tasklet) so we can switch from netif_rx to
netif_receive_skb. This allows us to exploit gro code for the
layer 3 driver. I would introduce a dummy napi_struct and call
napi_gro_flush when the inbound tasklet ends.

Should I post the patch for review?

Thanks,
  Frank
 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a3fccc8..468a11d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1527,7 +1527,6 @@ extern int		netif_rx(struct sk_buff *skb);
>  extern int		netif_rx_ni(struct sk_buff *skb);
>  #define HAVE_NETIF_RECEIVE_SKB 1
>  extern int		netif_receive_skb(struct sk_buff *skb);
> -extern void		napi_gro_flush(struct napi_struct *napi);
>  extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
>  					struct sk_buff *skb);
>  extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a008f69..5747b9e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2582,7 +2582,7 @@ out:
>  	return netif_receive_skb(skb);
>  }
> 
> -void napi_gro_flush(struct napi_struct *napi)
> +static void napi_gro_flush(struct napi_struct *napi)
>  {
>  	struct sk_buff *skb, *next;
> 
> @@ -2595,7 +2595,6 @@ void napi_gro_flush(struct napi_struct *napi)
>  	napi->gro_count = 0;
>  	napi->gro_list = NULL;
>  }
> -EXPORT_SYMBOL(napi_gro_flush);
> 
>  enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
>  {
> -- 
> 1.6.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
