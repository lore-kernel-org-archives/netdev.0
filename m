From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/10] ieee802154: add virtual loopback driver
Date: Mon,  1 Jun 2009 18:54:48 +0400
Message-ID: <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1243868091-5315-7-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

fakelb is a virtual loopback driver implementing one or several
interconnected radios. Packets from the radio are either sent
back to the node (if no other fake radio are registered) or to
all other fake radio.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 drivers/ieee802154/Kconfig  |   11 ++
 drivers/ieee802154/Makefile |    1 +
 drivers/ieee802154/fakelb.c |  335 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 347 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c

diff --git a/drivers/ieee802154/Kconfig b/drivers/ieee802154/Kconfig
index 8610620..d1799e3 100644
--- a/drivers/ieee802154/Kconfig
+++ b/drivers/ieee802154/Kconfig
@@ -19,5 +19,16 @@ config IEEE802154_FAKEHARD
           This driver can also be built as a module. To do so say M here.
 	  The module will be called 'fakehard'.
 
+
+if IEEE802154_DRIVERS && MAC802154
+config IEEE802154_FAKELB
+	tristate "Fake LR-WPAN driver with several interconnected devices"
+	---help---
+	  Say Y here to enable the fake driver that can emulate a net
+          of several interconnected radio devices.
+
+          This driver can also be built as a module. To do so say M here.
+	  The module will be called 'fakelb'.
+
 endif
 
diff --git a/drivers/ieee802154/Makefile b/drivers/ieee802154/Makefile
index e0e8e1a..2bd7bdf 100644
--- a/drivers/ieee802154/Makefile
+++ b/drivers/ieee802154/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
+obj-$(CONFIG_IEEE802154_FAKELB) += fakelb.o
 
 EXTRA_CFLAGS += -DDEBUG -DCONFIG_FFD
diff --git a/drivers/ieee802154/fakelb.c b/drivers/ieee802154/fakelb.c
new file mode 100644
index 0000000..7c00f07
--- /dev/null
+++ b/drivers/ieee802154/fakelb.c
@@ -0,0 +1,335 @@
+/*
+ * Loopback IEEE 802.15.4 interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
+#include <net/ieee802154/mac802154.h>
+
+struct fake_dev_priv {
+	struct ieee802154_dev *dev;
+	phy_status_t cur_state, pend_state;
+
+	struct list_head list;
+	struct fake_priv *fake;
+};
+
+struct fake_priv {
+	struct list_head list;
+	rwlock_t lock;
+};
+
+static int is_transmitting(struct ieee802154_dev *dev)
+{
+	return 0;
+}
+
+static int is_receiving(struct ieee802154_dev *dev)
+{
+	return 0;
+}
+
+static phy_status_t
+hw_ed(struct ieee802154_dev *dev, u8 *level)
+{
+	pr_debug("%s\n", __func__);
+	might_sleep();
+	BUG_ON(!level);
+	*level = 0xbe;
+	return PHY_SUCCESS;
+}
+
+static phy_status_t
+hw_cca(struct ieee802154_dev *dev)
+{
+	pr_debug("%s\n", __func__);
+	might_sleep();
+	return PHY_IDLE;
+}
+
+static phy_status_t
+hw_state(struct ieee802154_dev *dev, phy_status_t state)
+{
+	struct fake_dev_priv *priv = dev->priv;
+	pr_debug("%s %d %d\n", __func__, priv->cur_state, state);
+	might_sleep();
+	if (state != PHY_TRX_OFF && state != PHY_RX_ON && state != PHY_TX_ON && state != PHY_FORCE_TRX_OFF)
+		return PHY_INVAL;
+	else if (state == PHY_FORCE_TRX_OFF) {
+		priv->cur_state = PHY_TRX_OFF;
+		return PHY_SUCCESS;
+	} else if (priv->cur_state == state)
+		return state;
+	else if ((state == PHY_TRX_OFF || state == PHY_RX_ON) && is_transmitting(dev)) {
+		priv->pend_state = state;
+		return PHY_BUSY_TX;
+	} else if ((state == PHY_TRX_OFF || state == PHY_TX_ON) && is_receiving(dev)) {
+		priv->pend_state = state;
+		return PHY_BUSY_RX;
+	} else {
+		priv->cur_state = state;
+		return PHY_SUCCESS;
+	}
+}
+
+static phy_status_t
+hw_channel(struct ieee802154_dev *dev, int channel)
+{
+	pr_debug("%s %d\n", __func__, channel);
+	might_sleep();
+	dev->current_channel = channel;
+	return PHY_SUCCESS;
+}
+
+static void
+hw_deliver(struct fake_dev_priv *priv, struct sk_buff *skb)
+{
+	struct sk_buff *newskb;
+
+	newskb = pskb_copy(skb, GFP_ATOMIC);
+
+	ieee802154_rx_irqsafe(priv->dev, newskb, 0xcc);
+}
+
+static int
+hw_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
+{
+	struct fake_dev_priv *priv = dev->priv;
+	struct fake_priv *fake = priv->fake;
+
+	might_sleep();
+
+	read_lock_bh(&fake->lock);
+	if (priv->list.next == priv->list.prev) {
+		/* we are the only one device */
+		hw_deliver(priv, skb);
+	} else {
+		struct fake_dev_priv *dp;
+		list_for_each_entry(dp, &priv->fake->list, list)
+			if (dp != priv && dp->dev->current_channel == priv->dev->current_channel)
+				hw_deliver(dp, skb);
+	}
+	read_unlock_bh(&fake->lock);
+
+	return PHY_SUCCESS;
+}
+
+static struct ieee802154_ops fake_ops = {
+	.owner = THIS_MODULE,
+	.tx = hw_tx,
+	.ed = hw_ed,
+	.cca = hw_cca,
+	.set_trx_state = hw_state,
+	.set_channel = hw_channel,
+};
+
+static int ieee802154fake_add_priv(struct device *dev, struct fake_priv *fake, const u8 *macaddr)
+{
+	struct fake_dev_priv *priv;
+	int err = -ENOMEM;
+
+	priv = kzalloc(sizeof(struct fake_dev_priv), GFP_KERNEL);
+	if (!priv)
+		goto err_alloc;
+
+	INIT_LIST_HEAD(&priv->list);
+
+	priv->dev = ieee802154_alloc_device();
+	if (!priv->dev)
+		goto err_alloc_dev;
+	priv->dev->name = "IEEE 802.15.4 fake";
+	priv->dev->priv = priv;
+	priv->dev->parent = dev;
+	priv->fake = fake;
+
+	err = ieee802154_register_device(priv->dev, &fake_ops);
+	if (err)
+		goto err_reg;
+	rtnl_lock();
+	err = ieee802154_add_slave(priv->dev, macaddr);
+	rtnl_unlock();
+	if (err < 0)
+		goto err_slave;
+
+	write_lock_bh(&fake->lock);
+	list_add_tail(&priv->list, &fake->list);
+	write_unlock_bh(&fake->lock);
+
+	return 0;
+
+err_slave:
+	ieee802154_unregister_device(priv->dev);
+err_reg:
+	ieee802154_free_device(priv->dev);
+err_alloc_dev:
+	kfree(priv);
+err_alloc:
+	return err;
+}
+
+static void ieee802154fake_del_priv(struct fake_dev_priv *priv)
+{
+	write_lock_bh(&priv->fake->lock);
+	list_del(&priv->list);
+	write_unlock_bh(&priv->fake->lock);
+
+	ieee802154_unregister_device(priv->dev);
+	ieee802154_free_device(priv->dev);
+	kfree(priv);
+}
+
+static ssize_t
+adddev_store(struct device *dev, struct device_attribute *attr,
+	const char *buf, size_t n)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct fake_priv *priv = platform_get_drvdata(pdev);
+	char hw[8] = {};
+	int i, j, ch, err;
+
+	for (i = 0, j = 0; i < 16 && j < n; j++) {
+		ch = buf[j];
+		switch (buf[j]) {
+		default:
+			return -EINVAL;
+		case '0'...'9':
+			ch -= '0';
+			break;
+		case 'A'...'F':
+			ch -= 'A' - 10;
+			break;
+		case 'a'...'f':
+			ch -= 'a' - 10;
+			break;
+		case ':':
+		case '.':
+			continue;
+		}
+		if (i % 2)
+			hw[i/2] = (hw[i/2] & 0xf0) | ch;
+		else
+			hw[i/2] = ch << 4;
+		i++;
+	}
+	if (i != 16)
+		return -EINVAL;
+	err = ieee802154fake_add_priv(dev, priv, hw);
+	if (err)
+		return err;
+	return n;
+}
+
+static DEVICE_ATTR(adddev, 0200, NULL, adddev_store);
+
+static struct attribute *fake_attrs[] = {
+	&dev_attr_adddev.attr,
+	NULL,
+};
+
+static struct attribute_group fake_group = {
+	.name	= NULL /* fake */,
+	.attrs	= fake_attrs,
+};
+
+
+static int __devinit ieee802154fake_probe(struct platform_device *pdev)
+{
+	struct fake_priv *priv;
+	struct fake_dev_priv *dp;
+
+	int err = -ENOMEM;
+	priv = kzalloc(sizeof(struct fake_priv), GFP_KERNEL);
+	if (!priv)
+		goto err_alloc;
+
+	INIT_LIST_HEAD(&priv->list);
+	rwlock_init(&priv->lock);
+
+	err = sysfs_create_group(&pdev->dev.kobj, &fake_group);
+	if (err)
+		goto err_grp;
+
+	err = ieee802154fake_add_priv(&pdev->dev, priv, "\xde\xad\xbe\xaf\xca\xfe\xba\xbe");
+	if (err < 0)
+		goto err_slave;
+
+/*	err = ieee802154fake_add_priv(priv, "\x67\x45\x23\x01\x67\x45\x23\x01");
+	if (err < 0)
+		goto err_slave;*/
+
+	platform_set_drvdata(pdev, priv);
+	dev_info(&pdev->dev, "Added ieee802154 hardware\n");
+	return 0;
+
+err_slave:
+	list_for_each_entry(dp, &priv->list, list)
+		ieee802154fake_del_priv(dp);
+	sysfs_remove_group(&pdev->dev.kobj, &fake_group);
+err_grp:
+	kfree(priv);
+err_alloc:
+	return err;
+}
+
+static int __devexit ieee802154fake_remove(struct platform_device *pdev)
+{
+	struct fake_priv *priv = platform_get_drvdata(pdev);
+	struct fake_dev_priv *dp, *temp;
+
+	list_for_each_entry_safe(dp, temp, &priv->list, list)
+		ieee802154fake_del_priv(dp);
+	sysfs_remove_group(&pdev->dev.kobj, &fake_group);
+	kfree(priv);
+	return 0;
+}
+
+static struct platform_device *ieee802154fake_dev;
+
+static struct platform_driver ieee802154fake_driver = {
+	.probe = ieee802154fake_probe,
+	.remove = __devexit_p(ieee802154fake_remove),
+	.driver = {
+			.name = "ieee802154fakelb",
+			.owner = THIS_MODULE,
+	},
+};
+
+static __init int fake_init(void)
+{
+	ieee802154fake_dev = platform_device_register_simple("ieee802154fakelb", -1, NULL, 0);
+	return platform_driver_register(&ieee802154fake_driver);
+}
+
+static __exit void fake_exit(void)
+{
+	platform_driver_unregister(&ieee802154fake_driver);
+	platform_device_unregister(ieee802154fake_dev);
+}
+
+module_init(fake_init);
+module_exit(fake_exit);
+MODULE_LICENSE("GPL");
+
-- 
1.6.2.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
