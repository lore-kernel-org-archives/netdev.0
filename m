From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Sat, 2 Jul 2005 00:30:03 -0500
Message-ID: <200507020030.03635.dtor_core@ameritech.net>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Radheka Godse <radheka.godse@intel.com>, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Friday 01 July 2005 15:48, Radheka Godse wrote:
> This large patch adds the sysfs interface to channel bonding. It will
> allow users to add and remove bonds, add and remove slaves, and change
> all bonding parameters without using ifenslave.
> The ifenslave interface still works.
...


Couple of comments:

> @@ -3569,7 +3593,10 @@
>   	bond_remove_proc_entry(bond);
>   	bond_create_proc_entry(bond);
>   #endif
> -
> +	down_write(&(bonding_rwsem));
> +        bond_destroy_sysfs_entry(bond);
> +        bond_create_sysfs_entry(bond);
> +	up_write(&(bonding_rwsem));

Space vs. tab identation.

>   	return NOTIFY_DONE;
>   }
> 
> @@ -4101,6 +4128,7 @@
>   		orig_app_abi_ver = prev_abi_ver;
>   	}
> 
> +	up_write(&(bonding_rwsem));

Whu extra parens?

> + * Changes:
> + *
> + * 2004/12/12 - Mitch Williams <mitch.a.williams at intel dot com>
> + *	- Initial creation of sysfs interface.
> + *
> + * 2005/06/22 - Radheka Godse <radheka.godse at intel dot com>
> + *	- Added ifenslave -c type functionality to sysfs
> + *	- Added sysfs files for attributes such as  MII Status and 
> + *	  802.3ad aggregator that are displayed in /proc
> + *	- Added "name value" format to sysfs "mode" and 
> + *	  "lacp_rate", for e.g., "active-backup 1" or "slow 0" for 
> + *	  consistency and ease of script parsing
> + *	- Fixed reversal of octets in arp_ip_targets via sysfs
> + *	- sysfs support to handle bond interface re-naming
> + *	- Moved all sysfs entries into /sys/class/net instead of
> + *	  of using a standalone subsystem.
> + *	- Added sysfs symlinks between masters and slaves
> + *	- Corrected bugs in sysfs unload path when creating bonds
> + *	  with existing interface names.
> + *	- Removed redundant sysfs stat file since it duplicates slave info 
> + *	  from the proc file
> + *	- Fixed errors in sysfs show/store arp targets.
> + *	- For consistency with ifenslave, instead of exiting 
> + *	  with an error, updated bonding sysfs to 
> + *	  close and attempt to enslave an up adapter. 
> + *	- Fixed NULL dereference when adding a slave interface
> + *	  that does not exist.
> + *	- Added checks in sysfs bonding to reject invalid ip addresses 
> + *	- Synch up with post linux-2.6.12 bonding changes 
> + *	- Created sysfs bond attrib for xmit_hash_policy 

I think we prefer to rely in SCMs to keep changelogs for new modules.

> +
> +static struct class *netdev_class;
> +/*--------------------------- Data Structures -----------------------------*/
> +
> +/* Bonding sysfs lock.  Why can't we just use the subsytem lock?
> + * Because kobject_register tries to acquire the subsystem lock.  If
> + * we already hold the lock (which we would if the user was creating
> + * a new bond through the sysfs interface), we deadlock.
> + */
> +
> +struct rw_semaphore bonding_rwsem; 

klists were just added to the kernel proper. Does this sentiment still
holds true?

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

Why extra parens?

> +		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
> +			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
> +			/* Temporarily set a meaningless flag.  When
> +			 * we get done with the loop, we'll check all of these.
> +			 * If the bond doesn't have this flag set, then we need
> +			 * to remove the bond.  If the flag has it set, then
> +			 * we can just clear the flag. 
> +			 */
> +				bond->flags |= IFF_DYNAMIC;
> +				found = 1;
> +				break;	/* Found it, so go to next name */
> +			}
> +		}

Why list_for_each_entry_safe is used? NO elements is being deleted in
the loop...

> +
> +	/* first, create a link from the slave back to the master */
> +	ret = sysfs_create_link(&(slave->class_dev.kobj), &(master->class_dev.kobj),
> +				"master");

Extra parens again.

> +static ssize_t bonding_show_arp_interval(struct class_device *cd, char *buf)
> +{
> +	int count;
> +	struct bonding *bond = to_bond(cd);
> +
> +	down_read(&(bonding_rwsem));
> +	count = sprintf(buf, "%d\n", bond->params.arp_interval) + 1;
> +	up_read(&(bonding_rwsem));
> +	return count;
> +}

What does this lock really protects here? As far as I can see params will
not go away...

> +
> +	/* get the netdev class pointer */
> +	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
> +	if (!firstbond)
> +	{

Open brace should go on the same line as if. Besides, here it is not needed
at all...

Thanks!

-- 
Dmitry
