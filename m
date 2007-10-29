From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Mon, 29 Oct 2007 15:33:20 +0900
Message-ID: <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
References: <20070306012010.GA25763@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:59129 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbXJ2Gds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 02:33:48 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9T6XhPJ011027
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:33:43 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9T6Xh07128300
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 00:33:43 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9T6XgeC012905
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 00:33:43 -0600
In-Reply-To: <20070306012010.GA25763@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Herbert,

Let me ask a question about this patch.
After this patch was applied, 2 of the protocol stack behaviors were
changed when it receives a UDP datagram with broken checksum:

 1. udp6InDatagrams is incremented instead of udpInErrors
 2. In userland, recvfrom() replies an error with EAGAIN.
    recvfrom() wasn't aware of such a packet before.

Are these changes intentional?

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>


On Tue, 6 Mar 2007 12:20:10 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> [UDP6]: Restore sk_filter optimisation
> 
> This reverts the changeset
> 
>     [IPV6]: UDPv6 checksum.
> 
>     We always need to check UDPv6 checksum because it is mandatory.
> 
> The sk_filter optimisation has nothing to do whether we verify the
> checksum.  It simply postpones it to the point when the user calls
> recv or poll.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 0ad4719..4474480 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -279,8 +279,10 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
>  		}
>  	}
> 
> -	if (udp_lib_checksum_complete(skb))
> -		goto drop;
> +	if (sk->sk_filter) {
> +		if (udp_lib_checksum_complete(skb))
> +			goto drop;
> +	}
> 
>  	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
>  		/* Note that an ENOMEM error is charged twice */
