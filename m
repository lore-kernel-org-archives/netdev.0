From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] xfrm: fix pmtu discovery (kill xfrm6_update_pmtu)
Date: Fri, 1 Feb 2013 18:25:29 +0100
Message-ID: <20130201172529.GA3014@midget.suse.cz>
References: <20130129144325.GB23396@midget.suse.cz>
 <20130201084515.GA29073@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757120Ab3BARZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 12:25:36 -0500
Content-Disposition: inline
In-Reply-To: <20130201084515.GA29073@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 09:45:15AM +0100, Steffen Klassert wrote:
> On Tue, Jan 29, 2013 at 03:43:25PM +0100, Jiri Bohac wrote:
> > When the TCP segment reaches ip6_xmit:
> > 	skb->len > dst_mtu(dst_B_xfrm)
> > 	1452 > 1414
> > This generates an ICMPV6_PKT_TOOBIG to self with MTU==1414.
> > This is intended to reach the protocol error handler (decrease
> > the MSS in the TCP case):
> 
> I think the above is the problem, we should not send packet to
> big messages to ourselves. The reduced mtu is because of some
> local reason (e.g. IPsec), it is not learned and therefore we
> should not update the pmtu value.
> 
> You could try the patch below. I'm travelling this week, so I
> can't do tests myself before monday.
> 
> Subject: [PATCH] ipv6: Don't send packet to big messages to self
> 
> Calling icmpv6_send() on a local message size error leads to an
> incorrect update of the path mtu in the case when IPsec is used.
> So use ipv6_local_error() instead to notify the socket about the
> error.

It fixes the problem I was trying to fix.
I tested the patch with the PMTU and IPsec parts of the ipv6ready
testsuite and it passed.

I wonder if this is going to do everything that should be done
e.g. in the TCPv6 case.  Now, tcp_v6_err() calls
tcp_v6_mtu_reduced() which syncs the MSS and forces a retransmit.

Looking at the code, I don't think this is going to happen with
this patch, so the MSS update and retransmit will only be done
when the respective TCP timer expires.

So perhaps the individual protocols will need to handle the new
error reporting?


And out of curiosity, do you know the reason why
xfrm[46]_update_pmtu changes the non-xfrm route's MTU?
Is this really intended?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
