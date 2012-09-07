From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Fri, 7 Sep 2012 11:35:42 -0400
Message-ID: <20120907153542.GB18673@redhat.com>
References: <cover.1345978012.git.joe@perches.com>
 <20120906175158.GB9786@redhat.com>
 <1346957026.13424.5.camel@joe2Laptop>
 <20120907145235.GA18673@redhat.com>
 <1347030721.13424.22.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753Ab2IGPft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 11:35:49 -0400
Content-Disposition: inline
In-Reply-To: <1347030721.13424.22.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 07, 2012 at 08:12:01AM -0700, Joe Perches wrote:
> On Fri, 2012-09-07 at 10:52 -0400, Jason Baron wrote:
> > On Thu, Sep 06, 2012 at 11:43:46AM -0700, Joe Perches wrote:
> > > On Thu, 2012-09-06 at 13:51 -0400, Jason Baron wrote:
> > > > On Sun, Aug 26, 2012 at 04:25:25AM -0700, Joe Perches wrote:
> > > > > The recent commit to fix dynamic_debug was a bit unclean.
> > > > > Neaten the style for dynamic_debug.
> > > > > Reduce the stack use of message logging that uses netdev_printk
> > > > > Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
> > > > > 
> > > > > Joe Perches (5):
> > > > >   dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
> > > > >   netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
> > > > >   netdev_printk/netif_printk: Remove a superfluous logging colon
> > > > >   dev: Add dev_vprintk_emit and dev_printk_emit
> > > > >   device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
> > > > > 
> > > > 
> > > > Looks Good.
> > > > 
> > > > The one thing that is bothering me though, is that for
> > > > __dynamic_dev_dbg(), __dynamic_netdev_dbg(), we are copying much of the core
> > > > logic of __dev_printk(), __netdev_printk(), respectively. I would prefer
> > > > have this in one place. Can we add a 'prefix' argument to __dev_printk(),
> > > > and __netdev_printk() that dynamic debug can use, but is simply empty
> > > > for dev_printk() and netdev_printk().
> > > 
> > > I don't think that's an improvement actually.
> > > Why don't you try it.
> > > 
> > 
> > Ok, below is what I was thinking. It winds up being more deletions than
> > insertions.
> > 
> > Thanks,
> > 
> > -Jason
> > 
> > dynamic debug: remove duplicate __netdev_printk() and  __dev_printk() logic 
> > 
> > Add an option prefix string argument to __netdev_printk() and __dev_printk().
> > In this way dynamic debug does not have to contain duplicate logic.
> > 
> > Signed-off-by: Jason Baron <jbaron@redhat.com>
> > ---
> >  drivers/base/core.c       |   13 +++++++------
> >  include/linux/device.h    |    3 +++
> >  include/linux/netdevice.h |    3 +++
> >  lib/dynamic_debug.c       |   32 ++++++++------------------------
> >  net/core/dev.c            |   11 ++++++-----
> >  5 files changed, 27 insertions(+), 35 deletions(-)
> > 
> > diff --git a/drivers/base/core.c b/drivers/base/core.c
> > index 65f82e3..7b4ee6d 100644
> > --- a/drivers/base/core.c
> > +++ b/drivers/base/core.c
> > @@ -1937,15 +1937,16 @@ int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...)
> >  }
> >  EXPORT_SYMBOL(dev_printk_emit);
> >  
> > -static int __dev_printk(const char *level, const struct device *dev,
> > -			struct va_format *vaf)
> > +int __dev_printk(const char *level, const struct device *dev,
> > +		 char *prefix, struct va_format *vaf)
> >  {
> >  	if (!dev)
> >  		return printk("%s(NULL device *): %pV", level, vaf);
> >  
> >  	return dev_printk_emit(level[1] - '0', dev,
> > -			       "%s %s: %pV",
> > -			       dev_driver_string(dev), dev_name(dev), vaf);
> > +			       "%s%s %s: %pV",
> > +			       prefix, dev_driver_string(dev),
> > +			       dev_name(dev), vaf);
> >  }
> >  
> >  int dev_printk(const char *level, const struct device *dev,
> > @@ -1960,7 +1961,7 @@ int dev_printk(const char *level, const struct device *dev,
> >  	vaf.fmt = fmt;
> >  	vaf.va = &args;
> >  
> > -	r = __dev_printk(level, dev, &vaf);
> > +	r = __dev_printk(level, dev, "", &vaf);
> >  
> >  	va_end(args);
> >  
> > @@ -1980,7 +1981,7 @@ int func(const struct device *dev, const char *fmt, ...)	\
> >  	vaf.fmt = fmt;						\
> >  	vaf.va = &args;						\
> >  								\
> > -	r = __dev_printk(kern_level, dev, &vaf);		\
> > +	r = __dev_printk(kern_level, dev, "", &vaf);		\
> >  								\
> >  	va_end(args);						\
> >  								\
> > diff --git a/include/linux/device.h b/include/linux/device.h
> > index 2da4589..573b15e 100644
> > --- a/include/linux/device.h
> > +++ b/include/linux/device.h
> > @@ -891,6 +891,9 @@ extern const char *dev_driver_string(const struct device *dev);
> >  
> >  #ifdef CONFIG_PRINTK
> >  
> > +extern int __dev_printk(const char *level, const struct device *dev,
> > +			char *prefix, struct va_format *vaf);
> > +
> >  extern int dev_vprintk_emit(int level, const struct device *dev,
> >  			    const char *fmt, va_list args);
> >  extern __printf(3, 4)
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 5f49cc0..63f6165 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -2720,6 +2720,9 @@ static inline const char *netdev_name(const struct net_device *dev)
> >  	return dev->name;
> >  }
> >  
> > +extern int __netdev_printk(const char *level, const struct net_device *dev,
> > +			   char *prefix, struct va_format *vaf);
> > +
> >  extern __printf(3, 4)
> >  int netdev_printk(const char *level, const struct net_device *dev,
> >  		  const char *format, ...);
> > diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
> > index e7f7d99..83bf601 100644
> > --- a/lib/dynamic_debug.c
> > +++ b/lib/dynamic_debug.c
> > @@ -578,6 +578,7 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
> >  	struct va_format vaf;
> >  	va_list args;
> >  	int res;
> > +	char buf[PREFIX_SIZE];
> >  
> >  	BUG_ON(!descriptor);
> >  	BUG_ON(!fmt);
> > @@ -587,16 +588,9 @@ int __dynamic_dev_dbg(struct _ddebug *descriptor,
> >  	vaf.fmt = fmt;
> >  	vaf.va = &args;
> >  
> > -	if (!dev) {
> > -		res = printk(KERN_DEBUG "(NULL device *): %pV", &vaf);
> > -	} else {
> > -		char buf[PREFIX_SIZE];
> > -
> > -		res = dev_printk_emit(7, dev, "%s%s %s: %pV",
> > -				      dynamic_emit_prefix(descriptor, buf),
> > -				      dev_driver_string(dev), dev_name(dev),
> > -				      &vaf);
> > -	}
> > +	res = __dev_printk(KERN_DEBUG, dev,
> > +			   dynamic_emit_prefix(descriptor, buf),
> > +			   &vaf);
> >  
> >  	va_end(args);
> >  
> > @@ -612,6 +606,7 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
> >  	struct va_format vaf;
> >  	va_list args;
> >  	int res;
> > +	char buf[PREFIX_SIZE];
> >  
> >  	BUG_ON(!descriptor);
> >  	BUG_ON(!fmt);
> > @@ -621,20 +616,9 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
> >  	vaf.fmt = fmt;
> >  	vaf.va = &args;
> >  
> > -	if (dev && dev->dev.parent) {
> > -		char buf[PREFIX_SIZE];
> > -
> > -		res = dev_printk_emit(7, dev->dev.parent,
> > -				      "%s%s %s %s: %pV",
> > -				      dynamic_emit_prefix(descriptor, buf),
> > -				      dev_driver_string(dev->dev.parent),
> > -				      dev_name(dev->dev.parent),
> > -				      netdev_name(dev), &vaf);
> > -	} else if (dev) {
> > -		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
> > -	} else {
> > -		res = printk(KERN_DEBUG "(NULL net_device): %pV", &vaf);
> > -	}
> > +	res = __netdev_printk(KERN_DEBUG, dev,
> > +			      dynamic_emit_prefix(descriptor, buf),
> > +			      &vaf);
> >  
> >  	va_end(args);
> >  
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 8ad42fd..5fef0f6 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -6422,15 +6422,16 @@ const char *netdev_drivername(const struct net_device *dev)
> >  	return empty;
> >  }
> >  
> > -static int __netdev_printk(const char *level, const struct net_device *dev,
> > -			   struct va_format *vaf)
> > +int __netdev_printk(const char *level, const struct net_device *dev,
> > +		    char *prefix, struct va_format *vaf)
> >  {
> >  	int r;
> >  
> >  	if (dev && dev->dev.parent) {
> >  		r = dev_printk_emit(level[1] - '0',
> >  				    dev->dev.parent,
> > -				    "%s %s %s: %pV",
> > +				    "%s%s %s %s: %pV",
> > +				    prefix,
> >  				    dev_driver_string(dev->dev.parent),
> >  				    dev_name(dev->dev.parent),
> >  				    netdev_name(dev), vaf);
> > @@ -6455,7 +6456,7 @@ int netdev_printk(const char *level, const struct net_device *dev,
> >  	vaf.fmt = format;
> >  	vaf.va = &args;
> >  
> > -	r = __netdev_printk(level, dev, &vaf);
> > +	r = __netdev_printk(level, dev, "", &vaf);
> >  
> >  	va_end(args);
> >  
> > @@ -6475,7 +6476,7 @@ int func(const struct net_device *dev, const char *fmt, ...)	\
> >  	vaf.fmt = fmt;						\
> >  	vaf.va = &args;						\
> >  								\
> > -	r = __netdev_printk(level, dev, &vaf);			\
> > +	r = __netdev_printk(level, dev, "", &vaf);		\
> >  								\
> >  	va_end(args);						\
> >  								\
> 
> 'Morning Jason.
> 
> Funny.  Crossed emails.
> 
> I still don't think this is better.
> 
> This does add an effectively unused "" to non-dynamic debug builds.
> ie: the more common paths are encumbered as dynamic_debug isn't
> a normally enabled distribution CONFIG_ option.

Yeah, not sure - I know Fedora enables it.

> 
> About the patch:
> 
> Wouldn't dev_printk_emit now would have a single caller and
> could be made static?
> 

Yes, I believe so.

> Don't __dev_printk and __netdev_printk need EXPORT_SYMBOLs?
> 

The usage in lib/dynamic_debug.c can't be built as a module. So not required.

If nobody else thinks this patch is better, let's at least add a comment in
__dev_printk() and __netdev_printk() to fix dynamic debug, if these are changed.

Thanks,

-Jason
