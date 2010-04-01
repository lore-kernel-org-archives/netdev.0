From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 1 Apr 2010 08:33:52 +0800
Message-ID: <20100401003352.GA19147@gondor.apana.org.au>
References: <1270053478.26743.111.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:55318 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750795Ab0DAAeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:34:18 -0400
Content-Disposition: inline
In-Reply-To: <1270053478.26743.111.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 12:37:58PM -0400, jamal wrote:
> 
> This may be oversight in current implementation and possibly
> nobody has needed it before - hence it is not functional.
> 
> I want to have a drop-all policy on a per-interface level
> for incoming packets and add exceptions as i need them.
> [using the flow table is cheap if you have xfrm built in].
> i.e something along the lines of:
> 
> #eth0, wild-card drop all
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
>        dir in ptype main action block priority $SOME-HIGH-value
> #eth0, exception
> ip xfrm policy add blah blah dev eth0 \
> dir in ptype main action allow priority $SOME-small-value
> #eth1, wild-card drop all
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth1 \
>        dir in ptype main action block priority $SOME-HIGH-value
> #eth1 exception ...
> 
> The problem is this works as long as i dont specify an interface.
> i.e, this would work in the in-direction:
> 
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 \
>         dir in ptype main action block priority $SOME-HIGH-value
> 
> This would not work:
> ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
>        dir in ptype main action block priority $SOME-HIGH-value
> 
> 
> The checks in the selector matching is the culprit, example for v4:
> 
> __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
> {
>         return  .... &&
>                 .... &&
>                 (fl->oif == sel->ifindex || !sel->ifindex);
> }
> 
> i.e in the second case i have a non-zero sel->ifindex but
> a zero fl->oif; so it wont match.
> 
> One approach to fix this is to pass the direction then i can do
> in the function call, then i can do something along the lines of
> matching if:
> (fl_dir == FLOW_DIR_IN && (fl->iif == sel->ifindex || !sel->ifindex) ||
> (fl->oif == sel->ifindex || !sel->ifindex);
> 
> Is there any reason the selector matching only assumes fl->oif?
> Are there any unforeseen issues/breakages if i added a check for the
> above.

If we're going to change this then we should just add a second
interface field to the selector, rather than trying to overload
the existing one.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
