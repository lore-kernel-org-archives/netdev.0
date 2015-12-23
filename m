From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 16:35:13 +0100
Message-ID: <567ABF31.8080306@stressinduktion.org>
References: <c891d011ef98267cd72157a5b01c78347ada8d8e.1450883640.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>, Jesse Gross <jesse@nicira.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:58972 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbbLWPfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 10:35:16 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 204F120D09
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 10:35:15 -0500 (EST)
In-Reply-To: <c891d011ef98267cd72157a5b01c78347ada8d8e.1450883640.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.12.2015 16:21, Paolo Abeni wrote:
> Currently the needed_headroom field for the geneve device is left
> to the default value.
> 
> This patch set it to space required for basic geneve encapsulation,
> so that we can avoid the skb head re-allocation on xmit.
> 
> This give a 6% speedup for unsegment traffic on geneve tunnel.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

(Sorry, just saw this.)

> ---
>  drivers/net/geneve.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index c2b79f5..bb3e6ed 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -1155,7 +1155,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>  	struct geneve_net *gn = net_generic(net, geneve_net_id);
>  	struct geneve_dev *t, *geneve = netdev_priv(dev);
>  	bool tun_collect_md, tun_on_same_port;
> -	int err;
> +	int err, encap_len;
>  
>  	if (!remote)
>  		return -EINVAL;
> @@ -1187,6 +1187,14 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>  	if (t)
>  		return -EBUSY;
>  
> +	/* make enough headroom for basic scenario */
> +	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
> +	if (remote->sa.sa_family == AF_INET)
> +		encap_len += sizeof(struct iphdr);
> +	else
> +		encap_len += sizeof(struct ipv6hdr);
> +	dev->needed_headroom = encap_len;
> +

We are missing one time ETH_HLEN or hard_header_len of the lower_dev (if
available) in here AFAIK.

Thanks,
Hannes
