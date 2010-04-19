From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 1/2] add iovnl netlink support
Date: Mon, 19 Apr 2010 12:18:07 -0700
Message-ID: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:62622 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab0DSTSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 15:18:08 -0400
In-Reply-To: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

IOV netlink (IOVNL) adds I/O Virtualization control support to a master
device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
design allows for the case where master and slave are the
same netdev interface.

One control setting example is MAC/VLAN settings for a VF.  Another
example control setting is a port-profile for a VF.  A port-profile is an
identifier that defines policy-based settings on the network port
backing the VF.  The network port settings examples are VLAN membership,
QoS settings, and L2 security settings, typical of a data center network.

This patch adds the iovnl interface definitions and an iovnl module.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/iovnl.h     |  124 +++++++++++++++++++++
 include/linux/netdevice.h |    4 +
 include/linux/rtnetlink.h |    5 +
 include/net/iovnl.h       |   36 ++++++
 net/Kconfig               |    1 
 net/Makefile              |    3 +
 net/iovnl/Kconfig         |   10 ++
 net/iovnl/Makefile        |    1 
 net/iovnl/iovnl.c         |  260 +++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 444 insertions(+), 0 deletions(-)

diff --git a/include/linux/iovnl.h b/include/linux/iovnl.h
new file mode 100644
index 0000000..ac5fcd3
--- /dev/null
+++ b/include/linux/iovnl.h
@@ -0,0 +1,124 @@
+/*
+ * Copyright 2010 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __LINUX_IOVNL_H__
+#define __LINUX_IOVNL_H__
+
+#include <linux/types.h>
+
+#define IOVNL_PROTO_VERSION 1
+
+/**
+ * IOV netlink (IOVNL) adds I/O Virtualization control support to a master
+ * device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
+ * control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
+ * design allows for the degenerative case where master and slave are the
+ * same netdev interface.
+ *
+ * One control setting example is MAC/VLAN settings for a VF.  Another
+ * example control setting is a port-profile for a VF.  A port-profile is an
+ * identifier that defines policy-based settings on the network port
+ * backing the VF.  The network port settings examples are VLAN membership,
+ * QoS settings, and L2 security settings, typical of a data center network.
+ *
+ * This file defines an rtnetlink interface to allow setting of IOVNL
+ * on capable netdev devices.
+ */
+
+struct iovnlmsg {
+	__u8	family;
+	__u8	cmd;
+	__u16	pad;
+};
+
+/**
+ * enum iovnl_cmds - supported IOV commands
+ *
+ * @IOV_CMD_UNDEFINED: unspecified command to catch errors
+ * @IOV_CMD_SET_PORT_PROFILE: set the port-profile on the device
+ * @IOV_CMD_UNSET_PORT_PROFILE: clear port-profile on the device
+ * @IOV_CMD_GET_PORT_PROFILE_STATUS: return status of last
+ *   IOV_CMD_SET_PORT_PROFILE command
+ * @IOV_SET_MAC_VLAN: Set the MAC address and VLAN on the device
+ */
+enum iovnl_cmds {
+	IOV_CMD_UNDEFINED,
+
+	IOV_CMD_SET_PORT_PROFILE,
+	IOV_CMD_UNSET_PORT_PROFILE,
+	IOV_CMD_GET_PORT_PROFILE_STATUS,
+
+	IOV_CMD_SET_MAC_VLAN,
+
+	__IOV_CMD_ENUM_MAX,
+	IOV_CMD_MAX = __IOV_CMD_ENUM_MAX - 1,
+};
+
+/**
+ * enum iovnl_attrs - IOV top-level netlink attributes
+ *
+ * @IOV_ATTR_UNDEFINED: unspecified attribute to catch errors
+ * @IOV_ATTR_IFNAME: interface name of master (PF) net device (NLA_NUL_STRING)
+ * @IOV_ATTR_VF_IFNAME: interface name of target VF device (NLA_NUL_STRING)
+ * @IOV_ATTR_PORT_PROFILE: port-profile name to assign to device
+ *   (NLA_NUL_STRING)
+ * @IOV_ATTR_CLIENT_NAME: client name (NLA_NUL_STRING)
+ * @IOV_ATTR_HOST_UUID: host UUID (NLA_NUL_STRING)
+ * @IOV_ATTR_PORT_PROFILE_STATUS: status of last IOV_CMD_SET_PORT_PROFILE
+ *   command (NLA_U8)
+ * @IOV_ATTR_MAC_ADDR: device station MAC address (NLA_U8[6])
+ * @IOV_ATTR_VLAN: device 8021q VLAN ID (NLA_U16)
+ # @IOV_ATTR_STATUS: cmd return status code
+ */
+enum iovnl_attrs {
+	IOV_ATTR_UNDEFINED,
+
+	IOV_ATTR_IFNAME,
+	IOV_ATTR_VF_IFNAME,
+
+	IOV_ATTR_PORT_PROFILE,
+	IOV_ATTR_CLIENT_NAME,
+	IOV_ATTR_HOST_UUID,
+	IOV_ATTR_PORT_PROFILE_STATUS,
+
+	IOV_ATTR_MAC_ADDR,
+	IOV_ATTR_VLAN,
+
+	IOV_ATTR_STATUS,
+
+	__IOV_ATTR_ENUM_MAX,
+	IOV_ATTR_MAX = __IOV_ATTR_ENUM_MAX - 1,
+};
+
+/**
+ * enum iovnl_port_profile_status - IOV_ATTR_PORT_PROFILE_STATUS status
+ * return codes
+ *
+ * @IOV_PORT_PROFILE_STATUS_UNKNOWN: unspecified to catch errors
+ * @IOV_PORT_PROFILE_STATUS_SUCCESS:  port-profile aiovlied successfully
+ * @IOV_PORT_PROFILE_STATUS_ERROR: port-profile setting had error
+ * @IOV_PORT_PROFILE_STATUS_INPROGRESS: port-profile setting in-progress
+ */
+enum iovnl_port_profile_status {
+	IOV_PORT_PROFILE_STATUS_UNKNOWN,
+	IOV_PORT_PROFILE_STATUS_SUCCESS,
+	IOV_PORT_PROFILE_STATUS_ERROR,
+	IOV_PORT_PROFILE_STATUS_INPROGRESS,
+};
+
+#endif /* __LINUX_IOVNL_H__ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 649a025..b531b0d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -50,6 +50,7 @@
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
+#include <net/iovnl.h>
 
 struct vlan_group;
 struct netpoll_info;
@@ -1048,6 +1049,9 @@ struct net_device {
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
 
+	/* IOV netlink ops */
+	const struct iovnl_ops *iovnl_ops;
+
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index d1c7c90..aafadf7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -113,6 +113,11 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_GETIOV = 82,
+#define RTM_GETIOV RTM_GETIOV
+	RTM_SETIOV,
+#define RTM_SETIOV RTM_SETIOV
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/include/net/iovnl.h b/include/net/iovnl.h
new file mode 100644
index 0000000..c353eee
--- /dev/null
+++ b/include/net/iovnl.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright 2010 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __NET_IOVNL_H__
+#define __NET_IOVNL_H__
+
+/*
+ * Ops struct for the netlink callbacks.  Used by IOVNL-enabled drivers through
+ * the netdevice struct.
+ */
+struct iovnl_ops {
+	int (*set_port_profile)(struct net_device *, struct net_device *,
+		char *, u8 *, char *, char *);
+	int (*unset_port_profile)(struct net_device *, struct net_device *);
+	int (*get_port_profile_status)(struct net_device *,
+		struct net_device *);
+	int (*set_mac_vlan)(struct net_device *, struct net_device *,
+		u8 *, u16);
+};
+
+#endif /* __NET_IOVNL_H__ */
diff --git a/net/Kconfig b/net/Kconfig
index 0d68b40..aca5de0 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -203,6 +203,7 @@ source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
+source "net/iovnl/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index cb7bdc1..23589e9 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -61,6 +61,9 @@ obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
+ifneq ($(CONFIG_IOVNL),)
+obj-y				+= iovnl/
+endif
 obj-y				+= ieee802154/
 
 ifeq ($(CONFIG_NET),y)
diff --git a/net/iovnl/Kconfig b/net/iovnl/Kconfig
new file mode 100644
index 0000000..4548417
--- /dev/null
+++ b/net/iovnl/Kconfig
@@ -0,0 +1,10 @@
+config IOVNL
+	tristate "IOV rtnetlink support"
+	default n
+	---help---
+	  This enables support for configuring IOV
+	  on Ethernet adapters via rtnetlink.  Say 'Y'
+	  if you have a Ethernet adapter which supports network
+	  configuration using IOV rtnetlinl.
+
+	  If unsure, say N.
diff --git a/net/iovnl/Makefile b/net/iovnl/Makefile
new file mode 100644
index 0000000..9256d01
--- /dev/null
+++ b/net/iovnl/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_IOVNL) += iovnl.o
diff --git a/net/iovnl/iovnl.c b/net/iovnl/iovnl.c
new file mode 100644
index 0000000..ce9db50
--- /dev/null
+++ b/net/iovnl/iovnl.c
@@ -0,0 +1,260 @@
+/*
+ * Copyright 2010 Cisco Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <linux/iovnl.h>
+#include <net/netlink.h>
+#include <net/rtnetlink.h>
+#include <net/iovnl.h>
+#include <net/sock.h>
+
+MODULE_AUTHOR("Roopa Prabhu <roprabhu@cisco.com, "
+	"Scott Feldman <scofeldm@cisco.com>");
+MODULE_DESCRIPTION("IOV netlink");
+MODULE_LICENSE("GPL");
+
+/* IOVNL netlink attributes policy */
+static const struct nla_policy iovnl_rtnl_policy[IOV_ATTR_MAX + 1] = {
+	[IOV_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
+	[IOV_ATTR_VF_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
+	[IOV_ATTR_PORT_PROFILE] =  { .type = NLA_NUL_STRING, .len = 32 },
+	[IOV_ATTR_CLIENT_NAME] = { .type = NLA_NUL_STRING, .len = 32 },
+	[IOV_ATTR_HOST_UUID] = { .type = NLA_NUL_STRING, .len = 64 },
+	[IOV_ATTR_PORT_PROFILE_STATUS] = { .type = NLA_U8 },
+	[IOV_ATTR_MAC_ADDR] = { .len = 6 },
+	[IOV_ATTR_VLAN] = { .type = NLA_U16 },
+	[IOV_ATTR_STATUS] = { .type = NLA_U8 },
+};
+
+/* standard netlink reply call */
+static int iovnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
+	u32 seq, u16 flags)
+{
+	struct sk_buff *skb;
+	struct iovnlmsg *iov;
+	struct nlmsghdr *nlh;
+	int ret = -EINVAL;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ret;
+
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*iov), flags);
+
+	iov = NLMSG_DATA(nlh);
+	iov->family = AF_UNSPEC;
+	iov->cmd = cmd;
+	iov->pad = 0;
+
+	ret = nla_put_u8(skb, attr, value);
+	if (ret)
+		goto err;
+
+	/* end the message, assign the nlmsg_len. */
+	nlmsg_end(skb, nlh);
+	ret = rtnl_unicast(skb, &init_net, pid);
+	if (ret)
+		return -EINVAL;
+
+	return 0;
+nlmsg_failure:
+err:
+	kfree_skb(skb);
+	return ret;
+}
+
+static int iovnl_get_port_profile_status(struct net_device *dev,
+	struct net_device *vf_dev, u32 pid, u32 seq, u16 flags)
+{
+	int ret;
+
+	if (!dev->iovnl_ops->get_port_profile_status)
+		return -EINVAL;
+
+	ret = dev->iovnl_ops->get_port_profile_status(dev, vf_dev);
+
+	return  iovnl_reply(ret, RTM_GETIOV,
+		IOV_CMD_GET_PORT_PROFILE_STATUS, IOV_ATTR_PORT_PROFILE_STATUS,
+		pid, seq, flags);
+}
+
+
+static int iovnl_set_port_profile(struct net_device *dev,
+	struct net_device *vf_dev, struct nlattr **tb,
+	u32 pid, u32 seq, u16 flags)
+{
+	int i, ret;
+	char *port_profile = NULL;
+	u8 *mac_addr = NULL;
+	char *client_name = NULL;
+	char *host_uuid = NULL;
+
+	if (!tb[IOV_ATTR_PORT_PROFILE] || !dev->iovnl_ops->set_port_profile)
+		return -EINVAL;
+
+	for (i = 0; i <= IOV_ATTR_MAX; i++) {
+		if (!tb[i])
+			continue;
+		switch (tb[i]->nla_type) {
+		case IOV_ATTR_PORT_PROFILE:
+			port_profile = nla_data(tb[i]);
+			break;
+		case IOV_ATTR_MAC_ADDR:
+			mac_addr = nla_data(tb[i]);
+			break;
+		case IOV_ATTR_CLIENT_NAME:
+			client_name = nla_data(tb[i]);
+			break;
+		case IOV_ATTR_HOST_UUID:
+			host_uuid = nla_data(tb[i]);
+			break;
+		}
+	}
+
+	ret = dev->iovnl_ops->set_port_profile(dev, vf_dev,
+		port_profile, mac_addr, client_name, host_uuid);
+
+	return iovnl_reply(ret, RTM_SETIOV, IOV_CMD_SET_PORT_PROFILE,
+		IOV_ATTR_STATUS, pid, seq, flags);
+}
+
+static int iovnl_set_mac_vlan(struct net_device *dev,
+	struct net_device *vf_dev, struct nlattr **tb,
+	u32 pid, u32 seq, u16 flags)
+{
+	int i, ret;
+	u8 *mac_addr = NULL;
+	u16 vlan = 0;
+
+	if (!dev->iovnl_ops->set_mac_vlan)
+		return -EINVAL;
+
+	for (i = 0; i <= IOV_ATTR_MAX; i++) {
+		if (!tb[i])
+			continue;
+		switch (tb[i]->nla_type) {
+		case IOV_ATTR_MAC_ADDR:
+			mac_addr = nla_data(tb[i]);
+			break;
+		case IOV_ATTR_VLAN:
+			vlan = nla_get_u16(tb[i]);
+			break;
+		}
+	}
+
+	ret = dev->iovnl_ops->set_mac_vlan(dev, vf_dev,
+		mac_addr, vlan);
+
+	return iovnl_reply(ret, RTM_SETIOV, IOV_CMD_SET_MAC_VLAN,
+		IOV_ATTR_STATUS, pid, seq, flags);
+}
+
+static int iovnl_unset_port_profile(struct net_device *dev,
+	struct net_device *vf_dev, struct nlattr **tb,
+	u32 pid, u32 seq, u16 flags)
+{
+	int ret;
+
+	if (!dev->iovnl_ops->unset_port_profile)
+		return -EINVAL;
+
+	ret = dev->iovnl_ops->unset_port_profile(dev, vf_dev);
+
+	return iovnl_reply(ret, RTM_SETIOV, IOV_CMD_UNSET_PORT_PROFILE,
+		IOV_ATTR_STATUS, pid, seq, flags);
+}
+
+static int iovnl_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	struct net_device *vf_dev = NULL;
+	struct iovnlmsg  *iov = (struct iovnlmsg *)NLMSG_DATA(nlh);
+	struct nlattr *tb[IOV_ATTR_MAX + 1];
+	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
+	int ret;
+
+	if (!net_eq(net, &init_net))
+		return -EINVAL;
+
+	ret = nlmsg_parse(nlh, sizeof(*iov), tb, IOV_ATTR_MAX,
+		iovnl_rtnl_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[IOV_ATTR_IFNAME])
+		return -EINVAL;
+
+	dev = dev_get_by_name(&init_net, nla_data(tb[IOV_ATTR_IFNAME]));
+	if (!dev)
+		return -EINVAL;
+
+	if (tb[IOV_ATTR_VF_IFNAME])
+		vf_dev = dev_get_by_name(&init_net,
+			nla_data(tb[IOV_ATTR_VF_IFNAME]));
+
+	if (!dev->iovnl_ops)
+		goto errout;
+
+	switch (iov->cmd) {
+	case IOV_CMD_SET_PORT_PROFILE:
+		ret = iovnl_set_port_profile(dev, vf_dev,
+			tb, pid, nlh->nlmsg_seq, nlh->nlmsg_flags);
+		goto out;
+	case IOV_CMD_UNSET_PORT_PROFILE:
+		ret = iovnl_unset_port_profile(dev, vf_dev,
+			tb, pid, nlh->nlmsg_seq, nlh->nlmsg_flags);
+		goto out;
+	case IOV_CMD_GET_PORT_PROFILE_STATUS:
+		ret = iovnl_get_port_profile_status(dev, vf_dev,
+			pid, nlh->nlmsg_seq, nlh->nlmsg_flags);
+		goto out;
+	case IOV_CMD_SET_MAC_VLAN:
+		ret = iovnl_set_mac_vlan(dev, vf_dev,
+			tb, pid, nlh->nlmsg_seq, nlh->nlmsg_flags);
+		goto out;
+	default:
+		goto errout;
+	}
+errout:
+	ret = -EINVAL;
+out:
+	dev_put(dev);
+	if (vf_dev)
+		dev_put(vf_dev);
+
+	return ret;
+}
+
+static int __init iovnl_init(void)
+{
+	rtnl_register(PF_UNSPEC, RTM_GETIOV, iovnl_doit, NULL);
+	rtnl_register(PF_UNSPEC, RTM_SETIOV, iovnl_doit, NULL);
+
+	return 0;
+}
+module_init(iovnl_init);
+
+static void __exit iovnl_exit(void)
+{
+	rtnl_unregister(PF_UNSPEC, RTM_GETIOV);
+	rtnl_unregister(PF_UNSPEC, RTM_SETIOV);
+}
+module_exit(iovnl_exit);

