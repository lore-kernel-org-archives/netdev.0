From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: [PATCH] 2.6.3 orinoco.c patch to support ethtool get_link
Date: Sun, 07 Mar 2004 02:49:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078624195.3551.3.camel@fk460t28.lun.dk.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: hermes@gibson.dropbear.id.au, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there!

I noticed that there wasn't a good way, from userland, to get the link
status of an orinoco device. So I implemented the basic stuff required
to support ethtool. then I implemented the get_link functionality of
ethtool (maps orinoco_private->connected the the ethtool link state). It
seems to work and will save people some boot-time (on the distros that
check for link before attempting DHCP configuration etc.) when laptop
users are not on there wireless location.

Also it lays the ground to move more functionality to the ethtool model.

Please let me know what you think!

Best regards

Thomas


--- drivers/net/wireless/orinoco.c.tmus 2004-03-07 00:25:47.000000000
+0100
+++ drivers/net/wireless/orinoco.c 2004-03-07 01:19:29.433223192 +0100
@@ -430,6 +430,7 @@
#include <linux/if_arp.h>
#include <linux/etherdevice.h>
#include <linux/wireless.h>
+#include <linux/ethtool.h>

#include <asm/uaccess.h>
#include <asm/io.h>
@@ -566,6 +567,8 @@ static void orinoco_stat_gather(struct n
static struct net_device_stats *orinoco_get_stats(struct net_device
*dev);
static struct iw_statistics *orinoco_get_wireless_stats(struct
net_device *dev);

+static struct ethtool_ops orinoco_ethtool_ops;   
+
/* Hardware control routines */

static int __orinoco_program_rids(struct net_device *dev);
@@ -3941,6 +3944,19 @@ orinoco_ioctl(struct net_device *dev, st
return err;
}

+/* ethtool - get link state */
+static u32 orinoco_get_link(struct net_device *dev)
+{
+        struct orinoco_private *priv = dev->priv;
+
+        return priv->connected;
+}
+
+/* ethtool - function definitions */
+static struct ethtool_ops orinoco_ethtool_ops = {
+        .get_link = orinoco_get_link,
+};
+
struct {
u16 rid;
char *name;
@@ -4150,6 +4166,9 @@ struct net_device *alloc_orinocodev(int 
dev->set_multicast_list = orinoco_set_multicast_list;
/* we use the default eth_mac_addr for setting the MAC addr */

+ /* setup ethtool ops structure for this device */
+        SET_ETHTOOL_OPS(dev, &orinoco_ethtool_ops);
+
/* Set up default callbacks */
dev->open = orinoco_open;
dev->stop = orinoco_stop;
