From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: CCM/GCM implementation defect
Date: Thu, 23 Apr 2015 13:45:34 +0200
Message-ID: <20150423114533.GI8928@secunet.com>
References: <20150423032619.GA17648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150423032619.GA17648@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 11:26:20AM +0800, Herbert Xu wrote:
> Hi:
> 
> It looks like our IPsec implementations of CCM and GCM are buggy
> in that they don't include the IV in the authentication calculation.

Seems like crypto_rfc4106_crypt() passes the associated data it
got from ESP directly to gcm, without chaining with the IV.

> 
> This definitely breaks interoperability with anyone who implements
> them correctly.  The fact that there have been no reports on this
> probably means that nobody has run into this in the field yet.
> 
> On the security side, this is probably not a big deal for CCM
> because it always verifies the authentication tag after decryption.
> But for GCM this may be a DoS issue as an attacker could modify
> the IV without triggering the authentication check and thus cause
> an unnecessary decryption.  For both CCM and GCM this will result
> in random data injected as a packet into the network stack which
> hopefully will be dropped.
> 
> In order to fix this without breaking backwards compatibility,
> my plan is to introduce new templates such as rfc4106v2 which
> implement the RFC correctly.  The existing templates will be
> retained so that current users aren't broken by the fix.

Adding a second template for the correct implementation is
probaply the only thing that we can do if we don't want to
break backwards compatibility. But maybe we can add a warning
to the old implementation, such that users notice that they
use a broken version.
