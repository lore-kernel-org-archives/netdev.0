From: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Subject: [RFC PATCH 3/3] driver/net/usb: Add support for DSA to ax88772b
Date: Tue, 21 Apr 2015 13:26:31 +0000
Message-ID: <1429622791-7195-4-git-send-email-kaisrja1@fel.cvut.cz>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: kaisrja1@fel.cvut.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kaisrlik <ja.kaisrlik@gmail.com>

This patch adds a possibility to use the RMII interface of the ax88772b
instead of the Ethernet PHY which is used now.

Binding DSA to a USB device is done via sysfs.

---
 drivers/net/usb/asix.h         |   7 ++
 drivers/net/usb/asix_devices.c | 258 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 261 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 5d049d0..6b1a5f5 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -174,6 +174,13 @@ struct asix_rx_fixup_info {
 
 struct asix_common_private {
 	struct asix_rx_fixup_info rx_fixup_info;
+#ifdef CONFIG_NET_DSA
+	struct kobject kobj;
+	struct mii_bus *mdio;
+	int use_embphy;
+	bool dsa_up;
+	struct usbnet *dev;
+#endif
 };
 
 extern const struct driver_info ax88172a_info;
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index bf49792..57b3a34 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -35,6 +35,88 @@
 
 #define	PHY_MODE_RTL8211CL	0x000C
 
+#ifdef CONFIG_NET_DSA
+
+#define AX88772_RMII 0x02
+#define AX88772_MAX_PORTS 0x20
+#define MV88e6065_ID  0x0c89
+
+#include <linux/phy.h>
+#include <net/dsa.h>
+
+#define to_asix_obj(x) container_of(x, struct asix_common_private, kobj)
+#define to_asix_attr(x) container_of(x, struct asix_attribute, attr)
+
+static int mii_asix_read(struct mii_bus *bus, int phy_id, int regnum)
+{
+	return asix_mdio_read(((struct usbnet *)bus->priv)->net, phy_id, regnum);
+}
+
+static int mii_asix_write(struct mii_bus *bus, int phy_id, int regnum, u16 val)
+{
+	asix_mdio_write(((struct usbnet *)bus->priv)->net, phy_id, regnum, val);
+	return 0;
+}
+
+static int ax88772_init_mdio(struct usbnet *dev){
+	struct asix_common_private *priv = dev->driver_priv;
+	int ret, i;
+
+	priv->mdio = mdiobus_alloc();
+	if (!priv->mdio) {
+		netdev_err(dev->net, "Could not allocate mdio bus\n");
+		return -ENOMEM;
+	}
+
+	priv->mdio->priv = (void *)dev;
+	priv->mdio->read = &mii_asix_read;
+	priv->mdio->write = &mii_asix_write;
+	priv->mdio->name = "ax88772 mdio bus";
+	priv->mdio->parent = &dev->udev->dev;
+
+	/* mii bus name is usb-<usb bus number>-<usb device number> */
+	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",dev->udev->bus->busnum, dev->udev->devnum);
+
+	priv->mdio->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!priv->mdio->irq) {
+		ret = -ENOMEM;
+		goto free;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		priv->mdio->irq[i] = PHY_POLL;
+
+	ret = mdiobus_register(priv->mdio);
+	if (ret) {
+		netdev_err(dev->net, "Could not register MDIO bus\n");
+		goto free_irq;
+	}
+
+	netdev_info(dev->net, "registered mdio bus %s\n", priv->mdio->id);
+	return 0;
+
+free_irq:
+	kfree(priv->mdio->irq);
+free:
+	mdiobus_free(priv->mdio);
+	return ret;
+}
+
+static void ax88772_remove_mdio(struct usbnet *dev)
+{
+	struct asix_common_private *priv = dev->driver_priv;
+
+//	dsa_free(); TODO
+
+	netdev_info(dev->net, "deregistering mdio bus %s\n", priv->mdio->id);
+	mdiobus_unregister(priv->mdio);
+	kfree(priv->mdio->irq);
+	mdiobus_free(priv->mdio);
+	kfree(priv);
+}
+
+#endif
+
 struct ax88172_int_data {
 	__le16 res1;
 	u8 link;
@@ -301,6 +383,27 @@ static int ax88772_reset(struct usbnet *dev)
 	int ret, embd_phy;
 	u16 rx_ctl;
 
+#ifdef CONFIG_NET_DSA
+	int temp = AX88772_RMII;
+	struct asix_common_private *priv = dev->driver_priv;
+
+	if (priv->use_embphy == 1) {
+		data->phymode = PHY_MODE_MARVELL;
+		data->ledmode = 0;
+
+		/* Set AX88772 to enable RMII interface for external PHY */
+		asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL);
+		asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 1, &temp);
+
+		asix_sw_reset(dev, 0);
+		msleep(150);
+
+		asix_write_rx_ctl(dev, 0);
+		msleep(60);
+   }
+
+#endif
+
 	ret = asix_write_gpio(dev,
 			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5);
 	if (ret < 0)
@@ -415,11 +518,131 @@ static const struct net_device_ops ax88772_netdev_ops = {
 	.ndo_set_rx_mode        = asix_set_multicast,
 };
 
+
+#ifdef CONFIG_NET_DSA
+struct asix_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct asix_common_private *priv, struct asix_attribute *attr, char *buf);
+	ssize_t (*store)(struct asix_common_private *priv, struct asix_attribute *attr, const char *buf, size_t count);
+};
+
+static int ax88772_set_bind_dsa(struct asix_common_private *priv)
+{
+	struct usbnet *dev = priv->dev;
+	int i, ret, embd_phy;
+	u32 phyid;
+	int temp = AX88772_RMII;
+
+	if (priv->dsa_up == 1)
+		return -EINVAL;
+	priv->dsa_up = 1;
+
+	/* Enable RMII interface for external PHY */
+	asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 1, &temp);
+	for (i = 0; i < AX88772_MAX_PORTS; i++){
+		phyid = asix_mdio_read(dev->net, i, 0x3);
+		if (phyid == MV88e6065_ID)
+			break;
+	}
+
+	if (phyid == MV88e6065_ID) {
+		ret = ax88772_init_mdio(dev);
+		if (ret)
+			return ret;
+
+		ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, &priv->use_embphy);
+		priv->use_embphy = 1;
+		ret = dsa_probe_mii(priv->mdio, dev->net);
+		if (ret)
+			return ret;
+
+		dev->mii.phy_id = 0x11; //TODO load addr of mii reg
+	}else{
+		/* Revert to previous settings */
+		embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
+		ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
+		if (ret)
+			return ret;
+
+		priv->use_embphy = 0;
+	}
+
+	return 0;
+}
+
+static ssize_t usb_dsa_store(struct asix_common_private *priv,
+		struct asix_attribute *attr, const char *buf, size_t count)
+{
+	ax88772_set_bind_dsa(priv);
+	return count;
+}
+
+static ssize_t usb_dsa_show(struct asix_common_private *priv,
+		struct asix_attribute *attr, char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "usb_dsa_binding.\n");
+}
+
+static void driver_release(struct kobject *kobj)
+{
+	pr_debug("driver: '%s': %s\n", kobject_name(kobj), __func__);
+//   kfree(drv_priv); TODO free
+}
+
+static ssize_t usb_dsa_attr_show(struct kobject *kobj,
+	struct attribute *attr,
+	char *buf)
+{
+	struct asix_attribute *attribute;
+	struct asix_common_private *priv;
+
+	attribute = to_asix_attr(attr);
+	priv = to_asix_obj(kobj);
+
+	if (!attribute->show)
+		return -EINVAL;
+
+	return attribute->show(priv, attribute, buf);
+}
+static ssize_t usb_dsa_attr_store(struct kobject *kobj,
+		struct attribute *attr,
+		const char *buf, size_t len)
+{
+	struct asix_attribute *attribute;
+	struct asix_common_private *priv;
+
+	attribute = to_asix_attr(attr);
+	priv = to_asix_obj(kobj);
+
+	if (!attribute->store)
+		return -EINVAL;
+	return attribute->store(priv, attribute, buf, len);
+}
+
+static struct asix_attribute asix_attribute =  __ATTR(usb_dsa_bind, 0664, usb_dsa_show, usb_dsa_store);
+static struct attribute *asix_default_attrs[] = {
+	&asix_attribute.attr,
+	NULL,
+};
+static const struct sysfs_ops dsa_bind_sysfs_ops = {
+	.show   = usb_dsa_attr_show,
+	.store  = usb_dsa_attr_store,
+};
+static struct kobj_type dsa_bind_ktype = {
+	.sysfs_ops      = &dsa_bind_sysfs_ops,
+	.release        = driver_release,
+	.default_attrs  = asix_default_attrs,
+};
+#endif
+
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret, embd_phy, i;
 	u8 buf[ETH_ALEN];
 	u32 phyid;
+#ifdef CONFIG_NET_DSA
+	struct asix_common_private *priv;
+#endif
 
 	usbnet_get_endpoints(dev,intf);
 
@@ -465,6 +688,25 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		return ret;
 	}
 
+	dev->driver_priv = kzalloc(sizeof(struct asix_common_private), GFP_KERNEL);
+	if (!dev->driver_priv)
+		return -ENOMEM;
+
+#ifdef CONFIG_NET_DSA
+	priv = dev->driver_priv;
+	priv->dev = dev;
+	priv->dsa_up = 0;
+	priv->kobj.kset = kset_create_and_add("DSA_BIND", NULL, kobject_get(&dev->udev->dev.kobj));
+	if (!priv->kobj.kset){
+		ret = -ENOMEM;
+		goto free;
+	}
+
+	ret = kobject_init_and_add(&priv->kobj, &dsa_bind_ktype, NULL, "dsa_bind");
+	if (ret)
+		goto free_kobj;
+#endif
+
 	ax88772_reset(dev);
 
 	/* Read PHYID register *AFTER* the PHY was reset properly */
@@ -478,15 +720,23 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		dev->rx_urb_size = 2048;
 	}
 
-	dev->driver_priv = kzalloc(sizeof(struct asix_common_private), GFP_KERNEL);
-	if (!dev->driver_priv)
-		return -ENOMEM;
-
 	return 0;
+
+#ifdef CONFIG_NET_DSA
+free_kobj:
+	kobject_put(&priv->kobj);
+free:
+	kfree(priv);
+	return ret;
+#endif
 }
 
 static void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
+#ifdef CONFIG_NET_DSA
+	if (((struct asix_common_private *)dev->driver_priv)->dsa_up == 1)
+	   ax88772_remove_mdio(dev);
+#endif
 	kfree(dev->driver_priv);
 }
 
-- 
2.1.3
