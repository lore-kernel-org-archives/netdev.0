From: <Narendra_K@Dell.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Mon, 15 Jul 2013 08:34:33 -0700
Message-ID: <20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
 <20130711203938.GA4078@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<john.r.fastabend@intel.com>
To: <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:24062 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535Ab3GOPgm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:36:42 -0400
In-Reply-To: <20130711203938.GA4078@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 02:09:38AM +0530, Jiri Pirko wrote:
> 
> Mon, Jun 17, 2013 at 08:10:32PM CEST, Narendra_K@Dell.com wrote:
[...]
> >3. Add a new field 'phys_port' to 'struct net_device' and export it
> >to sysfs:
> >
> >The 'phys_port' will be a universally unique identifier, which
> >would be a MAC-48 or EUI-64 or a 128 bit UUID value, but not
> >restricted to these spaces. It will uniquely identify the physical
> >port used by a network interface. The 'length' of the identifier will
> >be zero if the field is not set for a network interface.
> >
> >This patch implements option 3. It creates a new sysfs attribute
> >'phys_port' -
> 
> 
> I think that correct way is to (Ben mentioned already part of it):
> 1) introduce ndo_phys_port_id() which would be used by core to get the
> struct port_identifier filled by the driver (struct port_identifier is

Hi Jiri, thank you for the comments.

I was thinking if ndo_phys_port_id() is required.
'netdev->phys_port.port_id' and port_id_len are set by driver before calling
'register_netdev' and are available to the core. If 'port_id' is changed
by driver, then point 2 would notify the interested components and point 3
would notify the userspace. Please let me know if i am missing something.

> not really a good name (namespace prefix should be there))

Ok. I have changed it 'struct phys_port_identifier'. Please let me know
if it is suitable.

> 
> 2) add netdev nofitier event type which would allow driver to propagate
> changes of phys to to rtnetlink code and drivers which might be
> interested (like bond/bridge/whatever) as well.

Ok. I have added 'NETDEV_CHANGE_PHYS_PORT' event type which could be
used by drivers.

> 
> 3) export phys port id through rtnetlink api to userspace.

It is implemented in this patch here -
[RFC,net-next] net: Include phys_port identifier in the RTM_NEWLINK
message
http://patchwork.ozlabs.org/patch/255435/

Please find the patch with the changes incorporated. If the changes look
good, i will incorporate them in the next version of the patch.

[PATCH net-next ] Add phys_port identifier to struct net_device
 and export it to sysfs

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
 include/linux/netdevice.h | 14 ++++++++++++++
 net/core/net-sysfs.c      | 22 ++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0741a1e..17db7e5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1062,6 +1062,14 @@ struct net_device_ops {
 						      bool new_carrier);
 };
 
+/* This structure holds a universally unique identifier to
+ * identify the physical port used by a netdevice
+ */
+struct phys_port_identifier {
+	unsigned char port_id[MAX_ADDR_LEN];
+	unsigned char port_id_len;
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -1181,6 +1189,11 @@ struct net_device {
 						 * that share the same link
 						 * layer address
 						 */
+	struct phys_port_identifier	phys_port; /* Universally unique physical
+						    * port identifier, MAC-48 or
+						    * EUI-64 or 128 bit UUID,
+						    * length is zero if not set
+						    */
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
@@ -1633,6 +1646,7 @@ struct packet_offload {
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
 #define NETDEV_CHANGEUPPER	0x0015
+#define NETDEV_CHANGE_PHYS_PORT	0x0016
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..b77ebe6 100644
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
+		if (!len)
+			ret = 0;
+		else
+			ret = sysfs_format_mac(buf, net->phys_port.port_id,
+					       len);
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
