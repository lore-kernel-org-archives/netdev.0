From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/6] net: add the nwhwconfig support
Date: Thu, 17 Nov 2011 09:01:40 +0100
Message-ID: <1321516900-616-1-git-send-email-peppe.cavallaro@st.com>
Cc: mamoroso@micron.com, shiraz.hashim@st.com, armando.visconti@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Stuart Menefy <stuart.menefy@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:51313 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755898Ab1KQIBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network drivers support hardware level configuration via utilities such as
ifconfig, ethtool and mii-tool. However sometimes these settings need to be
adjusted before a file system is available (typically if the root file system
uses NFS).

This patch adds a new support called nwhwconf. It is used in STLinux embedded
platforms since long time. This support adds a simple kernel command line
interface to configure some common network parameters i.e. the MAC address.
In fact, some boards (like ST STB) with embedded  the stmmac Ethernet device
drivers do not have a MAC address blown into the serial EEPROM and the nwhwconf
 is actually used for providing it.

Enable this feature (CONFIG_NWHW_CONFIG) from the configuration menu as
follows:

Device Drivers ---> Networking Support --->
  Configure network hardware from the command line

This is an example how to add the MAC address to the boot command line:

nwhwconf=device:<dev>,hwaddr:<addr>

where:
    <dev> is the device name, normally eth0
    <addr> is the MAC address, which has the form: xx:xx:xx:xx:xx:xx,

Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/Kconfig      |   10 +++
 drivers/net/Makefile     |    1 +
 drivers/net/nwhwconfig.c |  173 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 184 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/nwhwconfig.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 654a5e9..921a8c8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -338,4 +338,14 @@ config VMXNET3
 	  To compile this driver as a module, choose M here: the
 	  module will be called vmxnet3.
 
+config NWHW_CONFIG
+	bool "Configure network hardware from the command line"
+	help
+	  Many network drivers support hardware level configuration via
+	  utilities such as ifconfig, ethtool and mii-tool. However sometimes
+	  these settings need to be adjusted before a file system is
+	  available (typically if the root file system uses NFS).
+	  This option adds a simple kernel command line interface to configure
+	  some common network parameters.
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fa877cd..0869bf7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -66,3 +66,4 @@ obj-$(CONFIG_USB_USBNET)        += usb/
 obj-$(CONFIG_USB_ZD1201)        += usb/
 obj-$(CONFIG_USB_IPHETH)        += usb/
 obj-$(CONFIG_USB_CDC_PHONET)   += usb/
+obj-$(CONFIG_NWHW_CONFIG) += nwhwconfig.o
diff --git a/drivers/net/nwhwconfig.c b/drivers/net/nwhwconfig.c
new file mode 100644
index 0000000..76f3fdf
--- /dev/null
+++ b/drivers/net/nwhwconfig.c
@@ -0,0 +1,173 @@
+/*
+ * Configuration of network device hardware from the kernel command line.
+ *
+ * Official documentation available at:
+ *   http://www.stlinux.com/howto/network/ethernet-MAC
+ *
+ * Copyright (c) STMicroelectronics Limited
+ *
+ * Author: Stuart Menefy <stuart.menefy@st.com>
+ * Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+ */
+
+#include <linux/string.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <net/ip.h>
+
+static struct eth_dev {
+	char dev_name[IFNAMSIZ];
+	char hw_addr[18];
+	int speed;
+	int duplex;
+} nwhwdev[NETDEV_BOOT_SETUP_MAX];
+
+static int parse_addr(char *str, struct sockaddr *addr)
+{
+	char *s;
+	char *mac = addr->sa_data;
+
+	while ((s = strsep(&str, ":")) != NULL) {
+		unsigned byte;
+		if (sscanf(s, "%x", &byte) != 1 || byte > 0xff)
+			return -1;
+		*mac++ = byte;
+	}
+	addr->sa_family = ARPHRD_ETHER;
+	return 0;
+}
+
+/**
+ * nwhw_config
+ * @dev : net device pointer
+ * Description: it sets the MAC address.
+ * Note that if the network device driver already uses a right
+ * address this function doesn't replace any value.
+ */
+static int __init nwhw_config(void)
+{
+	struct net_device *dev;
+	struct sockaddr s_addr;
+	int ndev = 0;
+
+	while ((ndev < NETDEV_BOOT_SETUP_MAX) &&
+	       (dev = __dev_get_by_name(&init_net, nwhwdev[ndev].dev_name))) {
+
+		if (!dev)
+			break;
+
+		if (!is_valid_ether_addr(dev->dev_addr)) {
+
+			if (nwhwdev[ndev].hw_addr[0]) {
+				int valid_ether =
+				    parse_addr(nwhwdev[ndev].hw_addr, &s_addr);
+				if (!valid_ether) {
+					rtnl_lock();
+					if (dev_set_mac_address(dev, &s_addr))
+						pr_err("%s: Error: not set MAC"
+						       " addr", __func__);
+					rtnl_unlock();
+					goto hw_mac_done;
+				} else
+					pr_err("%s: Error: Invalid MAC addr",
+					       __func__);
+			}
+			/* Although many drivers do that in case of
+			 * problems, we assume the nwhw_config always
+			 * has to exit with a good MAC address (even if
+			 * generated randomly). */
+			random_ether_addr(dev->dev_addr);
+			pr_warning("%s: generating random addr...", __func__);
+		}
+hw_mac_done:
+		pr_info("%s: (%s) setting mac address: %pM", __func__,
+			dev->name, dev->dev_addr);
+
+		if ((nwhwdev[ndev].speed != -1) ||
+		    (nwhwdev[ndev].duplex != -1)) {
+			struct ethtool_cmd cmd = { ETHTOOL_GSET };
+
+			if (!dev->ethtool_ops->get_settings ||
+			    (dev->ethtool_ops->get_settings(dev, &cmd) < 0))
+				pr_err("%s: cannot read ether device settings",
+				       __func__);
+			else {
+				cmd.cmd = ETHTOOL_SSET;
+				cmd.autoneg = AUTONEG_DISABLE;
+				if (nwhwdev[ndev].speed != -1)
+					cmd.speed = nwhwdev[ndev].speed;
+				if (nwhwdev[ndev].duplex != -1)
+					cmd.duplex = nwhwdev[ndev].duplex;
+				if (!dev->ethtool_ops->set_settings ||
+				    (dev->ethtool_ops->set_settings(dev, &cmd) <
+				     0))
+					pr_err("%s: cannot setting the eth dev",
+					       __func__);
+			}
+		}
+		ndev++;
+	}
+	return 0;
+}
+
+device_initcall(nwhw_config);
+
+/**
+ * nwhw_config_setup - parse the nwhwconfig parameters
+ * @str : pointer to the nwhwconfig parameter
+ * Description:
+ * This function parses the nwhwconfig command line argumets.
+ * Command line syntax:
+ * nwhwconf=device:eth0,hwaddr:<mac0>[,speed:<speed0>][,duplex:<duplex0>];
+ *	    device:eth1,hwaddr:<mac1>[,speed:<speed1>][,duplex:<duplex1>];
+ *	...
+ */
+static int __init nwhw_config_setup(char *str)
+{
+	char *opt;
+	int j = 0;
+
+	if (!str || !*str)
+		return 0;
+
+	while (((opt = strsep(&str, ";")) != NULL)
+	       && (j < NETDEV_BOOT_SETUP_MAX)) {
+		char *p;
+
+		nwhwdev[j].speed = -1;
+		nwhwdev[j].duplex = -1;
+
+		while ((p = strsep(&opt, ",")) != NULL) {
+			if (!strncmp(p, "device:", 7))
+				strlcpy(nwhwdev[j].dev_name, p + 7,
+					sizeof(nwhwdev[j].dev_name));
+			else if (!strncmp(p, "hwaddr:", 7))
+				strlcpy(nwhwdev[j].hw_addr, p + 7,
+					sizeof(nwhwdev[j].hw_addr));
+			else if (!strcmp(p, "duplex:full"))
+				nwhwdev[j].duplex = DUPLEX_FULL;
+
+			else if (!strcmp(p, "duplex:half"))
+				nwhwdev[j].duplex = DUPLEX_HALF;
+
+			else if (!strncmp(p, "speed:", 6)) {
+				int speed;
+
+				if (!(kstrtoul(p + 6, 0,
+						     (unsigned long *)&speed)))
+					if ((speed == SPEED_10) ||
+					    (speed == SPEED_100) ||
+					    (speed == SPEED_1000) ||
+					    (speed == SPEED_10000))
+						nwhwdev[j].speed = speed;
+			}
+
+		}
+		j++;
+	}
+	return 1;
+}
+
+__setup("nwhwconf=", nwhw_config_setup);
-- 
1.7.4.4
