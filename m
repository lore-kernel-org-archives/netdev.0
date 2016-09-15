From: Patrick Ruddy <pruddy@brocade.com>
Subject: [net-next PATCH] net: netlink messages for HW addr programming
Date: Thu, 15 Sep 2016 17:48:02 +0100
Message-ID: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jiri@resnulli.us>,
        <alexander.h.duyck@intel.com>, <stephen@networkplumber.org>,
        <lboccass@brocade.com>, <sven@brocade.com>,
        Patrick Ruddy <pruddy@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:43538 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750731AbcIOQtj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 12:49:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add RTM_NEWADDR and RTM_DELADDR netlink messages with family
AF_UNSPEC to indicate interest in specific unicast and multicast
hardware addresses. These messages are sent when addresses are
added or deleted from the appropriate interface driver.
Added AF_UNSPEC GETADDR function to allow the netlink notifications
to be replayed to avoid loss of state due to application start
ordering or restart.

Signed-off-by: Patrick Ruddy <pruddy@brocade.com>
---
 include/linux/netdevice.h |   1 +
 net/core/dev_addr_lists.c | 157 ++++++++++++++++++++++++++++++++++++++++++++--
 net/core/rtnetlink.c      |   8 ++-
 3 files changed, 161 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2095b6a..2029618 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3751,6 +3751,7 @@ int dev_mc_sync_multiple(struct net_device *to, struct net_device *from);
 void dev_mc_unsync(struct net_device *to, struct net_device *from);
 void dev_mc_flush(struct net_device *dev);
 void dev_mc_init(struct net_device *dev);
+int unspec_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb);
 
 /**
  *  __dev_mc_sync - Synchonize device's multicast list
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index c0548d2..70343e6 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -12,9 +12,17 @@
  */
 
 #include <linux/netdevice.h>
+#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/export.h>
 #include <linux/list.h>
+#include <net/sock.h>
+
+enum unspec_addr_idx {
+	UNSPEC_UCAST = 0,
+	UNSPEC_MCAST,
+	UNSPEC_MAX
+};
 
 /*
  * General list handling functions
@@ -477,6 +485,139 @@ out:
 }
 EXPORT_SYMBOL(dev_uc_add_excl);
 
+static int fill_addr(struct sk_buff *skb, struct net_device *dev,
+		     const unsigned char *addr, u32 seq, int type,
+		     int addr_type, int ifa_flags, unsigned int flags)
+{
+	struct nlmsghdr *nlh;
+	struct ifaddrmsg *ifm;
+
+	nlh = nlmsg_put(skb, 0, seq, type, sizeof(*ifm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ifm = nlmsg_data(nlh);
+	ifm->ifa_family = AF_UNSPEC;
+	ifm->ifa_prefixlen = 0;
+	ifm->ifa_flags = ifa_flags;
+	ifm->ifa_scope = RT_SCOPE_LINK;
+	ifm->ifa_index = dev->ifindex;
+	if (nla_put(skb, addr_type, dev->addr_len, addr))
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
+static void addr_notify(struct net_device *dev, const unsigned char *addr,
+			int type, int addr_type)
+{
+	struct net *net = dev_net(dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(addr_nlmsg_size(), GFP_ATOMIC);
+	if (!skb)
+		goto errout;
+
+	err = fill_addr(skb, dev, addr, 0, type, addr_type, IFA_F_SECONDARY,
+			0);
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
+int unspec_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	struct hlist_head *head;
+	struct netdev_hw_addr_list *list;
+	struct netdev_hw_addr *ha;
+	int h, s_h;
+	int idx = 0, s_idx;
+	int mac_idx = 0, s_mac_idx;
+	enum unspec_addr_idx addr_idx = 0, s_addr_idx;
+	int err = 0;
+
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+	s_addr_idx = cb->args[2];
+	s_mac_idx = cb->args[3];
+
+	rcu_read_lock();
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		cb->seq = atomic_read(&net->ipv4.dev_addr_genid) ^
+			  net->dev_base_seq;
+		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (h > s_h || idx > s_idx)
+				s_mac_idx = 0;
+			for (addr_idx = 0; addr_idx < UNSPEC_MAX;
+			     addr_idx++, s_addr_idx = 0) {
+				if (addr_idx < s_addr_idx)
+					continue;
+				list = (addr_idx == UNSPEC_UCAST) ? &dev->uc :
+					&dev->mc;
+				if (netdev_hw_addr_list_empty(list))
+					continue;
+				mac_idx = 0;
+				list_for_each_entry(ha, &list->list, list) {
+					if (mac_idx < s_mac_idx) {
+						mac_idx++;
+						continue;
+					}
+					err = fill_addr(skb, dev, ha->addr,
+							cb->nlh->nlmsg_seq,
+							RTM_NEWADDR,
+							(addr_idx ==
+							 UNSPEC_UCAST) ?
+							IFA_ADDRESS :
+							IFA_MULTICAST,
+							IFA_F_SECONDARY,
+							NLM_F_MULTI);
+					if (err < 0)
+						goto done;
+					nl_dump_check_consistent(cb,
+								 nlmsg_hdr(skb)
+								 );
+					mac_idx++;
+				}
+				s_mac_idx = 0;
+			}
+cont:
+			idx++;
+		}
+	}
+done:
+	rcu_read_unlock();
+	cb->args[0] = h;
+	cb->args[1] = idx;
+	cb->args[2] = addr_idx;
+	cb->args[3] = mac_idx;
+
+	return skb->len;
+}
+
 /**
  *	dev_uc_add - Add a secondary unicast address
  *	@dev: device
@@ -492,8 +633,10 @@ int dev_uc_add(struct net_device *dev, const unsigned char *addr)
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_add(&dev->uc, addr, dev->addr_len,
 			    NETDEV_HW_ADDR_T_UNICAST);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		addr_notify(dev, addr, RTM_NEWADDR, IFA_ADDRESS);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
@@ -514,8 +657,10 @@ int dev_uc_del(struct net_device *dev, const unsigned char *addr)
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_del(&dev->uc, addr, dev->addr_len,
 			    NETDEV_HW_ADDR_T_UNICAST);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		addr_notify(dev, addr, RTM_DELADDR, IFA_ADDRESS);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
@@ -669,8 +814,10 @@ static int __dev_mc_add(struct net_device *dev, const unsigned char *addr,
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
 			       NETDEV_HW_ADDR_T_MULTICAST, global, false, 0);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		addr_notify(dev, addr, RTM_NEWADDR, IFA_MULTICAST);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
@@ -709,8 +856,10 @@ static int __dev_mc_del(struct net_device *dev, const unsigned char *addr,
 	netif_addr_lock_bh(dev);
 	err = __hw_addr_del_ex(&dev->mc, addr, dev->addr_len,
 			       NETDEV_HW_ADDR_T_MULTICAST, global, false);
-	if (!err)
+	if (!err) {
 		__dev_set_rx_mode(dev);
+		addr_notify(dev, addr, RTM_DELADDR, IFA_MULTICAST);
+	}
 	netif_addr_unlock_bh(dev);
 	return err;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 937e459..e6292bb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2686,8 +2686,14 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx;
 	int s_idx = cb->family;
 
-	if (s_idx == 0)
+	if (s_idx == 0) {
+		if (unspec_dump_ifaddr(skb, cb))
+			return skb->len;
+		memset(&cb->args[0], 0, sizeof(cb->args));
+		cb->prev_seq = 0;
+		cb->seq = 0;
 		s_idx = 1;
+	}
 	for (idx = 1; idx <= RTNL_FAMILY_MAX; idx++) {
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
 		if (idx < s_idx || idx == PF_PACKET)
-- 
2.1.4
