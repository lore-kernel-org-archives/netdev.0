From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: xfrm_input() and ->seq oddities
Date: Sun, 3 Feb 2008 11:04:44 +0000
Message-ID: <20080203110444.GR27894@ZenIV.linux.org.uk>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi> <20080202222226.GB31388@gondor.apana.org.au> <20080202235827.GP27894@ZenIV.linux.org.uk> <20080203002019.GA32295@gondor.apana.org.au> <20080203003718.GQ27894@ZenIV.linux.org.uk> <20080203030516.GA5685@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39363 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbYBCLEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 06:04:51 -0500
Content-Disposition: inline
In-Reply-To: <20080203030516.GA5685@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2008 at 02:05:16PM +1100, Herbert Xu wrote:
> On Sun, Feb 03, 2008 at 12:37:19AM +0000, Al Viro wrote:
> >
> > This is still very odd...  Where do you initialize ->seq.input?  What
> 
> In xfrm_input.
> 
> > guarantees that async call of xfrm_input() will be always preceded by
> > at least one non-async one?
> 
> OK I admit it isn't pretty.  But the encap_type argument is reused to
> indicate async resumption.  That is, if we enter with encap_type < 0,
> it means that we're resuming a previous operation and seq.input has
> therefore been set by the previous xfrm_input call.

*Ouch*

So what you are saying is
	* callers of xfrm_input_resume() are in callbacks that couldn't
have been set other than from esp_input()/esp6_input()
	* these two could have only been called via ->type->input()
	* ->type->input() is called from xfrm_input(), immediately after
having set ->seq.input, *or* from xfrm6_input_addr().  The former is safe.
	* xfrm6_input_addr() calls ->type->input() of object it gets from
xfrm_state_lookup_byaddr().  The protocol number passed to the latter comes
from xfrm6_input_addr() argument.
	* the protocol numbers given to xfrm6_input_addr() by its callers
are IPPROTO_DSTOPTS and IPPROTO_ROUTING resp; ->input() instances in their
xfrm_type do *not* set callbacks that could lead to xfrm_input_resume(),
so we are safe.

IMO that at least deserves a comment near xfrm_input()...
doe
