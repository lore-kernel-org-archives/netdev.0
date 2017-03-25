From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] xfrm: branchless addr4_match() on 64-bit
Date: Sat, 25 Mar 2017 19:37:12 +0300
Message-ID: <20170325163712.GA4950@avx2>
References: <20170323233247.GE31372@avx2>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB93A8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35574 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdCYQhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 12:37:18 -0400
Received: by mail-lf0-f68.google.com with SMTP id v2so2169063lfi.2
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 09:37:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB93A8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 05:16:44PM +0000, David Laight wrote:
> From: Alexey Dobriyan
> > Sent: 23 March 2017 23:33
> > Current addr4_match() code has special test for /0 prefixes because of
> > standard required undefined behaviour. However, it is possible to omit
> > it on 64-bit because shifting can be done in a 64-bit register and then
> > truncated to the expected value (which is 0 mask).
> > 
> > Implicit truncation by htonl() fits nicely into R32-within-R64 model
> > on x86-64.
> ...
> >  static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
> >  {
> > +#ifdef CONFIG_64BIT
> > +	/* L in UL is not a typo. */
> > +	return !((a1 ^ a2) & htonl(~0UL << (32 - prefixlen)));
> > +#else
> >  	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> >  	if (prefixlen == 0)
> >  		return true;
> >  	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> > +#endif
> 
> Can't this just be written:
> 
>   	if (sizeof (long) == 4 && prefixlen == 0)

Indeed.

>   		return true;
> 	return !((a1 ^ a2) & htonl(0xFFFFFFFFUL << (32 - prefixlen)));

0xFFFFFFFFUL is really long movabs, ~0UL is better.
