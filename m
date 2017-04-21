From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] xfrm: fix stack access out of bounds with
 CONFIG_XFRM_SUB_POLICY
Date: Fri, 21 Apr 2017 14:05:31 +0200
Message-ID: <20170421120531.GA12502@bistromath.localdomain>
References: <17208ec89e09ed7223ffd2302abfa3475255c384.1492769294.git.sd@queasysnail.net>
 <20170421110643.GA13809@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1038924AbdDUMFj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 08:05:39 -0400
Content-Disposition: inline
In-Reply-To: <20170421110643.GA13809@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-21, 19:06:44 +0800, Herbert Xu wrote:
> On Fri, Apr 21, 2017 at 12:14:51PM +0200, Sabrina Dubroca wrote:
> > When CONFIG_XFRM_SUB_POLICY=y, xfrm_dst stores a copy of the flowi for
> > that dst. Unfortunately, the code that allocates and fills this copy
> > doesn't care about what type of flowi (flowi, flowi4, flowi6) gets
> > passed. In multiple code paths (from raw_sendmsg, from TCP when
> > replying to a FIN, in vxlan, geneve, and gre), the flowi that gets
> > passed to xfrm is actually an on-stack flowi4, so we end up reading
> > memory on the stack past the end of the flowi4 struct.
> > 
> > Since xfrm_dst->origin isn't used anywhere, just get rid of it.
> > xfrm_dst->partner isn't used either, so get rid of that too.
> > 
> > Fixes: ca116922afa8 ("xfrm: Eliminate "fl" and "pol" args to xfrm_bundle_ok().")
> 
> The commit you refer to here doesn't seem to have caused this bug.

You're right. I had a note about that but it got lost.  The bug
(ignoring what flavor of flowi is passed) is older than that (from the
introduction of subpolicies, I suspect, but I would have to dig more
into the history), but this commit removed the last uses of
origin/partner.

Looking into raw_sendmsg(), this code may have been safe before
9d6ec938019c ("ipv4: Use flowi4 in public route lookup interfaces."),
since full flowi were used.

If we want a fix for kernels that don't have ca116922afa8, we would
probably need to take the size of the flowi* struct depending on the
address family passed to xfrm_resolve_and_create_bundle().


I'm not sure how to proceed here, any advice?


Thanks,

-- 
Sabrina
