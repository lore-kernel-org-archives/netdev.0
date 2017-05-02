From: gfree.wind@foxmail.com
Subject: [PATCH net v4 11/12] net: vlan: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 21:41:44 +0800
Message-ID: <7ba8926009ed518d3758972a48b8b7b67ec52171.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:43452 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdEBNl4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 09:41:56 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
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
@@ -803,10 +815,7 @@ static int vlan_dev_get_iflink(const struct net_device *dev)
 
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
1.9.1
