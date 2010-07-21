From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Wed, 21 Jul 2010 10:10:08 +0200
Message-ID: <4C46AB60.5060008@redhat.com>
References: <4C458CB7.3030508@redhat.com>	<4C458F50.4070200@ixiacom.com>	<4C4593DA.9040207@redhat.com> <20100720.131839.134093789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: abadea@ixiacom.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762740Ab0GUIKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 04:10:23 -0400
In-Reply-To: <20100720.131839.134093789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.07.2010 22:18, David Miller wrote:
> From: Stefan Assmann <sassmann@redhat.com>
> Date: Tue, 20 Jul 2010 14:17:30 +0200
> 
>> On 20.07.2010 13:58, Alex Badea wrote:
>>> Hi,
>>>
>>> On 07/20/2010 02:47 PM, Stefan Assmann wrote:
>>>>> What about devices that 'steal' MAC addresses from slave devices?
>>>
>>> Might I suggest an attribute such as "address_type", which could report
>>> "permanent", "random", "stolen", or something else in the future?
>>
>> In case there's demand for such a multi-purpose attribute I see no
>> reason to object. More thoughts on this?
> 
> I think this is a great idea.
> 
> Now it makes sense to use a new 'u8' in struct netdevice or similar to
> store this, since we'll have more than a boolean here.
> 

I put Alex' idea into code for further discussion, keeping the names
mentioned here until we agree on the scope of this attribute. When we
have settled I'll post a patch with proper patch description.

  Stefan
---
 include/linux/etherdevice.h |   14 ++++++++++++++
 include/linux/netdevice.h   |    6 ++++++
 net/core/net-sysfs.c        |    2 ++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d7a668..f15cac8 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -127,6 +127,20 @@ static inline void random_ether_addr(u8 *addr)
 }

 /**
+ * dev_hw_addr_random - Create random MAC and set device flag
+ * @dev: pointer to net_device structure
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Generate random MAC to be used by a device and set addr_type
+ * so the state can be read by sysfs and be used by udev.
+ */
+static inline void dev_hw_addr_random(struct net_device *dev, u8 *hwaddr)
+{
+	dev->addr_type |= NET_ADDR_RANDOM;
+	random_ether_addr(hwaddr);
+}
+
+/**
  * compare_ether_addr - Compare two Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b626289..2718895 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -66,6 +66,11 @@ struct wireless_dev;
 #define HAVE_FREE_NETDEV		/* free_netdev() */
 #define HAVE_NETDEV_PRIV		/* netdev_priv() */

+/* hardware address types */
+#define NET_ADDR_PERM		0	/* address is permanent (default) */
+#define NET_ADDR_RANDOM		1	/* address is generated randomly */
+#define NET_ADDR_STOLEN		2	/* address is stolen from other device */
+
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
 #define NET_RX_DROP		1	/* packet dropped */
@@ -920,6 +925,7 @@ struct net_device {
 	/* Interface address info. */
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_len;	/* hardware address length	*/
+	unsigned char		addr_type;	/* hardware address type	*/
 	unsigned short          dev_id;		/* for shared network cards */

 	spinlock_t		addr_list_lock;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index d2b5965..052ab14 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -96,6 +96,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,

 NETDEVICE_SHOW(dev_id, fmt_hex);
 NETDEVICE_SHOW(addr_len, fmt_dec);
+NETDEVICE_SHOW(addr_type, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
 NETDEVICE_SHOW(features, fmt_long_hex);
@@ -296,6 +297,7 @@ static ssize_t show_ifalias(struct device *dev,

 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
+	__ATTR(addr_type, S_IRUGO, show_addr_type, NULL),
 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
-- 
1.7.1

