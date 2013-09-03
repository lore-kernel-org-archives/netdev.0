From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH RFC net-next 06/21] net: create sysfs symlinks for
 neighbour devices
Date: Tue, 3 Sep 2013 10:05:26 +0200
Message-ID: <20130903080526.GB18504@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
 <1378157965-17537-7-git-send-email-vfalico@redhat.com>
 <20130903074853.GB1437@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045Ab3ICIGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 04:06:54 -0400
Content-Disposition: inline
In-Reply-To: <20130903074853.GB1437@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:48:53AM +0200, Jiri Pirko wrote:
>Mon, Sep 02, 2013 at 11:39:10PM CEST, vfalico@redhat.com wrote:
>>Also, remove the same functionality from bonding - it will be already done
>>for any device that links to its lower/upper neighbour.
>>
>>The links will be created for dev's kobject, and will look like
>>slave_eth0 for lower device eth0 and upper_bridge0 for upper device
>>bridge0.
>
>The pair should be either slave/master or lower/upper. It's undesirable
>to mix these two. Maybe for compatibility reasons we should leave
>current bonding sysfs files and create proper new generic ones?

I completely agree with the slave/master vs lower/upper logic, and you've
correctly understood why I've chosen this path.

I'm ok with any approach, but it looks weird. I've googled a bit and saw
that people use the slave_eth0...

So dunno what's best option here, really.

>
>I think there should be directories under netdev dir like:
>/sys/class/net/em1-
>                  |-upper-
>                         |-bond0(link)
>                         |-vlanx(link)
>/sys/class/net/bond0-
>                    |-lower-
>                           |-em1(link)
>                           |-em2(link)
>
>
>>
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>CC: "David S. Miller" <davem@davemloft.net>
>>CC: Eric Dumazet <edumazet@google.com>
>>CC: Jiri Pirko <jiri@resnulli.us>
>>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>---
>> drivers/net/bonding/bond_main.c  | 11 +----------
>> drivers/net/bonding/bond_sysfs.c | 25 -------------------------
>> drivers/net/bonding/bonding.h    |  2 --
>> net/core/dev.c                   | 29 +++++++++++++++++++++++++++++
>> 4 files changed, 30 insertions(+), 37 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>index c50679f..b0b753d 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -1635,15 +1635,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>
>> 	read_unlock(&bond->lock);
>>
>>-	res = bond_create_slave_symlinks(bond_dev, slave_dev);
>>-	if (res)
>>-		goto err_detach;
>>-
>> 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
>> 					 new_slave);
>> 	if (res) {
>> 		pr_debug("Error %d calling netdev_rx_handler_register\n", res);
>>-		goto err_dest_symlinks;
>>+		goto err_detach;
>> 	}
>>
>> 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
>>@@ -1655,9 +1651,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>> 	return 0;
>>
>> /* Undo stages on error */
>>-err_dest_symlinks:
>>-	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>>-
>> err_detach:
>> 	if (!USES_PRIMARY(bond->params.mode))
>> 		bond_hw_addr_flush(bond_dev, slave_dev);
>>@@ -1856,8 +1849,6 @@ static int __bond_release_one(struct net_device *bond_dev,
>> 			bond_dev->name, slave_dev->name, bond_dev->name);
>>
>> 	/* must do this from outside any spinlocks */
>>-	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>>-
>> 	vlan_vids_del_by_dev(slave_dev, bond_dev);
>>
>> 	/* If the mode USES_PRIMARY, then this cases was handled above by
>>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>>index 5715277..7b962a2 100644
>>--- a/drivers/net/bonding/bond_sysfs.c
>>+++ b/drivers/net/bonding/bond_sysfs.c
>>@@ -168,31 +168,6 @@ static const struct class_attribute class_attr_bonding_masters = {
>> 	.namespace = bonding_namespace,
>> };
>>
>>-int bond_create_slave_symlinks(struct net_device *master,
>>-			       struct net_device *slave)
>>-{
>>-	char linkname[IFNAMSIZ+7];
>>-	int ret = 0;
>>-
>>-	/* create a link from the master to the slave */
>>-	sprintf(linkname, "slave_%s", slave->name);
>>-	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
>>-				linkname);
>>-
>>-	return ret;
>>-
>>-}
>>-
>>-void bond_destroy_slave_symlinks(struct net_device *master,
>>-				 struct net_device *slave)
>>-{
>>-	char linkname[IFNAMSIZ+7];
>>-
>>-	sprintf(linkname, "slave_%s", slave->name);
>>-	sysfs_remove_link(&(master->dev.kobj), linkname);
>>-}
>>-
>>-
>> /*
>>  * Show the slaves in the current bond.
>>  */
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>index 4abc925..f7a167d 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -455,8 +455,6 @@ int bond_create(struct net *net, const char *name);
>> int bond_create_sysfs(struct bond_net *net);
>> void bond_destroy_sysfs(struct bond_net *net);
>> void bond_prepare_sysfs_group(struct bonding *bond);
>>-int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave);
>>-void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
>> int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
>> int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
>> void bond_mii_monitor(struct work_struct *);
>>diff --git a/net/core/dev.c b/net/core/dev.c
>>index 7eecf35..1c3e98d 100644
>>--- a/net/core/dev.c
>>+++ b/net/core/dev.c
>>@@ -4580,6 +4580,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>> 					bool upper, void *private)
>> {
>> 	struct netdev_adjacent *adj, *neigh = NULL;
>>+	char linkname[IFNAMSIZ+7];
>> 	int ret;
>>
>> 	adj = __netdev_find_adj(dev, adj_dev, upper, false);
>>@@ -4628,6 +4629,16 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>> 			 */
>> 			if (master)
>> 				neigh->private = private;
>>+
>>+			sprintf(linkname, "slave_%s", adj_dev->name);
>>+			ret = sysfs_create_link(&(dev->dev.kobj),
>>+						&(adj_dev->dev.kobj),
>>+						linkname);
>>+			if (ret) {
>>+				kfree(neigh);
>>+				kfree(adj);
>>+				return ret;
>>+			}
>> 			list_add_tail_rcu(&neigh->list,
>> 					  &dev->neighbour_dev_list.lower);
>> 		}
>>@@ -4635,10 +4646,24 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>> 		return 0;
>> 	}
>>
>>+	/* it's upper neighbour, we don't care if it's master or not */
>>+	if (neigh) {
>>+		sprintf(linkname, "upper_%s", adj_dev->name);
>>+		ret = sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
>>+					linkname);
>>+		if (ret) {
>>+			kfree(neigh);
>>+			kfree(adj);
>>+			return ret;
>>+		}
>>+	}
>>+
>> 	/* Ensure that master upper link is always the first item in list. */
>> 	if (master) {
>> 		ret = sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj), "master");
>> 		if (ret) {
>>+			if (neigh)
>>+				sysfs_remove_link(&(dev->dev.kobj), linkname);
>> 			kfree(neigh);
>> 			kfree(adj);
>> 			return ret;
>>@@ -4678,6 +4703,7 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
>> 				  struct net_device *adj_dev, bool upper)
>> {
>> 	struct netdev_adjacent *adj, *neighbour;
>>+	char linkname[IFNAMSIZ+7];
>>
>> 	if (upper) {
>> 		adj = __netdev_find_upper(dev, adj_dev);
>>@@ -4725,6 +4751,9 @@ void __netdev_adjacent_dev_remove(struct net_device *dev,
>> 		list_del_rcu(&neighbour->list);
>> 		if (neighbour->master && upper)
>> 			sysfs_remove_link(&(dev->dev.kobj), "master");
>>+		sprintf(linkname, "%s_%s", upper ? "upper" : "slave",
>>+			adj_dev->name);
>>+		sysfs_remove_link(&(dev->dev.kobj), linkname);
>> 		dev_put(adj_dev);
>> 		kfree_rcu(neighbour, rcu);
>> 	}
>>--
>>1.8.4
>>
