From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv3 net-next 5/7] net: add confirm_neigh method to
 dst_ops
Date: Fri, 3 Feb 2017 11:16:16 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702031101550.2584@ja.home.ssi.bg>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg> <1485899827-5212-6-git-send-email-ja@ssi.bg> <20170201074402.GX30338@gauss.secunet.com> <alpine.LFD.2.11.1702012326130.2580@ja.home.ssi.bg> <20170203074609.GA30338@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        linux-rdma@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52790 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752514AbdBCJRo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 04:17:44 -0500
In-Reply-To: <20170203074609.GA30338@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 3 Feb 2017, Steffen Klassert wrote:

> On Thu, Feb 02, 2017 at 01:04:34AM +0200, Julian Anastasov wrote:
> > 
> > 	It may sounds good. But only dst->path->ops->confirm_neigh
> > points to real IPv4/IPv6 function. And also, I guess, the
> > family can change while walking the chain, so we should be
> > careful while providing the original daddr (which comes from
> > sendmsg). I had the idea to walk all xforms to get the latest
> > tunnel address but this can be slow. 
> 
> Is this a per packet call or is the information cached somewhere?

	It is for every packet that is sent with both
MSG_CONFIRM and MSG_PROBE, i.e. when nothing is sent
on the wire. It is used by patch 6 just for UDP, RAW, ICMP, L2TP.

> > Something like this?:
> > 
> > static void xfrm_confirm_neigh(const struct dst_entry *dst, const void 
> > *daddr)
> > {
> > 	const struct dst_entry *path = dst->path;
> > 
> > 	/* By default, daddr is from sendmsg() if we have no tunnels */
> > 	for (;dst != path; dst = dst->child) {
> > 		const struct xfrm_state *xfrm = dst->xfrm;
> > 
> > 		/* Use address from last tunnel	*/
> > 		if (xfrm->props.mode != XFRM_MODE_TRANSPORT)
> > 			daddr = &xfrm->id.daddr;
> > 	}
> > 	path->ops->confirm_neigh(path, daddr);
> > }
> 
> I thought about this (completely untested) one:
> 
> static void xfrm_confirm_neigh(const struct dst_entry *dst, const void
> *daddr)
> 
> {
> 	const struct dst_entry *dst = dst->child;

	When starting and dst arg is first xform, the above
assignment skips it. May be both lines should be swapped.

> 	const struct xfrm_state *xfrm = dst->xfrm;
> 
> 	if (xfrm)
> 		daddr = &xfrm->id.daddr;
> 
> 	dst->ops->confirm_neigh(dst, daddr);
> }
> 
> Only the last dst_entry in this call chain (path) sould
> not have dst->xfrm set. So it finally calls path->ops->confirm_neigh
> with the daddr of the last transformation. But your version
> should do the same.

	Above can be fixed but it is risky for the stack
usage when using recursion. In practice, there should not be
many xforms, though. Also, is id.daddr valid for transports?

> > 	This should work as long as path and last tunnel are
> > from same family.
> 
> Yes, the outer mode of the last transformation has the same
> family as path.
> 
> > Also, after checking xfrm_dst_lookup() I'm not
> > sure using just &xfrm->id.daddr is enough. Should we consider
> > more places for daddr value?
> 
> Yes, indeed. We should do it like xfrm_dst_lookup() does it.

	OK, I'll get logic from there. Should I use loop or
recursion?

Regards
