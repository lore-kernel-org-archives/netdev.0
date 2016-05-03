From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv2 bluetooth-next 05/10] ndisc: add addr_len parameter to
 ndisc_opt_addr_data
Date: Tue, 3 May 2016 20:17:14 +0200
Message-ID: <5728EB2A.4060001@osg.samsung.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-6-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:57932 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933568AbcECSRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 14:17:19 -0400
In-Reply-To: <1461140382-4784-6-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20/04/16 10:19, Alexander Aring wrote:
> This patch makes the address length as argument for the
> ndisc_opt_addr_data function. This is necessary to handle addresses
> which don't use dev->addr_len as address length.
>
> Cc: David S. Miller<davem@davemloft.net>
> Cc: Alexey Kuznetsov<kuznet@ms2.inr.ac.ru>
> Cc: James Morris<jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy<kaber@trash.net>
> Signed-off-by: Alexander Aring<aar@pengutronix.de>
> ---
>   include/net/ndisc.h |  5 +++--
>   net/ipv6/ndisc.c    | 11 +++++++----
>   net/ipv6/route.c    |  2 +-
>   3 files changed, 11 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index ef43e88..aac868e 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -134,12 +134,13 @@ static inline int ndisc_opt_addr_space(struct net_device *dev,
>   }
>   
>   static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> -				      struct net_device *dev)
> +				      struct net_device *dev,
> +				      unsigned char addr_len)
>   {
>   	u8 *lladdr = (u8 *)(p + 1);
>   	int lladdrlen = p->nd_opt_len << 3;
>   	int prepad = ndisc_addr_option_pad(dev->type);
> -	if (lladdrlen != ndisc_opt_addr_space(dev, dev->addr_len))
> +	if (lladdrlen != ndisc_opt_addr_space(dev, addr_len))
>   		return NULL;
>   	return lladdr + prepad;
>   }
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 69e20e3..4e91d5e 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -744,7 +744,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>   	}
>   
>   	if (ndopts.nd_opts_src_lladdr) {
> -		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev);
> +		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev,
> +					     dev->addr_len);
>   		if (!lladdr) {
>   			ND_PRINTK(2, warn,
>   				  "NS: invalid link-layer address length\n");
> @@ -916,7 +917,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
>   		return;
>   	}
>   	if (ndopts.nd_opts_tgt_lladdr) {
> -		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev);
> +		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev,
> +					     dev->addr_len);
>   		if (!lladdr) {
>   			ND_PRINTK(2, warn,
>   				  "NA: invalid link-layer address length\n");
> @@ -1024,7 +1026,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>   
>   	if (ndopts.nd_opts_src_lladdr) {
>   		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
> -					     skb->dev);
> +					     skb->dev, skb->dev->addr_len);
>   		if (!lladdr)
>   			goto out;
>   	}
> @@ -1322,7 +1324,8 @@ skip_linkparms:
>   		u8 *lladdr = NULL;
>   		if (ndopts.nd_opts_src_lladdr) {
>   			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
> -						     skb->dev);
> +						     skb->dev,
> +						     skb->dev->addr_len);
>   			if (!lladdr) {
>   				ND_PRINTK(2, warn,
>   					  "RA: invalid link-layer address length\n");
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ed44663..cc180b3 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2157,7 +2157,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>   	lladdr = NULL;
>   	if (ndopts.nd_opts_tgt_lladdr) {
>   		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
> -					     skb->dev);
> +					     skb->dev, skb->dev->addr_len);
>   		if (!lladdr) {
>   			net_dbg_ratelimited("rt6_redirect: invalid link-layer address length\n");
>   			return;

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
