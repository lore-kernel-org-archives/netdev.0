From: <Narendra_K@Dell.com>
Subject: [PATCH v1 net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Fri, 28 Jun 2013 20:57:41 +0530
Message-ID: <20130628152652.GA4247@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>, <john.r.fastabend@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:36609 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab3F1P2R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 11:28:17 -0400
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
would be a MAC-48 or EUI-64 or a 128 bit UUID value, but not
restricted to these spaces. It will uniquely identify the physical
port used by a network interface. The 'length' of the identifier will
be zero if the field is not set for a network interface.

This patch implements option 3. It creates a new sysfs attribute
'phys_port' -

/sys/class/net/<interface name>/phys_port

References: http://marc.info/?l=linux-netdev&m=136920998009209&w=2
References: http://marc.info/?l=linux-netdev&m=136992041432498&w=2

Signed-off-by: Narendra K <narendra_k@dell.com>
---
Changes from RFC version:

Suggestions from Ben Hutchings -
1. 'struct port_identifier' is changed to be generic instead of
restricting it to MAC-48 or EUI-64 or 128 bit UUID.
2. Commit message updated to indicate point 1.
3. 'show_phys_port' function modified to handle zero length
instead of returning -EINVAL
4. 'show_phys_port' function made generic to handle all
lengths instead 6, 8 or 16 bytes.

v0 -> v1:
Added the missing locking in 'show_phys_port' function - suggested
by John Fastabend.

 include/linux/netdevice.h | 13 +++++++++++++
 net/core/net-sysfs.c      | 22 ++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09b4188..ddb14ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1062,6 +1062,14 @@ struct net_device_ops {
 						      bool new_carrier);
 };
 
+/* This structure holds a universally unique identifier to
+ * identify the physical port used by a netdevice
+ */
+struct port_identifier {
+	unsigned char port_id[MAX_ADDR_LEN];
+	unsigned port_id_len;
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1181,6 +1189,11 @@ struct net_device {
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
index 981fed3..f151eab 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -334,6 +334,27 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_group);
 }
 
+static ssize_t show_phys_port(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+	unsigned char len;
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(net)) {
+		len = net->phys_port.port_id_len;
+		if (!len) {
+			read_unlock(&dev_base_lock);
+			return 0;
+		}
+		ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
+	}
+	read_unlock(&dev_base_lock);
+
+	return ret;
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
@@ -355,6 +376,7 @@ static struct device_attribute net_class_attributes[] = {
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
