From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Sun, 11 Jan 2015 21:26:50 +0100
Message-ID: <20150111202650.GB4214@localhost.localdomain>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, luto@amacapital.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:62770 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbbAKU0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 15:26:55 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so11116052wid.0
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 12:26:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420824719-28848-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 12:31:55PM -0500, Willem de Bruijn wrote:
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index a317797..d81ef70 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -440,7 +440,7 @@ static bool ipv4_pktinfo_prepare_errqueue(const struct sock *sk,
>  
>  	if ((ee_origin != SO_EE_ORIGIN_TIMESTAMPING) ||
>  	    (!(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_CMSG)) ||
> -	    (!skb->dev))
> +	    (!skb->dev) || (!skb->len))
>  		return false;

Nit: You have already tested for the condition (!skb->len) ...

>  
>  	info->ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
> @@ -483,7 +483,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>  
>  	serr = SKB_EXT_ERR(skb);
>  
> -	if (sin) {
> +	if (sin && skb->len) {
>  		sin->sin_family = AF_INET;
>  		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
>  						   serr->addr_offset);
> @@ -496,8 +496,9 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>  	sin = &errhdr.offender;
>  	sin->sin_family = AF_UNSPEC;
>  
> -	if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> -	    ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin)) {
> +	if (skb->len &&
> +	    (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
> +	     ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin))) {

... here.

>  		struct inet_sock *inet = inet_sk(sk);
>  
>  		sin->sin_family = AF_INET;

Thanks,
Richard
