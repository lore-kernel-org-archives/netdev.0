From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Thu, 24 Mar 2011 16:42:57 +0000
Message-ID: <1300984977.2689.11.camel@bwh-desktop>
References: <20110323124939.GA7834@redhat.com>
	 <20110323083357.457f10aa@nehalam> <20110324081621.GA5508@redhat.com>
	 <20110324081539.47ad0972@nehalam>  <20110324155937.GA6041@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23401 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab1CXQnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 12:43:01 -0400
In-Reply-To: <20110324155937.GA6041@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-24 at 16:59 +0100, Stanislaw Gruszka wrote:
> On Thu, Mar 24, 2011 at 08:15:39AM -0700, Stephen Hemminger wrote:
> > > On Wed, Mar 23, 2011 at 08:33:57AM -0700, Stephen Hemminger wrote:
> > > > On Wed, 23 Mar 2011 13:52:04 +0100
> > > > Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> > > > 
> > > > > Add lro_enable variable to read NETIF_F_LRO flag only once per napi poll
> > > > > call. This should fix theoretical race condition with
> > > > > myri10ge_set_rx_csum() and myri10ge_set_flags() where flag NETIF_F_LRO
> > > > > can be changed.
> > > > 
> > > > You may need a barrier or the race may still be there.
> > > 
> > > I don't understand why barrier in that case is need.
> > > 
> > > What I tried to avoid is.
> > > 
> > > myri10ge_clean_rx_done():
> > > 
> > > if (dev->features & NETIF_F_LRO) 
> > > 	setup lro 
> > > 					myri10ge_set_flags()
> > > 
> > > if (dev->features & NETIF_F_LRO)
> > > 	flush lro
> > > 
> > > Now we read dev->features & NETIF_F_LRO only once to local
> > > lro_enabled variable. So we can not flush without setup
> > > or setup without flush. No idea why memory barries is still
> > > needed.
> > > 
> > > > The driver seems to use mb() where wmb() is intended, and never use rmb()?
> > > 
> > > Yes, I think we can have some optimalization here.
> > > 
> > 
> > Without barrier there is no guarantee that compiler read the flags
> > into a local variable. It is free to do the same thing as the original
> > code.
> 
> Ok, so C code like:
> 
> code1
> if (dev->features & NETIF_F_LRO) 
> 	branch1
> code2;
> if (dev->features & NETIF_F_LRO)
> 	branch2
> 
> and
> 
> bool lro_enabled = dev->features & NETIF_F_LRO;
> code1
> if (lro_enabled)
> 	branch1
> code2
> if (lro_enabled)
> 	branch2
> 
> can give the same assembly output.
[...]

Yes.  A C compiler is allowed to assume that data are not shared between
multiple threads, and apply any transformations that would not affect
the behaviour of a single-threaded program.

We can make use of some gcc extensions (wrapped up in macros like
barrier()) to inhibit some such transformations.  We also assume that
access to an int, long or pointer variable can be atomic.  The
ACCESS_ONCE() macro adds volatile-qualification to such memory access,
which inhibits duplication of the access.

So, if you only care that this function has a consistent value for
lro_enabled, you can read dev->features with ACCESS_ONCE():

	bool lro_enabled = ACCESS_ONCE(dev->features) & NETIF_F_LRO;

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

