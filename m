From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] xen-netfront: use skb_partial_csum_set() to
 simplify the codes
Date: Fri, 07 Jun 2013 11:05:29 +0800
Message-ID: <51B14DF9.2060400@redhat.com>
References: <1370500519-2244-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751264Ab3FGDFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 23:05:55 -0400
In-Reply-To: <1370500519-2244-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2013 02:35 PM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> use skb_partial_csum_set() to simplify the codes
>
> Cc: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  drivers/net/xen-netfront.c |   20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 62238a0..76a2236 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -858,7 +858,6 @@ static RING_IDX xennet_fill_frags(struct netfront_info *np,
>  static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>  {
>  	struct iphdr *iph;
> -	unsigned char *th;
>  	int err = -EPROTO;
>  	int recalculate_partial_csum = 0;
>  
> @@ -883,27 +882,27 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>  		goto out;
>  
>  	iph = (void *)skb->data;
> -	th = skb->data + 4 * iph->ihl;
> -	if (th >= skb_tail_pointer(skb))
> -		goto out;
>  
> -	skb->csum_start = th - skb->head;
>  	switch (iph->protocol) {
>  	case IPPROTO_TCP:
> -		skb->csum_offset = offsetof(struct tcphdr, check);
> +		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
> +					  offsetof(struct tcphdr, check)))
> +			goto out;
>  
>  		if (recalculate_partial_csum) {
> -			struct tcphdr *tcph = (struct tcphdr *)th;
> +			struct tcphdr *tcph = tcp_hdr(skb);
>  			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
>  							 skb->len - iph->ihl*4,
>  							 IPPROTO_TCP, 0);
>  		}
>  		break;
>  	case IPPROTO_UDP:
> -		skb->csum_offset = offsetof(struct udphdr, check);
> +		if (!skb_partial_csum_set(skb, 4 * iph->ihl,
> +					  offsetof(struct udphdr, check)))
> +			goto out;
>  
>  		if (recalculate_partial_csum) {
> -			struct udphdr *udph = (struct udphdr *)th;
> +			struct udphdr *udph = udp_hdr(skb);
>  			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
>  							 skb->len - iph->ihl*4,
>  							 IPPROTO_UDP, 0);
> @@ -917,9 +916,6 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
>  		goto out;
>  	}
>  
> -	if ((th + skb->csum_offset + 2) > skb_tail_pointer(skb))
> -		goto out;
> -
>  	err = 0;
>  
>  out:

Acked-by: Jason Wang <jasowang@redhat.com>
