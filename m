From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] [PATCH 1/3] netpoll api
Date: Fri, 3 Oct 2003 14:11:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003191116.GA13573@waste.org>
References: <20031003014104.GR1897@waste.org> <1065179359.1031.42.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1065179359.1031.42.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 03, 2003 at 07:09:20AM -0400, jamal wrote:
> Hi,
> 
> 
> On Thu, 2003-10-02 at 21:41, Matt Mackall wrote:
> > This patch implements a new netpoll API, which allows sending and
> > receiving packets in context where interrupts may be disabled. It
> > provides a common API for implementing features like netconsole,
> > netdump/LKCD, and kgdb-over-ethernet and manages to isolate them
> > almost completely from the details of the network layer.
> > 
> 
> Nice.
> Is the ethernet card in a case like this almost dedicated for this
> kind of work?

No, I've had good results with it as the only interface to the
machine. As netpoll traffic is fairly infrequent, performance seems
little affected.

> Is disable_irq() in the controller safe for shared irqs? Or maybe this
> is critical enough that you dont care?

I'm not aware of any issues there. I understand Red Hat has banged on
this piece pretty heavily recently for their AS kernel. 

> Its a little wasteful to call the controller when there are is no work
> to be done; we have found in NAPI that any extra PCI transactions cost.
> (some IBM people doing benchmarking have complained about specweb not
> looking good where NAPI will have one extra PCI transaction per packet.
> You do it twice the rate NAPI would do it at low speeds).
> Again, the answer maybe who cares, this is critical work.

Just to be sure you read this right, the poll method (NAPI) is
different from poll_controller (netpoll). The name is unfortunate, but
it's what Ingo had in his early 2.4 netconsole patches. I could
s/poll_controller/netpoll/ perhaps.

The NAPI method only gets called when we've frozen the system (kgdb or
netdump) and we're the only ones checking for rx work. The netpoll
method gets called in that case and when something like netconsole is
sending out printks (eg low bandwidth or high priority).

> Have you done any measurements to check whether it was worthwile to do
> the skb preallocation? 

Yes, one of the longer sysrq dumps could knock over earlier versions
of the code.

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
