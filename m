From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH v3 3/3] can: at91_can: make can_id of mailbox 0 configurable
Date: Mon, 24 Jan 2011 15:15:32 +0100
Message-ID: <1295878532-15769-4-git-send-email-mkl@pengutronix.de>
References: <1295878532-15769-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1295878532-15769-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
"AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailbox
0 may be send under certain conditions (even if disabled or in rx mode).

The workaround in the errata suggests not to use the mailbox and load it
with an unused identifier.

This patch implements the second part of the workaround. A sysfs entry
"mb0_id" is introduced. While the interface is down it can be used to
configure the can_id of mailbox 0. The default value id 0x7ff.

In order to use an extended can_id add the CAN_EFF_FLAG (0x80000000U)
to the can_id. Example:

- standard id 0x7ff:
echo 0x7ff      > /sys/class/net/can0/mb0_id

- extended id 0x1fffffff:
echo 0x9fffffff > /sys/class/net/can0/mb0_id

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Acked-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
For the Documentation-part:
Acked-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-platform-at91 |   25 +++++++
 drivers/net/can/at91_can.c                    |   90 +++++++++++++++++++++++--
 2 files changed, 108 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-platform-at91

diff --git a/Documentation/ABI/testing/sysfs-platform-at91 b/Documentation/ABI/testing/sysfs-platform-at91
new file mode 100644
index 0000000..4cc6a86
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-platform-at91
@@ -0,0 +1,25 @@
+What:		/sys/devices/platform/at91_can/net/<iface>/mb0_id
+Date:		January 2011
+KernelVersion:	2.6.38
+Contact:	Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
+Description:
+		Value representing the can_id of mailbox 0.
+
+		Default: 0x7ff (standard frame)
+
+		Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
+		"AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the
+		contents of mailbox 0 may be send under certain
+		conditions (even if disabled or in rx mode).
+
+		The workaround in the errata suggests not to use the
+		mailbox and load it with an unused identifier.
+
+		In order to use an extended can_id add the
+		CAN_EFF_FLAG (0x80000000U) to the can_id. Example:
+
+		- standard id 0x7ff:
+		echo 0x7ff      > /sys/class/net/can0/mb0_id
+
+		- extended id 0x1fffffff:
+		echo 0x9fffffff > /sys/class/net/can0/mb0_id
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 16e45a5..2532b96 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/platform_device.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
@@ -169,6 +170,8 @@ struct at91_priv {
 
 	struct clk		*clk;
 	struct at91_can_data	*pdata;
+
+	canid_t			mb0_id;
 };
 
 static struct can_bittiming_const at91_bittiming_const = {
@@ -221,6 +224,18 @@ static inline void set_mb_mode(const struct at91_priv *priv, unsigned int mb,
 	set_mb_mode_prio(priv, mb, mode, 0);
 }
 
+static inline u32 at91_can_id_to_reg_mid(canid_t can_id)
+{
+	u32 reg_mid;
+
+	if (can_id & CAN_EFF_FLAG)
+		reg_mid = (can_id & CAN_EFF_MASK) | AT91_MID_MIDE;
+	else
+		reg_mid = (can_id & CAN_SFF_MASK) << 18;
+
+	return reg_mid;
+}
+
 /*
  * Swtich transceiver on or off
  */
@@ -234,6 +249,7 @@ static void at91_setup_mailboxes(struct net_device *dev)
 {
 	struct at91_priv *priv = netdev_priv(dev);
 	unsigned int i;
+	u32 reg_mid;
 
 	/*
 	 * Due to a chip bug (errata 50.2.6.3 & 50.3.5.3) the first
@@ -242,8 +258,13 @@ static void at91_setup_mailboxes(struct net_device *dev)
 	 * overwrite option. The overwrite flag indicates a FIFO
 	 * overflow.
 	 */
-	for (i = 0; i < AT91_MB_RX_FIRST; i++)
+	reg_mid = at91_can_id_to_reg_mid(priv->mb0_id);
+	for (i = 0; i < AT91_MB_RX_FIRST; i++) {
 		set_mb_mode(priv, i, AT91_MB_MODE_DISABLED);
+		at91_write(priv, AT91_MID(i), reg_mid);
+		at91_write(priv, AT91_MCR(i), 0x0);	/* clear dlc */
+	}
+
 	for (i = AT91_MB_RX_FIRST; i < AT91_MB_RX_LAST; i++)
 		set_mb_mode(priv, i, AT91_MB_MODE_RX);
 	set_mb_mode(priv, AT91_MB_RX_LAST, AT91_MB_MODE_RX_OVRWR);
@@ -378,12 +399,7 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netdev_err(dev, "BUG! TX buffer full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
-
-	if (cf->can_id & CAN_EFF_FLAG)
-		reg_mid = (cf->can_id & CAN_EFF_MASK) | AT91_MID_MIDE;
-	else
-		reg_mid = (cf->can_id & CAN_SFF_MASK) << 18;
-
+	reg_mid = at91_can_id_to_reg_mid(cf->can_id);
 	reg_mcr = ((cf->can_id & CAN_RTR_FLAG) ? AT91_MCR_MRTR : 0) |
 		(cf->can_dlc << 16) | AT91_MCR_MTCR;
 
@@ -1047,6 +1063,64 @@ static const struct net_device_ops at91_netdev_ops = {
 	.ndo_start_xmit	= at91_start_xmit,
 };
 
+static ssize_t at91_sysfs_show_mb0_id(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct at91_priv *priv = netdev_priv(to_net_dev(dev));
+
+	if (priv->mb0_id & CAN_EFF_FLAG)
+		return snprintf(buf, PAGE_SIZE, "0x%08x\n", priv->mb0_id);
+	else
+		return snprintf(buf, PAGE_SIZE, "0x%03x\n", priv->mb0_id);
+}
+
+static ssize_t at91_sysfs_set_mb0_id(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct at91_priv *priv = netdev_priv(ndev);
+	unsigned long can_id;
+	ssize_t ret;
+	int err;
+
+	rtnl_lock();
+
+	if (ndev->flags & IFF_UP) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	err = strict_strtoul(buf, 0, &can_id);
+	if (err) {
+		ret = err;
+		goto out;
+	}
+
+	if (can_id & CAN_EFF_FLAG)
+		can_id &= CAN_EFF_MASK | CAN_EFF_FLAG;
+	else
+		can_id &= CAN_SFF_MASK;
+
+	priv->mb0_id = can_id;
+	ret = count;
+
+ out:
+	rtnl_unlock();
+	return ret;
+}
+
+static DEVICE_ATTR(mb0_id, S_IWUGO | S_IRUGO,
+	at91_sysfs_show_mb0_id, at91_sysfs_set_mb0_id);
+
+static struct attribute *at91_sysfs_attrs[] = {
+	&dev_attr_mb0_id.attr,
+	NULL,
+};
+
+static struct attribute_group at91_sysfs_attr_group = {
+	.attrs = at91_sysfs_attrs,
+};
+
 static int __devinit at91_can_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -1092,6 +1166,7 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	dev->netdev_ops	= &at91_netdev_ops;
 	dev->irq = irq;
 	dev->flags |= IFF_ECHO;
+	dev->sysfs_groups[0] = &at91_sysfs_attr_group;
 
 	priv = netdev_priv(dev);
 	priv->can.clock.freq = clk_get_rate(clk);
@@ -1103,6 +1178,7 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->clk = clk;
 	priv->pdata = pdev->dev.platform_data;
+	priv->mb0_id = 0x7ff;
 
 	netif_napi_add(dev, &priv->napi, at91_poll, AT91_NAPI_WEIGHT);
 
-- 
1.7.2.3
