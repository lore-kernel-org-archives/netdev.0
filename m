From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 15:57:10 +0100
Message-ID: <20050314145710.GO31837@postel.suug.ch>
References: <200503141435.38227.hasso@estpak.ee> <20050314133216.GM31837@postel.suug.ch> <200503141605.02959.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200503141605.02959.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Hasso Tepper <200503141605.02959.hasso@estpak.ee> 2005-03-14 16:05
> > The routes must stay if the interface isn't shut down completely. A loss
> > of the carrier can be temporarly for just a very short period of time.
> > What we can do is, like in the neighbour tables, differ between a
> > adimistrative shutdown and a loss of the carrier with a new flag, would
> > that help you?
> 
> In theory yes, if this info is carried over netlink. 

It is carried but not in the way I mentioned. I was wrong with IFF_UP, it
isn't modified. An event is sent upon carrier off and again when the carrier
is found again so you must toggle. Alternatively we can alter a flag in
netif_carrier_(on|off) which is probably a good idea anyway. I'll prepare
a patch for this. Polling sysfs is definitely not the way to go.

> > Problem #1: Differ between a temporary loss of carrier and a permanent
> >             failure. Relatively easy from userspace because userspace
> >      knows about the strategy.
> 
> Is there need for that? There should be knob of course to tune behaviour 
> IMHO. Sure there are applications which expect current behaviour. 

Now that I know you're only taking about implicite routes the problem
is less serious, still a timeout value would be a good thing, one can
always set it to 0 to remove routes immediately or disable it completely.

> I think that you misunderstood. I don't talk about any routes created by any 
> user space applications or by user. These _must_ be untouched of course. 
> I'm talking about routes _kernel_ creates if address is added to the 
> interface. All other routes are not problem anyway. Even if their next hop 
> points to network behind down interface, their next hop is unreachable and 
> route shouldn't be used, no?

Makes a lot more sense now. Yes, the nexthops should be marked unreachable
since the routing cache flushed upon a NETDEV_CHANGE.

What about setting RFT_REJECT/RTN_UNREACHABLE on those routes for the time
the carrier is gone?
