From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Perform a replay check after return from async
 codepaths
Date: Wed, 21 Sep 2011 13:57:27 +0200
Message-ID: <20110921115727.GX1808@secunet.com>
References: <20110921093858.GW1808@secunet.com>
 <20110921112158.GB18648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50071 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794Ab1IUL53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 07:57:29 -0400
Content-Disposition: inline
In-Reply-To: <20110921112158.GB18648@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 09:21:58PM +1000, Herbert Xu wrote:
> On Wed, Sep 21, 2011 at 11:38:58AM +0200, Steffen Klassert wrote:
> > When asyncronous crypto algorithms are used, there might be many
> > packets that passed the xfrm replay check, but the replay advance
> > function is not called yet for these packets. So the replay check
> > function would accept a replay of all of these packets. Also the
> > system might crash if there are more packets in async processing
> > than the size of the anti replay window, because the replay advance
> > function would try to update the replay window beyond the bounds.
> > 
> > This pach adds a second replay check after resuming from the async
> > processing to fix these issues.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Actually why does this matter? For a single SA, the processing
> in xfrm_input should be completely synchronous, even when you're
> using asynchronous algorithms.
> 

Well, I've got pretty reproduceable crashes when the sender of
the IPsec packets introduces reorder, that's why I noticed this.

The problem is, that the replay check function is called before
the asynchronous crypto processing and the replay advance function
is called after resume from the asynchronous processing. So
we can submit multiple packets to the crypto layer without
updating the replay window. This means that the replay check
function accepts packets that should have been dropped, because
they are reordered and more than 'replay window size' packets
to late. This leads to a crash as we try to update the replay
window beyond the allocated bounds.
