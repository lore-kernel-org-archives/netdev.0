From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] use mmiowb in tg3.c
Date: Fri, 22 Oct 2004 11:16:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098407804.6071.22.camel@gaston>
References: <200410211613.19601.jbarnes@engr.sgi.com>
	 <200410211628.06906.jbarnes@engr.sgi.com>
	 <20041021164007.4933b10b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel list <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>, gnb@sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041021164007.4933b10b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-22 at 09:40, David S. Miller wrote:
> On Thu, 21 Oct 2004 16:28:06 -0700
> Jesse Barnes <jbarnes@engr.sgi.com> wrote:
> 
> > This patch originally from Greg Banks.  Some parts of the tg3 driver depend on 
> > PIO writes arriving in order.  This patch ensures that in two key places 
> > using the new mmiowb macro.  This not only prevents bugs (the queues can be 
> > corrupted), but is much faster than ensuring ordering using PIO reads (which 
> > involve a few round trips to the target bus on some platforms).
> 
> Do other PCI systems which post PIO writes also potentially reorder
> them just like this SGI system does?  Just trying to get this situation
> straight in my head.

I think the problem they have is really related to their spinlock, that
is the IO leaking out of the spinlock vs. other CPUs.

On the other hand, as I discussed with Jesse in the past, I'd like to
extend the semantics of mmiowb() to also define full barrier between
cacheable and non-cacheable accesses. That would help fixing a lot of issues
on ppc and ppc64.

Typically, our normal "light" write barrier doesn't reorder between cacheable
and non-cacheable (MMIO) stores, which is why we had to put some heavy sync
barrier in our MMIO writes macros.

By having an mmiowb() that allow to explicitely do this ordering, it would
allow us to relax the barriers in the MMIO macros, and so get back a few
percent of perfs that we lost with the "fix".

I haven't had time to work on that yet though, I need to review with paulus
all the possible race cases, but hopefully, I'll have a patch on top of
Jesse next week or so and will start converting more drivers.

Ben.
