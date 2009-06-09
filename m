From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: BUG: bonding module can only be loaded once
Date: Tue, 9 Jun 2009 08:02:32 -0700
Message-ID: <20090609080232.45f81833@nehalam>
References: <20090608151127.70146505@nehalam>
	<200906091406.45463.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42799 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208AbZFIPCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 11:02:36 -0400
In-Reply-To: <200906091406.45463.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Jun 2009 14:06:44 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 09 June 2009, Stephen Hemminger wrote:
> > In order to create multiple bonding dynamically, it is common practice to
> > load the bonding module multiple times.  This got broken in recent kernels
> > 2.6.29 and later.
> > 
> > Doing the following will OOPS:
> >   modprobe -o bond0 bonding
> >   modprobe -o bond1 bonding
> > 
> > 2.6.29 actually OOPS on error handling, but that is fixed in 2.6.30.
> > But 2.6.30 still has the regression (caused by sysfs).
> > 
> > This regression was introduced by changes to sysfs and proc that
> > made duplicate insertion a problem.
> 
> Well, I guess it's more like the changes just made it obvious that
> it's wrong to do this. Registering the same entries in procfs or sysfs 
> means that the user will only be able to talk to one of the two
> bonding drivers through these interfaces. 
> 
> The log messages you quoted are not actually Oops but rather WARNING,
> which is (in this case) not fatal at all, just an indication that the
> root user did something he should not have:
> 
> > [  134.012578] WARNING: at fs/proc/generic.c:590 proc_register+0x154/0x191()
> > [  134.012583] proc_dir_entry 'net/bonding' already registered
> 
> > [  134.014516] WARNING: at fs/sysfs/dir.c:487 sysfs_add_one+0xcc/0xe4()
> > [  134.014521] sysfs: cannot create duplicate filename '/class/net/bonding_masters'
> 
> The bonding driver could work around this by checking if the directories
> already exist before registering them. One can also add rtnl_link_ops to
> the driver for dynamically adding more interfaces.
> 
> If you combine the two, you can even print a helpful message like 'please
> use "ip link add type bonding" instead of "modprobe -o bond0 bonding"'.
> 
> In the mean time, you could probably work around this by ignoring the error
> condition (see below), but I would suspect that there may be more problems
> with the concept of just loading the module again. The best advice to
> users is probably to configure the maximum number of bonding devices they
> might need with the max_bonds= module parameter (if I understand that
> parameter correctly.
> 
> 	Arnd <><
> 
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -5203,7 +5203,7 @@ static int __init bonding_init(void)
>  
>  	res = bond_create_sysfs();
>  	if (res)
> -		goto err;
> +		pr_info("Loading bonding module without sysfs interface\n");
>  
>  	register_netdevice_notifier(&bond_netdev_notifier);
>  	register_inetaddr_notifier(&bond_inetaddr_notifier);

That only makes it limp along, and there still are warnings.
The point is that who ever added the WARN() in proc and sysfs, effectively
broke a bonding usage model.

-- 
