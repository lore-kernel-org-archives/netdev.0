From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Thu, 15 Nov 2007 12:47:29 +1100
Message-ID: <200711151247.29424.nickpiggin@yahoo.com.au>
References: <200711140927.39796.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0711141650150.21965@schroedinger.engr.sgi.com> <20071115011110.GB21193@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.mail.mud.yahoo.com ([209.191.85.217]:43609 "HELO
	smtp107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750747AbXKOBrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 20:47:36 -0500
In-Reply-To: <20071115011110.GB21193@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 November 2007 12:11, Herbert Xu wrote:
> On Wed, Nov 14, 2007 at 05:03:25PM -0800, Christoph Lameter wrote:
> > Well this is likely the result of the SLUB regression. If you allocate an
> > order 1 page then the zone locks need to be taken. SLAB queues the a

Yeah, it appears this is what happened. The lockless page allocator
fastpath appears on the list and the slowpaths disappear after
Herbert's patches. SLAB is doing its own thing, so it avoids that
pitfall.


> > couple of higher order pages and can so serve a couple of requests
> > without going into the page allocator whereas SLUB has to go directly to
> > the page allocator for allocate and free. I guess that needs fixing in
> > the page allocator. Or do I need to add a mechanism to buffer higher
> > order page allcoations to SLUB?
>
> Actually this serves to discourage people from using high-order
> allocations which IMHO is a good thing :)

Yeah I completely agree. The right fix is in the caller...
The bug / suboptimal allocation would not have been found in tcp
if not for this ;)

