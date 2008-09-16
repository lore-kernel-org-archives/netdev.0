From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 06/14] Phonet: Netlink interface
Date: Tue, 16 Sep 2008 18:08:06 +0300
Message-ID: <1221577694-4513-6-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52817 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbYIPPI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:27 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF88JH031631
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:24 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides support for configuring Phonet addresses, notifying
Phonet configuration changes, and dumping the configuration.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |    1 +
 net/phonet/pn_netlink.c     |  240 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 243 insertions(+), 0 deletions(-)
 create mode 100644 net/phonet/pn_netlink.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index be02ee9..d62883c 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -68,4 +68,5 @@ struct phonet_protocol {
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
index 744b47f..12c72e1 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -210,6 +210,7 @@ static int __init phonet_init(void)
 	}
 
 	dev_add_pack(&phonet_packet_type);
+	phonet_netlink_register();
 	return 0;
 
 unregister:
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
new file mode 100644
index 0000000..121b62e
--- /dev/null
+++ b/net/phonet/pn_netlink.c
@@ -0,0 +1,240 @@
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
+static int fill_addr(struct sk_buff *skb, struct phonet_address *ifaddr,
+		     u32 pid, u32 seq, int event);
+
+static void rtmsg_notify(int event, struct phonet_address *pna)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+			nla_total_size(1), GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+	err = fill_addr(skb, pna, 0, 0, event);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	err = rtnl_notify(skb, dev_net(pna->pnd->netdev), 0,
+			  RTNLGRP_PHONET_IFADDR, NULL, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(dev_net(pna->pnd->netdev),
+				RTNLGRP_PHONET_IFADDR, err);
+}
+
+static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, void *attr)
+{
+	struct rtattr **rta = attr;
+	struct ifaddrmsg *ifm = NLMSG_DATA(nlm);
+	struct net_device *dev;
+	struct phonet_device *pnd;
+	struct phonet_address *pna;
+	uint8_t pnaddr;
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
+	if (ifm->ifa_prefixlen > 8)
+		return -EINVAL;
+
+	memcpy((void *)&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
+
+	spin_lock_bh(&pndevs.lock);
+	if (phonet_addr2addr(pnaddr, PN_FIND_EXACT)) {
+		spin_unlock_bh(&pndevs.lock);
+		return -EADDRINUSE;
+	}
+	pnd = __phonet_get_by_index(ifm->ifa_index);
+	if (pnd == NULL)
+		pnd = phonet_device_alloc(dev);
+	spin_unlock_bh(&pndevs.lock);
+	if (pnd == NULL)
+		return -ENOMEM;
+
+	pna = phonet_address_alloc();
+	if (pna == NULL) {
+		spin_lock_bh(&pndevs.lock);
+		if (list_empty(&pnd->own))
+			phonet_device_free(pnd);
+		spin_unlock_bh(&pndevs.lock);
+		return -ENOMEM;
+	}
+	/*
+	 * Now we have a Phonet device where the already allocated address
+	 * needs to be added to. Address manipulation is already protected
+	 * by rtnl_lock, so pndevs.lock isn't needed all the time.
+	 */
+	pna->pnd = pnd;
+	pna->addr = pnaddr;
+	pna->prefix = ifm->ifa_prefixlen;
+
+	spin_lock_bh(&pndevs.lock);
+	phonet_address_add(&pnd->own, pna);
+	spin_unlock_bh(&pndevs.lock);
+
+	rtmsg_notify(RTM_NEWADDR, pna);
+
+	return 0;
+}
+
+static int deladdr_doit(struct sk_buff *skb, struct nlmsghdr *nlm, void *attr)
+{
+	struct rtattr **rta = attr;
+	struct ifaddrmsg *ifm = NLMSG_DATA(nlm);
+	struct phonet_address *pna;
+	struct phonet_device *pnd = NULL;
+	int err;
+	uint8_t pnaddr;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	ASSERT_RTNL();
+
+	if (rta[IFA_LOCAL - 1] == NULL)
+		return -EINVAL;
+
+	memcpy((void *)&pnaddr, RTA_DATA(rta[IFA_LOCAL - 1]), 1);
+
+	spin_lock_bh(&pndevs.lock);
+	err = -ENODEV;
+	pnd = __phonet_get_by_index(ifm->ifa_index);
+	if (!pnd)
+		goto out;
+
+	pna = phonet_dev2addr(pnd, pnaddr, PN_FIND_EXACT);
+	if (!pna)
+		goto out;
+
+	phonet_address_free(pna);
+	if (list_empty(&pnd->own))
+		phonet_device_free(pnd);
+	spin_unlock_bh(&pndevs.lock);
+	rtmsg_notify(RTM_DELADDR, pna);
+	return 0;
+
+out:
+	spin_unlock_bh(&pndevs.lock);
+	return err;
+}
+
+static int fill_addr(struct sk_buff *skb, struct phonet_address *ifaddr,
+			u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr *nlh;
+	unsigned int orig_len = skb->len;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(struct ifaddrmsg));
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_PHONET;
+	ifm->ifa_prefixlen = ifaddr->prefix;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_HOST;
+	ifm->ifa_index = ifaddr->pnd->netdev->ifindex;
+	RTA_PUT(skb, IFA_LOCAL, 1, &ifaddr->addr);
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
+	struct list_head *ptr;
+	int dev_idx = 0, addr_idx = 0;
+	int dev_start_idx, addr_start_idx;
+
+	dev_start_idx = cb->args[0];
+	addr_start_idx = cb->args[1];
+
+	spin_lock_bh(&pndevs.lock);
+
+	for (ptr = pndevs.list.next; ptr != &pndevs.list;
+	     ptr = ptr->next, dev_idx++) {
+		struct list_head *ptr2;
+		struct phonet_device *pnd =
+			list_entry(ptr, struct phonet_device, list);
+
+		if (dev_idx < dev_start_idx)
+			continue;
+		else if (dev_idx > dev_start_idx)
+			addr_start_idx = 0;
+
+		addr_idx = 0;
+
+		for (ptr2 = pnd->own.next; ptr2 != &pnd->own;
+			ptr2 = ptr2->next, addr_idx++) {
+			struct phonet_address *pna =
+				list_entry(ptr2, struct phonet_address, list);
+
+			if (addr_idx < addr_start_idx)
+				continue;
+
+			if (fill_addr(skb, pna, NETLINK_CB(cb->skb).pid,
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

