From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 26/33] net: ipoib - set name assign type
Date: Thu, 10 Jul 2014 10:17:31 +0200
Message-ID: <1404980258-30853-27-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Erez Shitrit <erezsh@mellanox.com>,
	Michal Schmidt <mschmidt@redhat.com>,
	Jim Foraker <foraker1@llnl.gov>, linux-rdma@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:39081 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbaGJIS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:57 -0400
Received: by mail-lb0-f180.google.com with SMTP id w7so5775617lbi.39
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:56 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When naming a device based on a combination of the parent device, and
the upsr-supplied key, inherit the name assign type from the parent.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Erez Shitrit <erezsh@mellanox.com>
Cc: Michal Schmidt <mschmidt@redhat.com>
Cc: Jim Foraker <foraker1@llnl.gov>
Cc: linux-rdma@vger.kernel.org
---
 drivers/infiniband/ulp/ipoib/ipoib.h      |  2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 12 +++++++-----
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c |  2 +-
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index c639f90..2654288 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -464,7 +464,7 @@ void ipoib_reap_ah(struct work_struct *work);
 
 void ipoib_mark_paths_invalid(struct net_device *dev);
 void ipoib_flush_paths(struct net_device *dev);
-struct ipoib_dev_priv *ipoib_intf_alloc(const char *format);
+struct ipoib_dev_priv *ipoib_intf_alloc(const char *format, unsigned char name_assign_type);
 
 int ipoib_ib_dev_init(struct net_device *dev, struct ib_device *ca, int port);
 void ipoib_ib_dev_flush_light(struct work_struct *work);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 4e675f4..b1d58ef 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1390,12 +1390,13 @@ void ipoib_setup(struct net_device *dev)
 	INIT_DELAYED_WORK(&priv->neigh_reap_task, ipoib_reap_neigh);
 }
 
-struct ipoib_dev_priv *ipoib_intf_alloc(const char *name)
+struct ipoib_dev_priv *ipoib_intf_alloc(const char *name,
+					unsigned char name_assign_type)
 {
 	struct net_device *dev;
 
-	dev = alloc_netdev((int)sizeof(struct ipoib_dev_priv), name,
-			   NET_NAME_UNKNOWN, ipoib_setup);
+	dev = alloc_netdev((int) sizeof (struct ipoib_dev_priv), name,
+			   name_assign_type, ipoib_setup);
 	if (!dev)
 		return NULL;
 
@@ -1535,13 +1536,14 @@ int ipoib_set_dev_features(struct ipoib_dev_priv *priv, struct ib_device *hca)
 }
 
 static struct net_device *ipoib_add_port(const char *format,
+					 unsigned char name_assign_type,
 					 struct ib_device *hca, u8 port)
 {
 	struct ipoib_dev_priv *priv;
 	struct ib_port_attr attr;
 	int result = -ENOMEM;
 
-	priv = ipoib_intf_alloc(format);
+	priv = ipoib_intf_alloc(format, name_assign_type);
 	if (!priv)
 		goto alloc_mem_failed;
 
@@ -1676,7 +1678,7 @@ static void ipoib_add_one(struct ib_device *device)
 	for (p = s; p <= e; ++p) {
 		if (rdma_port_get_link_layer(device, p) != IB_LINK_LAYER_INFINIBAND)
 			continue;
-		dev = ipoib_add_port("ib%d", device, p);
+		dev = ipoib_add_port("ib%d", NET_NAME_ENUM, device, p);
 		if (!IS_ERR(dev)) {
 			priv = netdev_priv(dev);
 			list_add_tail(&priv->list, dev_list);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 9fad7b5..88558d3 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -133,7 +133,7 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 
 	snprintf(intf_name, sizeof intf_name, "%s.%04x",
 		 ppriv->dev->name, pkey);
-	priv = ipoib_intf_alloc(intf_name);
+	priv = ipoib_intf_alloc(intf_name, ppriv->dev->name_assign_type);
 	if (!priv)
 		return -ENOMEM;
 
-- 
1.9.3
