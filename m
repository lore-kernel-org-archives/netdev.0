From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next] net/8021q: create device with all possible features in wanted_features
Date: Wed, 15 Mar 2017 17:41:14 -0700
Message-ID: <20170316004114.17059-1-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>,
        Alexey Kuznetsov <kuznet@virtuozzo.com>,
        "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34018 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdCPAle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 20:41:34 -0400
Received: by mail-pf0-f195.google.com with SMTP id o126so3795420pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:41:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wanted_features is a set of features which have to be enabled if a
hardware allows that.

Currently when a vlan device is created, its wanted_features is set to
current features of its base device.

The problem is that the base device can get new features and they are
not propagated to vlan-s of this device.

If we look at bonding devices, they doesn't have this problem and this
patch suggests to fix this issue by the same way how it works for bonding
devices.

We meet this problem, when we try to create a vlan device over a bonding
device. When a system are booting, real devices require time to be
initialized, so bonding devices created without slaves, then vlan
devices are created and only then ethernet devices are added to the
bonding device. As a result we have vlan devices with disabled
scatter-gather.

* create a bonding device
  $ ip link add bond0 type bond
  $ ethtool -k bond0 | grep scatter
  scatter-gather: off
	tx-scatter-gather: off [requested on]
	tx-scatter-gather-fraglist: off [requested on]

* create a vlan device
  $ ip link add link bond0 name bond0.10 type vlan id 10
  $ ethtool -k bond0.10 | grep scatter
  scatter-gather: off
	tx-scatter-gather: off
	tx-scatter-gather-fraglist: off

* Add a slave device to bond0
  $ ip link set dev eth0 master bond0

And now we can see that the bond0 device has got the scatter-gather
feature, but the bond0.10 hasn't got it.
[root@laptop linux-task-diag]# ethtool -k bond0 | grep scatter
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: on
[root@laptop linux-task-diag]# ethtool -k bond0.10 | grep scatter
scatter-gather: off
	tx-scatter-gather: off
	tx-scatter-gather-fraglist: off

With this patch the vlan device will get all new features from the
bonding device.

Here is a call trace how features which are set in this patch reach
dev->wanted_features.

register_netdevice
   vlan_dev_init
	...
	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG |
		       NETIF_F_FRAGLIST | NETIF_F_GSO_SOFTWARE |
		       NETIF_F_HIGHDMA | NETIF_F_SCTP_CRC |
		       NETIF_F_ALL_FCOE;

	dev->features |= dev->hw_features;
	...
    dev->wanted_features = dev->features & dev->hw_features;
    __netdev_update_features(dev);
        vlan_dev_fix_features
	   ...

Cc: Alexey Kuznetsov <kuznet@virtuozzo.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/8021q/vlan_dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 10da6c5..b9ad2f8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -562,8 +562,7 @@ static int vlan_dev_init(struct net_device *dev)
 			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CRC |
 			   NETIF_F_ALL_FCOE;
 
-	dev->features |= real_dev->vlan_features | NETIF_F_LLTX |
-			 NETIF_F_GSO_SOFTWARE;
+	dev->features |= dev->hw_features | NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
 	dev->gso_max_segs = real_dev->gso_max_segs;
 	if (dev->features & NETIF_F_VLAN_FEATURES)
-- 
2.9.3
