From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 22:06:05 -0800 (PST)
Message-ID: <20070110.220605.38709282.davem@davemloft.net>
References: <20070110204922.GA1652@gondor.apana.org.au>
	<001601c734fb$89ed3b90$cc0a010a@tcssec.com>
	<20070110232713.GA13180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@trustedcs.com, jmorris@namei.org,
	netdev@vger.kernel.org, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33581
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965266AbXAKGGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 01:06:08 -0500
To: herbert.xu@redhat.com
In-Reply-To: <20070110232713.GA13180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert.xu@redhat.com>
Date: Thu, 11 Jan 2007 10:27:13 +1100

> On Wed, Jan 10, 2007 at 03:08:55PM -0600, Venkat Yekkirala wrote:
> > 
> > I was talking about this (the latter) as well. Currently, on a proper
> > "negative", -ESRCH is returned by security_xfrm_policy_lookup(), and
> > this comes back up as a 0 from resolver(), correctly indicating NO
> > applicable
> > xfrm policy (after taking security into account). But if
> > security_xfrm_policy_lookup()
> > were to return anything other than a zero or -ESRCH, such as -ENOMEM,
> > you will see it come back up as such (as -ENOMEM) from resolver(),
> > and in this case, it's neither a positive nor a negative, just an error.
> > Hence a full lookup would be in order, the next time round.
> 
> OK, I see that now.  The EACCES error is translated to ESRCH in
> the security layer.
> 
> > Also, I would fix the other bug you had noted, by something like:
> 
> I agree.
> 
> [IPSEC] flow: Fix potential memory leak
> 
> When old flow cache entries that are not at the head of their chain
> trigger a transient security error they get unlinked along with all
> the entries preceding them in the chain.  The preceding entries are
> not freed correctly.
> 
> This patch fixes this by simply leaving the entry around.  It's based
> on a suggestion by Venkat Yekkirala.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This version of the fix looks good, I'll apply it, thanks Herbert.

>  
> > I am planning to test and submit a patch to SELinux
> > to invoke flow_cache_flush() on policy reloads tomorrow.
> 
> flow_cache_flush() shouldn't be used by SELinux.  You probably
> want to increase the genid instead.

That's what I recommend too.  Active flushes are very bad for
performance, passive garbage collection of stale entries should
be used for coherency whenever possible.

> BTW, we should probably add some code to deal with overflows in
> genid.  With the recent improvements in policy update speeds, it
> could be conceivable for an overflow to occur.

Even if you had a very powerful computer, doing nothing but
inserting and deleting policies, it'd take around 90 days for
the generation count to overflow.

But of course it could happen.

One thing we could do is force a full flow cache flush when some
percentage before the generation count would overflow.  Say every
%80 of the generation ID space?  That gives enough space to ensure
the flush tasklet runs before the ID really does wrap.
