From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
	CAN module
Date: Thu, 1 Apr 2010 17:43:11 -0700
Message-ID: <20100402004311.GB25412@ovro.caltech.edu>
References: <1269881932-3803-3-git-send-email-iws@ovro.caltech.edu>
	<20100401130359.9a9b5c7b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100401130359.9a9b5c7b.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 01, 2010 at 01:03:59PM -0700, Andrew Morton wrote:
> On Mon, 29 Mar 2010 09:58:51 -0700
> "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org> wrote:
> 
> > The Janz VMOD-ICAN3 is a MODULbus daughterboard which fits onto any
> > MODULbus carrier board. It is an intelligent CAN controller with a
> > microcontroller and associated firmware.
> > 
> 
> A neat-looking driver.
> 
> > ...
> >
> > +	spin_lock_irqsave(&mod->lock, flags);
> >
> > ...
> 
> It does this rather a lot.  it seems to be doing quite a lot of work
> under that lock, too - quite a lot of memcpy_toio(), other stuff.
> 

Like most similar cards, the host computer communicates to the
microcontroller through a dual ported memory (DPM) interface. In this
card, it is split into 256x 256 byte pages/windows.

The lock ensures that once code sets a window, it doesn't change while
the memcpy/iowrite happens.

> Is there potential here to disable interrupt for too long?  Not
> possible to use spin_lock_bh() here?
> 

The largest possible memcpy_(to|from)io() in the driver is 256 bytes.
Not too huge, but I understand the concern.

Looking at this again, I don't take the lock in the interrupt handler
(nor do I need to). What contexts do the network driver's xmit() and
napi() routines run in? hardirq and softirq respectively, right? In that
case, I think spin_lock_bh() is probably enough.

Ira
