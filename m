From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] team: Fix possible deadlock during team enslave
Date: Mon, 20 Jun 2016 11:53:20 +0300
Message-ID: <1466412800-18400-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jiri@mellanox.com>, <eladr@mellanox.com>,
	<yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, <lucien.xin@gmail.com>,
	Ido Schimmel <idosch@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0055.outbound.protection.outlook.com ([157.55.234.55]:10019
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752770AbcFTI4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 04:56:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both dev_uc_sync_multiple() and dev_mc_sync_multiple() require the
source device to be locked by netif_addr_lock_bh(), but this is missing
in team's enslave function, so add it.

This fixes the following lockdep warning:

Possible interrupt unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(_xmit_ETHER/1);
                                local_irq_disable();
                                lock(&(&mc->mca_lock)->rlock);
                                lock(&team_netdev_addr_lock_key);
   <Interrupt>
     lock(&(&mc->mca_lock)->rlock);

  *** DEADLOCK ***

Fixes: cb41c997d444 ("team: team should sync the port's uc/mc addrs when add a port")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/team/team.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2ace126..fdee772 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1203,8 +1203,10 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_dev_open;
 	}
 
+	netif_addr_lock_bh(dev);
 	dev_uc_sync_multiple(port_dev, dev);
 	dev_mc_sync_multiple(port_dev, dev);
+	netif_addr_unlock_bh(dev);
 
 	err = vlan_vids_add_by_dev(port_dev, dev);
 	if (err) {
-- 
2.8.2
