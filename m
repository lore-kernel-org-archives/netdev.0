From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] netconf: add the handler to dump entries
Date: Wed,  6 Mar 2013 10:42:06 +0100
Message-ID: <1362562926-4181-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52083 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683Ab3CFJ5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 04:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's useful to be able to get the initial state of all entries. The patch adds
the support for IPv4 and IPv6.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c  | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/addrconf.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 138 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f678507..af57bba 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1791,6 +1791,74 @@ errout:
 	return err;
 }
 
+static int inet_netconf_dump_devconf(struct sk_buff *skb,
+				     struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	int h, s_h;
+	int idx, s_idx;
+	struct net_device *dev;
+	struct in_device *in_dev;
+	struct hlist_head *head;
+
+	s_h = cb->args[0];
+	s_idx = idx = cb->args[1];
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			in_dev = __in_dev_get_rcu(dev);
+			if (!in_dev)
+				goto cont;
+
+			if (inet_netconf_fill_devconf(skb, dev->ifindex,
+						      &in_dev->cnf,
+						      NETLINK_CB(cb->skb).portid,
+						      cb->nlh->nlmsg_seq,
+						      RTM_NEWNETCONF,
+						      NLM_F_MULTI,
+						      -1) <= 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+cont:
+			idx++;
+		}
+		rcu_read_unlock();
+	}
+	if (h == NETDEV_HASHENTRIES) {
+		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
+					      net->ipv4.devconf_all,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWNETCONF, NLM_F_MULTI,
+					      -1) <= 0)
+			goto done;
+		else
+			h++;
+	}
+	if (h == NETDEV_HASHENTRIES + 1) {
+		if (inet_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
+					      net->ipv4.devconf_dflt,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWNETCONF, NLM_F_MULTI,
+					      -1) <= 0)
+			goto done;
+		else
+			h++;
+	}
+done:
+	cb->args[0] = h;
+	cb->args[1] = idx;
+
+	return skb->len;
+}
+
 #ifdef CONFIG_SYSCTL
 
 static void devinet_copy_dflt_conf(struct net *net, int i)
@@ -2195,6 +2263,6 @@ void __init devinet_init(void)
 	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL, NULL);
 	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, NULL);
 	rtnl_register(PF_INET, RTM_GETNETCONF, inet_netconf_get_devconf,
-		      NULL, NULL);
+		      inet_netconf_dump_devconf, NULL);
 }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2c7e61..fa36a67 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -605,6 +605,74 @@ errout:
 	return err;
 }
 
+static int inet6_netconf_dump_devconf(struct sk_buff *skb,
+				      struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	int h, s_h;
+	int idx, s_idx;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct hlist_head *head;
+
+	s_h = cb->args[0];
+	s_idx = idx = cb->args[1];
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			idev = __in6_dev_get(dev);
+			if (!idev)
+				goto cont;
+
+			if (inet6_netconf_fill_devconf(skb, dev->ifindex,
+						       &idev->cnf,
+						       NETLINK_CB(cb->skb).portid,
+						       cb->nlh->nlmsg_seq,
+						       RTM_NEWNETCONF,
+						       NLM_F_MULTI,
+						       -1) <= 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+cont:
+			idx++;
+		}
+		rcu_read_unlock();
+	}
+	if (h == NETDEV_HASHENTRIES) {
+		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_ALL,
+					       net->ipv6.devconf_all,
+					       NETLINK_CB(cb->skb).portid,
+					       cb->nlh->nlmsg_seq,
+					       RTM_NEWNETCONF, NLM_F_MULTI,
+					       -1) <= 0)
+			goto done;
+		else
+			h++;
+	}
+	if (h == NETDEV_HASHENTRIES + 1) {
+		if (inet6_netconf_fill_devconf(skb, NETCONFA_IFINDEX_DEFAULT,
+					       net->ipv6.devconf_dflt,
+					       NETLINK_CB(cb->skb).portid,
+					       cb->nlh->nlmsg_seq,
+					       RTM_NEWNETCONF, NLM_F_MULTI,
+					       -1) <= 0)
+			goto done;
+		else
+			h++;
+	}
+done:
+	cb->args[0] = h;
+	cb->args[1] = idx;
+
+	return skb->len;
+}
+
 #ifdef CONFIG_SYSCTL
 static void dev_forward_change(struct inet6_dev *idev)
 {
@@ -4940,7 +5008,7 @@ int __init addrconf_init(void)
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL,
 			inet6_dump_ifacaddr, NULL);
 	__rtnl_register(PF_INET6, RTM_GETNETCONF, inet6_netconf_get_devconf,
-			NULL, NULL);
+			inet6_netconf_dump_devconf, NULL);
 
 	ipv6_addr_label_rtnl_register();
 
-- 
1.8.0.1
