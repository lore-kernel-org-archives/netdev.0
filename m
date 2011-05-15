From: Stefanos Harhalakis <v13@v13.gr>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Sun, 15 May 2011 18:08:38 +0300
Message-ID: <201105151808.39231.v13@v13.gr>
References: <201105141938.28344.v13@v13.gr> <1305464176.3120.113.camel@edumazet-laptop> <1305466542.3120.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out.forthnet.gr ([193.92.150.115]:8608 "EHLO
	mx-out.forthnet.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760051Ab1EOPYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 11:24:33 -0400
In-Reply-To: <1305466542.3120.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sunday 15 of May 2011, Eric Dumazet wrote:
> +static inline int ip4_frag_ecn_fold(u8 ecn)
> +{
> +	switch (ecn) {
> +	/* If same ECN combination was observed on all fragments, do nothing */
> +	case IPFRAG_ECN_NOT_ECT:
> +	case IPFRAG_ECN_ECT_1:
> +	case IPFRAG_ECN_ECT_0:
> +	case IPFRAG_ECN_CE:
> +	/* if a ECT_1 ECT_0 combination was observed, do nothing as well */
> +	case IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
> +		return 0;
> +	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
> +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0:
> +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1:
> +	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
> +		return INET_ECN_CE;
> +	/* other combinations are invalid : drop frame */
> +	default:
> +		return -1;
> +	}
>  }

You may wish to simplify this exhaustive check to:

if (unlikely((ecn & IPFRAG_ECN_NOT_ECT) && ecn!=IPFRAG_ECN_NOT_ECT))
  return -1;
else if (ecn & IPFRAG_ECN_CE)
  return INET_ECN_CE;
else
  return 0;

although I'm not sure which method will be faster.

Also, returning the exact same value for NOT_ECT and ECT_X and then ORing
this with the TOS seems like it will make it loose the ECT_X info. No? (but
also, I'm not sure if this is needed anyway from that point on).

p.s. I'm not sure whether this message will make it to the netdev list.
