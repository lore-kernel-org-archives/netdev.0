From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/15] net: remove no longer used netdev_set_bond_master() and netdev_set_master()
Date: Sun, 30 Dec 2012 12:58:21 +0100
Message-ID: <1356868702-8144-15-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:49196 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab2L3MBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:01:17 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so5749537eek.39
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 04:01:15 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  6 +----
 net/core/dev.c            | 63 -----------------------------------------------
 2 files changed, 1 insertion(+), 68 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 52d1146..c3723ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -856,8 +856,7 @@ struct netdev_fcoe_hbainfo {
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
  *
- *	Slave management functions (for bridge, bonding, etc). User should
- *	call netdev_set_master() to set dev->master properly.
+ *	Slave management functions (for bridge, bonding, etc).
  * int (*ndo_add_slave)(struct net_device *dev, struct net_device *slave_dev);
  *	Called to make another netdev an underling.
  *
@@ -2648,9 +2647,6 @@ extern int netdev_master_upper_dev_link(struct net_device *dev,
 					struct net_device *upper_dev);
 extern void netdev_upper_dev_unlink(struct net_device *dev,
 				    struct net_device *upper_dev);
-extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern int netdev_set_bond_master(struct net_device *dev,
-				  struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1af3141..ccca4bf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4824,69 +4824,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-/**
- *	netdev_set_master	-	set up master pointer
- *	@slave: slave device
- *	@master: new master device
- *
- *	Changes the master device of the slave. Pass %NULL to break the
- *	bonding. The caller must hold the RTNL semaphore. On a failure
- *	a negative errno code is returned. On success the reference counts
- *	are adjusted and the function returns zero.
- */
-int netdev_set_master(struct net_device *slave, struct net_device *master)
-{
-	struct net_device *old = slave->master;
-	int err;
-
-	ASSERT_RTNL();
-
-	if (master) {
-		if (old)
-			return -EBUSY;
-		err = netdev_master_upper_dev_link(slave, master);
-		if (err)
-			return err;
-	}
-
-	slave->master = master;
-
-	if (old)
-		netdev_upper_dev_unlink(slave, master);
-
-	return 0;
-}
-EXPORT_SYMBOL(netdev_set_master);
-
-/**
- *	netdev_set_bond_master	-	set up bonding master/slave pair
- *	@slave: slave device
- *	@master: new master device
- *
- *	Changes the master device of the slave. Pass %NULL to break the
- *	bonding. The caller must hold the RTNL semaphore. On a failure
- *	a negative errno code is returned. On success %RTM_NEWLINK is sent
- *	to the routing socket and the function returns zero.
- */
-int netdev_set_bond_master(struct net_device *slave, struct net_device *master)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	err = netdev_set_master(slave, master);
-	if (err)
-		return err;
-	if (master)
-		slave->flags |= IFF_SLAVE;
-	else
-		slave->flags &= ~IFF_SLAVE;
-
-	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
-	return 0;
-}
-EXPORT_SYMBOL(netdev_set_bond_master);
-
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.0
