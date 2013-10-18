From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] bonding: remove bond_ioctl_change_active()
Date: Fri, 18 Oct 2013 17:43:36 +0200
Message-ID: <1382111019-1102-5-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:47136 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab3JRPns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:48 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so2133661eek.16
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:47 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no longer needed since bond_option_active_slave_set() can be used
instead.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 59 ++---------------------------------------
 1 file changed, 2 insertions(+), 57 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a113e42..d90734f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1910,61 +1910,6 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	return ret;
 }
 
-/*
- * This function changes the active slave to slave <slave_dev>.
- * It returns -EINVAL in the following cases.
- *  - <slave_dev> is not found in the list.
- *  - There is not active slave now.
- *  - <slave_dev> is already active.
- *  - The link state of <slave_dev> is not BOND_LINK_UP.
- *  - <slave_dev> is not running.
- * In these cases, this function does nothing.
- * In the other cases, current_slave pointer is changed and 0 is returned.
- */
-static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_device *slave_dev)
-{
-	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *old_active = NULL;
-	struct slave *new_active = NULL;
-	int res = 0;
-
-	if (!USES_PRIMARY(bond->params.mode))
-		return -EINVAL;
-
-	/* Verify that bond_dev is indeed the master of slave_dev */
-	if (!(slave_dev->flags & IFF_SLAVE) ||
-	    !netdev_has_upper_dev(slave_dev, bond_dev))
-		return -EINVAL;
-
-	read_lock(&bond->lock);
-
-	old_active = bond->curr_active_slave;
-	new_active = bond_get_slave_by_dev(bond, slave_dev);
-	/*
-	 * Changing to the current active: do nothing; return success.
-	 */
-	if (new_active && new_active == old_active) {
-		read_unlock(&bond->lock);
-		return 0;
-	}
-
-	if (new_active &&
-	    old_active &&
-	    new_active->link == BOND_LINK_UP &&
-	    IS_UP(new_active->dev)) {
-		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
-		bond_change_active_slave(bond, new_active);
-		write_unlock_bh(&bond->curr_slave_lock);
-		unblock_netpoll_tx();
-	} else
-		res = -EINVAL;
-
-	read_unlock(&bond->lock);
-
-	return res;
-}
-
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3257,6 +3202,7 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 
 static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd)
 {
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device *slave_dev = NULL;
 	struct ifbond k_binfo;
 	struct ifbond __user *u_binfo = NULL;
@@ -3287,7 +3233,6 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 
 		if (mii->reg_num == 1) {
-			struct bonding *bond = netdev_priv(bond_dev);
 			mii->val_out = 0;
 			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
@@ -3359,7 +3304,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
-			res = bond_ioctl_change_active(bond_dev, slave_dev);
+			res = bond_option_active_slave_set(bond, slave_dev);
 			break;
 		default:
 			res = -EOPNOTSUPP;
-- 
1.8.3.1
