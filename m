From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] xfrm: branchless addr4_match() on 64-bit
Date: Fri, 24 Mar 2017 17:16:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB93A8@AcuExch.aculab.com>
References: <20170323233247.GE31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexey Dobriyan' <adobriyan@gmail.com>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:54563 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966910AbdCXRRB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:17:01 -0400
In-Reply-To: <20170323233247.GE31372@avx2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan
> Sent: 23 March 2017 23:33
> Current addr4_match() code has special test for /0 prefixes because of
> standard required undefined behaviour. However, it is possible to omit
> it on 64-bit because shifting can be done in a 64-bit register and then
> truncated to the expected value (which is 0 mask).
> 
> Implicit truncation by htonl() fits nicely into R32-within-R64 model
> on x86-64.
...
>  static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
>  {
> +#ifdef CONFIG_64BIT
> +	/* L in UL is not a typo. */
> +	return !((a1 ^ a2) & htonl(~0UL << (32 - prefixlen)));
> +#else
>  	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
>  	if (prefixlen == 0)
>  		return true;
>  	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> +#endif

Can't this just be written:

  	if (sizeof (long) == 4 && prefixlen == 0)
  		return true;
	return !((a1 ^ a2) & htonl(0xFFFFFFFFUL << (32 - prefixlen)));

	David
