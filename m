From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: [PATCH] veth: Allow a peer to be up at creation time
Date: Thu, 24 Apr 2014 17:56:06 +0900
Message-ID: <5358d1a70002df7a00005df100005bf3a00002a40d3b@amlmta037.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, a veth peer cannot be up at creation time.

# ip link add type veth peer up
RTNETLINK answers: Transport endpoint is not connected

Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>
---
 drivers/net/veth.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b4a10bc..aa87afc 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -373,10 +373,6 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	netif_carrier_off(peer);
 
-	err = rtnl_configure_link(peer, ifmp);
-	if (err < 0)
-		goto err_configure_peer;
-
 	/*
 	 * register dev last
 	 *
@@ -407,11 +403,16 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+
+	err = rtnl_configure_link(peer, ifmp);
+	if (err < 0)
+		goto err_configure_peer;
+
 	return 0;
 
-err_register_dev:
-	/* nothing to do */
 err_configure_peer:
+	unregister_netdevice(dev);
+err_register_dev:
 	unregister_netdevice(peer);
 	return err;
 
-- 
2.0.0.rc0
