From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] [PATCH 1/3] netpoll api
Date: Sat, 4 Oct 2003 15:33:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004203304.GD13573@waste.org>
References: <20031003014104.GR1897@waste.org> <1065179359.1031.42.camel@jzny.localdomain> <20031003191116.GA13573@waste.org> <1065297729.1031.73.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1065297729.1031.73.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2003 at 04:02:09PM -0400, jamal wrote:
> On Fri, 2003-10-03 at 15:11, Matt Mackall wrote:
> 
> > > Nice.
> > > Is the ethernet card in a case like this almost dedicated for this
> > > kind of work?
> > 
> > No, I've had good results with it as the only interface to the
> > machine. As netpoll traffic is fairly infrequent, performance seems
> > little affected.
> > 
> 
> Ok, I suppose if you are running some serious server you wont be
> debugging either. Did i understand correctly that no netpoll trafic
> translates to a device being removed from the poll list? i.e only when
> theres traffic to send for example would the controller be invoked? 

Polling is only on demand. Eg, in the netconsole case, polling only
happens to push a packet out when a printk occurs. In the netdump or
kgdb case, the entire machine is essentially brought to a halt anyway,
so overhead is irrelevant.
 
> > > Is disable_irq() in the controller safe for shared irqs? Or maybe this
> > > is critical enough that you dont care?
> > 
> > I'm not aware of any issues there. I understand Red Hat has banged on
> > this piece pretty heavily recently for their AS kernel. 
> > 
> 
> Lets say you have a vga card and ethernet sharing the same irq and doing
> a lot of debugging ... would disabling that shared irq kill the display
> for example? 

Yes. Again, in the netconsole case, this will only happen when a
printk is occurring. Netconsole is primarily of interest for debugging
or replacing serial console for headless servers. In the 'replacing
serial console' case, it actually reduces overhead because polling the
network is much faster than polling serial.

> > > Its a little wasteful to call the controller when there are is no work
> > > to be done; we have found in NAPI that any extra PCI transactions cost.
> > > (some IBM people doing benchmarking have complained about specweb not
> > > looking good where NAPI will have one extra PCI transaction per packet.
> > > You do it twice the rate NAPI would do it at low speeds).
> > > Again, the answer maybe who cares, this is critical work.
> > 
> > Just to be sure you read this right, the poll method (NAPI) is
> > different from poll_controller (netpoll). The name is unfortunate, but
> > it's what Ingo had in his early 2.4 netconsole patches. I could
> > s/poll_controller/netpoll/ perhaps.
> > 
> 
> Actually the name is proper since polling is involved. I can see the
> confusion with NAPI - so from that angle changing it to something
> more descriptive of its function rather than how it achieves it would
> help.

Ok, netpoll it is.

-- 
Matt Mackall : http://www.selenic.com : of or relating to the moon
