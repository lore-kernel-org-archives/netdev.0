From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 10/27] bonding: use bond_for_each_slave() in
 bond_uninit()
Date: Wed, 18 Sep 2013 11:53:45 +0200
Message-ID: <20130918095345.GA4077@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
 <1379378812-18346-11-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: jiri@resnulli.us, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab3IRJzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 05:55:35 -0400
Content-Disposition: inline
In-Reply-To: <1379378812-18346-11-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 02:46:35AM +0200, Veaceslav Falico wrote:
>We're safe agains removal there, cause we use neighbours primitives.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>---
>
>Notes:
>    v2  -> v3:
>    No change.
>
>    v1  -> v2:
>    No changes.
>
>    RFC -> v1:
>    Move the patch rigth after we start using neighbour lists for
>    bond_for_each_slave().
>
> drivers/net/bonding/bond_main.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index cdd5c5f..2075321 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4090,12 +4090,13 @@ static void bond_setup(struct net_device *bond_dev)
> static void bond_uninit(struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>-	struct slave *slave, *tmp_slave;
>+	struct list_head *iter;
>+	struct slave *slave;
>
> 	bond_netpoll_cleanup(bond_dev);
>
> 	/* Release the bonded slaves */
>-	list_for_each_entry_safe(slave, tmp_slave, &bond->slave_list, list)
>+	bond_for_each_slave(bond, slave, iter)
> 		__bond_release_one(bond_dev, slave->dev, true);

Seems like we're not really safe here, however it's easily fixable if the
*iter in netdev_for_each_lower_private() will contain the ->next pointer,
just as in list_for_each_entry_safe().

I'll fix it in the next version, something like that:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b487302..e101f5a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2839,7 +2839,7 @@ extern void *netdev_lower_get_next_private_rcu(struct net_device *dev,
  					       struct list_head **iter);
  
  #define netdev_for_each_lower_private(dev, priv, iter) \
-	for (iter = &(dev)->adj_list.lower, \
+	for (iter = (dev)->adj_list.lower.next, \
  	     priv = netdev_lower_get_next_private(dev, &(iter)); \
  	     priv; \
  	     priv = netdev_lower_get_next_private(dev, &(iter)))
diff --git a/net/core/dev.c b/net/core/dev.c
index 5fe2dd0..8bd0c43 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4563,7 +4563,7 @@ void *netdev_lower_get_next_private(struct net_device *dev,
  	struct netdev_adjacent *lower;
  
  	if (iter)
-		lower = list_entry((*iter)->next, struct netdev_adjacent,
+		lower = list_entry(*iter, struct netdev_adjacent,
  				   list);
  	else
  		lower = list_entry(dev->adj_list.lower.next,
@@ -4573,7 +4573,7 @@ void *netdev_lower_get_next_private(struct net_device *dev,
  		return NULL;
  
  	if (iter)
-		*iter = &lower->list;
+		*iter = lower->list.next;
  
  	return lower->private;
  }

> 	pr_info("%s: released all slaves\n", bond_dev->name);
>
>-- 
>1.8.4
>
