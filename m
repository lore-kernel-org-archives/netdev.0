From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] use mmiowb in tg3.c
Date: Fri, 22 Oct 2004 14:00:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16760.34275.675065.538997@cargo.ozlabs.ibm.com>
References: <200410211613.19601.jbarnes@engr.sgi.com>
	<200410211628.06906.jbarnes@engr.sgi.com>
	<20041021164007.4933b10b.davem@davemloft.net>
	<200410212201.35430.jbarnes@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesse Barnes <jbarnes@engr.sgi.com>, akpm@osdl.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        gnb@sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Barnes <jbarnes@sgi.com>
In-Reply-To: <200410212201.35430.jbarnes@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse Barnes writes:

> On Thursday, October 21, 2004 6:40 pm, David S. Miller wrote:
> > On Thu, 21 Oct 2004 16:28:06 -0700
> >
> > Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> > > This patch originally from Greg Banks.  Some parts of the tg3 driver
> > > depend on PIO writes arriving in order.  This patch ensures that in two
> > > key places using the new mmiowb macro.  This not only prevents bugs (the
> > > queues can be corrupted), but is much faster than ensuring ordering using
> > > PIO reads (which involve a few round trips to the target bus on some
> > > platforms).
> >
> > Do other PCI systems which post PIO writes also potentially reorder
> > them just like this SGI system does?  Just trying to get this situation
> > straight in my head.
> 
> The HP guys claim that theirs don't, but PPC does, afaik.  And clearly any 
> large system that posts PCI writes has the *potential* of reordering them.

No, PPC systems don't reorder writes to PCI devices.  Provided you use
inl/outl/readl/writel et al., all PCI accesses from one processor are
strictly ordered, and if you use a spinlock, that gives you strict
access ordering between processors.

Our barrier instructions mostly order cacheable accesses separately
from non-cacheable accesses, except for the strongest barrier
instruction, which orders everything.  Thus it would be useful for us
to have an explicit indication of when a cacheable write (i.e. to main
memory) has to be completed (from a PCI device's point of view) before
a non-cacheable device read or write (e.g. to kick off DMA).

Paul.
