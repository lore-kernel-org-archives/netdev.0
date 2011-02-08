From: David Miller <davem@davemloft.net>
Subject: [PATCH] net/caif: Fix dangling list pointer in freed object on
 error.
Date: Tue, 08 Feb 2011 14:33:21 -0800 (PST)
Message-ID: <20110208.143321.28812684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34574
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753679Ab1BHWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


rtnl_link_ops->setup(), and the "setup" callback passed to alloc_netdev*(),
cannot make state changes which need to be undone on failure.  There is
no cleanup mechanism available at this point.

So we have to add the caif private instance to the global list once we
are sure that register_netdev() has succedded in ->newlink().

Otherwise, if register_netdev() fails, the caller will invoke free_netdev()
and we will have a reference to freed up memory on the chnl_net_list.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-2.6, I need this setup() invariant to be properly
followed tree-wide in order to fix another bug.

 net/caif/chnl_net.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index fa9dab3..6008d6d 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -394,9 +394,7 @@ static void ipcaif_net_setup(struct net_device *dev)
 	priv->conn_req.sockaddr.u.dgm.connection_id = -1;
 	priv->flowenabled = false;
 
-	ASSERT_RTNL();
 	init_waitqueue_head(&priv->netmgmt_wq);
-	list_add(&priv->list_field, &chnl_net_list);
 }
 
 
@@ -453,6 +451,8 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 	ret = register_netdevice(dev);
 	if (ret)
 		pr_warn("device rtml registration failed\n");
+	else
+		list_add(&caifdev->list_field, &chnl_net_list);
 	return ret;
 }
 
-- 
1.7.4

