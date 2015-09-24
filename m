From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 9/9] net: fix net_device refcounting
Date: Thu, 24 Sep 2015 20:19:03 +0100
Message-ID: <E1ZfC2p-00037y-Da@rmk-PC.arm.linux.org.uk>
References: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:44832 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbbIXTTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 15:19:15 -0400
In-Reply-To: <20150924191754.GC21513@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_find_net_device_by_node() uses class_find_device() internally to
lookup the corresponding network device.  class_find_device() returns
a reference to the embedded struct device, with its refcount
incremented.

Add a comment to the definition in net/core/net-sysfs.c indicating the
need to drop this refcount, and fix the DSA code to drop this refcount
when the OF-generated platform data is cleaned up and freed.  Also
arrange for the ref to be dropped when handling errors.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 net/core/net-sysfs.c | 9 +++++++++
 net/dsa/dsa.c        | 5 ++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b279077c3089..805a95a48107 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1481,6 +1481,15 @@ static int of_dev_node_match(struct device *dev, const void *data)
 	return ret == 0 ? dev->of_node == data : ret;
 }
 
+/*
+ * of_find_net_device_by_node - lookup the net device for the device node
+ * @np: OF device node
+ *
+ * Looks up the net_device structure corresponding with the device node.
+ * If successful, returns a pointer to the net_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure. The
+ * refcount must be dropped when done with the net_device.
+ */
 struct net_device *of_find_net_device_by_node(struct device_node *np)
 {
 	struct device *dev;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index bf4ba15fb780..c59fa5d9c22c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -679,7 +679,7 @@ static int dsa_of_probe(struct device *dev)
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (!pd) {
 		ret = -ENOMEM;
-		goto out_put_mdio;
+		goto out_put_ethernet;
 	}
 
 	dev->platform_data = pd;
@@ -773,6 +773,8 @@ static int dsa_of_probe(struct device *dev)
 out_free:
 	kfree(pd);
 	dev->platform_data = NULL;
+out_put_ethernet:
+	put_device(&ethernet_dev->dev);
 out_put_mdio:
 	put_device(&mdio_bus->dev);
 	return ret;
@@ -786,6 +788,7 @@ static void dsa_of_remove(struct device *dev)
 		return;
 
 	dsa_of_free_platform_data(pd);
+	put_device(&pd->of_netdev->dev);
 	kfree(pd);
 }
 #else
-- 
2.1.0
