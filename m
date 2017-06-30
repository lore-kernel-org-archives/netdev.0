From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] vxlan: correctly set vxlan->net when creating the device in a netns
Date: Fri, 30 Jun 2017 15:50:00 +0200
Message-ID: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Matthias Schiffer <mschiffer@universe-factory.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49066 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751927AbdF3NuF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:50:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a985343ba906 ("vxlan: refactor verification and application of
configuration") modified vxlan device creation, and replaced the
assignment of vxlan->net to src_net with dev_net(netdev) in ->setup().

But dev_net(netdev) is not the same as src_net. At the time ->setup()
is called, dev_net hasn't been set yet, so we end up creating the
socket for the vxlan device in init_net.

Fix this by bringing back the assignment of vxlan->net during device
creation.

Fixes: a985343ba906 ("vxlan: refactor verification and application of configuration")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/vxlan.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fd0ff97e3d81..47d6e65851aa 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2656,7 +2656,6 @@ static void vxlan_setup(struct net_device *dev)
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
 	vxlan->dev = dev;
-	vxlan->net = dev_net(dev);
 
 	gro_cells_init(&vxlan->gro_cells, dev);
 
@@ -3028,7 +3027,9 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 
 static void vxlan_config_apply(struct net_device *dev,
 			       struct vxlan_config *conf,
-			       struct net_device *lowerdev, bool changelink)
+			       struct net_device *lowerdev,
+			       struct net *src_net,
+			       bool changelink)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
@@ -3044,6 +3045,8 @@ static void vxlan_config_apply(struct net_device *dev,
 
 		if (conf->mtu)
 			dev->mtu = conf->mtu;
+
+		vxlan->net = src_net;
 	}
 
 	dst->remote_vni = conf->vni;
@@ -3086,7 +3089,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	if (ret)
 		return ret;
 
-	vxlan_config_apply(dev, conf, lowerdev, changelink);
+	vxlan_config_apply(dev, conf, lowerdev, src_net, changelink);
 
 	return 0;
 }
-- 
2.13.2
