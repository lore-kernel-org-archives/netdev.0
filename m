From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 08/10] dynamic_debug: make netif_dbg() call
 __netdev_printk()
Date: Thu, 7 Jul 2011 10:13:00 -0400
Message-ID: <20110707141259.GA2536@redhat.com>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
 <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
 <1309989543.1710.19.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309989543.1710.19.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 06, 2011 at 02:59:03PM -0700, Joe Perches wrote:
> On Wed, 2011-07-06 at 13:25 -0400, Jason Baron wrote:
> > From: Jason Baron <jbaron@redhat.com>
> > 
> > Previously, netif_dbg() was using dynamic_dev_dbg() to perform
> > the underlying printk. Fix it to use __netdev_printk(), instead.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Jason Baron <jbaron@redhat.com>
> > ---
> >  include/linux/dynamic_debug.h |   12 ++++++++++++
> >  include/linux/netdevice.h     |    6 ++----
> >  2 files changed, 14 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
> []
> > +#define dynamic_netif_dbg(dev, cond, fmt, ...) do {			\
> > +	static struct _ddebug descriptor				\
> > +	__used								\
> > +	__attribute__((section("__verbose"), aligned(8))) =		\
> > +	{ KBUILD_MODNAME, __func__, __FILE__, fmt, __LINE__,		\
> > +		_DPRINTK_FLAGS_DEFAULT };				\
> > +	if (unlikely(descriptor.enabled)) {				\
> > +		if (cond)						\
> > +			__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);\
> > +	}								\
> > +	} while (0)
> > +
> 
> Just nits:
> 
> I think it'd be better to use
> #define dynamic_netif_dbg(etc)						\
> do {									\
> 	etc...
> } while (0)
> 
> so that there aren't 2 consecutive close braces at the same indent level.
> 
> and maybe just use one test
> 
> 	if (unlikely(descriptor.enabled) && cond)
> 		__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);
> 

If you look at the next patch, 9/10, I've combined the tests there
just as you've described. I agree, that it would be better if that were
folded into this patch. will fix.

> 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 9b132ef..99c358f 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -2731,10 +2731,8 @@ do {								\
> >  #elif defined(CONFIG_DYNAMIC_DEBUG)
> >  #define netif_dbg(priv, type, netdev, format, args...)		\
> >  do {								\
> > -	if (netif_msg_##type(priv))				\
> > -		dynamic_dev_dbg((netdev)->dev.parent,		\
> > -				"%s: " format,			\
> > -				netdev_name(netdev), ##args);	\
> > +	dynamic_netif_dbg(netdev, (netif_msg_##type(priv)),	\
> > +				  format, ##args);		\
> 
> Because you've already added dynamic_netdev_dbg,
> maybe this should be:
> 
> #define netif_dbg(priv, type, netdev, format, args...)		\
> do {								\
> 	if (netif_msg_##type(priv))				\
> 		dynamic_netdev_dbg(netdev, format, ##args);	\
> } while (0)
> 
> 

The reason I didn't add it this way is b/c I plan on converting the
outer 'ifs' to the jump label infrastructure - which makes the disabled
case just a no-op and moves the printk and tests out of line.

Until that is done, i could see coding it as you've suggested, but I'd
prefer to leave it as is (and leave future churn to within the dynamic
debug code as opposed to the netdevice.h header).

Thanks,

-Jason
