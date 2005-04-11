From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: Mon, 11 Apr 2005 22:08:01 +1000
Message-ID: <20050411120801.GA26029@gondor.apana.org.au>
References: <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <1113049844.1090.23.camel@jzny.localdomain> <20050409192926.GA9423@gondor.apana.org.au> <20050409200306.GA9660@gondor.apana.org.au> <1113142244.1088.287.camel@jzny.localdomain> <20050410212707.GA30337@gondor.apana.org.au> <1113218420.1090.351.camel@jzny.localdomain> <20050411113040.GA25718@gondor.apana.org.au> <1113220648.1090.364.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113220648.1090.364.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2005 at 07:57:29AM -0400, jamal wrote:
> Herbert,
> 
> Ok, what you are saying is sensible, but: does this mean there was never
> an issue then there was never a possibility of delete and expire
> intefering with each other then?

The problem before was that the timer didn't check the return value
of xfrm_policy_delete (in fact the latter didn't return anything).
xfrm_policy_delete tself always checked whether it succeeded in
deleting the entry from xfrm_policy_list.  This is used to determine
whether it should call xfrm_policy_kill.

Not checking the return value in the timer allows the following
situation to occur:

CPU 0				CPU 1
xfrm_policy_timer
	goto expired
				xfrm_get_policy(delete == 1)
					xfrm_policy_byid() succeeds
					notification is sent
	xfrm_policy_delete
	km_policy_expired <--- BUG

So as long as xfrm_policy_delete returns the correct value and it's
checked by the xfrm_policy_timer then we're OK.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
