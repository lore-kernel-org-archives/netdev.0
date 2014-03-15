From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Fri, 14 Mar 2014 22:02:53 -0400 (EDT)
Message-ID: <20140314.220253.2108022241165181233.davem@davemloft.net>
References: <5321165A.1000208@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaCOCC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 22:02:57 -0400
In-Reply-To: <5321165A.1000208@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 13 Mar 2014 10:22:18 +0800

> When I open the LOCKDEP config and run these steps:

This doesn't work?

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4b65aa4..9ad89ff 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -556,10 +556,22 @@ static struct device_type vlan_type = {
 
 static const struct net_device_ops vlan_netdev_ops;
 
+static int vlan_calculate_locking_subclass(struct net_device *real_dev)
+{
+	int subclass = 0;
+
+	while (is_vlan_dev(real_dev)) {
+		subclass++;
+		real_dev = vlan_dev_priv(real_dev)->real_dev;
+	}
+
+	return subclass;
+}
+
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
-	int subclass = 0, i;
+	int subclass, i;
 
 	netif_carrier_off(dev);
 
@@ -604,9 +616,7 @@ static int vlan_dev_init(struct net_device *dev)
 
 	SET_NETDEV_DEVTYPE(dev, &vlan_type);
 
-	if (is_vlan_dev(real_dev))
-		subclass = 1;
-
+	subclass = vlan_calculate_locking_subclass(real_dev);
 	vlan_dev_set_lockdep_class(dev, subclass);
 
 	vlan_dev_priv(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
