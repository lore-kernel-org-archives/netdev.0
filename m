From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the skb
Date: Thu, 24 Oct 2013 09:43:38 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73A5@saturn3.aculab.com>
References: <20131023.161603.1190144528425577653.davem@davemloft.net> <1382564190-334-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Antonio Quartulli" <antonio@meshcoding.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52555 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752517Ab3JXIpH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 04:45:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28954-06 for <netdev@vger.kernel.org>;
 Thu, 24 Oct 2013 09:45:02 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1382564190-334-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the skb
> 
> Right now skb->data is passed to rx_hook() even if the skb
> has not been linearised and without giving rx_hook() a way
> to linearise it.
> 
> Change the rx_hook() interface and make it accept the skb
> and the offset to the UDP payload as arguments. rx_hook() is
> also renamed to rx_skb_hook() to ensure that out of the tree
> users notice the API change.
> 
> In this way any rx_skb_hook() implementation can perform all
> the needed operations to properly (and safely) access the
> skb data.
...
> @@ -820,7 +823,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
> 
>  		len -= iph->ihl*4;
>  		uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
> +		offset = (unsigned char *)(uh + 1) - skb->data;
>  		ulen = ntohs(uh->len);
> +		data_len = skb->len - offset;
> +		source = ntohs(uh->source);
> 
>  		if (ulen != len)
>  			goto out;
> @@ -834,9 +840,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
>  			if (np->local_port && np->local_port != ntohs(uh->dest))
>  				continue;
> 
> -			np->rx_hook(np, ntohs(uh->source),
> -				       (char *)(uh+1),
> -				       ulen - sizeof(struct udphdr));
> +			np->rx_skb_hook(np, source, skb, offset, data_len);
>  			hits++;
>  		}
>  	} else {

>From a code optimisation point of view you probably don't want to be
calculating the source, offset and length early.
It is quite likely that the local variables will have to be written
to the stack (because of the function calls) - so it is almost
certainly more efficient to calculate them just before the call.

	David
