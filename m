From: Erez Shitrit <erezsh@mellanox.com>
Subject: [PATCH net-next] IB/ipoib: Fix ndo_get_iflink
Date: Thu, 16 Apr 2015 16:30:35 +0300
Message-ID: <1429191035-8555-1-git-send-email-erezsh@mellanox.com>
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
	linux-rdma@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
	Honggang Li <honli@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:38568 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754527AbbDPNbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 09:31:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, iflink of the parent interface was always accessed, event 
when interface didn't have a parent and hence we rashed there.

Handle the interface types properly: for a child interface, return
the ifindex of the parent, for parent interface, return its ifindex.

For child devices, make sure to set the parent pointer prior to
invoking register_netdevice(), this allows the new ndo to be called
by the stack immediately after the child device is registered.

Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
Reported-by: Honggang Li <honli@redhat.com>
Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Honggang Li <honli@redhat.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 5 +++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c | 3 +--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 657b89b..915ad04 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -846,6 +846,11 @@ static int ipoib_get_iflink(const struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
+	/* parent interface */
+	if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
+		return dev->ifindex;
+
+	/* child/vlan interface */
 	return priv->parent->ifindex;
 }
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 4dd1313..fca1a88 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -58,6 +58,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 	/* MTU will be reset when mcast join happens */
 	priv->dev->mtu   = IPOIB_UD_MTU(priv->max_ib_mtu);
 	priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
+	priv->parent = ppriv->dev;
 	set_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags);
 
 	result = ipoib_set_dev_features(priv, ppriv->ca);
@@ -84,8 +85,6 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 		goto register_failed;
 	}
 
-	priv->parent = ppriv->dev;
-
 	ipoib_create_debug_files(priv->dev);
 
 	/* RTNL childs don't need proprietary sysfs entries */
-- 
1.7.11.3
