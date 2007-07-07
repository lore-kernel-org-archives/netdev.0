From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH -mm 9/9] netconsole: Support dynamic reconfiguration using configfs
Date: Fri, 6 Jul 2007 23:01:15 -0700
Message-ID: <20070707060114.GB1011@tasint.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:64836 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbXGGGBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 02:01:49 -0400
Content-Disposition: inline
In-Reply-To: <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:38:24PM +0530, Satyam Sharma wrote:
>  struct netconsole_target {
>  	struct list_head	list;
> +	struct config_item	item;
> +	int			id;
> +	int			enabled;
>  	int			dev_status;
>  	struct netpoll		np;
>  };

	If you're trying to be good with your CONFIG_NETCONSOLE_DYNAMIC
ifdefs, you probably want to ifdef the item.  You'll save space when
NETCONSOLE_DYNAMIC is off.

> +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> +
> +/*
> + * Targets that were created by parsing the boot/module option string
> + * do not exist in the configfs hierarchy and will never go away (and
> + * have zeroed-out config_item members). So make these a no-op for them.
> + */
> +static void netconsole_target_get(struct netconsole_target *nt)
> +{
> +	static struct config_item empty_item;	/* Zeroed-out config_item */
> +
> +	if (memcmp(&nt->item, &empty_item, sizeof(struct config_item)))
> +		config_item_get(&nt->item);
> +}

	I was going to point out that you could merely check
config_item_name(&nt->item) != NULL, because a valid configfs object has
a name and your zeroed object does not.  But your followup email
suggests you'll be removing this code anyway.
	I don't, off the top of my head, see a problem with removing the
_get/_put cycle, because you do have them under the spinlock.  Things
should behave correctly.  However, the _get/_put pair is "cleaner", in
that it expresses the relationship and doesn't add a special case of "I
happen to know this is safe".

> + * Our subsystem hierarchy is:
> + *
> + * /config/netconsole/
> + *		     |
> + *		     <target>/
> + *		     |	     id
> + *		     |	     enabled

	Your configfs bits seem to be pretty straightforward.

> +		/*
> +		 * Skip netpoll_parse_options() -- all the attributes are
> +		 * already configured in nt->np through configfs. But at
> +		 * least let's print the useful stuff it used to output :-)
> +		 */
> +		printk(KERN_INFO "%s: local port %d\n",
> +				 np->name, np->local_port);
> +		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
> +				 np->name, HIPQUAD(np->local_ip));
> +		printk(KERN_INFO "%s: interface %s\n",
> +				 np->name, np->dev_name);
> +		printk(KERN_INFO "%s: remote port %d\n",
> +				 np->name, np->remote_port);
> +		printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
> +				 np->name, HIPQUAD(np->remote_ip));
> +		printk(KERN_INFO "%s: remote ethernet address "
> +				 "%02x:%02x:%02x:%02x:%02x:%02x\n",
> +				 np->name,
> +				 np->remote_mac[0], np->remote_mac[1],
> +				 np->remote_mac[2], np->remote_mac[3],
> +				 np->remote_mac[4], np->remote_mac[5]);

	Shouldn't you break this out into a function so that both places
can use it?

> +#define NETCONSOLE_TARGET_ATTR_RO(_name)				\
> +static struct netconsole_target_attr netconsole_target_##_name =	\
> +__CONFIGFS_ATTR(_name, S_IRUGO, show_##_name, NULL)
> +
> +#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
> +static struct netconsole_target_attr netconsole_target_##_name =	\
> +__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)

	Perhaps an indent would be clearer, but that's a tiny nitpick.

>  	/*
> -	 * Neither the netdev notifier, nor the console have been
> -	 * registered so far. Nobody's racing us, so skip the lock.
> +	 * Neither the netdev notifier, not the configfs subsystem and
> +	 * nor the console have been registered so far. Nobody's racing us,
> +	 * so skip the lock.

	Once again, while you know you can skip the lock, it's unclear
without the comment.  Perhaps using the lock makes it explicitly
"correct"?  Food for thought.

> @@ -251,6 +796,17 @@ static int __init init_netconsole(void)
>  	if (err)
>  		goto fail;
>  
> +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> +	config_group_init(&netconsole_subsys.su_group);
> +	mutex_init(&netconsole_subsys.su_mtx);
> +
> +	err = configfs_register_subsystem(&netconsole_subsys);
> +	if (err) {
> +		unregister_netdevice_notifier(&netconsole_netdev_notifier);
> +		goto fail;
> +	}
> +#endif	/* CONFIG_NETCONSOLE_DYNAMIC */

	I'd abstract this to a dynamic_init() function.

> +
> +#ifdef	CONFIG_NETCONSOLE_DYNAMIC
> +	configfs_unregister_subsystem(&netconsole_subsys);
> +#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
> +

	and this to an dynamic_fini() function.  Basically, do what you
did with _get()/_put().  This keeps the ifdef up above and out of the
functions themselves.

#ifdef CONFIG_NETCONSOLE_DYNAMIC
static int __init dynamic_netconsole_init(void)
{
	config_group_init(&netconsole_subsys.su_group);
	mutex_init(&netconsole_subsys.su_mtx);
	return configfs_register_subsystem(&netconsole_subsys);
}
#else
static int __init dynamic_netconsole_init(void)
{
	return 0;
}
#endif   


Joel

-- 

Life's Little Instruction Book #3

	"Watch a sunrise at least once a year."

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
