From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Extending xfrm_selector (Was: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS)
Date: Wed, 30 Mar 2005 19:49:26 +1000
Message-ID: <20050330094926.GA8653@gondor.apana.org.au>
References: <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net> <423DA58D.4050406@protactive.nl> <20050320171707.GE4201@xi.wantstofly.org> <423DB7B7.1070604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Ludo Stellingwerff <ludo@protactive.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <423DB7B7.1070604@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 20, 2005 at 06:49:43PM +0100, Patrick McHardy wrote:
>
> >- I have no idea beforehand what address ranges are going to be routed
> >  over this vlan.  (Customers might send traffic with source addresses
> >  in address ranges that they don't announce to us (asymmetric routing),
> >  and I don't want those packets to remain unencrypted just because they
> >  don't match the SPD rule.)  A 0.0.0.0/0 0.0.0.0/0 rule would not be
> >  appropriate either since that'd suck _all_ traffic into this tunnel
> 
> You can specify an ifindex for oif in the selector, but you need
> to use the xfrm_user interface.

Unfortunately that doesn't work currently because we don't fill in
the oif field in the flow.  More importantly, having an interface
specific outbound policy isn't very useful when you can't have an
interface specific inbound/forward policy to match.

This actually leads to another issue.  The xfrm_selector structure
only contains one iface field.  So we can't specify both iif and oif
for forwarded packets.

Extending xfrm_selector is not trivial.  Ludo Stellingwerff also
wanted to do that in order use fwmark in the selector.

Here is one possible solution that allows xfrm_selector to be
extended.

We store new selector fields in a separate netlink payload.  This
works because all the current messages that carry xfrm_selector carry
exactly one selector.

When the kernel receives a message containing an xfrm_selector it'll
initialise the kernel xfrm_selector to contain that plus whatever
is in the correspond netlink payload.  If the payload is absent the
kernel should fill in sane default values for compatibility.

For messages sent by the kernel we also attach a netlink payload to
cover the new values.  This should be backwards compatible as appliations
should ignore unknown payloads.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
