From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] sit: correct IP protocol used in ipip6_err
Date: Thu, 16 Jun 2016 17:10:11 +0900
Message-ID: <20160616081009.GA32730@vergenet.net>
References: <1466064379-32355-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32957 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbcFPIKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:10:21 -0400
Received: by mail-pa0-f51.google.com with SMTP id b13so15986117pat.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 01:10:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1466064379-32355-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 05:06:19PM +0900, Simon Horman wrote:
> Since 32b8a8e59c9c ("sit: add IPv4 over IPv4 support")
> ipip6_err() may be called for packets whose IP protocol is
> IPPROTO_IPIP as well as those whose IP protocol is IPPROTO_IPV6.
> 
> In the case of IPPROTO_IPIP packets the correct protocol value is not
> passed to ipv4_update_pmtu() or ipv4_redirect().
> 
> This patch resolves this problem by using the IP protocol of the packet
> rather than a hard-coded value. This appears to be consistent
> with the usage of the protocol of a packet by icmp_socket_deliver()
> the caller of ipip6_err().
> 
> I was able to exercise the redirect case by using a setup where an ICMP
> redirect was received for the destination of the encapsulated packet.
> However, it appears that although incorrect the protocol field is not used
> in this case and thus no problem manifests.  On inspection it does not
> appear that a problem will manifest in the fragmentation needed/update pmtu
> case either.
> 
> In short I believe this is a cosmetic fix. None the less, the use of
> IPPROTO_IPV6 seems wrong and confusing.
> 
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Apologies for not making this more obvious, this is a "net-next" patch.

> ---
>  net/ipv6/sit.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index d9f2bd6ef72d..f4356bb13f4b 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -560,13 +560,13 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
>  
>  	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
>  		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
> -				 t->parms.link, 0, IPPROTO_IPV6, 0);
> +				 t->parms.link, 0, iph->protocol, 0);
>  		err = 0;
>  		goto out;
>  	}
>  	if (type == ICMP_REDIRECT) {
>  		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
> -			      IPPROTO_IPV6, 0);
> +			      iph->protocol, 0);
>  		err = 0;
>  		goto out;
>  	}
> -- 
> 2.1.4
> 
