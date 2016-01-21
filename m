From: Patrick Ruddy <pruddy@brocade.com>
Subject: [PATCH] Netlink messages for multicast HW addr programming
Date: Thu, 21 Jan 2016 11:47:54 +0000
Message-ID: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick Ruddy <pruddy@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:40429 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759369AbcAULsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 06:48:30 -0500
Received: from pps.filterd (m0048193.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u0LBC0uY018004
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 03:48:29 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 20gmypa1he-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 03:48:29 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RTM_NEWADDR and RTM_DELADDR netlink messages to indicate
interest in specific multicast hardware addresses. These messages
are sent when addressed are added or deleted from the appropriate
interface driver.

Signed-off-by: Patrick Ruddy <pruddy@brocade.com>

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index c0548d2..a0ebadd 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/netdevice.h>
+#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/export.h>
 #include <linux/list.h>
@@ -661,6 +662,62 @@ out:
 }
 EXPORT_SYMBOL(dev_mc_add_excl);
 
+static int fill_addr(struct sk_buff *skb, struct net_device *dev,
+		     const unsigned char *addr, int type)
+{
+	struct nlmsghdr *nlh;
+	struct ifaddrmsg *ifm;
+
+	nlh = nlmsg_put(skb, 0, 0, type, sizeof(*ifm), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	ifm = nlmsg_data(nlh);
+	ifm->ifa_family = AF_UNSPEC;
+	ifm->ifa_prefixlen = 0;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_LINK;
+	ifm->ifa_index = dev->ifindex;
+	if (nla_put(skb, IFA_ADDRESS, dev->addr_len, addr))
+		goto nla_put_failure;
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static inline size_t addr_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
+		+ nla_total_size(MAX_ADDR_LEN);
+}
+
+static void mc_addr_notify(struct net_device *dev, const unsigned char * addr,
+			   int type)
+{
+	struct net *net = dev_net(dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(addr_nlmsg_size(), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = fill_addr(skb, dev, addr, type);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+}
+
 static int __dev_mc_add(struct net_device *dev, const unsigned char *addr,
 			bool global)
 {
@@ -669,8 +726,10 @@ static int __dev_mc_add(struct net_device *dev, const unsigned char *addr,
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
 			       NETDEV_HW_ADDR_T_MULTICAST, global, false, 0);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		mc_addr_notify(dev, addr, RTM_NEWADDR);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
@@ -709,8 +768,10 @@ static int __dev_mc_del(struct net_device *dev, const unsigned char *addr,
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_del_ex(&dev->mc, addr, dev->addr_len,
 			       NETDEV_HW_ADDR_T_MULTICAST, global, false);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		mc_addr_notify(dev, addr, RTM_DELADDR);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
-- 
2.1.4
