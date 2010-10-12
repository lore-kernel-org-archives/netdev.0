From: nhorman@tuxdriver.com
Subject: [PATCH 5/5] Re-enable netpoll over bonding
Date: Tue, 12 Oct 2010 17:55:52 -0400
Message-ID: <1286920552-2173-6-git-send-email-nhorman@tuxdriver.com>
References: <1286920552-2173-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56618 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578Ab0JLV4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:56:19 -0400
In-Reply-To: <1286920552-2173-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

With the inclusion of previous fixup patches, netpoll over bonding apears to
work reliably with failover conditions.  This reverts Gospos previous commit
c22d7ac844f1cb9c6a5fd20f89ebadc2feef891b, and allows access again to the netpoll
functionality in the bonding driver.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c |   31 +++++++++++--------------------
 1 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1d0d8c5..3b53360 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -173,7 +173,7 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static cpumask_var_t netpoll_block_tx;
 
-static inline void block_netpoll_tx(void
+static inline void block_netpoll_tx(void)
 {
 	preempt_disable();
 	BUG_ON(cpumask_test_and_set_cpu(smp_processor_id(),
@@ -209,9 +209,6 @@ static int arp_ip_count;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static int disable_netpoll = 1;
-#endif
 
 const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	"slow",		AD_LACP_SLOW},
@@ -1836,19 +1833,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -2055,10 +2048,8 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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

