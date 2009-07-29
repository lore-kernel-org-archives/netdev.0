From: Matt Mackall <mpm@selenic.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Wed, 29 Jul 2009 16:48:17 -0500
Message-ID: <1248904097.4545.2934.camel@calx>
References: <20090729073523.GA4515@gondor.apana.org.au>
	 <1248894478.4545.2822.camel@calx>
	 <20090729194300.GB17410@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:51320 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbZG2VtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 17:49:09 -0400
In-Reply-To: <20090729194300.GB17410@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-29 at 15:43 -0400, Neil Horman wrote:
> On Wed, Jul 29, 2009 at 02:07:58PM -0500, Matt Mackall wrote:
> > On Wed, 2009-07-29 at 15:35 +0800, Herbert Xu wrote:
> > > Hi:
> > > 
> > > While working on TX mitigiation, I noticed that while netpoll
> > > takes care to avoid recursive dead locks on the NAPI path, it
> > > has no protection against the TX path when calling the poll
> > > function.
> > > 
> > > So if a driver is in the TX path, and a printk occurs, then a
> > > recursive dead lock can occur if that driver tries to take the
> > > xmit lock in its poll function to clean up descriptors.
> > > 
> > > Fortunately not a lot of drivers do this but at least some are
> > > vulnerable to it, e.g., tg3.
> > > 
> > > So we need to make it very clear that the poll function must
> > > not take any locks or they must use try_lock if the driver is
> > > to support netpoll.
> > 
> > What do you propose?
> 
> I think there is actually some recursion protection.  If you look in
> netpoll_send_skb (where all netpoll transmits pass through), we do a
> __netif_tx_trylock, and only continue down the tx path if we obtain the lock.
> If not, we call netpoll_poll, wait a while, and try again.  I think that should
> prevent the deadlock condition you are concerned about.

Maybe. The general point remains that drivers implementing poll need to
be aware of possible recursion through printk/netconsole in the xmit
path. If there are private locks, netpoll is powerless to prevent
recursive lock attempts.

It occurs to me that we might be able to know when we've moved from core
kernel into a driver's tx path by wrapping the tx method pointer or call
its call sites with something that disabled netconsole until it exited.

-- 
http://selenic.com : development and support for Mercurial and Linux


