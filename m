From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 14/15] wireless/orinoco: add minimal ethtool
	support
Date: Tue, 26 Oct 2004 15:24:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818684.9874.1.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Add minimal ethtool support (Pavel Roskin)

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.14-ethtool	2004-10-26 13:40:22.388220424 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 13:44:23.281599064 -0400
@@ -494,6 +494,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/wireless.h>
 #if WIRELESS_EXT > 12
 #include <net/iw_handler.h>
@@ -4229,6 +4230,48 @@
 	return err;
 }
 
+static int orinoco_ioctl_ethtool(struct net_device *dev, void *useraddr)
+{
+	u32 ethcmd;
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
+		return -EFAULT;
+
+	switch (ethcmd) {
+	case ETHTOOL_GDRVINFO: {
+		struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
+		strncpy(info.driver, DRIVER_NAME, sizeof(info.driver) - 1);
+		strncpy(info.version, DRIVER_VERSION,
+			sizeof(info.version) - 1);
+		strncpy(info.fw_version, priv->fw_name,
+			sizeof(info.fw_version) - 1);
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 5, 0)
+		if (dev->class_dev.dev)
+			strncpy(info.bus_info, dev->class_dev.dev->bus_id,
+				sizeof(info.bus_info) - 1);
+		else
+			snprintf(info.bus_info, sizeof(info.bus_info) - 1,
+				 "PCMCIA 0x%lx", priv->hw.iobase);
+#endif
+		if (copy_to_user(useraddr, &info, sizeof(info)))
+			return -EFAULT;
+		return 0;
+	}
+#ifdef ETHTOOL_GLINK
+	case ETHTOOL_GLINK: {
+		struct ethtool_value edata = { ETHTOOL_GLINK };
+		edata.data = netif_carrier_ok(dev) ? 1 : 0;
+		if (copy_to_user (useraddr, &edata, sizeof(edata)))
+			return -EFAULT;
+		return 0;
+	}
+#endif
+	}
+
+	return -EOPNOTSUPP;
+}
+
 static const struct iw_priv_args orinoco_privtab[] = {
 	{ SIOCIWFIRSTPRIV + 0x0, 0, 0, "force_reset" },
 	{ SIOCIWFIRSTPRIV + 0x1, 0, 0, "card_reset" },
@@ -4699,6 +4742,10 @@
 	else
 #endif /* WIRELESS_EXT <= 12 */
 	switch (cmd) {
+	case SIOCETHTOOL:
+		err = orinoco_ioctl_ethtool(dev, (void *) rq->ifr_data);
+		break;
+
 	default:
 		err = -EOPNOTSUPP;
 	}
