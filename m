From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: honour gratuitous ARP _replies_
Date: Mon, 15 May 2017 14:08:32 -0400 (EDT)
Message-ID: <20170515.140832.354922796595622860.davem@davemloft.net>
References: <20170510001607.9716-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org
To: ihrachys@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdEOSIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:08:36 -0400
In-Reply-To: <20170510001607.9716-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ihar Hrachyshka <ihrachys@redhat.com>
Date: Tue,  9 May 2017 17:16:07 -0700

> @@ -842,8 +844,20 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
>  		   It is possible, that this option should be enabled for some
>  		   devices (strip is candidate)
>  		 */
> -		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
> -			  addr_type == RTN_UNICAST;
> +		is_garp = tip == sip && addr_type == RTN_UNICAST;
> +
> +		/* Unsolicited ARP _replies_ also require target hwaddr to be
> +		 * the same as source.
> +		 */
> +		if (is_garp && arp->ar_op == htons(ARPOP_REPLY))
> +			is_garp =
> +#if IS_ENABLED(CONFIG_FIREWIRE_NET)
> +				/* IPv4 over IEEE 1394 doesn't provide target
> +				 * hardware address field in its ARP payload.
> +				 */
> +				tha &&
> +#endif
> +				!memcmp(tha, sha, dev->addr_len);
>  

The ifdefs here make the test harder to understand.

I would suggest removing the ifdef and letting the compiler remove the 'tha'
check if it can.

Thank you.
