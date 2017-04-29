From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: vlan: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:59:03 +0800
Message-ID: <1493438343-27692-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, idosch@mellanox.com, jiri@mellanox.co,
        pabeni@redhat.com, mmanning@brocade.com, jarod@redhat.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg62.qq.com ([103.7.29.139]:20759 "EHLO smtpbg64.qq.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751442AbdD2ECj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Apr 2017 00:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The vlan driver allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func vlan_destructor_free to free the mem in the
destructor, and ndo_uninit func also invokes it when fail to register
the vlan device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/8021q/vlan_dev.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e97ab82..adcaa39 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -608,6 +608,14 @@ static int vlan_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void vlan_destructor_free(struct net_device *dev)
+{
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+
+	free_percpu(vlan->vlan_pcpu_stats);
+	vlan->vlan_pcpu_stats = NULL;
+}
+
 static void vlan_dev_uninit(struct net_device *dev)
 {
 	struct vlan_priority_tci_mapping *pm;
@@ -620,6 +628,10 @@ static void vlan_dev_uninit(struct net_device *dev)
 			kfree(pm);
 		}
 	}
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		vlan_destructor_free(dev);
 }
 
 static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
@@ -803,10 +815,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 
 static void vlan_dev_free(struct net_device *dev)
 {
-	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
-
-	free_percpu(vlan->vlan_pcpu_stats);
-	vlan->vlan_pcpu_stats = NULL;
+	vlan_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
2.7.4
