From: Matt Mackall <mpm@selenic.com>
Subject: Re: serious netpoll bug w/NAPI
Date: Thu, 10 Feb 2005 09:14:00 -0800
Message-ID: <20050210171400.GM2366@waste.org>
References: <20050208201634.03074349.davem@davemloft.net> <20050209183219.GA2366@waste.org> <20050209164658.409f8950.davem@davemloft.net> <20050210011104.GF2366@waste.org> <Pine.LNX.4.58.0502101008290.2550@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jmoyer@redhat.com,
        netdev@oss.sgi.com
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0502101008290.2550@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2005 at 10:16:08AM +0100, Martin Josefsson wrote:
> On Wed, 9 Feb 2005, Matt Mackall wrote:
> 
> > --- mm1npc.orig/net/core/dev.c	2005-02-09 14:15:11.236086000 -0800
> > +++ mm1npc/net/core/dev.c	2005-02-09 14:15:13.710042000 -0800
> > @@ -1772,6 +1772,7 @@
> >
> >  		dev = list_entry(queue->poll_list.next,
> >  				 struct net_device, poll_list);
> > +		netpoll_poll_lock(dev);
> >
> >  		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
> >  			local_irq_disable();
> > @@ -1782,9 +1783,11 @@
> >  			else
> >  				dev->quota = dev->weight;
> >  		} else {
> > +			netpoll_poll_unlock(dev);
> >  			dev_put(dev);
> >  			local_irq_disable();
> >  		}
> > +		netpoll_poll_unlock(dev);
> >
> >  #ifdef CONFIG_KGDBOE
> >  		kgdb_process_breakpoint();
> 
> Double unlock?

Yes. The second one should instead be up a few lines here:

                if (dev->quota <= 0 || dev->poll(dev, &budget)) {
+                       netpoll_poll_unlock(dev);
                        local_irq_disable();


-- 
Mathematics is the supreme nostalgia of our time.
