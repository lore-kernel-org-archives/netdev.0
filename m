From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Sat, 2 Jul 2005 01:13:46 -0700
Message-ID: <20050702081346.GA20789@kroah.com>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Radheka Godse <radheka.godse@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 01, 2005 at 01:48:44PM -0700, Radheka Godse wrote:
> This large patch adds the sysfs interface to channel bonding. It will
> allow users to add and remove bonds, add and remove slaves, and change
> all bonding parameters without using ifenslave.
> The ifenslave interface still works.

Have a short example of what the sysfs tree looks like, and what the new
files contain and expect to be written to?

> diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bonding.h 
> linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h
> --- linux-2.6.12post/drivers/net/bonding/bonding.h	2005-06-28 
> 18:18:03.000000000 -0700

patch looks linewrapped :(

> +/* Bonding sysfs lock.  Why can't we just use the subsytem lock?

The subsystem lock is no more.  Well, it's still around, but almost no
one uses it, due to the klist changes.  You shouldn't need a lock
either now.

> + * Because kobject_register tries to acquire the subsystem lock.  If
> + * we already hold the lock (which we would if the user was creating
> + * a new bond through the sysfs interface), we deadlock.
> + */
> +
> +struct rw_semaphore bonding_rwsem;
> +
> +
> +
> +
> +/*------------------------------ Functions 
> --------------------------------*/
> +
> +/*
> + * "show" function for the bond_masters attribute.
> + * The class parameter is ignored.
> + */
> +static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
> +{
> +	int res = 0;
> +	struct bonding *bond;
> +
> +	down_read(&(bonding_rwsem));
> +
> +	list_for_each_entry(bond, &bond_dev_list, bond_list) {
> +		res += sprintf(buffer + res, "%s ",
> +			       bond->dev->name);
> +		if (res > (PAGE_SIZE - IFNAMSIZ)) {
> +			dprintk("eek! too many bonds!\n");
> +			break;
> +		}
> +	}
> +	res += sprintf(buffer + res, "\n");
> +	res++;
> +	up_read(&(bonding_rwsem));
> +	return res;

This violates the 1-value-per-sysfs file rule.  Please fix this up.

> +static ssize_t bonding_show_slaves(struct class_device *cd, char *buf)
> +{
> +	struct slave *slave;
> +	int i, res = 0;
> +	struct bonding *bond = to_bond(cd);
> +
> +	down_read(&(bonding_rwsem));
> +
> +	read_lock_bh(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		res += sprintf(buf + res, "%s ", slave->dev->name);
> +		if (res > (PAGE_SIZE - IFNAMSIZ)) {
> +			dprintk("eek! too many slaves!\n");
> +			break;
> +		}
> +	}
> +	read_unlock_bh(&bond->lock);
> +	res += sprintf(buf + res, "\n");
> +        res++; 
> +	up_read(&(bonding_rwsem));
> +	return res;
> +}

Same sysfs violation.  I think other files also have problems :(

thanks,

greg k-h
