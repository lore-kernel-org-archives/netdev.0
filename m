From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 19:11:35 -0500
Message-ID: <1206663095.4122.82.camel@calx>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <1206645050.4849.77.camel@localhost>
	 <20080327.150456.39560267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, ilpo.jarvinen@helsinki.fi,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:44737 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753408AbYC1AMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 20:12:45 -0400
In-Reply-To: <20080327.150456.39560267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-03-27 at 15:04 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 27 Mar 2008 12:10:50 -0700
>=20
> > On Thu, 2008-03-27 at 14:38 +0200, Ilpo J=C3=A4rvinen wrote:
> > > Allyesconfig (v2.6.24-mm1):
> >=20
> > I think this change is only good in severely memory
> > limited uses.  This will very likely negatively impact
> > high speed networking.  It's a speed/size trade off.
>=20
> I severely doubt this, the bulk of the overhead of
> skb_put() is the atomic operation, not whether the
> instructions get executed inline or not.

More generally, we have to weigh the cost of a function call against th=
e
cost of a cache miss here or -somewhere else-. That is, running multipl=
e
copies of this code inline means that much other code gets pushed out o=
f
cache. Further, consolidating multiple copies of this code into one
means it's that much more likely to already be in cache when we hit it.

In the 486 era, when CPU performance was close to 1:1 with memory,
branches were more expensive than sequential memory fetches, and
registers were scarce, inlining made a fair amount of sense.

But now we've moved very far away from that indeed: CPU is orders of
magnitude faster than memory, branches are quite cheap, and register
are.. well, not quite as scarce. All of that means that a cache miss is
much more expensive than a function call.

Inlining typical only makes sense for fairly trivial transformations
(something you'd consider doing with a macro) where the code to set up =
a
function call is comparable to the size of the function itself and code
in innermost loops. And if the inline is in a header file, it's probabl=
y
not in the latter class.

In the case of this patch, removing 60-100k from the network stack mean=
s
we're almost certainly avoiding a lot of cache misses in the big pictur=
e
while taking a few cycle hit per packet in the smallest scale.

--=20
Mathematics is the supreme nostalgia of our time.

