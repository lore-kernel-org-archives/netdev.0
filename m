From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: Re: [PATCH] IPv6: Add 'autoconf' and 'disable_ipv6' module
 parameters
Date: Wed, 25 Mar 2009 05:28:27 +0100 (CET)
Message-ID: <alpine.LNX.2.00.0903250526050.6682@firda.kolla.no>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Brian Haley <brian.haley@hp.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, linux@kolla.no, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:44264 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbZCYE2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 00:28:33 -0400
In-Reply-To: <49C99315.6070504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Mar 2009, Vlad Yasevich wrote:

> Brian Haley wrote:
> > This is the quick and easy patch to add autoconf and
> > disable_ipv6 module parameters to IPv6.  I don't think anything
> > more complicated is needed, assuming you play with the /etc
> > configuration files.
> > 
> > For example, if you wanted to enable IPv6 just on 'lo' you
> > would:
> > 
> > 1. Add "ipv6" to /etc/modules (if you don't, step #3 might fail)
> > 
> > 2. Add this to /etc/modprobe.conf:
> > 
> > 	options ipv6 disable_ipv6=1
> > 
> > 3. Add these to /etc/sysctl.conf:
> > 
> > 	net.ipv6.conf.all.disable_ipv6=0
> > 	net.ipv6.conf.lo.disable_ipv6=0
> 
> This is kind of confusing.  First you say, disable IPv6, then you say enable IPv6, but
> nothing happens.  Unless you typo-ed the 'all.disable_ipv6 = 0'...

I bet that should have been "net.ipv6.conf.all.disable_ipv6=1" yes. :)

> Also, it looks like if someone decides to switch IPv6 back on for a particular
> interface, they would have to wait until the next RA to get an address.  Not an
> optimum solution.

Isnt this the normal way anyways, or do new interfaces send some sort of
"I'm new here, give me a prefix and router announcement, please!" normally
when they go online? If so, maybe that should be done here as well.

> > # ip -6 a
> > 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 
> >     inet6 ::1/128 scope host 
> >        valid_lft forever preferred_lft forever
> > 
> > The wording can probably be cleaned-up a little in ipv6.txt,
> > comments welcome.
> > 
> > 
> > ---------------------------------------------------------------
> > 
> > Add 'autoconf' and 'disable_ipv6' parameters to the IPv6 module.
> > 
> > The first controls if IPv6 addresses are autoconfigured from
> > prefixes received in Router Advertisements.  The IPv6 loopback
> > (::1) and link-local addresses are still configured.
> > 
> > The second controls if IPv6 addresses are desired at all.  No
> > IPv6 addresses will be added to any interfaces.
> > 
> > Signed-off-by: Brian Haley <brian.haley@hp.com>
> > ---
> >  Documentation/networking/ipv6.txt |   37 +++++++++++++++++++++++++++++++++++++
> >  include/linux/ipv6.h              |    6 ++++++
> >  net/ipv6/addrconf.c               |   12 +++++++++---
> >  net/ipv6/af_inet6.c               |   22 +++++++++++++++++-----
> >  4 files changed, 69 insertions(+), 8 deletions(-)
> > 
> > diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/ipv6.txt
> > index 268e5c1..9fd7e21 100644
> > --- a/Documentation/networking/ipv6.txt
> > +++ b/Documentation/networking/ipv6.txt
> > @@ -33,3 +33,40 @@ disable
> >  
> >  		A reboot is required to enable IPv6.
> >  
> > +autoconf
> > +
> > +	Specifies whether to enable IPv6 address autoconfiguration
> > +	on all interfaces.  This might be used when one does not wish
> > +	for addresses to be automatically generated from prefixes
> > +	received in Router Advertisements.
> > +
> > +	The possible values and their effects are:
> > +
> > +	0
> > +		IPv6 address autoconfiguration is disabled on all interfaces.
> > +
> > +		Only the IPv6 loopback address (::1) and link-local addresses
> > +		will be added to interfaces.
> > +
> > +	1
> > +		IPv6 address autoconfiguration is enabled on all interfaces.
> > +
> > +		This is the default value.
> > +
> > +disable_ipv6
> > +
> > +	Specifies whether to disable IPv6 on all interfaces.
> > +	This might be used when no IPv6 addresses are desired.
> > +
> > +	The possible values and their effects are:
> > +
> > +	0
> > +		IPv6 is enabled on all interfaces.
> > +
> > +		This is the default value.
> > +
> > +	1
> > +		IPv6 is disabled on all interfaces.
> > +
> > +		No IPv6 addresses will be added to interfaces.
> > +
> > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > index 476d946..c662efa 100644
> > --- a/include/linux/ipv6.h
> > +++ b/include/linux/ipv6.h
> > @@ -169,6 +169,12 @@ struct ipv6_devconf {
> >  	__s32		accept_dad;
> >  	void		*sysctl;
> >  };
> > +
> > +struct ipv6_params {
> > +	__s32 disable_ipv6;
> > +	__s32 autoconf;
> > +};
> > +extern struct ipv6_params ipv6_defaults;
> >  #endif
> >  
> >  /* index values for the variables in ipv6_devconf */
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 8499da9..da6f01e 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -1784,6 +1784,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
> >  	__u32 prefered_lft;
> >  	int addr_type;
> >  	struct inet6_dev *in6_dev;
> > +	struct net *net = dev_net(dev);
> >  
> >  	pinfo = (struct prefix_info *) opt;
> >  
> > @@ -1841,7 +1842,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
> >  		if (addrconf_finite_timeout(rt_expires))
> >  			rt_expires *= HZ;
> >  
> > -		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
> > +		rt = rt6_lookup(net, &pinfo->prefix, NULL,
> >  				dev->ifindex, 1);
> >  
> >  		if (rt && addrconf_is_prefix_route(rt)) {
> > @@ -1874,11 +1875,11 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
> >  
> >  	/* Try to figure out our local address for this prefix */
> >  
> > -	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
> > +	if (pinfo->autoconf && in6_dev->cnf.autoconf &&
> > +	    net->ipv6.devconf_all->autoconf) {
> >  		struct inet6_ifaddr * ifp;
> >  		struct in6_addr addr;
> >  		int create = 0, update_lft = 0;
> > -		struct net *net = dev_net(dev);
> >  
> >  		if (pinfo->prefix_len == 64) {
> >  			memcpy(&addr, &pinfo->prefix, 8);
> > @@ -4378,6 +4379,11 @@ static int addrconf_init_net(struct net *net)
> >  		dflt = kmemdup(dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
> >  		if (dflt == NULL)
> >  			goto err_alloc_dflt;
> > +	} else {
> > +		/* these will be inherited by all namespaces */
> > +		all->autoconf = dflt->autoconf = ipv6_defaults.autoconf;
> > +		all->disable_ipv6 = dflt->disable_ipv6 =
> > +			ipv6_defaults.disable_ipv6;
> 
> Why set 'all'?  Since no interfaces are created yet, setting dflt accomplishes
> what you want.

How do you know that no interfaces are created? The IPv6 modules might not
have been loaded on boot, but at a later stage.

> >  	}
> >  
> >  	net->ipv6.devconf_all = all;
> > diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > index fbf533c..7278dce 100644
> > --- a/net/ipv6/af_inet6.c
> > +++ b/net/ipv6/af_inet6.c
> > @@ -72,9 +72,21 @@ MODULE_LICENSE("GPL");
> >  static struct list_head inetsw6[SOCK_MAX];
> >  static DEFINE_SPINLOCK(inetsw6_lock);
> >  
> > -static int disable_ipv6 = 0;
> > -module_param_named(disable, disable_ipv6, int, 0);
> > -MODULE_PARM_DESC(disable, "Disable IPv6 such that it is non-functional");
> > +struct ipv6_params ipv6_defaults = {
> > +	.disable_ipv6 = 0,
> > +	.autoconf = 1,
> > +};
> > +
> > +static int disable_ipv6_mod = 0;
> > +
> > +module_param_named(disable, disable_ipv6_mod, int, 0444);
> > +MODULE_PARM_DESC(disable, "Disable IPv6 module such that it is non-functional");
> > +
> > +module_param_named(disable_ipv6, ipv6_defaults.disable_ipv6, int, 0444);
> > +MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
> > +
> > +module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
> > +MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all interfaces");
> >  
> >  static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
> >  {
> > @@ -1013,7 +1025,7 @@ static int __init inet6_init(void)
> >  	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
> >  		INIT_LIST_HEAD(r);
> >  
> > -	if (disable_ipv6) {
> > +	if (disable_ipv6_mod) {
> >  		printk(KERN_INFO
> >  		       "IPv6: Loaded, but administratively disabled, "
> >  		       "reboot required to enable\n");
> > @@ -1202,7 +1214,7 @@ module_init(inet6_init);
> >  
> >  static void __exit inet6_exit(void)
> >  {
> > -	if (disable_ipv6)
> > +	if (disable_ipv6_mod)
> >  		return;
> >  
> >  	/* First of all disallow new sockets creation. */

-- kolla
