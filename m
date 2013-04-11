From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [net-next PATCH] xen-netback: switch to use
 skb_partial_csum_set()
Date: Thu, 11 Apr 2013 08:46:04 +0100
Message-ID: <1365666364.27868.114.camel@zakaz.uk.xensource.com>
References: <1365662129-38031-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365662129-38031-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-11 at 07:35 +0100, Jason Wang wrote:
> Switch to use skb_partial_csum_set() to simplify the codes.

This is incremental on top of your previous patch, right?

> 
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Note:
> - Compile test only.
> ---
>  drivers/net/xen-netback/netback.c |   22 ++++++++--------------
>  1 files changed, 8 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 83905a9..70631f0 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1156,7 +1156,6 @@ static int netbk_set_skb_gso(struct xenvif *vif,
>  static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
>  {
>  	struct iphdr *iph;
> -	unsigned char *th;
>  	int err = -EPROTO;
>  	int recalculate_partial_csum = 0;
>  
> @@ -1180,28 +1179,26 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
>  		goto out;
>  
>  	iph = (void *)skb->data;
> -	th = skb->data + 4 * iph->ihl;
> -	if (th >= skb_tail_pointer(skb))
> -		goto out;
> -
> -	skb_set_transport_header(skb, 4 * iph->ihl);

Is removing this line really correct?

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
> @@ -1215,9 +1212,6 @@ static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
>  		goto out;
>  	}
>  
> -	if ((th + skb->csum_offset + 2) > skb_tail_pointer(skb))
> -		goto out;
> -
>  	err = 0;
>  
>  out:
