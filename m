From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v8 1/4] net: add name_assign_type netdev attribute
Date: Thu, 10 Jul 2014 23:01:03 +0200
Message-ID: <1405026066-2547-2-git-send-email-teg@jklm.no>
References: <1405026066-2547-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36959 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbaGJVBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 17:01:23 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so358979wib.8
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 14:01:22 -0700 (PDT)
In-Reply-To: <1405026066-2547-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch by David Herrmann.

The name_assign_type attribute gives hints where the interface name of a
given net-device comes from. These values are currently defined:
  NET_NAME_ENUM:
    The ifname is provided by the kernel with an enumerated
    suffix, typically based on order of discovery. Names may
    be reused and unpredictable.
  NET_NAME_PREDICTABLE:
    The ifname has been assigned by the kernel in a predictable way
    that is guaranteed to avoid reuse and always be the same for a
    given device. Examples include statically created devices like
    the loopback device and names deduced from hardware properties
    (including being given explicitly by the firmware). Names
    depending on the order of discovery, or in any other way on the
    existence of other devices, must not be marked as PREDICTABLE.
  NET_NAME_USER:
    The ifname was provided by user-space during net-device setup.
  NET_NAME_RENAMED:
    The net-device has been renamed from userspace. Once this type is set,
    it cannot change again.
  NET_NAME_UNKNOWN:
    This is an internal placeholder to indicate that we yet haven't yet
    categorized the name. It will not be exposed to userspace, rather
    -EINVAL is returned.

The aim of these patches is to improve user-space renaming of interfaces. As
a general rule, userspace must rename interfaces to guarantee that names stay
the same every time a given piece of hardware appears (at boot, or when
attaching it). However, there are several situations where userspace should
not perform the renaming, and that depends on both the policy of the local
admin, but crucially also on the nature of the current interface name.

If an interface was created in repsonse to a userspace request, and userspace
already provided a name, we most probably want to leave that name alone. The
main instance of this is wifi-P2P devices created over nl80211, which currently
have a long-standing bug where they are getting renamed by udev. We label such
names NET_NAME_USER.

If an interface, unbeknown to us, has already been renamed from userspace, we
most probably want to leave also that alone. This will typically happen when
third-party plugins (for instance to udev, but the interface is generic so could
be from anywhere) renames the interface without informing udev about it. A
typical situation is when you switch root from an installer or an initrd to the
real system and the new instance of udev does not know what happened before
the switch. These types of problems have caused repeated issues in the past. To
solve this, once an interface has been renamed, its name is labelled
NET_NAME_RENAMED.

In many cases, the kernel is actually able to name interfaces in such a
way that there is no need for userspace to rename them. This is the case when
the enumeration order of devices, or in fact any other (non-parent) device on
the system, can not influence the name of the interface. Examples include
statically created devices, or any naming schemes based on hardware properties
of the interface. In this case the admin may prefer to use the kernel-provided
names, and to make that possible we label such names NET_NAME_PREDICTABLE.
We want the kernel to have tho possibilty of performing predictable interface
naming itself (and exposing to userspace that it has), as the information
necessary for a proper naming scheme for a certain class of devices may not
be exposed to userspace.

The case where renaming is almost certainly desired, is when the kernel has
given the interface a name using global device enumeration based on order of
discovery (ethX, wlanY, etc). These naming schemes are labelled NET_NAME_ENUM.

Lastly, a fallback is left as NET_NAME_UNKNOWN, to indicate that a driver has
not yet been ported. This is mostly useful as a transitionary measure, allowing
us to label the various naming schemes bit by bit.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Reviewed-by: David Herrmann <dh.herrmann@gmail.com>
Reviewed-by: Kay Sievers <kay@vrfy.org>

v8: minor documentation fixes
---
 Documentation/ABI/testing/sysfs-class-net | 11 +++++++++++
 include/linux/netdevice.h                 |  2 ++
 include/uapi/linux/netdevice.h            |  6 ++++++
 net/core/dev.c                            | 11 ++++++-----
 net/core/net-sysfs.c                      | 20 ++++++++++++++++++++
 5 files changed, 45 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index 416c5d5..d322b05 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -1,3 +1,14 @@
+What:		/sys/class/net/<iface>/name_assign_type
+Date:		July 2014
+KernelVersion:	3.17
+Contact:	netdev@vger.kernel.org
+Description:
+		Indicates the name assignment type. Possible values are:
+		1: enumerated by the kernel, possibly in an unpredictable way
+		2: predictably named by the kernel
+		3: named by userspace
+		4: renamed
+
 What:		/sys/class/net/<iface>/addr_assign_type
 Date:		July 2010
 KernelVersion:	3.2
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66f9a04..551e187 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1379,6 +1379,8 @@ struct net_device {
 	struct kset		*queues_kset;
 #endif
 
+	unsigned char		name_assign_type;
+
 	bool			uc_promisc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
diff --git a/include/uapi/linux/netdevice.h b/include/uapi/linux/netdevice.h
index fdfbd1c..5581854 100644
--- a/include/uapi/linux/netdevice.h
+++ b/include/uapi/linux/netdevice.h
@@ -37,6 +37,12 @@
 #define INIT_NETDEV_GROUP	0
 
 
+/* interface name assignment types (sysfs name_assign_type attribute) */
+#define NET_NAME_UNKNOWN	0	/* unknown origin (not exposed to userspace) */
+#define NET_NAME_ENUM		1	/* enumerated by kernel */
+#define NET_NAME_PREDICTABLE	2	/* predictably named by the kernel */
+#define NET_NAME_USER		3	/* provided by user-space */
+#define NET_NAME_RENAMED	4	/* renamed by user-space */
 
 /* Media selection options. */
 enum {
diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf6..392c784 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6438,11 +6438,12 @@ void netdev_freemem(struct net_device *dev)
 
 /**
  *	alloc_netdev_mqs - allocate network device
- *	@sizeof_priv:	size of private data to allocate space for
- *	@name:		device name format string
- *	@setup:		callback to initialize device
- *	@txqs:		the number of TX subqueues to allocate
- *	@rxqs:		the number of RX subqueues to allocate
+ *	@sizeof_priv:		size of private data to allocate space for
+ *	@name:			device name format string
+ *	@name_assign_type: 	origin of device name
+ *	@setup:			callback to initialize device
+ *	@txqs:			the number of TX subqueues to allocate
+ *	@rxqs:			the number of RX subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
  *	and performs basic initialization.  Also allocates subqueue structs
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..7752f2a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -112,6 +112,25 @@ NETDEVICE_SHOW_RO(ifindex, fmt_dec);
 NETDEVICE_SHOW_RO(type, fmt_dec);
 NETDEVICE_SHOW_RO(link_mode, fmt_dec);
 
+static ssize_t format_name_assign_type(const struct net_device *net, char *buf)
+{
+	return sprintf(buf, fmt_dec, net->name_assign_type);
+}
+
+static ssize_t name_assign_type_show(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	if (net->name_assign_type != NET_NAME_UNKNOWN)
+		ret = netdev_show(dev, attr, buf, format_name_assign_type);
+
+	return ret;
+}
+static DEVICE_ATTR_RO(name_assign_type);
+
 /* use same locking rules as GIFHWADDR ioctl's */
 static ssize_t address_show(struct device *dev, struct device_attribute *attr,
 			    char *buf)
@@ -387,6 +406,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_dev_port.attr,
 	&dev_attr_iflink.attr,
 	&dev_attr_ifindex.attr,
+	&dev_attr_name_assign_type.attr,
 	&dev_attr_addr_assign_type.attr,
 	&dev_attr_addr_len.attr,
 	&dev_attr_link_mode.attr,
-- 
1.9.3
