From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/6] nfp: flower: restore RTNL locking around representor updates
Date: Sat,  2 Sep 2017 18:26:05 -0700
Message-ID: <20170903012605.7435-7-jakub.kicinski@netronome.com>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:37271 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752966AbdICB0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:18 -0400
Received: by mail-pg0-f47.google.com with SMTP id 83so9852143pgb.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:18 -0700 (PDT)
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we moved to updating representors from a workqueue grabbing
the RTNL somehow got lost in the process.  Restore it, and make
sure RCU lock is not held while we are grabbing the RTNL.  RCU
protects the representor table, so since we will be under RTNL
we can drop RCU lock as soon as we find the netdev pointer.
RTNL is needed for the dev_set_mtu() call.

Fixes: 2dff19622421 ("nfp: process MTU updates from firmware flower app")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
index e014d862b9b6..c3ca05d10fe1 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.c
@@ -141,12 +141,14 @@ nfp_flower_cmsg_portmod_rx(struct nfp_app *app, struct sk_buff *skb)
 	msg = nfp_flower_cmsg_get_data(skb);
 	link = msg->info & NFP_FLOWER_CMSG_PORTMOD_INFO_LINK;
 
+	rtnl_lock();
 	rcu_read_lock();
 	netdev = nfp_app_repr_get(app, be32_to_cpu(msg->portnum));
+	rcu_read_unlock();
 	if (!netdev) {
 		nfp_flower_cmsg_warn(app, "ctrl msg for unknown port 0x%08x\n",
 				     be32_to_cpu(msg->portnum));
-		rcu_read_unlock();
+		rtnl_unlock();
 		return;
 	}
 
@@ -161,7 +163,7 @@ nfp_flower_cmsg_portmod_rx(struct nfp_app *app, struct sk_buff *skb)
 	} else {
 		netif_carrier_off(netdev);
 	}
-	rcu_read_unlock();
+	rtnl_unlock();
 }
 
 static void
-- 
2.14.1
