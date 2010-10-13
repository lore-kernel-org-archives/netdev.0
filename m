From: nhorman@tuxdriver.com
Subject: [PATCH 5/5] Re-enable netpoll over bonding
Date: Wed, 13 Oct 2010 08:35:34 -0400
Message-ID: <1286973334-4339-6-git-send-email-nhorman@tuxdriver.com>
References: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38117 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283Ab0JMMgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 08:36:11 -0400
In-Reply-To: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

With the inclusion of previous fixup patches, netpoll over bonding apears to
work reliably with failover conditions.  This reverts Gospos previous commit
c22d7ac844f1cb9c6a5fd20f89ebadc2feef891b, and allows access again to the netpoll
functionality in the bonding driver.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c |   29 ++++++++++-------------------
 1 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bc38d69..d42c380 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -184,9 +184,6 @@ static int arp_ip_count;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static int disable_netpoll = 1;
-#endif
 
 const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	"slow",		AD_LACP_SLOW},
@@ -1811,19 +1808,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	if (disable_netpoll) {
+	if (slaves_support_netpoll(bond_dev)) {
+		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+		if (bond_dev->npinfo)
+			slave_dev->npinfo = bond_dev->npinfo;
+	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-	} else {
-		if (slaves_support_netpoll(bond_dev)) {
-			bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-			if (bond_dev->npinfo)
-				slave_dev->npinfo = bond_dev->npinfo;
-		} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
-			bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-			pr_info("New slave device %s does not support netpoll\n",
-				slave_dev->name);
-			pr_info("Disabling netpoll support for %s\n", bond_dev->name);
-		}
+		pr_info("New slave device %s does not support netpoll\n",
+			slave_dev->name);
+		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
 	}
 #endif
 	read_unlock(&bond->lock);
@@ -2030,10 +2023,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	read_lock_bh(&bond->lock);
 
-	 /* Make sure netpoll over stays disabled until fixed. */
-	if (!disable_netpoll)
-		if (slaves_support_netpoll(bond_dev))
-				bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+	if (slaves_support_netpoll(bond_dev))
+		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
 	read_unlock_bh(&bond->lock);
 	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
 		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
-- 
1.7.2.3

