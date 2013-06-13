From: <Narendra_K@Dell.com>
Subject: [RFC PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Thu, 13 Jun 2013 08:45:18 -0700
Message-ID: <20130613154253.GA1380@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>, <john.r.fastabend@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:4800 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862Ab3FMPqa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 11:46:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to know if network interfaces from NIC partitions
'map to/use the' same physical port. For example,  when creating
bonding in fault tolerance mode, if  two network interfaces map to/use
the same physical port, it might not have the desired result. This
information is not available today in a standard format or it is not
present.  If this information can be made available in a generic  way
to user space, tools such as NetworkManager or Libteam or Wicked can
make smarter bonding decisions (such as warn users when setting up
configurations which will not have desired effect).

The requirement is to have a generic interface using which
kernel/drivers can provide information/hints to user space about the
physical port number used by a network interface.

The following options were explored -

1. 'dev_id' sysfs attribute:

In addition to being used to differentiate between devices that share
the same link layer address, it is being used to indicate the physical
port number used by a network interface.

As dev_id exists to differentiate between devices sharing the same
link layer address, dev_id option is not selected.

2. Re-using 'if_port' field in 'struct net_device':

if_port field exists to indicate the media type(please refer to
netdevice.h). It seemed like it was also used to indicate the physical
port number.

As re-using 'if_port' might possibly break user space, this option is
not selected.

3. Add a new field 'phys_port' to 'struct net_device' and export it
to sysfs:

The 'phys_port' will be a universally unique identifier, which
would be a MAC-48 or EUI-64 or a 128 bit UUID value. It will
uniquely identify the physical port used by a network interface.
The 'length' of the identifier will be zero if the field is not set
for a network interface.

This patch implements option 3. It creates a new sysfs attribute
'phys_port' -

/sys/class/net/<interface name>/phys_port

References: http://marc.info/?l=linux-netdev&m=136920998009209&w=2
References: http://marc.info/?l=linux-netdev&m=136992041432498&w=2

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 include/linux/netdevice.h | 17 +++++++++++++++++
 net/core/net-sysfs.c      | 31 +++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e5d6557..1dfb79f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1059,6 +1059,18 @@ struct net_device_ops {
 						      bool new_carrier);
 };
 
+/* This structure holds a universally unique identifier to
+ * identify the physical port used by a netdevice
+ */
+struct port_identifier {
+	union {
+		u8 mac48[6];
+		u8 eui64[8];
+		u8 uuid[16];
+	} id;
+	unsigned short length;
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1178,6 +1190,11 @@ struct net_device {
 						 * that share the same link
 						 * layer address
 						 */
+	struct port_identifier	phys_port;	/* Universally unique physical
+						 * port identifier, MAC-48 or
+						 * EUI-64 or 128 bit UUID,
+						 * length is zero if not set
+						 */
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..9338f44 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -334,6 +334,36 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_group);
 }
 
+static ssize_t show_phys_port(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+	unsigned short len;
+
+	if (!dev_isalive(net))
+		return ret;
+
+	len = net->phys_port.length;
+
+	switch (len) {
+	case 6:
+		ret = sysfs_format_mac(buf, net->phys_port.id.mac48, len);
+		break;
+	case 8:
+		ret = sysfs_format_mac(buf, net->phys_port.id.eui64, len);
+		break;
+	case 16:
+		ret = scnprintf(buf, PAGE_SIZE, "%pU\n",
+				net->phys_port.id.uuid);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
@@ -355,6 +385,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
 	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
+	__ATTR(phys_port, S_IRUGO, show_phys_port, NULL),
 	{}
 };
 
-- 
1.8.0.1

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
