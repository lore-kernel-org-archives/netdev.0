From: Stefan Assmann <sassmann@redhat.com>
Subject: [PATCH net-next] sysfs: add attribute to indicate hw address assignment
 type
Date: Thu, 22 Jul 2010 14:50:21 +0200
Message-ID: <4C483E8D.4080300@redhat.com>
References: <4C458CB7.3030508@redhat.com>	<4C458F50.4070200@ixiacom.com>	 <4C4593DA.9040207@redhat.com>	 <20100720.131839.134093789.davem@davemloft.net>	 <4C46AB60.5060008@redhat.com> <1279720478.2089.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, abadea@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279720478.2089.3.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.07.2010 15:54, Ben Hutchings wrote:
> On Wed, 2010-07-21 at 10:10 +0200, Stefan Assmann wrote:
>> I put Alex' idea into code for further discussion, keeping the names
>> mentioned here until we agree on the scope of this attribute. When we
>> have settled I'll post a patch with proper patch description.
> [...]
> 
> Just a little nitpick: I think it would be clearer to use a more
> specific term like 'address source' or 'address assignment type' rather
> than 'address type'.

Here's a proposal for the final patch.

  Stefan

From: Stefan Assmann <sassmann@redhat.com>

Add addr_assign_type to struct net_device and expose it via sysfs.
This new attribute has the purpose of giving user-space the ability to
distinguish between different assignment types of MAC addresses.

For example user-space can treat NICs with randomly generated MAC
addresses differently than NICs that have permanent (locally assigned)
MAC addresses.
For the former udev could write a persistent net rule by matching the
device path instead of the MAC address.
There's also the case of devices that 'steal' MAC addresses from slave
devices. In which it is also be beneficial for user-space to be aware
of the fact.

This patch also introduces a helper function to assist adoption of
drivers that generate MAC addresses randomly.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 include/linux/etherdevice.h |   14 ++++++++++++++
 include/linux/netdevice.h   |    6 ++++++
 net/core/net-sysfs.c        |    2 ++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d7a668..848480b 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -127,6 +127,20 @@ static inline void random_ether_addr(u8 *addr)
 }

 /**
+ * dev_hw_addr_random - Create random MAC and set device flag
+ * @dev: pointer to net_device structure
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Generate random MAC to be used by a device and set addr_assign_type
+ * so the state can be read by sysfs and be used by udev.
+ */
+static inline void dev_hw_addr_random(struct net_device *dev, u8 *hwaddr)
+{
+	dev->addr_assign_type |= NET_ADDR_RANDOM;
+	random_ether_addr(hwaddr);
+}
+
+/**
  * compare_ether_addr - Compare two Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b626289..1bca617 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -66,6 +66,11 @@ struct wireless_dev;
 #define HAVE_FREE_NETDEV		/* free_netdev() */
 #define HAVE_NETDEV_PRIV		/* netdev_priv() */

+/* hardware address assignment types */
+#define NET_ADDR_PERM		0	/* address is permanent (default) */
+#define NET_ADDR_RANDOM		1	/* address is generated randomly */
+#define NET_ADDR_STOLEN		2	/* address is stolen from other device */
+
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
 #define NET_RX_DROP		1	/* packet dropped */
@@ -919,6 +924,7 @@ struct net_device {

 	/* Interface address info. */
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
+	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index d2b5965..af4dfba 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -95,6 +95,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 }

 NETDEVICE_SHOW(dev_id, fmt_hex);
+NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
@@ -295,6 +296,7 @@ static ssize_t show_ifalias(struct device *dev,
 }

 static struct device_attribute net_class_attributes[] = {
+	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
-- 
1.6.5.2
