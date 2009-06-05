From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/5] ieee802154: add simple HardMAC driver sample
Date: Fri,  5 Jun 2009 06:29:50 +0400
Message-ID: <1244168990-28355-6-git-send-email-dbaryshkov@gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-5-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244168990-28355-5-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

fakehard is a really simple driver implementing only necessary
callbacks and serves the role of an example of driver for HardMAC
IEEE 802.15.4 device.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 drivers/Makefile              |    1 +
 drivers/ieee802154/Kconfig    |   22 ++++
 drivers/ieee802154/Makefile   |    3 +
 drivers/ieee802154/fakehard.c |  270 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/Kconfig           |    2 +
 5 files changed, 298 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ieee802154/Kconfig
 create mode 100644 drivers/ieee802154/Makefile
 create mode 100644 drivers/ieee802154/fakehard.c

diff --git a/drivers/Makefile b/drivers/Makefile
index 1266ead..9e7d4e5 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -107,3 +107,4 @@ obj-$(CONFIG_SSB)		+= ssb/
 obj-$(CONFIG_VIRTIO)		+= virtio/
 obj-$(CONFIG_STAGING)		+= staging/
 obj-y				+= platform/
+obj-y				+= ieee802154/
diff --git a/drivers/ieee802154/Kconfig b/drivers/ieee802154/Kconfig
new file mode 100644
index 0000000..25740bd
--- /dev/null
+++ b/drivers/ieee802154/Kconfig
@@ -0,0 +1,22 @@
+menuconfig IEEE802154_DRIVERS
+	bool "IEEE 802.15.4 drivers"
+	depends on NETDEVICES && IEEE802154
+	default y
+	---help---
+	  Say Y here to get to see options for IEEE 802.15.4 Low-Rate
+	  Wireless Personal Area Network device drivers. This option alone
+	  does not add any kernel code.
+
+	  If you say N, all options in this submenu will be skipped and
+	  disabled.
+
+config IEEE802154_FAKEHARD
+	tristate "Fake LR-WPAN driver with several interconnected devices"
+	depends on  IEEE802154_DRIVERS
+	---help---
+	  Say Y here to enable the fake driver that serves as an example
+          of HardMAC device driver.
+
+          This driver can also be built as a module. To do so say M here.
+	  The module will be called 'fakehard'.
+
diff --git a/drivers/ieee802154/Makefile b/drivers/ieee802154/Makefile
new file mode 100644
index 0000000..e0e8e1a
--- /dev/null
+++ b/drivers/ieee802154/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
+
+EXTRA_CFLAGS += -DDEBUG -DCONFIG_FFD
diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
new file mode 100644
index 0000000..0384144
--- /dev/null
+++ b/drivers/ieee802154/fakehard.c
@@ -0,0 +1,270 @@
+/*
+ * Sample driver for HardMAC IEEE 802.15.4 devices
+ *
+ * Copyright (C) 2009 Siemens AG
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
+ * Dmitry Eremin-Solenikov <dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/netdevice.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/nl802154.h>
+
+static u16 fake_get_pan_id(struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0xeba1;
+}
+
+static u16 fake_get_short_addr(struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x1;
+}
+
+static u8 fake_get_dsn(struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x00; /* DSN are implemented in HW, so return just 0 */
+}
+
+static u8 fake_get_bsn(struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x00; /* BSN are implemented in HW, so return just 0 */
+}
+
+static int fake_assoc_req(struct net_device *dev,
+		struct ieee802154_addr *addr, u8 channel, u8 cap)
+{
+	/* We simply emulate it here */
+	return ieee802154_nl_assoc_confirm(dev, fake_get_short_addr(dev),
+			IEEE802154_SUCCESS);
+}
+
+static int fake_assoc_resp(struct net_device *dev,
+		struct ieee802154_addr *addr, u16 short_addr, u8 status)
+{
+	return 0;
+}
+
+static int fake_disassoc_req(struct net_device *dev,
+		struct ieee802154_addr *addr, u8 reason)
+{
+	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
+}
+
+static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
+				u8 channel,
+				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+				u8 coord_realign)
+{
+	return 0;
+}
+
+static int fake_scan_req(struct net_device *dev, u8 type, u32 channels,
+		u8 duration)
+{
+	u8 edl[27] = {};
+	return ieee802154_nl_scan_confirm(dev, IEEE802154_SUCCESS, type,
+			channels,
+			type == IEEE802154_MAC_SCAN_ED ? edl : NULL);
+}
+
+static struct ieee802154_mlme_ops fake_mlme = {
+	.assoc_req = fake_assoc_req,
+	.assoc_resp = fake_assoc_resp,
+	.disassoc_req = fake_disassoc_req,
+	.start_req = fake_start_req,
+	.scan_req = fake_scan_req,
+
+	.get_pan_id = fake_get_pan_id,
+	.get_short_addr = fake_get_short_addr,
+	.get_dsn = fake_get_dsn,
+	.get_bsn = fake_get_bsn,
+};
+
+static int ieee802154_fake_open(struct net_device *dev)
+{
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_fake_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int ieee802154_fake_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->iif = dev->ifindex;
+	skb->dev = dev;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	dev->trans_start = jiffies;
+
+	/* FIXME: do hardware work here ... */
+
+	return 0;
+}
+
+
+static int ieee802154_fake_ioctl(struct net_device *dev, struct ifreq *ifr,
+		int cmd)
+{
+	struct sockaddr_ieee802154 *sa =
+		(struct sockaddr_ieee802154 *)&ifr->ifr_addr;
+	u16 pan_id, short_addr;
+
+	switch (cmd) {
+	case SIOCGIFADDR:
+		/* FIXME: fixed here, get from device IRL */
+		pan_id = fake_get_pan_id(dev);
+		short_addr = fake_get_short_addr(dev);
+		if (pan_id == IEEE802154_PANID_BROADCAST ||
+		    short_addr == IEEE802154_ADDR_BROADCAST)
+			return -EADDRNOTAVAIL;
+
+		sa->family = AF_IEEE802154;
+		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
+		sa->addr.pan_id = pan_id;
+		sa->addr.short_addr = short_addr;
+		return 0;
+	}
+	return -ENOIOCTLCMD;
+}
+
+static int ieee802154_fake_mac_addr(struct net_device *dev, void *p)
+{
+	return -EBUSY; /* HW address is built into the device */
+}
+
+static const struct net_device_ops fake_ops = {
+	.ndo_open		= ieee802154_fake_open,
+	.ndo_stop		= ieee802154_fake_close,
+	.ndo_start_xmit		= ieee802154_fake_xmit,
+	.ndo_do_ioctl		= ieee802154_fake_ioctl,
+	.ndo_set_mac_address	= ieee802154_fake_mac_addr,
+};
+
+
+static void ieee802154_fake_setup(struct net_device *dev)
+{
+	dev->addr_len		= IEEE802154_ADDR_LEN;
+	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
+	dev->features		= NETIF_F_NO_CSUM;
+	dev->needed_tailroom	= 2; /* FCS */
+	dev->mtu		= 127;
+	dev->tx_queue_len	= 10;
+	dev->type		= ARPHRD_IEEE802154;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+}
+
+
+static int __devinit ieee802154fake_probe(struct platform_device *pdev)
+{
+	struct net_device *dev =
+		alloc_netdev(0, "hardwpan%d", ieee802154_fake_setup);
+	int err;
+
+	if (!dev)
+		return -ENOMEM;
+
+	memcpy(dev->dev_addr, "\xba\xbe\xca\xfe\xde\xad\xbe\xef",
+			dev->addr_len);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+
+	dev->netdev_ops = &fake_ops;
+	dev->ml_priv = &fake_mlme;
+
+	/*
+	 * If the name is a format string the caller wants us to do a
+	 * name allocation.
+	 */
+	if (strchr(dev->name, '%')) {
+		err = dev_alloc_name(dev, dev->name);
+		if (err < 0)
+			goto out;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	platform_set_drvdata(pdev, dev);
+
+	err = register_netdev(dev);
+	if (err < 0)
+		goto out;
+
+
+	dev_info(&pdev->dev, "Added ieee802154 HardMAC hardware\n");
+	return 0;
+
+out:
+	unregister_netdev(dev);
+	return err;
+}
+
+static int __devexit ieee802154fake_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	unregister_netdev(dev);
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_device *ieee802154fake_dev;
+
+static struct platform_driver ieee802154fake_driver = {
+	.probe = ieee802154fake_probe,
+	.remove = __devexit_p(ieee802154fake_remove),
+	.driver = {
+			.name = "ieee802154hardmac",
+			.owner = THIS_MODULE,
+	},
+};
+
+static __init int fake_init(void)
+{
+	ieee802154fake_dev = platform_device_register_simple(
+			"ieee802154hardmac", -1, NULL, 0);
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
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..ec8cf21 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2704,6 +2704,8 @@ source "drivers/net/wan/Kconfig"
 
 source "drivers/atm/Kconfig"
 
+source "drivers/ieee802154/Kconfig"
+
 source "drivers/s390/net/Kconfig"
 
 config XEN_NETDEV_FRONTEND
-- 
1.6.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
