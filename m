From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Fw: b44 ifconfig fails with ENOMEM
Date: Fri, 21 Jan 2005 02:32:22 +0200
Message-ID: <20050121003222.GA4290@ee.oulu.fi>
References: <20050103191836.57f918e5.akpm@osdl.org> <20050104142026.000be2e8.davem@davemloft.net> <20050107220233.GA9639@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050107220233.GA9639@ee.oulu.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 08, 2005 at 12:02:33AM +0200, Pekka Pietikainen wrote:
> On Tue, Jan 04, 2005 at 02:20:26PM -0800, David S. Miller wrote:
> > On Mon, 3 Jan 2005 19:18:36 -0800
> > Andrew Morton <akpm@osdl.org> wrote:
> > 
> > > b44 requires an order-8 allocation?  Good luck...
> > 
> > Yes, it allocates a full TX ring worth of bounce buffers
> > to work around a DMA addressing limitation.  It should do
> > a bunch of smaller consistent allocations instead of one
> > huge one, that's for sure.
> -ENOHARDWARE (Santa got me an Athlon64 with dual GigE) so someone else will
> have to pick up the ball. Shouldn't be too difficult, quickly thinking
> something like:
Found some testers, even when the allocations are done a page at a time it
still won't work, something else is always sucking up GFP_DMA. I don't think
there really a way to work around the DMA issue and be useful to the 99% of
the userbase that don't need the workaround (only people with a non-standard
VM layout actually do). IIRC making the ring smaller makes it crash and 
burn for whatever reason so that's not a solution either.

Awful kludge of the day would be to just fake having a 4GB DMA mask and
check every consistent allocation until something over 1GB gets used, then 
set the mask correctly to 1GB and watch the kernel give you <=16MB mem...

or the even more trivial:

#ifdef CONFIG_4G4G 
#define B44_DMA_MASK 0x3fffffff
#else
#define B44_DMA_MASK 0xffffffff
#endif

Or fix the generic i386 PCI DMA stuff, but is that worth it for just one
driver? 
