From: Mike Anderson <andmike@us.ibm.com>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Wed, 11 Jul 2007 16:37:36 -0700
Message-ID: <20070711233736.GA29241@us.ibm.com>
References: <20070711210137.GE24114@agk.fab.redhat.com>
	<20070711142712.e646995b.akpm@linux-foundation.org>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, Alasdair G Kergon <agk@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20070711142712.e646995b.akpm@linux-foundation.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 11 Jul 2007 22:01:37 +0100
> Alasdair G Kergon <agk@redhat.com> wrote:
> 
> > From: Mike Anderson <andmike@us.ibm.com>
> > 
> > This patch adds a dm-netlink skeleton support to the Makefile, and the dm
> > directory.
> > 
> > ...
> >  
> > +config DM_NETLINK
> > +	bool "DM netlink events (EXPERIMENTAL)"
> > +	depends on BLK_DEV_DM && EXPERIMENTAL
> > +	---help---
> > +	Generate netlink events for DM events.
> 
> Need a dependency on NET there?
> 

Yes.

> > ...
> >
> > +#ifdef CONFIG_DM_NETLINK
> > +
> > +int dm_netlink_init(void);
> > +void dm_netlink_exit(void);
> > +
> > +#else	/* CONFIG_DM_NETLINK */
> > +
> > +static inline int __init dm_netlink_init(void)
> 
> The __init here isn't needed (doesn't make sense, is missing the required
> #include anyway)
> 
> > +{
> > +	return 0;
> > +}
> > +static inline void dm_netlink_exit(void)
> > +{
> > +}
> > +
> > +#endif	/* CONFIG_DM_NETLINK */
> > +
> > +#endif	/* DM_NETLINK_H */
> > Index: linux/drivers/md/dm.c
> > ===================================================================
> > --- linux.orig/drivers/md/dm.c	2007-07-11 21:37:47.000000000 +0100
> > +++ linux/drivers/md/dm.c	2007-07-11 21:37:50.000000000 +0100
> > @@ -7,6 +7,7 @@
> >  
> >  #include "dm.h"
> >  #include "dm-bio-list.h"
> > +#include "dm-netlink.h"
> >  
> >  #include <linux/init.h>
> >  #include <linux/module.h>
> > @@ -176,6 +177,7 @@ int (*_inits[])(void) __initdata = {
> >  	dm_linear_init,
> >  	dm_stripe_init,
> >  	dm_interface_init,
> > +	dm_netlink_init,
> >  };
> >  
> >  void (*_exits[])(void) = {
> > @@ -184,6 +186,7 @@ void (*_exits[])(void) = {
> >  	dm_linear_exit,
> >  	dm_stripe_exit,
> >  	dm_interface_exit,
> > +	dm_netlink_exit,
> >  };
> 
> hm, so if CONFIG_DM_NETLINK=n we end up taking the address of an inlined
> function.  So the __init above _did_ make sense, in a peculiar way.  I
> don't know that gcc will actually put that converted-to-non-inline function
> into the desired section though.
> 
> There's no way in which those inlined functions will ever get inlined.
> Perhaps all this would be better if there was no implementation of
> dm_netlink_init() and dm_netlink_exit() if CONFIG_DM_NETLINK=n and you just
> whack the requisite ifdefs into these tables here?
> 

ok, I will switch to the ifdef CONFIG_DM_NETLINK in the tables.


> >  static int __init dm_init(void)
> > Index: linux/include/linux/netlink.h
> > ===================================================================
> > --- linux.orig/include/linux/netlink.h	2007-07-11 21:37:31.000000000 +0100
> > +++ linux/include/linux/netlink.h	2007-07-11 21:37:50.000000000 +0100
> > @@ -21,7 +21,7 @@
> >  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
> >  #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
> >  #define NETLINK_GENERIC		16
> > -/* leave room for NETLINK_DM (DM Events) */
> > +#define NETLINK_DM		17	/* Device Mapper */
> >  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> >  #define NETLINK_ECRYPTFS	19
> 
> Have the net guys checked this?  

No. The support is a derivative of the netlink support in
scsi_transport_iscsi.c.

-andmike
--
Michael Anderson
andmike@us.ibm.com
