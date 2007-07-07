From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 9/9] netconsole: Support dynamic reconfiguration
 using configfs
Date: Sat, 7 Jul 2007 13:18:45 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707071216450.24470@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070707060114.GB1011@tasint.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:56824 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211AbXGGH1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 03:27:04 -0400
In-Reply-To: <20070707060114.GB1011@tasint.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joel,

On Fri, 6 Jul 2007, Joel Becker wrote:
> On Wed, Jul 04, 2007 at 04:38:24PM +0530, Satyam Sharma wrote:
> >  struct netconsole_target {
> >  	struct list_head	list;
> > +	struct config_item	item;
> > +	int			id;
> > +	int			enabled;
> >  	int			dev_status;
> >  	struct netpoll		np;
> >  };
> 
> 	If you're trying to be good with your CONFIG_NETCONSOLE_DYNAMIC
> ifdefs, you probably want to ifdef the item.  You'll save space when
> NETCONSOLE_DYNAMIC is off.

Hmm, I had thought about this, but thought people might not like
another #ifdef. But then this kind of thing is very idiomatic throughout
the kernel, so ok, I'll do this.

[ BTW that .id field also looks like it can be gotten rid of altogether.
I was using it to print informational / error messages in the store()
operations below, but I guess I'll just use config_item_name() there
as well. ]

> > +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> > +
> > +/*
> > + * Targets that were created by parsing the boot/module option string
> > + * do not exist in the configfs hierarchy and will never go away (and
> > + * have zeroed-out config_item members). So make these a no-op for them.
> > + */
> > +static void netconsole_target_get(struct netconsole_target *nt)
> > +{
> > +	static struct config_item empty_item;	/* Zeroed-out config_item */
> > +
> > +	if (memcmp(&nt->item, &empty_item, sizeof(struct config_item)))
> > +		config_item_get(&nt->item);
> > +}
> 
> 	I was going to point out that you could merely check
> config_item_name(&nt->item) != NULL, because a valid configfs object has
> a name and your zeroed object does not.

Ok.

[ BTW: not related to dynamic netconsole / issue at hand, but ... I
just noticed in fs/configfs/item.c that ci_name is set to point to
embedded ci_namebuf array in config_item_set_name (if name was small
enough to be set in ci_namebuf itself), which is called from
config_item_init_type_name(). So, this keeps ci_name and ci_namebuf
in sync for such items.

However, for items that are statically initialized (often the
group->cg_item members of subsystems or default groups) we often simply
set ci_namebuf and then call config_item_init() -- say via
config_group_init(), like I've done with the netconsole subsystem in this
patch -- but config_item_init() does not set ci_name for such items to
ci_namebuf. This means the ci_name member of _initialized_ config_items
with their names in ci_namebuf is left un-initialized (NULL, actually,
because the subsys / default group would likely be static).

This doesn't really affect dynamic netconsole, because all config_items
that will be checked in the get() / put() check above are targets that
were initialized with config_item_init_type_name(), but something to
think about for perhaps other users?

Perhaps users who want to statically initialize their config_items must
be asked to just use ci_name and avoid ci_namebuf altogether? ]

> 	I don't, off the top of my head, see a problem with removing the
> _get/_put cycle, because you do have them under the spinlock.  Things
> should behave correctly.  However, the _get/_put pair is "cleaner", in
> that it expresses the relationship and doesn't add a special case of "I
> happen to know this is safe".

Right. We shouldn't special case (at least not without adding a comment
why that would be right) and we never know what might happen to the code
at some later day. So let's keep the get() / put() pair.

> > +		/*
> > +		 * Skip netpoll_parse_options() -- all the attributes are
> > +		 * already configured in nt->np through configfs. But at
> > +		 * least let's print the useful stuff it used to output :-)
> > +		 */
> > +		printk(KERN_INFO "%s: local port %d\n",
> > +				 np->name, np->local_port);
> > +		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
> > +				 np->name, HIPQUAD(np->local_ip));
> > +		printk(KERN_INFO "%s: interface %s\n",
> > +				 np->name, np->dev_name);
> > +		printk(KERN_INFO "%s: remote port %d\n",
> > +				 np->name, np->remote_port);
> > +		printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
> > +				 np->name, HIPQUAD(np->remote_ip));
> > +		printk(KERN_INFO "%s: remote ethernet address "
> > +				 "%02x:%02x:%02x:%02x:%02x:%02x\n",
> > +				 np->name,
> > +				 np->remote_mac[0], np->remote_mac[1],
> > +				 np->remote_mac[2], np->remote_mac[3],
> > +				 np->remote_mac[4], np->remote_mac[5]);
> 
> 	Shouldn't you break this out into a function so that both places
> can use it?

Hmm, netpoll_parse_options() currently prints these separately as and
how it walks through the input string parsing it. But changing that to
just print all these out together at the end if / when the parse is
successful seems better than what it's doing right now. I'll do this too.

> > +#define NETCONSOLE_TARGET_ATTR_RO(_name)				\
> > +static struct netconsole_target_attr netconsole_target_##_name =	\
> > +__CONFIGFS_ATTR(_name, S_IRUGO, show_##_name, NULL)
> > +
> > +#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
> > +static struct netconsole_target_attr netconsole_target_##_name =	\
> > +__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
> 
> 	Perhaps an indent would be clearer, but that's a tiny nitpick.

Yes, an indent would be good there.

> >  	/*
> > -	 * Neither the netdev notifier, nor the console have been
> > -	 * registered so far. Nobody's racing us, so skip the lock.
> > +	 * Neither the netdev notifier, not the configfs subsystem and
> > +	 * nor the console have been registered so far. Nobody's racing us,
> > +	 * so skip the lock.
> 
> 	Once again, while you know you can skip the lock, it's unclear
> without the comment.  Perhaps using the lock makes it explicitly
> "correct"?  Food for thought.

Yes. That special-casing was really ugly and unnecessary -- we just need
to hold the lock around list_add(). I was going to set that right in the
next iteration myself.

> > @@ -251,6 +796,17 @@ static int __init init_netconsole(void)
> >  	if (err)
> >  		goto fail;
> >  
> > +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> > +	config_group_init(&netconsole_subsys.su_group);
> > +	mutex_init(&netconsole_subsys.su_mtx);
> > +
> > +	err = configfs_register_subsystem(&netconsole_subsys);
> > +	if (err) {
> > +		unregister_netdevice_notifier(&netconsole_netdev_notifier);
> > +		goto fail;
> > +	}
> > +#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
> 
> 	I'd abstract this to a dynamic_init() function.
> 
> > +
> > +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> > +	configfs_unregister_subsystem(&netconsole_subsys);
> > +#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
> > +
> 
> 	and this to an dynamic_fini() function.  Basically, do what you
> did with _get()/_put().  This keeps the ifdef up above and out of the
> functions themselves.
> 
> #ifdef CONFIG_NETCONSOLE_DYNAMIC
> static int __init dynamic_netconsole_init(void)
> {
> 	config_group_init(&netconsole_subsys.su_group);
> 	mutex_init(&netconsole_subsys.su_mtx);
> 	return configfs_register_subsystem(&netconsole_subsys);
> }
> #else
> static int __init dynamic_netconsole_init(void)
> {
> 	return 0;
> }
> #endif   

Right, this looks neater and is again the idiom followed throughout the
kernel.

Thanks,
Satyam
