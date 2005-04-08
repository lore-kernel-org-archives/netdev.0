From: Radheka Godse <radheka.godse@intel.com>
Subject: Re: [Bonding-devel] [PATCH 2.6.12-rc2 r8/17] bonding: SYSFS INTERFACE
 (large)-revised
Date: Fri, 8 Apr 2005 14:52:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081330240.14083@localhost.localdomain>
References: <Pine.LNX.4.61.0504081654530.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Radheka Godse <radheka.godse@intel.com>
In-Reply-To: <Pine.LNX.4.61.0504081654530.10355@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>I'm not adverse to sysfs per say, but you are using like /proc with 
>multiple values per file.  This is not what the original design was.

I revised earlier patch submittal to remove sysfs stat file since the 
slave info is duplicated from /proc/net/bonding/bondX and is in proc 
format.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bonding.h	2005-04-09 11:19:27.000000000 -0700
@@ -33,6 +33,7 @@
  #include <linux/timer.h>
  #include <linux/proc_fs.h>
  #include <linux/if_bonding.h>
+#include <linux/kobject.h>
  #include "bond_3ad.h"
  #include "bond_alb.h"

@@ -255,6 +247,13 @@
  int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
  int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
  void bond_deinit(struct net_device *bond_dev);
+int bond_create_sysfs(void);
+void bond_destroy_sysfs(void);
+void bond_destroy_sysfs_entry(struct bonding *bond);
+int bond_create_sysfs_entry(struct bonding *bond);
+int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave);
+void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
+int bond_check_abi_ver(void);
  int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev, struct slave **vassal);
  int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
  int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_main.c	2005-04-09 11:18:45.000000000 -0700
@@ -573,6 +573,7 @@
  static struct proc_dir_entry *bond_proc_dir = NULL;
  #endif

+extern struct rw_semaphore bonding_rwsem;
  static u32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
  static int arp_ip_count	= 0;
  static int bond_mode	= BOND_MODE_ROUNDROBIN;
@@ -1957,6 +1957,9 @@
  		}
  	}

+	res = bond_create_slave_symlinks(bond_dev, slave_dev);
+	if (res)
+		goto err_unset_master;
  	printk(KERN_INFO DRV_NAME
  	       ": %s: enslaving %s as a%s interface with a%s link.\n",
  	       bond_dev->name, slave_dev->name,
@@ -2128,6 +2173,9 @@

  	write_unlock_bh(&bond->lock);

+	/* must do this from outside any spinlocks */
+	bond_destroy_slave_symlinks(bond_dev, slave_dev);
+
  	bond_del_vlans_from_slave(bond, slave_dev);

  	/* If the mode USES_PRIMARY, then we should only remove its
@@ -2399,6 +2406,22 @@
  	}
  }

+int bond_check_abi_ver(void)
+{
+	int retval = 1;
+ 
+	if (orig_app_abi_ver == -1) {
+		orig_app_abi_ver  = BOND_ABI_VERSION;
+		app_abi_ver = BOND_ABI_VERSION;
+	}
+	else {
+		if (app_abi_ver == 0)
+			retval = 0;
+	}
+
+	return retval;
+}
+
  static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
  {
  	struct bonding *bond = bond_dev->priv;
@@ -3367,7 +3390,10 @@
  	bond_remove_proc_entry(bond);
  	bond_create_proc_entry(bond);
  #endif
-
+	down_write(&(bonding_rwsem));
+        bond_destroy_sysfs_entry(bond);
+        bond_create_sysfs_entry(bond);
+	up_write(&(bonding_rwsem));
  	return NOTIFY_DONE;
  }

@@ -3761,6 +3787,7 @@
  		return -EINVAL;
  	}

+	down_write(&(bonding_rwsem));
  	slave_dev = dev_get_by_name(ifr->ifr_slave);

  	dprintk("slave_dev=%p: \n", slave_dev);
@@ -3801,6 +3828,7 @@
  		orig_app_abi_ver = prev_abi_ver;
  	}

+	up_write(&(bonding_rwsem));
  	return res;
  }

@@ -4683,17 +4701,21 @@
  			goto err;
  	}

+	res = bond_create_sysfs();
+	if (res)
+		goto err;
+
  	register_netdevice_notifier(&bond_netdev_notifier);

-	return 0;
-
-out_err:
-	/* free and unregister all bonds that were successfully added */
+	goto out;
+err:
+	rtnl_lock();
  	bond_free_all();
-
+	bond_destroy_sysfs();
  	rtnl_unlock();
-
+out:
  	return res;
+
  }

  static void __exit bonding_exit(void)
@@ -4702,6 +4701,7 @@

  	rtnl_lock();
  	bond_free_all();
+	bond_destroy_sysfs();
  	rtnl_unlock();
  }

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_sysfs.c linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_sysfs.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_sysfs.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_sysfs.c	2005-04-09 11:04:01.000000000 -0700
@@ -0,0 +1,1348 @@
+
+/*
+ * Copyright(c) 2004 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ *
+ * Changes:
+ *
+ * 2004/12/12 - Mitch Williams <mitch.a.williams at intel dot com>
+ *	- Initial creation of sysfs interface.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/device.h>
+#include <linux/sysdev.h>
+#include <linux/fs.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/in.h>
+#include <linux/sysfs.h>
+#include <linux/string.h>
+#include <linux/ctype.h>
+#include <linux/inet.h>
+#include <linux/rtnetlink.h>
+
+/* #define BONDING_DEBUG 1 */
+#include "bonding.h"
+#define to_class_dev(obj) container_of(obj,struct class_device,kobj)
+#define to_net_dev(class) container_of(class, struct net_device, class_dev)
+#define to_bond(cd)	((struct bonding *)(to_net_dev(cd)->priv))
+
+/*---------------------------- Declarations -------------------------------*/
+
+/* Macros for real simple parsing of text. */
+#define eat_nonalnum(str,whence,max) \
+	while (whence < max) {if (!isalnum(str[whence])) whence++; else break;};
+#define find_next_nonalpha(str,whence,max) \
+	while (whence < max) {if (isalnum(str[whence])) whence++; else break;};
+
+extern struct list_head bond_dev_list;
+extern struct bond_params bonding_defaults;
+extern struct bond_parm_tbl bond_mode_tbl[];
+extern struct bond_parm_tbl bond_lacp_tbl[];
+
+static struct class *netdev_class;
+/*--------------------------- Data Structures -----------------------------*/
+
+/* Bonding sysfs lock.  Why can't we just use the subsytem lock?
+ * Because kobject_register tries to acquire the subsystem lock.  If
+ * we already hold the lock (which we would if the user was creating
+ * a new bond through the sysfs interface), we deadlock.
+ */
+
+struct rw_semaphore bonding_rwsem;
+
+
+
+
+/*------------------------------ Functions --------------------------------*/
+
+/*
+ * "show" function for the bond_masters attribute.
+ * The class parameter is ignored.
+ */
+static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
+{
+	int res = 0;
+	struct bonding *bond;
+
+	down_read(&(bonding_rwsem));
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		res += sprintf(buffer + res, "%s ",
+			       bond->dev->name);
+		if (res > (PAGE_SIZE - IFNAMSIZ)) {
+			dprintk("eek! too many bonds!\n");
+			break;
+		}
+	}
+	res += sprintf(buffer + res, "\n");
+	res++;
+	up_read(&(bonding_rwsem));
+	return res;
+}
+
+/*
+ * "store" function for the bond_masters attribute.  This is what
+ * creates and deletes entire bonds.
+ *
+ * The class parameter is ignored.
+ *
+ * This function uses the eat_nonalnum and eat_alnum macros, define
+ * above.  Why not use sscanf()?  Scanf can get strings, but can't filter
+ * out inappropriate characters.  For example, we can't have bonds named
+ * "foo/bar" or "foo*bar" or "Does this work?" as these aren't valid
+ * filenames.  While we could use scanf to get strings and then validate
+ * them, this is quicker.
+ * The above examples give us these results:
+ * "foo/bar" gives two bonds, "foo" and "bar".
+ * "foo*bar" gives two bonds, "foo" and "bar".
+ * "Does this work?" gives three bonds, "Does", "this", and "work".
+ */
+
+static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t count)
+{
+	char name[IFNAMSIZ];
+	int i, res, found, pos = 0;
+	struct bonding *bond;
+	struct bonding *nxt;
+
+	down_write(&(bonding_rwsem));
+	/* First process adds */
+	eat_nonalnum(buffer, pos, count);
+	/* Pos now points to the first alpha character. */
+	i = pos;
+	find_next_nonalpha(buffer, i, count);
+	/* i now points to the next character past the end of the bond name. */
+	if (i - pos >= IFNAMSIZ) {
+		printk(KERN_ERR DRV_NAME "Interface name %.*s too large!  Ignoring.\n",
+		       i - pos, buffer + pos);
+		up_write(&(bonding_rwsem));
+		return -EPERM;
+	}
+	/* Copy the bond name so we can deal with it separately. */
+	strncpy(name, buffer + pos, i - pos);
+	/* Don't forget the null terminator! */
+	name[i - pos] = 0;
+	while (strlen(name)) {
+		/* Got a bond name in name.  Is it already in the list? */
+		found = 0;
+		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+			/* Temporarily set a meaningless flag.  When
+			 * we get done with the loop, we'll check all of these.
+			 * If the bond doesn't have this flag set, then we need
+			 * to remove the bond.  If the flag has it set, then
+			 * we can just clear the flag. 
+			 */
+				bond->flags |= IFF_DYNAMIC;
+				found = 1;
+				break;	/* Found it, so go to next name */
+			}
+		}
+		if (found == 0) {
+			printk(KERN_INFO DRV_NAME ": %s is being created...\n", name);
+			res = bond_create(name, &bonding_defaults, &bond);
+			if (res) {
+				up_write(&(bonding_rwsem));
+				printk(KERN_INFO DRV_NAME ": %s interface already exists. Bond creation failed.\n", name);
+				return res;
+			}
+			printk(KERN_INFO DRV_NAME ": %s created.\n", name);
+			/* Set the flag so we don't delete 
+			 * this interface in the loop below. 
+			 */
+			bond->flags |= IFF_DYNAMIC;
+		}
+		/* Scan for the next name. i still has the location of 
+		 * the char just past the end of the last name we handled. 
+		 */
+		pos = i;
+		eat_nonalnum(buffer, pos, count);
+		i = pos;
+		find_next_nonalpha(buffer, i, count);
+		if (i - pos >= IFNAMSIZ) {
+			printk(KERN_ERR DRV_NAME
+			       ": %.*s interface name too large!  Ignoring.\n",
+			       i - pos, buffer + pos);
+			up_write(&(bonding_rwsem));
+			return -EPERM;
+		}
+		strncpy(name, buffer + pos, i - pos);
+		name[i - pos] = 0;
+	} /* end of while loop and end of input */
+
+	/* Now we do deletes.   Walk through the list, and check to see
+	 * if the flag didn't get set.  If it's set, clear it.  If it's
+	 * not set, delete the bond. 
+	 */
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		if (bond->flags & IFF_DYNAMIC) {
+			bond->flags &= ~IFF_DYNAMIC;
+		} else {
+			printk(KERN_INFO DRV_NAME ": %s is being deleted...\n", bond->dev->name);
+			rtnl_lock();
+			unregister_netdevice(bond->dev);
+			bond_deinit(bond->dev);
+        		bond_destroy_sysfs_entry(bond);
+			rtnl_unlock();
+			printk(KERN_INFO DRV_NAME ": %s deleted.\n", bond->dev->name);
+		}
+	}
+	/* Always return either count or an error.  If you return 0, you'll
+	 * get called forever, which is bad. 
+	 */
+	up_write(&(bonding_rwsem));
+	return count;
+}
+/* class attribute for bond_masters file.  This ends up in /sys/class/net */
+static CLASS_ATTR(bonding_masters,  S_IWUSR | S_IRUGO, 
+		  bonding_show_bonds, bonding_store_bonds);
+
+int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave)
+{
+	char linkname[IFNAMSIZ+7];
+	int ret = 0;
+ 
+	/* first, create a link from the slave back to the master */
+	ret = sysfs_create_link(&(slave->class_dev.kobj), &(master->class_dev.kobj),
+				"master");
+	if (ret) 
+		return ret;
+	/* next, create a link from the master to the slave */
+	sprintf(linkname,"slave_%s",slave->name);
+	ret = sysfs_create_link(&(master->class_dev.kobj), &(slave->class_dev.kobj),
+				linkname);
+	return ret; 
+
+}
+
+void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave)
+{
+	char linkname[IFNAMSIZ+7];
+ 
+	sysfs_remove_link(&(slave->class_dev.kobj), "master");
+	sprintf(linkname,"slave_%s",slave->name);
+	sysfs_remove_link(&(master->class_dev.kobj), linkname);
+}
+
+
+/*
+ * Show the slaves in the current bond.
+ */
+static ssize_t bonding_show_slaves(struct class_device *cd, char *buf)
+{
+	struct slave *slave;
+	int i, res = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+
+	read_lock_bh(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		res += sprintf(buf + res, "%s ", slave->dev->name);
+		if (res > (PAGE_SIZE - IFNAMSIZ)) {
+			dprintk("eek! too many slaves!\n");
+			break;
+		}
+	}
+	read_unlock_bh(&bond->lock);
+	res += sprintf(buf + res, "\n");
+        res++; 
+	up_read(&(bonding_rwsem));
+	return res;
+}
+
+/*
+ * Set the slaves in the current bond.  The bond interface must be
+ * up for this to succeed.
+ * This function is largely the same flow as bonding_update_bonds().
+ */
+static ssize_t bonding_store_slaves(struct class_device *cd, const char *buffer, size_t count)
+{
+	char name[IFNAMSIZ];
+	int i, j, res, found, pos = 0, ret = count;
+	struct slave *slave;
+	struct net_device *dev = 0;
+	struct bonding *bond = to_bond(cd);
+
+	if (!bond_check_abi_ver())
+	{
+		printk(KERN_ERR DRV_NAME
+		       ": Error: your version of ifenslave is incompatible "
+		       "with the sysfs interface in this version of bonding.  "
+		       "Upgrade ifenslave to version 1 or greater and reload "
+		       "bonding.\n");
+		return -EINVAL;
+	}
+
+	down_write(&(bonding_rwsem));
+
+	/* Quick sanity check -- is the bond interface up? */
+	if (!(bond->dev->flags & IFF_UP)) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to update slaves because interface is down.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
+
+	/* First process adds */
+
+	/* Copy the first name we find. */
+	eat_nonalnum(buffer, pos, count);
+	i = pos;
+	find_next_nonalpha(buffer, i, count);
+	if (i - pos >= IFNAMSIZ) {
+		printk(KERN_ERR DRV_NAME ": %s: Slave name %.*s too large! Ignoring.\n",
+		        bond->dev->name,
+			i - pos, buffer + pos);
+		ret =  -EPERM;
+		goto out;
+	}
+	strncpy(name, buffer + pos, i - pos);
+	name[i - pos] = 0;
+
+	while (strlen(name)) {
+		/* Got a slave name in name.  Is it already there? */
+		found = 0;
+		read_lock_bh(&bond->lock);
+		bond_for_each_slave(bond, slave, j) {
+			if (strnicmp(slave->dev->name, name, IFNAMSIZ) == 0) {
+			/* Temporarily set a meaningless flag.  When
+			 * we get done with the loop, we'll check all of these.
+			 * If the slave doesn't have this flag set, then we need
+			 * to remove the slave.  If the flag has it set, then
+			 * we can just clear the flag. 
+			 */
+				slave->original_flags |= IFF_DYNAMIC;
+				found = 1;
+				break;	/* Found it, so go to next name */
+			}
+		}
+		read_unlock_bh(&bond->lock);
+		if (found == 0) {
+			printk(KERN_INFO DRV_NAME ": %s: Adding slave %s.\n", 
+			       bond->dev->name, name);
+			dev = dev_get_by_name(name);
+			if (!dev) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: Interface %s does not exist!\n", 
+				       bond->dev->name, name);
+				ret = -EPERM;
+				goto out;
+			}
+
+			if (dev->flags & IFF_SLAVE) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: Interface %s is already enslaved!\n",
+				       bond->dev->name, name);
+				ret = -EPERM;
+				goto out;
+			}
+
+			/* If this is the first slave, then we need to set
+			   the master's hardware address to be the same as the
+			   slave's. */
+			if (!(*((u32 *) & (bond->dev->dev_addr[0])))) {
+				memcpy(bond->dev->dev_addr, dev->dev_addr,
+				       dev->addr_len);
+			}
+
+			/* Set the slave's MTU to match the bond */
+			if (dev->mtu != bond->dev->mtu) {
+				if (dev->change_mtu) {
+					res = dev->change_mtu(dev,
+							      bond->dev->mtu);
+					if (res) {
+						ret = res;
+						goto out;
+					}
+				} else {
+					dev->mtu = bond->dev->mtu;
+				}
+			}
+			rtnl_lock();
+			res = bond_enslave(bond->dev, dev, &slave);
+			rtnl_unlock();
+			if (res) {
+				ret = res;
+				goto out;
+			}
+			slave->original_flags |= IFF_DYNAMIC;
+			dev_put(dev);
+		}
+		/* Get the next name in the buffer. */
+		pos = i;
+		eat_nonalnum(buffer, pos, count);
+		i = pos;
+		find_next_nonalpha(buffer, i, count);
+		if (i - pos >= IFNAMSIZ) {
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Slave name %.*s too large!  Ignoring.\n",
+			       bond->dev->name, i - pos, buffer + pos);
+			ret = -EPERM;
+			goto out;
+		}
+		strncpy(name, buffer + pos, i - pos);
+		name[i - pos] = 0;
+	}			/* End of while loop, and end of input. */
+
+	/* Now handle deletes.
+	 * We can't use bond_for_each_slave here because we might modify
+	 * the list when we're inside the loop.  We can't hold the lock
+	 * either because bond_release grabs it.
+	 */
+	slave = bond->first_slave;
+	i = bond->slave_cnt;
+	while (i > 0) {
+		BUG_ON(slave == 0);
+		if (slave->original_flags & IFF_DYNAMIC) {
+			slave->original_flags &= ~IFF_DYNAMIC;
+			slave = slave->next;
+		} else {
+			/* Didn't find the name of this slave in the list, so 
+			 * remove the slave. 
+			 */
+			printk(KERN_INFO DRV_NAME 
+			       ": %s: Removing slave %s\n",
+			       bond->dev->name,
+			       slave->dev->name);
+			dev = slave->dev;
+			slave = slave->next;
+			rtnl_lock();
+			res = bond_release(bond->dev, dev);
+			rtnl_unlock();
+			if (res) {
+				ret = res;
+				goto out;
+			}
+			/* set the slave MTU to the default */
+			if (dev->change_mtu) {
+				dev->change_mtu(dev, 1500);
+			} else {
+				dev->mtu = 1500;
+			}
+		}
+		i--;
+	}
+
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves, bonding_store_slaves);
+
+/*
+ * Show and set the bonding mode.  The bond interface must be down to
+ * change the mode.
+ */
+static ssize_t bonding_show_mode(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%s %d\n", 
+			bond_mode_tbl[bond->params.mode].modename, 
+			bond->params.mode) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_mode(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	if (bond->dev->flags & IFF_UP) {
+		printk(KERN_ERR DRV_NAME
+		       "Unable to update mode of %s because interface is up.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	new_value = bond_parse_parm((char *)buf, bond_mode_tbl);
+	if (new_value < 0)  {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid mode value %.*s.\n",
+		       bond->dev->name,
+		       (int)strlen(buf) - 1, buf);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.mode = new_value;
+		bond_set_mode_ops(bond->dev, bond->params.mode);
+		printk(KERN_INFO DRV_NAME ": %s: setting mode to %s (%d).\n", 
+			bond->dev->name, bond_mode_tbl[new_value].modename, new_value);
+	}
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(mode, S_IRUGO | S_IWUSR, bonding_show_mode, bonding_store_mode);
+
+/*
+ * Show and set the arp timer interval.  There are two tricky bits
+ * here.  First, if ARP monitoring is activated, then we must disable
+ * MII monitoring.  Second, if the ARP timer isn't running, we must
+ * start it.
+ */
+static ssize_t bonding_show_arp_interval(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%d\n", bond->params.arp_interval) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_arp_interval(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	sscanf(buf, "%d", &new_value);
+
+	if (new_value < 0) {
+		printk(KERN_ERR DRV_NAME 
+		       ": %s: Ignoring invalid arp_interval value %d.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Setting ARP monitoring interval to %d.\n",
+		       bond->dev->name, new_value);
+		bond->params.arp_interval = new_value;
+		if (bond->params.miimon) {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: ARP monitoring cannot be used with MII monitoring. "
+			       "%s Disabling MII monitoring.\n",
+			       bond->dev->name, bond->dev->name);
+			bond->params.miimon = 0;
+			del_timer_sync(&bond->mii_timer);
+			/* Kill MII timer, else it brings bond's link down */
+		}
+		if (!bond->params.arp_targets[0]) {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: ARP monitoring has been set up, "
+			       "but no ARP targets have been specified.\n",
+			       bond->dev->name);
+		}
+		if (bond->dev->flags & IFF_UP) {
+			/* If the interface is up, we may need to fire off 
+			 * the ARP timer.  If the interface is down, the 
+			 * timer will get fired off when the open function
+			 * is called. 
+			 */
+			if (bond->arp_timer.function) {
+				/* The timer's already set up, so fire it off */
+				mod_timer(&bond->arp_timer, jiffies + 1);
+			} else {
+				/* Set up the timer. */
+				init_timer(&bond->arp_timer);
+				bond->arp_timer.expires = jiffies + 1;
+				bond->arp_timer.data =
+					(unsigned long) bond->dev;
+				if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
+					bond->arp_timer.function =
+						(void *)
+						&bond_activebackup_arp_mon;
+				} else {
+					bond->arp_timer.function =
+						(void *)
+						&bond_loadbalance_arp_mon;
+				}
+				add_timer(&bond->arp_timer);
+			}
+		}
+	}
+
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR , bonding_show_arp_interval, bonding_store_arp_interval);
+
+/*
+ * Show and set the arp targets. 
+ */
+static ssize_t bonding_show_arp_targets(struct class_device *cd, char *buf)
+{
+	int i, res = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+
+	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i];
+	     i++) {
+		res += sprintf(buf + res, "%u.%u.%u.%u ",
+			       NIPQUAD(bond->params.arp_targets[i]));
+		res++;
+	}
+
+	up_read(&(bonding_rwsem));
+	return res;
+}
+
+static ssize_t bonding_store_arp_targets(struct class_device *cd, const char *buf, size_t count)
+{
+	int octet1, octet2, octet3, octet4, ret = count;
+	int newpos = 0, pos = 0, i = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	sscanf(buf, "%d.%d.%d.%d%n", &octet1, &octet2, &octet3, &octet4, &pos);
+	while ((pos < count) && (i < BOND_MAX_ARP_TARGETS)) {
+		if (   (octet1 < 0) || (octet1 > 255)
+		    || (octet2 < 0) || (octet2 > 255)
+		    || (octet3 < 0) || (octet3 > 255)
+		    || (octet4 < 0) || (octet4 > 255)
+		    || ((octet1 == 0) && (octet2 == 0) && 
+			(octet3 == 0) && (octet4 == 0))
+		    || ((octet1 == 255) && (octet2 == 255) && 
+			(octet3 == 255) && (octet4 == 255))
+		   ) {
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Unable to add arp target %d.%d.%d.%d\n",
+			       bond->dev->name, octet1, octet2, octet3, octet4);
+			ret = -EINVAL;
+			goto out;
+		} else {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Adding arp target %d.%d.%d.%d\n",
+			       bond->dev->name, octet1, octet2, octet3, octet4);
+			/* Is this going to get me into trouble on big-endian boxes? */
+			/* Is there a macro to do this?  I can't find one... */
+			bond->params.arp_targets[i] = htonl
+				((((u32) octet1 & 0xff) << 24) |
+				 (((u32) octet2 & 0xff) << 16) |
+				 (((u32) octet3 & 0xff) << 8) | ((u32) octet4 &
+								 0xff));
+
+			i++;
+		}
+
+		newpos = 0;
+		sscanf(buf + pos, "%d.%d.%d.%d%n", &octet1, &octet2, &octet3,
+		       &octet4, &newpos);
+		if (newpos == 0) {
+			break;
+		}
+		pos += newpos;
+	}
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(arp_ip_target, S_IRUGO | S_IWUSR , bonding_show_arp_targets, bonding_store_arp_targets);
+
+/*
+ * Show and set the up and down delays.  These must be multiples of the
+ * MII monitoring value, and are stored internally as the multiplier.
+ * Thus, we must translate to MS for the real world.
+ */
+static ssize_t bonding_show_downdelay(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%d\n", bond->params.downdelay * bond->params.miimon) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_downdelay(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	if (!(bond->params.miimon)) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to set down delay as MII monitoring is disabled\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	sscanf(buf, "%d", &new_value);
+	if (new_value < 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid down delay value %d.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		if ((new_value % bond->params.miimon) != 0) {
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: down delay (%d) is not a multiple "
+			       "of miimon (%d), delay rounded to %d ms\n",
+			       bond->dev->name, new_value, bond->params.miimon,
+			       (new_value / bond->params.miimon) *
+			       bond->params.miimon);
+		}
+		bond->params.downdelay = new_value / bond->params.miimon;
+		printk(KERN_INFO DRV_NAME ": %s: Setting down delay to %d.\n",
+		       bond->dev->name, bond->params.downdelay * bond->params.miimon);
+
+	}
+
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(down_delay, S_IRUGO | S_IWUSR , bonding_show_downdelay, bonding_store_downdelay);
+
+static ssize_t bonding_show_updelay(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%d\n", bond->params.updelay * bond->params.miimon) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+ 
+}
+
+static ssize_t bonding_store_updelay(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	if (!(bond->params.miimon)) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to set up delay as MII monitoring is disabled\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	sscanf(buf, "%d", &new_value);
+	if (new_value < 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid up delay value %d.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		if ((new_value % bond->params.miimon) != 0) {
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: up delay (%d) is not a multiple "
+			       "of miimon (%d), updelay rounded to %d ms\n",
+			       bond->dev->name, new_value, bond->params.miimon,
+			       (new_value / bond->params.miimon) *
+			       bond->params.miimon);
+		}
+		bond->params.updelay = new_value / bond->params.miimon;
+		printk(KERN_INFO DRV_NAME ": %s: Setting up delay to %d.\n",
+		       bond->dev->name, bond->params.updelay * bond->params.miimon);
+
+	}
+
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(up_delay, S_IRUGO | S_IWUSR , bonding_show_updelay, bonding_store_updelay);
+
+/*
+ * Show and set the LACP interval.  Interface must be down, and the mode
+ * must be set to 802.3ad mode.
+ */
+static ssize_t bonding_show_lacp(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%s %d\n", 
+		bond_lacp_tbl[bond->params.lacp_fast].modename, 
+		bond->params.lacp_fast) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_lacp(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	if (bond->dev->flags & IFF_UP) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to update LACP rate because interface is up.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	if (bond->params.mode != BOND_MODE_8023AD) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
+		       bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
+	new_value = bond_parse_parm((char *)buf, bond_lacp_tbl);
+
+	if ((new_value == 1) || (new_value == 0)) {
+		bond->params.lacp_fast = new_value;
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Setting LACP rate to %s (%d).\n", 
+		       bond->dev->name, bond_lacp_tbl[new_value].modename, new_value);
+	} else {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid LACP rate value %.*s.\n",
+		     	bond->dev->name, (int)strlen(buf) - 1, buf);
+		ret = -EINVAL;
+	}
+out:
+	up_write(&(bonding_rwsem));
+	return ret;
+}
+static CLASS_DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
+
+/*
+ * Show and set the MII monitor interval.  There are two tricky bits
+ * here.  First, if MII monitoring is activated, then we must disable
+ * ARP monitoring.  Second, if the timer isn't running, we must
+ * start it.
+ */
+static ssize_t bonding_show_miimon(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%d\n", bond->params.miimon) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_miimon(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+
+	sscanf(buf, "%d", &new_value);
+	if (new_value < 0) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Ignoring invalid miimon value %d.\n",
+		       bond->dev->name, new_value);
+	} else {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Setting MII monitoring interval to %d.\n",
+		       bond->dev->name, new_value);
+		bond->params.miimon = new_value;
+		if(bond->params.updelay)
+			printk(KERN_INFO DRV_NAME
+			      ": %s: Note: Updating updelay (to %d) "
+			      "since it is a multiple of the miimon value.\n",
+			      bond->dev->name,
+			      bond->params.updelay * bond->params.miimon);
+		if(bond->params.downdelay)
+			printk(KERN_INFO DRV_NAME
+			      ": %s: Note: Updating downdelay (to %d) "
+			      "since it is a multiple of the miimon value.\n",
+			      bond->dev->name,
+			      bond->params.downdelay * bond->params.miimon);
+		if (bond->params.arp_interval) {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: MII monitoring cannot be used with "
+			       "ARP monitoring. Disabling ARP monitoring...\n",
+			       bond->dev->name);
+			bond->params.arp_interval = 0;
+			del_timer_sync(&bond->arp_timer);
+			/* Kill ARP timer, else it brings bond's link down */
+		}
+
+		if (bond->dev->flags & IFF_UP) {
+			/* If the interface is up, we may need to fire off 
+			 * the MII timer. If the interface is down, the 
+			 * timer will get fired off when the open function
+			 * is called. 
+			 */
+			if (bond->mii_timer.function) {
+				/* The timer's already set up, so fire it off */
+				mod_timer(&bond->mii_timer, jiffies + 1);
+			} else {
+				/* Set up the timer. */
+				init_timer(&bond->mii_timer);
+				bond->mii_timer.expires = jiffies + 1;
+				bond->mii_timer.data =
+					(unsigned long) bond->dev;
+				bond->mii_timer.function =
+					(void *) &bond_mii_monitor;
+				add_timer(&bond->mii_timer);
+			}
+		}
+	}
+
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR, bonding_show_miimon, bonding_store_miimon);
+
+/*
+ * Show and set the primary slave.  The store function is much
+ * simpler than bonding_store_slaves function because it only needs to 
+ * handle one interface name.
+ * The bond must be a mode that supports a primary for this be 
+ * set.
+ */
+static ssize_t bonding_show_primary(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->primary_slave)
+		count = sprintf(buf, "%s\n", bond->primary_slave->dev->name) + 1;
+
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_primary(struct class_device *cd, const char *buf, size_t count)
+{
+	int i;
+	struct slave *slave;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	write_lock_bh(&bond->lock);
+	if (!USES_PRIMARY(bond->params.mode)) {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Unable to set primary slave; %s is in mode %d\n",
+		       bond->dev->name, bond->dev->name, bond->params.mode);
+	} else {
+		bond_for_each_slave(bond, slave, i) {
+			if (strnicmp
+			    (slave->dev->name, buf,
+			     strlen(slave->dev->name)) == 0) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: Setting %s as primary slave.\n",
+				       bond->dev->name, slave->dev->name);
+				bond->primary_slave = slave;
+				bond_select_active_slave(bond);
+				goto out;
+			}
+		}
+
+		/* if we got here, then we didn't match the name of any slave */
+
+		if (strlen(buf) == 0 || buf[0] == '\n') {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Setting primary slave to None.\n",
+			       bond->dev->name);
+			bond->primary_slave = 0;
+				bond_select_active_slave(bond);
+		} else {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Unable to set %.*s as primary slave as it is not a slave.\n",
+			       bond->dev->name, (int)strlen(buf) - 1, buf);
+		}
+	}
+out:
+	write_unlock_bh(&bond->lock);
+	up_write(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
+
+/*
+ * Show and set the use_carrier flag.
+ */
+static ssize_t bonding_show_carrier(struct class_device *cd, char *buf)
+{
+	int count;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	count = sprintf(buf, "%d\n", bond->params.use_carrier) + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_carrier(struct class_device *cd, const char *buf, size_t count)
+{
+	int new_value;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	sscanf(buf, "%d", &new_value);
+	if ((new_value == 0) || (new_value == 1)) {
+		bond->params.use_carrier = new_value;
+		printk(KERN_INFO DRV_NAME ": %s: Setting use_carrier to %d.\n",
+		       bond->dev->name, new_value);
+	} else {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Ignoring invalid use_carrier value %d.\n",
+		       bond->dev->name, new_value);
+	}
+	up_write(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR, bonding_show_carrier, bonding_store_carrier);
+
+
+/*
+ * Show and set currently active_slave.
+ */
+static ssize_t bonding_show_active_slave(struct class_device *cd, char *buf)
+{
+	struct slave *curr;
+	struct bonding *bond = to_bond(cd);
+	int count;
+
+	down_read(&(bonding_rwsem));
+ 
+	read_lock(&bond->curr_slave_lock);
+	curr = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+ 
+	if (USES_PRIMARY(bond->params.mode)) {
+		count = sprintf(buf, "%s\n", (curr) ? curr->dev->name : "None") + 1;
+	}
+	else {
+		count = sprintf(buf, "%s\n", "None") + 1;
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+
+static ssize_t bonding_store_active_slave(struct class_device *cd, const char *buf, size_t count)
+{
+	int i;
+	struct slave *slave;
+        struct slave *old_active = NULL;
+        struct slave *new_active = NULL;
+	struct bonding *bond = to_bond(cd);
+
+	down_write(&(bonding_rwsem));
+
+	write_lock_bh(&bond->lock);
+	if (!USES_PRIMARY(bond->params.mode)) {
+		printk(KERN_INFO DRV_NAME
+		       ": %s: Unable to change active slave; %s is in mode %d\n",
+		       bond->dev->name, bond->dev->name, bond->params.mode);
+	} else {
+		bond_for_each_slave(bond, slave, i) {
+			if (strnicmp
+			    (slave->dev->name, buf,
+			     strlen(slave->dev->name)) == 0) {
+        			old_active = bond->curr_active_slave;
+        			new_active = slave;
+        			if (new_active && (new_active == old_active)) {
+					/* do nothing */
+					printk(KERN_INFO DRV_NAME
+				       	       ": %s: %s is already the current active slave.\n",
+				               bond->dev->name, slave->dev->name);
+					goto out;
+				}
+				else {
+        				if ((new_active) &&
+            				    (old_active) &&
+				            (new_active->link == BOND_LINK_UP) &&
+				            IS_UP(new_active->dev)) {
+						printk(KERN_INFO DRV_NAME
+				       	              ": %s: Setting %s as active slave.\n",
+				                      bond->dev->name, slave->dev->name);
+                				bond_change_active_slave(bond, new_active);
+        				}
+					else {
+						printk(KERN_INFO DRV_NAME
+				       	              ": %s: Could not set %s as active slave; "
+						      "either %s is down or the link is down.\n",
+				                      bond->dev->name, slave->dev->name,
+						      slave->dev->name);
+					} 
+					goto out;
+				}
+			}
+		}
+
+		/* if we got here, then we didn't match the name of any slave */
+
+		if (strlen(buf) == 0 || buf[0] == '\n') {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Setting active slave to None.\n",
+			       bond->dev->name);
+			bond->primary_slave = 0;
+				bond_select_active_slave(bond);
+		} else {
+			printk(KERN_INFO DRV_NAME
+			       ": %s: Unable to set %.*s as active slave as it is not a slave.\n",
+			       bond->dev->name, (int)strlen(buf) - 1, buf);
+		}
+	}
+out:
+	write_unlock_bh(&bond->lock);
+	up_write(&(bonding_rwsem));
+	return count;
+
+}
+static CLASS_DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR, bonding_show_active_slave, bonding_store_active_slave);
+
+
+/*
+ * Show link status of the bond interface.
+ */
+static ssize_t bonding_show_mii_status(struct class_device *cd, char *buf)
+{
+	int count;
+	struct slave *curr;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+ 
+	read_lock(&bond->curr_slave_lock);
+	curr = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+ 
+	count = sprintf(buf, "%s\n", (curr) ? "up" : "down") + 1;
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
+
+
+/*
+ * Show current 802.3ad aggregator ID.
+ */
+static ssize_t bonding_show_ad_aggregator(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.aggregator_id) + 1;
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(ad_aggregator, S_IRUGO, bonding_show_ad_aggregator, NULL);
+
+
+/*
+ * Show number of active 802.3ad ports.
+ */
+static ssize_t bonding_show_ad_num_ports(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0: ad_info.ports) + 1;
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(ad_num_ports, S_IRUGO, bonding_show_ad_num_ports, NULL);
+
+
+/*
+ * Show current 802.3ad actor key.
+ */
+static ssize_t bonding_show_ad_actor_key(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.actor_key) + 1;
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(ad_actor_key, S_IRUGO, bonding_show_ad_actor_key, NULL);
+
+
+/*
+ * Show current 802.3ad partner key.
+ */
+static ssize_t bonding_show_ad_partner_key(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.partner_key) + 1;
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(ad_partner_key, S_IRUGO, bonding_show_ad_partner_key, NULL);
+
+
+/*
+ * Show current 802.3ad partner mac.
+ */
+static ssize_t bonding_show_ad_partner_mac(struct class_device *cd, char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(cd);
+
+	down_read(&(bonding_rwsem));
+	if (bond->params.mode == BOND_MODE_8023AD) {
+		struct ad_info ad_info;
+		if (!bond_3ad_get_active_agg_info(bond, &ad_info)) {
+			count = sprintf(buf,"%02x:%02x:%02x:%02x:%02x:%02x\n",
+				       ad_info.partner_system[0],
+				       ad_info.partner_system[1],
+				       ad_info.partner_system[2],
+				       ad_info.partner_system[3],
+				       ad_info.partner_system[4],
+				       ad_info.partner_system[5]) + 1;
+		}
+	}
+	up_read(&(bonding_rwsem));
+	return count;
+}
+static CLASS_DEVICE_ATTR(ad_partner_mac, S_IRUGO, bonding_show_ad_partner_mac, NULL);
+
+
+
+static struct attribute *per_bond_attrs[] = {
+	&class_device_attr_slaves.attr,
+	&class_device_attr_mode.attr,
+	&class_device_attr_arp_interval.attr,
+	&class_device_attr_arp_ip_target.attr,
+	&class_device_attr_down_delay.attr,
+	&class_device_attr_up_delay.attr,
+	&class_device_attr_lacp_rate.attr,
+	&class_device_attr_miimon.attr,
+	&class_device_attr_primary.attr,
+	&class_device_attr_use_carrier.attr,
+	&class_device_attr_active_slave.attr,
+	&class_device_attr_mii_status.attr,
+	&class_device_attr_ad_aggregator.attr,
+	&class_device_attr_ad_num_ports.attr,
+	&class_device_attr_ad_actor_key.attr,
+	&class_device_attr_ad_partner_key.attr,
+	&class_device_attr_ad_partner_mac.attr,
+	NULL,
+};
+
+static struct attribute_group bonding_group = {
+	.name = "bonding",
+	.attrs = per_bond_attrs,
+};
+
+/*
+ * Initialize sysfs.  This sets up the bonding_masters file in
+ * /sys/class/net.
+ */
+int bond_create_sysfs(void)
+{
+	int ret = 0;
+	struct bonding *firstbond;
+
+	init_rwsem(&bonding_rwsem);
+
+	/* get the netdev class pointer */
+	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
+	if (!firstbond)
+	{
+		return -ENODEV;
+ 
+	}
+	netdev_class = firstbond->dev->class_dev.class;
+	if (!netdev_class)
+	{
+		return -ENODEV;
+	}
+	ret = class_create_file(netdev_class, &class_attr_bonding_masters);
+ 
+	return ret;
+
+}
+
+/*
+ * Remove /sys/class/net/bonding_masters.
+ */
+void bond_destroy_sysfs(void)
+{
+	if (netdev_class)
+		class_remove_file(netdev_class, &class_attr_bonding_masters);
+}
+
+/*
+ * Initialize sysfs for each bond.  This sets up and registers
+ * the 'bondctl' directory for each individual bond under /sys/class/net.
+ */
+int bond_create_sysfs_entry(struct bonding *bond)
+{
+	struct net_device *dev = bond->dev;
+	int err;
+
+	err = sysfs_create_group(&(dev->class_dev.kobj), &bonding_group);
+	if (err) {
+		printk(KERN_EMERG "eek! didn't create group!\n");
+	}
+
+	return err;
+}
+/*
+ * Remove sysfs entries for each bond.
+ */
+void bond_destroy_sysfs_entry(struct bonding *bond)
+{
+	struct net_device *dev = bond->dev;
+
+	sysfs_remove_group(&(dev->class_dev.kobj), &bonding_group);
+}
+
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/Makefile linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/Makefile
--- linux-2.6.12-rc2clean/drivers/net/bonding/Makefile	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/Makefile	2005-04-09 11:01:39.000000000 -0700
@@ -4,5 +4,5 @@

  obj-$(CONFIG_BONDING) += bonding.o

-bonding-objs := bond_main.o bond_3ad.o bond_alb.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
