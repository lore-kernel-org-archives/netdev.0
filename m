From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/5] bonding: simplify bond_3ad_update_lacp_rate and use RTNL for sync
Date: Mon,  2 Sep 2013 13:51:40 +0200
Message-ID: <1378122702-28943-4-git-send-email-nikolay@redhat.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758232Ab3IBL4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:56:24 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can drop the use of bond->lock for mutual exclusion in
bond_3ad_update_lacp_rate and use RTNL in the sysfs store function
instead. This way we'll prevent races with mode change and interface
up/down as well as simplify update_lacp_rate by removing the check for
port->slave because it'll always be initialized (done while enslaving
with RTNL). This change will also help in the future removal of reader
bond->lock from bond_enslave.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c   | 8 +-------
 drivers/net/bonding/bond_sysfs.c | 7 ++++++-
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 9010265..0d8f427 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2514,17 +2514,13 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
  */
 void bond_3ad_update_lacp_rate(struct bonding *bond)
 {
-	struct slave *slave;
 	struct port *port = NULL;
+	struct slave *slave;
 	int lacp_fast;
 
-	write_lock_bh(&bond->lock);
 	lacp_fast = bond->params.lacp_fast;
-
 	bond_for_each_slave(bond, slave) {
 		port = &(SLAVE_AD_INFO(slave).port);
-		if (port->slave == NULL)
-			continue;
 		__get_state_machine_lock(port);
 		if (lacp_fast)
 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
@@ -2532,6 +2528,4 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
 			port->actor_oper_port_state &= ~AD_STATE_LACP_TIMEOUT;
 		__release_state_machine_lock(port);
 	}
-
-	write_unlock_bh(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0f539de..ce46776 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -852,8 +852,11 @@ static ssize_t bonding_store_lacp(struct device *d,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
 {
-	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
+	int new_value, ret = count;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
 
 	if (bond->dev->flags & IFF_UP) {
 		pr_err("%s: Unable to update LACP rate because interface is up.\n",
@@ -883,6 +886,8 @@ static ssize_t bonding_store_lacp(struct device *d,
 		ret = -EINVAL;
 	}
 out:
+	rtnl_unlock();
+
 	return ret;
 }
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
-- 
1.8.1.4
