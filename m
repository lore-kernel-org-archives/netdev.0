From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 05/11] Phonet: Netlink interface
Date: Mon, 22 Sep 2008 18:47:19 +0300
Message-ID: <1222098445-26175-5-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53001 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbYIVPro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:44 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlZFX027641
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:47:41 +0300
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides support for configuring Phonet addresses, notifying
Phonet configuration changes, and dumping the configuration.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |    1 +
 net/phonet/pn_netlink.c     |  186 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 189 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/pn_netlink.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index c53f2ab..8b77794 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -71,4 +71,5 @@ struct phonet_protocol {
 int phonet_proto_register(int protocol, struct phonet_protocol *pp);
 void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
 
+void phonet_netlink_register(void);
 #endif
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index 980a386..4143c3e 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -2,4 +2,5 @@ obj-$(CONFIG_PHONET) += phonet.o
 
 phonet-objs := \
 	pn_dev.o \
+	pn_netlink.o \
 	af_phonet.o
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index a8ba6f1..5c729ba 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -203,6 +203,7 @@ static int __init phonet_init(void)
 
 	phonet_device_init();
 	dev_add_pack(&phonet_packet_type);
+	phonet_netlink_register();
 	return 0;
 }
 
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
new file mode 100644
index 0000000..b1ea19a
--- /dev/null
+++ b/net/phonet/pn_netlink.c
@@ -0,0 +1,186 @@
+/*
+ * File: pn_netlink.c
+ *
+ * Phonet netlink interface
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/netlink.h>
+#include <linux/phonet.h>
+#include <net/sock.h>
+#include <net/phonet/pn_dev.h>
+
+static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
+		     u32 pid, u32 seq, int event);
+
+static void rtmsg_notify(int event, struct net_device *dev, u8 addr)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+			nla_total_size(1), GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+	err = fill_addr(skb, dev, addr, 0, 0, event);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	err = rtnl_notify(skb, dev_net(dev), 0,
+			  RTNLGRP_PHONET_IFADDR, NULL, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
+}
+
+static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, void *attr)
+{
+	struct rtattr **rta = attr;
+	struct ifaddrmsg *ifm = NLMSG_DATA(nlm);
+	struct net_device *dev;
+	int err;
+	u8 pnaddr;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	ASSERT_RTNL();
+
+	if (rta[IFA_LOCAL - 1] == NULL)
+		return -EINVAL;
+
+	dev = __dev_get_by_index(&init_net, ifm->ifa_index);
+	if (dev == NULL)
+		return -ENODEV;
+
+	if (ifm->ifa_prefixlen > 0)
+		return -EINVAL;
+
+	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
+
+	err = phonet_address_add(dev, pnaddr);
+	if (!err)
+		rtmsg_notify(RTM_NEWADDR, dev, pnaddr);
+	return err;
+}
+
+static int deladdr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, void *attr)
+{
+	struct rtattr **rta = attr;
+	struct ifaddrmsg *ifm = NLMSG_DATA(nlm);
+	struct net_device *dev;
+	int err;
+	u8 pnaddr;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	ASSERT_RTNL();
+
+	if (rta[IFA_LOCAL - 1] == NULL)
+		return -EINVAL;
+
+	dev = __dev_get_by_index(&init_net, ifm->ifa_index);
+	if (dev == NULL)
+		return -ENODEV;
+
+	if (ifm->ifa_prefixlen > 0)
+		return -EADDRNOTAVAIL;
+
+	memcpy(&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
+
+	err = phonet_address_del(dev, pnaddr);
+	if (!err)
+		rtmsg_notify(RTM_DELADDR, dev, pnaddr);
+	return err;
+}
+
+static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
+			u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr *nlh;
+	unsigned int orig_len = skb->len;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(struct ifaddrmsg));
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_PHONET;
+	ifm->ifa_prefixlen = 0;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_HOST;
+	ifm->ifa_index = dev->ifindex;
+	RTA_PUT(skb, IFA_LOCAL, 1, &addr);
+	nlh->nlmsg_len = skb->len - orig_len;
+
+	return 0;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, orig_len);
+
+	return -1;
+}
+
+static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct phonet_device *pnd;
+	int dev_idx = 0, dev_start_idx = cb->args[0];
+	int addr_idx = 0, addr_start_idx = cb->args[1];
+
+	spin_lock_bh(&pndevs.lock);
+	list_for_each_entry(pnd, &pndevs.list, list) {
+		u8 addr;
+
+		if (dev_idx > dev_start_idx)
+			addr_start_idx = 0;
+		if (dev_idx++ < dev_start_idx)
+			continue;
+
+		addr_idx = 0;
+		for (addr = find_first_bit(pnd->addrs, 64); addr < 64;
+			addr = find_next_bit(pnd->addrs, 64, 1+addr)) {
+			if (addr_idx++ < addr_start_idx)
+				continue;
+
+			if (fill_addr(skb, pnd->netdev, addr << 2,
+					 NETLINK_CB(cb->skb).pid,
+					cb->nlh->nlmsg_seq, RTM_NEWADDR))
+				goto out;
+		}
+	}
+
+out:
+	spin_unlock_bh(&pndevs.lock);
+	cb->args[0] = dev_idx;
+	cb->args[1] = addr_idx;
+
+	return skb->len;
+}
+
+void __init phonet_netlink_register(void)
+{
+	rtnl_register(PF_PHONET, RTM_NEWADDR, newaddr_doit, NULL);
+	rtnl_register(PF_PHONET, RTM_DELADDR, deladdr_doit, NULL);
+	rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
+}
-- 
1.5.4.3

