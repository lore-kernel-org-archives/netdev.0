From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Vlan interface nuisance
Date: Sun, 1 Mar 2009 21:05:41 -0800
Message-ID: <20090301210541.4585c199@nehalam>
References: <20090301204731.40ce346a@nehalam>
	<20090301.205702.81302378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35958 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730AbZCBFFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 00:05:45 -0500
In-Reply-To: <20090301.205702.81302378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 01 Mar 2009 20:57:02 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sun, 1 Mar 2009 20:47:31 -0800
> 
> > Why is interface created through netlink named 'vlan0' and
> > interface created through old vconfig called 'ethX.YY'.
> > Seems like the interface should be consistent.
> 
> I think the netlink scheme is saner, and the idea is to
> transition people over to that.
> 
> We can't change what vconfig uses, so what Patrick decided
> to do is pretty sane if you ask me.

This is missing:
------------------------------------------------------------------
Subject: vlan: names should be consistent

Vlan's created via netlink should be the same as vlan's created
via older interface. This patches changes is to be consistent.

One could argue this is an API change (it changes behaviour of netlink
interface), but I argue this was a design bug when the netlink interface
to VLAN was added.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlan.c	2009-03-01 20:54:15.906263870 -0800
+++ b/net/8021q/vlan.c	2009-03-01 20:58:34.290763830 -0800
@@ -292,24 +292,11 @@ out_free_group:
 	return err;
 }
 
-/*  Attach a VLAN device to a mac address (ie Ethernet Card).
- *  Returns 0 if the device was created or a negative error code otherwise.
- */
-static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
+void vlan_name(char *name, const struct net_device *real_dev, u16 vlan_id)
 {
-	struct net_device *new_dev;
-	struct net *net = dev_net(real_dev);
-	struct vlan_net *vn = net_generic(net, vlan_net_id);
-	char name[IFNAMSIZ];
-	int err;
-
-	if (vlan_id >= VLAN_VID_MASK)
-		return -ERANGE;
-
-	err = vlan_check_real_dev(real_dev, vlan_id);
-	if (err < 0)
-		return err;
-
+	const struct net *net = dev_net(real_dev);
+	const struct vlan_net *vn = net_generic(net, vlan_net_id);
+
 	/* Gotta set up the fields for the device. */
 	switch (vn->name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
@@ -336,6 +323,25 @@ static int register_vlan_device(struct n
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
+}
+
+/*  Attach a VLAN device to a mac address (ie Ethernet Card).
+ *  Returns 0 if the device was created or a negative error code otherwise.
+ */
+static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
+{
+	struct net_device *new_dev;
+	char name[IFNAMSIZ];
+	int err;
+
+	if (vlan_id >= VLAN_VID_MASK)
+		return -ERANGE;
+
+	err = vlan_check_real_dev(real_dev, vlan_id);
+	if (err < 0)
+		return err;
+
+	vlan_name(name, real_dev, vlan_id);
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
 			       vlan_setup);
 
--- a/net/8021q/vlan.h	2009-03-01 20:57:49.766013840 -0800
+++ b/net/8021q/vlan.h	2009-03-01 20:58:33.490013558 -0800
@@ -80,6 +80,7 @@ int vlan_dev_change_flags(const struct n
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 
 int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
+void vlan_name(char *name, const struct net_device *real_dev, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev);
--- a/net/8021q/vlan_netlink.c	2009-03-01 20:51:14.943013010 -0800
+++ b/net/8021q/vlan_netlink.c	2009-03-01 20:57:37.448624035 -0800
@@ -106,6 +106,7 @@ static int vlan_newlink(struct net_devic
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev;
 	int err;
+	char name[IFNAMSIZ];
 
 	if (!data[IFLA_VLAN_ID])
 		return -EINVAL;
@@ -129,6 +130,11 @@ static int vlan_newlink(struct net_devic
 	else if (dev->mtu > real_dev->mtu)
 		return -EINVAL;
 
+	vlan_name(name, real_dev, vlan->vlan_id);
+	err = dev_change_name(dev, name);
+	if (err < 0)
+		return err;
+
 	err = vlan_changelink(dev, tb, data);
 	if (err < 0)
 		return err;
