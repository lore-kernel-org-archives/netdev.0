From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] xfrm: fix pmtu discovery (kill xfrm6_update_pmtu)
Date: Mon, 4 Feb 2013 08:39:14 +0100
Message-ID: <20130204073914.GB23291@secunet.com>
References: <20130129144325.GB23396@midget.suse.cz>
 <20130201084515.GA29073@secunet.com>
 <20130201172529.GA3014@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32956 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428Ab3BDHjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 02:39:18 -0500
Content-Disposition: inline
In-Reply-To: <20130201172529.GA3014@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 06:25:29PM +0100, Jiri Bohac wrote:
> On Fri, Feb 01, 2013 at 09:45:15AM +0100, Steffen Klassert wrote:
> > 
> > Subject: [PATCH] ipv6: Don't send packet to big messages to self
> > 
> > Calling icmpv6_send() on a local message size error leads to an
> > incorrect update of the path mtu in the case when IPsec is used.
> > So use ipv6_local_error() instead to notify the socket about the
> > error.
> 
> It fixes the problem I was trying to fix.
> I tested the patch with the PMTU and IPsec parts of the ipv6ready
> testsuite and it passed.
> 
> I wonder if this is going to do everything that should be done
> e.g. in the TCPv6 case.  Now, tcp_v6_err() calls
> tcp_v6_mtu_reduced() which syncs the MSS and forces a retransmit.
> 
> Looking at the code, I don't think this is going to happen with
> this patch, so the MSS update and retransmit will only be done
> when the respective TCP timer expires.
> 
> So perhaps the individual protocols will need to handle the new
> error reporting?
> 

Well, we might loose the fast path retransmit. We could think
about implementing a fast path for such situations, but that's
another issue. Let's fix the bug first, I'll submit the patch
to fix it.

> 
> And out of curiosity, do you know the reason why
> xfrm[46]_update_pmtu changes the non-xfrm route's MTU?
> Is this really intended?
> 

The pmtu is a learned measure of the route, it depends on the
external environment, not on the question whether we add local
overhead. So I think it was intended to change always the
pmtu of the original route, even if we use IPsec.
