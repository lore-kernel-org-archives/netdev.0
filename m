From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next v3 07/10] net: Relocate dev_to_net_device() into
 core
Date: Sun, 15 Jan 2017 18:40:36 +0100
Message-ID: <20170115174036.GB19268@kroah.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
 <20170114214713.28109-8-f.fainelli@gmail.com>
 <20170115110753.GG26374@kroah.com>
 <621be9fe-0869-2d0a-fd49-97468c2d4972@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <621be9fe-0869-2d0a-fd49-97468c2d4972@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2017 at 09:20:06AM -0800, Florian Fainelli wrote:
> 
> 
> On 01/15/2017 03:07 AM, Greg KH wrote:
> > On Sat, Jan 14, 2017 at 01:47:10PM -0800, Florian Fainelli wrote:
> >> dev_to_net_device() is moved from net/dsa/dsa.c to net/core/dev.c since
> >> it going to be used by net/dsa/dsa2.c and the namespace of the function
> >> justifies making it available to other users potentially.
> >>
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >> ---
> >>  include/linux/netdevice.h |  2 ++
> >>  net/core/dev.c            | 19 +++++++++++++++++++
> >>  net/dsa/dsa.c             | 18 ------------------
> >>  3 files changed, 21 insertions(+), 18 deletions(-)
> >>
> >> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >> index 97ae0ac513ee..6d021c37b774 100644
> >> --- a/include/linux/netdevice.h
> >> +++ b/include/linux/netdevice.h
> >> @@ -4390,4 +4390,6 @@ do {								\
> >>  #define PTYPE_HASH_SIZE	(16)
> >>  #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
> >>  
> >> +struct net_device *dev_to_net_device(struct device *dev);
> >> +
> >>  #endif	/* _LINUX_NETDEVICE_H */
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index ad5959e56116..7547e2ccc06b 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -8128,6 +8128,25 @@ const char *netdev_drivername(const struct net_device *dev)
> >>  	return empty;
> >>  }
> >>  
> >> +struct net_device *dev_to_net_device(struct device *dev)
> >> +{
> >> +	struct device *d;
> >> +
> >> +	d = device_find_class(dev, "net");
> >> +	if (d) {
> >> +		struct net_device *nd;
> >> +
> >> +		nd = to_net_dev(d);
> >> +		dev_hold(nd);
> >> +		put_device(d);
> >> +
> >> +		return nd;
> >> +	}
> >> +
> >> +	return NULL;
> >> +}
> >> +EXPORT_SYMBOL_GPL(dev_to_net_device);
> > 
> > This really isn't just a "struct device to net device cast" type
> > function, (otherwise a simple container_of() would work).  You are
> > walking the device tree and assuming it is in a specific order so that
> > this function works.  You better document the hell out of this,
> > otherwise people are going to try to use this and get very confused,
> > very quickly...
> 
> Fair enough. Does that make it clearer how the device_find_class() is
> used though? Maybe device_find_class() should be named
> device_find_by_class_name() instead?

Better, but you are just poking around randomly in the device tree and
"hoping" you get it right.  What happens if devices move around?  You
are assuming some sort of heirachy here that I don't understand at
all...

thanks,

greg k-h
