From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.23] UDP: Cleanup UDP encapsulation code
Date: Thu, 05 Jul 2007 17:04:25 +0200
Message-ID: <468D0879.4080903@trash.net>
References: <200707051427.l65ER6iS016766@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: derek@ihtfp.com, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094AbXGEPEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 11:04:51 -0400
In-Reply-To: <200707051427.l65ER6iS016766@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index b9276f8..777d5e8 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -70,7 +70,8 @@
>   *	Alexey Kuznetsov:		allow both IPv4 and IPv6 sockets to bind
>   *					a single port at the same time.
>   *	Derek Atkins <derek@ihtfp.com>: Add Encapulation Support
> - *	James Chapman		:	Add L2TP encapsulation type.
> + *	James Chapman		:	Use socket's encap_rcv for all encapsulated
> + *					protocols..

We have git for changelogs, please don't add to this.

> -				}
> +		unsigned int len;
>  
> -				/* FALLTHROUGH -- pass up as UDP packet */
> +		/* if we're overly short, let UDP handle it */
> +		len = skb->len - sizeof(struct udphdr);
> +		if (len <= 0)
> +			goto udp;
> +
> +		if (up->encap_rcv != NULL) {
> +			int ret;
> +
> +			ret = (*up->encap_rcv)(sk, skb);
> +			if (ret == 0)
> +				goto out;
> +			if (ret < 0) {
> +				/* Eat the packet .. */
> +				kfree_skb(skb);
> +				goto out;
>  			}


This doesn't seem to handle encapsulated transport mode packets.
In that case xfrm4_rcv_encap returns the negative decapsulated
protocol number, you change it to a positive number again:

> +	ret = xfrm4_rcv_encap(skb, encap_type);
> +	return -ret;

and then continue to process it as UDP. What should happen in
that case is that the negative protocol value is returned to
ip_local_deliver_finish.
