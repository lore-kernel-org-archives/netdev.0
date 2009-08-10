From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] ieee802154: add virtual loopback
	driver
Date: Mon, 10 Aug 2009 18:16:40 +0400
Message-ID: <1249913800-10176-3-git-send-email-dbaryshkov@gmail.com>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	<1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249913800-10176-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

fakelb is a virtual loopback driver implementing one or several
interconnected radios. Packets from the radio are either sent
back to the node (if no other fake radio are registered) or to
all other fake radio.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 drivers/ieee802154/Kconfig  |   13 ++
 drivers/ieee802154/Makefile |    1 +
 drivers/ieee802154/fakelb.c |  255 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 269 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c

diff --git a/drivers/ieee802154/Kconfig b/drivers/ieee802154/Kconfig
index 9b9f43a..b68b5c5 100644
--- a/drivers/ieee802154/Kconfig
+++ b/drivers/ieee802154/Kconfig
@@ -20,3 +20,16 @@ config IEEE802154_FAKEHARD
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
+endif
+
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
index 0000000..9a135a9
--- /dev/null
+++ b/drivers/ieee802154/fakelb.c
@@ -0,0 +1,255 @@
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
+ * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
+#include <net/mac802154.h>
+
+struct fake_dev_priv {
+	struct ieee802154_dev *dev;
+
+	struct list_head list;
+	struct fake_priv *fake;
+
+	unsigned int working:1;
+};
+
+static int radios = 3;
+module_param(radios, int, 0444);
+MODULE_PARM_DESC(radios, "Number of simulated radios");
+
+struct fake_priv {
+	struct list_head list;
+	rwlock_t lock;
+};
+
+static int
+hw_ed(struct ieee802154_dev *dev, u8 *level)
+{
+	pr_debug("%s\n", __func__);
+	might_sleep();
+	BUG_ON(!level);
+	*level = 0xbe;
+	return 0;
+}
+
+static int
+hw_channel(struct ieee802154_dev *dev, int channel)
+{
+	pr_debug("%s %d\n", __func__, channel);
+	might_sleep();
+	dev->current_channel = channel;
+	return 0;
+}
+
+static void
+hw_deliver(struct fake_dev_priv *priv, struct sk_buff *skb)
+{
+	struct sk_buff *newskb;
+
+	if (!priv->working)
+		return;
+
+	newskb = pskb_copy(skb, GFP_ATOMIC);
+
+	ieee802154_rx_irqsafe(priv->dev, newskb, 0xcc);
+}
+
+static int
+hw_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
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
+			if (dp != priv &&
+			    dp->dev->current_channel ==
+					priv->dev->current_channel)
+				hw_deliver(dp, skb);
+	}
+	read_unlock_bh(&fake->lock);
+
+	return 0;
+}
+
+static int
+hw_start(struct ieee802154_dev *dev) {
+	struct fake_dev_priv *priv = dev->priv;
+
+	if (priv->working)
+		return -EBUSY;
+
+	priv->working = 1;
+
+	return 0;
+}
+
+static void
+hw_stop(struct ieee802154_dev *dev) {
+	struct fake_dev_priv *priv = dev->priv;
+
+	priv->working = 0;
+}
+
+static struct ieee802154_ops fake_ops = {
+	.owner = THIS_MODULE,
+	.xmit = hw_xmit,
+	.ed = hw_ed,
+	.set_channel = hw_channel,
+	.start = hw_start,
+	.stop = hw_stop,
+};
+
+static int ieee802154fake_add_priv(struct device *dev, struct fake_priv *fake)
+{
+	struct fake_dev_priv *priv;
+	int err = -ENOMEM;
+	struct ieee802154_dev *ieee;
+
+	ieee = ieee802154_alloc_device(sizeof(*priv), &fake_ops);
+	if (!dev)
+		goto err_alloc_dev;
+
+	priv = ieee->priv;
+	priv->dev = ieee;
+
+	INIT_LIST_HEAD(&priv->list);
+	priv->fake = fake;
+
+	ieee->parent = dev;
+
+	err = ieee802154_register_device(ieee);
+	if (err)
+		goto err_reg;
+
+	write_lock_bh(&fake->lock);
+	list_add_tail(&priv->list, &fake->list);
+	write_unlock_bh(&fake->lock);
+
+	return 0;
+
+err_reg:
+	ieee802154_free_device(priv->dev);
+err_alloc_dev:
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
+}
+
+static int __devinit ieee802154fake_probe(struct platform_device *pdev)
+{
+	struct fake_priv *priv;
+	struct fake_dev_priv *dp;
+	int err = -ENOMEM;
+	int i;
+
+	if (radios < 1 || radios > 100)
+		return -EINVAL;
+
+	priv = kzalloc(sizeof(struct fake_priv), GFP_KERNEL);
+	if (!priv)
+		goto err_alloc;
+
+	INIT_LIST_HEAD(&priv->list);
+	rwlock_init(&priv->lock);
+
+	for (i = 0; i < radios; i++) {
+		err = ieee802154fake_add_priv(&pdev->dev, priv);
+		if (err < 0)
+			goto err_slave;
+	}
+
+	platform_set_drvdata(pdev, priv);
+	dev_info(&pdev->dev, "Added ieee802154 hardware\n");
+	return 0;
+
+err_slave:
+	list_for_each_entry(dp, &priv->list, list)
+		ieee802154fake_del_priv(dp);
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
+	ieee802154fake_dev = platform_device_register_simple(
+			"ieee802154fakelb", -1, NULL, 0);
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
+MODULE_AUTHOR("Dmitry Eremin-Solenikov, Sergey Lapin");
+
+
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
