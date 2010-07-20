From: Stefan Assmann <sassmann@redhat.com>
Subject: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Tue, 20 Jul 2010 12:50:26 +0200
Message-ID: <4C457F72.8090708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55924 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009Ab0GTKul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 06:50:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

Reserve a bit in struct net_device to indicate whether an interface
generates its MAC address randomly, and expose the information via
sysfs.
May look like this:
/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0/ifrndmac

By default the value of ifrndmac is 0. Any driver that generates the MAC
address randomly should return a value to 1.

This simplifies the handling of network devices with random MAC addresses
as user-space may just query sysfs to find out if the MAC is real or fake.
Udev may check sysfs for devices that generate their MAC address
randomly and create persistent net rules by using the unique device path
if the value returned is 1.

Also introducing a helper function to assist driver adoption.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 include/linux/etherdevice.h |   14 ++++++++++++++
 include/linux/netdevice.h   |    1 +
 net/core/net-sysfs.c        |   12 ++++++++++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d7a668..ebb34ac 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -127,6 +127,20 @@ static inline void random_ether_addr(u8 *addr)
 }

 /**
+ * dev_hw_addr_random - Create random MAC and set device flag
+ * @dev: pointer to net_device structure
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Generate random MAC to be used by a device and set NETIF_F_RNDMAC flag
+ * so the state can be read by sysfs and be used by udev.
+ */
+static inline void dev_hw_addr_random(struct net_device *dev, u8 *hwaddr)
+{
+	dev->features |= NETIF_F_RNDMAC;
+	random_ether_addr(hwaddr);
+}
+
+/**
  * compare_ether_addr - Compare two Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b626289..2ea0298 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -845,6 +845,7 @@ struct net_device {
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_RNDMAC		(1 << 29) /* Interface with random MAC address */

 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index d2b5965..91a9808 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -188,6 +188,17 @@ static ssize_t show_dormant(struct device *dev,
 	return -EINVAL;
 }

+static ssize_t show_ifrndmac(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+
+	if (net->features & NETIF_F_RNDMAC)
+		return sprintf(buf, fmt_dec, 1);
+	else
+		return sprintf(buf, fmt_dec, 0);
+}
+
 static const char *const operstates[] = {
 	"unknown",
 	"notpresent", /* currently unused */
@@ -300,6 +311,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
+	__ATTR(ifrndmac, S_IRUGO, show_ifrndmac, NULL),
 	__ATTR(features, S_IRUGO, show_features, NULL),
 	__ATTR(type, S_IRUGO, show_type, NULL),
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
-- 
1.6.5.2

