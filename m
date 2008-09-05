From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 15/18] netdevice libertas: Fix directly reference of netdev->priv
Date: Fri, 05 Sep 2008 11:28:47 +0800
Message-ID: <48C0A76F.8090706@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48C0A219.2030004-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 drivers/net/wireless/libertas/main.c |   36 +++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index bd32ac0..71c4bd8 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -223,7 +223,7 @@ u8 lbs_data_rate_to_fw_index(u32 rate)
 static ssize_t lbs_anycast_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -242,7 +242,7 @@ static ssize_t lbs_anycast_get(struct device *dev,
 static ssize_t lbs_anycast_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_access mesh_access;
 	uint32_t datum;
 	int ret;
@@ -270,7 +270,7 @@ static void lbs_remove_mesh(struct lbs_private *priv);
 static ssize_t lbs_rtap_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	return snprintf(buf, 5, "0x%X\n", priv->monitormode);
 }
 
@@ -281,7 +281,7 @@ static ssize_t lbs_rtap_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
 	int monitor_mode;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 
 	sscanf(buf, "%x", &monitor_mode);
 	if (monitor_mode) {
@@ -330,7 +330,7 @@ static DEVICE_ATTR(lbs_rtap, 0644, lbs_rtap_get, lbs_rtap_set );
 static ssize_t lbs_mesh_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	return snprintf(buf, 5, "0x%X\n", !!priv->mesh_dev);
 }
 
@@ -340,7 +340,7 @@ static ssize_t lbs_mesh_get(struct device *dev,
 static ssize_t lbs_mesh_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	int enable;
 	int ret, action = CMD_ACT_MESH_CONFIG_STOP;
 
@@ -391,7 +391,7 @@ static struct attribute_group lbs_mesh_attr_group = {
  */
 static int lbs_dev_open(struct net_device *dev)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv ;
+	struct lbs_private *priv = netdev_priv(dev) ;
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_NET);
@@ -433,7 +433,7 @@ static int lbs_dev_open(struct net_device *dev)
  */
 static int lbs_mesh_stop(struct net_device *dev)
 {
-	struct lbs_private *priv = (struct lbs_private *) (dev->priv);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_MESH);
 	spin_lock_irq(&priv->driver_lock);
@@ -460,7 +460,7 @@ static int lbs_mesh_stop(struct net_device *dev)
  */
 static int lbs_eth_stop(struct net_device *dev)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_NET);
 
@@ -477,7 +477,7 @@ static int lbs_eth_stop(struct net_device *dev)
 
 static void lbs_tx_timeout(struct net_device *dev)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_TX);
 
@@ -529,7 +529,7 @@ EXPORT_SYMBOL_GPL(lbs_host_to_card_done);
  */
 static struct net_device_stats *lbs_get_stats(struct net_device *dev)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_NET);
 	return &priv->stats;
@@ -538,7 +538,7 @@ static struct net_device_stats *lbs_get_stats(struct net_device *dev)
 static int lbs_set_mac_address(struct net_device *dev, void *addr)
 {
 	int ret = 0;
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct sockaddr *phwaddr = addr;
 	struct cmd_ds_802_11_mac_address cmd;
 
@@ -672,7 +672,7 @@ static void lbs_set_mcast_worker(struct work_struct *work)
 
 static void lbs_set_multicast_list(struct net_device *dev)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	schedule_work(&priv->mcast_work);
 }
@@ -688,7 +688,7 @@ static void lbs_set_multicast_list(struct net_device *dev)
 static int lbs_thread(void *data)
 {
 	struct net_device *dev = data;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	wait_queue_t wait;
 
 	lbs_deb_enter(LBS_DEB_THREAD);
@@ -1116,7 +1116,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 		lbs_pr_err("init ethX device failed\n");
 		goto done;
 	}
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 
 	if (lbs_init_adapter(priv)) {
 		lbs_pr_err("failed to initialize adapter structure.\n");
@@ -1351,7 +1351,7 @@ static int lbs_add_mesh(struct lbs_private *priv)
 		ret = -ENOMEM;
 		goto done;
 	}
-	mesh_dev->priv = priv;
+	mesh_dev->ml_priv = priv;
 	priv->mesh_dev = mesh_dev;
 
 	mesh_dev->open = lbs_dev_open;
@@ -1564,7 +1564,7 @@ static int lbs_rtap_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *lbs_rtap_get_stats(struct net_device *dev)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = dev->ml_priv;
 	lbs_deb_enter(LBS_DEB_NET);
 	return &priv->stats;
 }
@@ -1605,7 +1605,7 @@ static int lbs_add_rtap(struct lbs_private *priv)
 	rtap_dev->stop = lbs_rtap_stop;
 	rtap_dev->get_stats = lbs_rtap_get_stats;
 	rtap_dev->hard_start_xmit = lbs_rtap_hard_start_xmit;
-	rtap_dev->priv = priv;
+	rtap_dev->ml_priv = priv;
 	SET_NETDEV_DEV(rtap_dev, priv->dev->dev.parent);
 
 	ret = register_netdev(rtap_dev);
-- 
1.5.3.4


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
