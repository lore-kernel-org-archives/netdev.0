From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 2/8] bonding: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 08:54:42 +0800
Message-ID: <485AFFD2.4090304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53577 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754299AbYFTA6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 20:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

In bond_alb and bond_main, we check all positive increment for promiscuity
and allmulti to get error return.
But there are still two problems left.
1. Some callers want quiet handle.
2. If there are multi slaves, it's hard to tell which slaves increment
   promisc/allmulti successfully and which failed.
So I left these problems to be FIXME.
Fortunately, the overflow is very rare case.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/bonding/bond_alb.c  |    7 ++++-
 drivers/net/bonding/bond_main.c |   41 +++++++++++++++++++++++++++++++-------
 2 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 5a67372..26d49d8 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -419,8 +419,11 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 	}
 
 	if (!bond->alb_info.primary_is_promisc) {
-		bond->alb_info.primary_is_promisc = 1;
-		dev_set_promiscuity(bond->curr_active_slave->dev, 1);
+		/* dev_set_promiscuity might overflow, check it here */
+		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
+			bond->alb_info.primary_is_promisc = 1;
+		else
+			bond->alb_info.primary_is_promisc = 0;
 	}
 
 	bond->alb_info.rlb_promisc_timeout_counter = 0;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 50a40e4..f5e5550 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -762,39 +762,49 @@ static struct dev_mc_list *bond_mc_list_find_dmi(struct dev_mc_list *dmi, struct
 /*
  * Push the promiscuity flag down to appropriate slaves
  */
-static void bond_set_promiscuity(struct bonding *bond, int inc)
+static int bond_set_promiscuity(struct bonding *bond, int inc)
 {
+	int err = 0;
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
-			dev_set_promiscuity(bond->curr_active_slave->dev, inc);
+			err = dev_set_promiscuity(bond->curr_active_slave->dev,
+						  inc);
 		}
 	} else {
 		struct slave *slave;
 		int i;
 		bond_for_each_slave(bond, slave, i) {
-			dev_set_promiscuity(slave->dev, inc);
+			err = dev_set_promiscuity(slave->dev, inc);
+			if (err)
+				return err;
 		}
 	}
+	return err;
 }
 
 /*
  * Push the allmulti flag down to all slaves
  */
-static void bond_set_allmulti(struct bonding *bond, int inc)
+static int bond_set_allmulti(struct bonding *bond, int inc)
 {
+	int err = 0;
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
-			dev_set_allmulti(bond->curr_active_slave->dev, inc);
+			err = dev_set_allmulti(bond->curr_active_slave->dev,
+					       inc);
 		}
 	} else {
 		struct slave *slave;
 		int i;
 		bond_for_each_slave(bond, slave, i) {
-			dev_set_allmulti(slave->dev, inc);
+			err = dev_set_allmulti(slave->dev, inc);
+			if (err)
+				return err;
 		}
 	}
+	return err;
 }
 
 /*
@@ -955,6 +965,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 	}
 
 	if (new_active) {
+		/* FIXME: promiscuity and allmulti might overflow,
+		 * but bond_mc_swap's caller likes quiet handle.
+		 */
 		if (bond->dev->flags & IFF_PROMISC) {
 			dev_set_promiscuity(new_active->dev, 1);
 		}
@@ -1456,12 +1469,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (!USES_PRIMARY(bond->params.mode)) {
 		/* set promiscuity level to new slave */
 		if (bond_dev->flags & IFF_PROMISC) {
-			dev_set_promiscuity(slave_dev, 1);
+			res = dev_set_promiscuity(slave_dev, 1);
+			if (res)
+				goto err_close;
 		}
 
 		/* set allmulti level to new slave */
 		if (bond_dev->flags & IFF_ALLMULTI) {
-			dev_set_allmulti(slave_dev, 1);
+			res = dev_set_allmulti(slave_dev, 1);
+			if (res)
+				goto err_close;
 		}
 
 		netif_tx_lock_bh(bond_dev);
@@ -3933,6 +3950,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	 * Do promisc before checking multicast_mode
 	 */
 	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC)) {
+		/*
+		 * FIXME: If bond has multi slaves, how to handle the error
+		 * when one of the slaves encounters promiscuity overflow.
+		 */
 		bond_set_promiscuity(bond, 1);
 	}
 
@@ -3942,6 +3963,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 
 	/* set allmulti flag to slaves */
 	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI)) {
+		/*
+		 * FIXME: If bond has multi slaves, how to handle the error
+		 * when one of the slaves encounters allmulti overflow.
+		 */
 		bond_set_allmulti(bond, 1);
 	}
 
-- 
1.5.3.4



