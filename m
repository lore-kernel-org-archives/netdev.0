From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI note
Date: Tue, 18 Feb 2003 21:53:12 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218212441.M25195@shell.cyberus.ca>
References: <3E4D66DF.3040800@colorfullife.com> <3E4D8295.2050400@pobox.com>
 <20030217.185719.28797590.davem@redhat.com> <3E525FD8.1060009@colorfullife.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
   "" <zaitcev@redhat.com>, "" <jbourne@mtroyal.ab.ca>,
   "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <3E525FD8.1060009@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 18 Feb 2003, Manfred Spraul wrote:

> David S. Miller wrote:
>
> >   From: Jeff Garzik <jgarzik@pobox.com>
> >   Date: Fri, 14 Feb 2003 18:58:13 -0500
> >
> >   Manfred Spraul wrote:
> >   > It seems to be a generic NAPI restriction:
> >   > The caller of netif_receive_skb() must not own a spinlock that is
> >   > acquired from an interrupt handler.
> >
> >   Thanks much for noticing this, Manfred.
> >
> >I think this logic is buggy.
> >
> >In the example I've seen posted, only a NAPI implementation bug
> >could cause the situation to occur.
> >
> >If cpu1 is in ->poll() for the driver, then by definition the
> >device shall not cause interrupts.  The device's interrupts
> >are disabled before we enter the ->poll() handler, and as such
> >the "cpu2 take device interrupt and takes driver->lock" cannot
> >occur.
> >
> >
> No. I think the rule is that drivers that use the NAPI interface must
> not cause interrupts for packet receive and out-of-rx-buffers conditions.

Ah, but that is only one of two rules.
Theres other drivers which dont follow this rule and just shutdown
all interupt sources. I know that the e1000 for example does this.
I am not sure about the tg3. I think the doc says this but may not
emphasize it as strongly.
So if tg3 uses method 2 then its as Dave says - a bug.

> But what about media error interrupts, or tx interrupts? Or MIB counter
> overflow, etc. What about shared pci interrupts?

Shared interupts should be interesting actually.
However if you are in poll mode and you receive an interupt you should be
able to quickly determine its not yours without much effect on shared
locks, no?

> All of them could occur, and if they take a spinlock that is held across
> netif_receive_skb(), then it can deadlock.
>

yes this could happen with method 1 of programming the driver; however,
tx, receive, link are essentially separate threads and would hardly share
locks.

> OTHO if it's guaranteed that no interrupt occurs, then the nic should
> not take a spinlock at all and rely on the synchronization provided by
> NAPI. (->poll is single-threaded).
>

i havent studied the e1000 theres a lot of this happening already.
I dont think you need say to protect the tx ring for example from
tx completion interupts vs regular softirq path.

cheers,
jamal
