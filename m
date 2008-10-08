From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] tun: Add offload related ethtool ops
Date: Wed,  8 Oct 2008 20:48:47 +0100
Message-ID: <1223495327-21661-1-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Mark McLoughlin <markmc@redhat.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail17.svc.cra.dublin.eircom.net ([159.134.118.216]:39347 "HELO
	mail17.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751561AbYJHTtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:49:31 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TUNSETOFFLOAD ioctl() allows setting various offload related
device fields, however it is not currently possible to then tweak
those settings using ethtool.

Implement the ethtool ops, but don't allow enabling a feature that
hasn't already been enabled by TUNSETOFFLOAD.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/tun.c |   40 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6daea0c..211e953 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -90,6 +90,7 @@ struct tap_filter {
 struct tun_struct {
 	struct list_head        list;
 	unsigned int 		flags;
+	unsigned long		offload;
 	int			attached;
 	uid_t			owner;
 	gid_t			group;
@@ -753,6 +754,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;
+		tun->offload = 0;
 		tun->txflt.count = 0;
 
 		tun_net_init(dev);
@@ -840,6 +842,7 @@ static int tun_get_iff(struct net *net, struct file *file, struct ifreq *ifr)
  * privs required. */
 static int set_offload(struct net_device *dev, unsigned long arg)
 {
+	struct tun_struct *tun = netdev_priv(dev);
 	unsigned int old_features, features;
 
 	old_features = dev->features;
@@ -873,6 +876,8 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 	if (old_features != dev->features)
 		netdev_features_change(dev);
 
+	tun->offload = dev->features & (NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_TSO);
+
 	return 0;
 }
 
@@ -1187,6 +1192,36 @@ static int tun_set_rx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int tun_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	if (data && !(tun->offload & NETIF_F_HW_CSUM))
+		return -EOPNOTSUPP;
+
+	return ethtool_op_set_tx_hw_csum(dev, data);
+}
+
+static int tun_set_sg(struct net_device *dev, u32 data)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	if (data && !(tun->offload & NETIF_F_SG))
+		return -EOPNOTSUPP;
+
+	return ethtool_op_set_sg(dev, data);
+}
+
+static int tun_set_tso(struct net_device *dev, u32 data)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	if (data && !(tun->offload & NETIF_F_TSO))
+		return -EOPNOTSUPP;
+
+	return ethtool_op_set_tso(dev, data);
+}
+
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_settings	= tun_get_settings,
 	.get_drvinfo	= tun_get_drvinfo,
@@ -1194,7 +1229,10 @@ static const struct ethtool_ops tun_ethtool_ops = {
 	.set_msglevel	= tun_set_msglevel,
 	.get_link	= tun_get_link,
 	.get_rx_csum	= tun_get_rx_csum,
-	.set_rx_csum	= tun_set_rx_csum
+	.set_rx_csum	= tun_set_rx_csum,
+	.set_tx_csum    = tun_set_tx_csum,
+	.set_sg         = tun_set_sg,
+	.set_tso        = tun_set_tso,
 };
 
 static int tun_init_net(struct net *net)
-- 
1.5.4.3

