From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: ipv6: Address selection needs to consider L3 domains
Date: Thu, 16 Jun 2016 16:24:26 -0700
Message-ID: <1466119466-3144-4-git-send-email-dsa@cumulusnetworks.com>
References: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32842 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbcFPXYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:24:37 -0400
Received: by mail-pa0-f47.google.com with SMTP id b13so22328810pat.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 16:24:37 -0700 (PDT)
In-Reply-To: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 version of 3f2fb9a834cb ("net: l3mdev: address selection should only
consider devices in L3 domain") and the follow up commit, a17b693cdd876
("net: l3mdev: prefer VRF master for source address selection").

That is, if outbound device is given then the address preference order
is an address from that device, an address from the master device if it
is enslaved, and then an address from a device in the same L3 domain.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 31 +++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 818fd4f100fc..e90095091aa0 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -79,6 +79,31 @@ static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
 	return rc;
 }
 
+static inline
+const struct net_device *l3mdev_master_dev_rcu(const struct net_device *_dev)
+{
+	/* netdev_master_upper_dev_get_rcu calls
+	 * list_first_or_null_rcu to walk the upper dev list.
+	 * list_first_or_null_rcu does not handle a const arg. We aren't
+	 * making changes, just want the master device from that list so
+	 * typecast to remove the const
+	 */
+	struct net_device *dev = (struct net_device *)_dev;
+	const struct net_device *master;
+
+	if (!dev)
+		return NULL;
+
+	if (netif_is_l3_master(dev))
+		master = dev;
+	else if (netif_is_l3_slave(dev))
+		master = netdev_master_upper_dev_get_rcu(dev);
+	else
+		master = NULL;
+
+	return master;
+}
+
 /* get index of an interface to use for FIB lookups. For devices
  * enslaved to an L3 master device FIB lookups are based on the
  * master index
@@ -190,6 +215,12 @@ static inline int l3mdev_master_ifindex_by_index(struct net *net, int ifindex)
 	return 0;
 }
 
+static inline
+const struct net_device *l3mdev_master_dev_rcu(const struct net_device *dev)
+{
+	return NULL;
+}
+
 static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
 {
 	return dev ? dev->ifindex : 0;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c8fc3f96b11..a1f6b7b31531 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1524,6 +1524,28 @@ static int __ipv6_dev_get_saddr(struct net *net,
 	return hiscore_idx;
 }
 
+static int ipv6_get_saddr_master(struct net *net,
+				 const struct net_device *dst_dev,
+				 const struct net_device *master,
+				 struct ipv6_saddr_dst *dst,
+				 struct ipv6_saddr_score *scores,
+				 int hiscore_idx)
+{
+	struct inet6_dev *idev;
+
+	idev = __in6_dev_get(dst_dev);
+	if (idev)
+		hiscore_idx = __ipv6_dev_get_saddr(net, dst, idev,
+						   scores, hiscore_idx);
+
+	idev = __in6_dev_get(master);
+	if (idev)
+		hiscore_idx = __ipv6_dev_get_saddr(net, dst, idev,
+						   scores, hiscore_idx);
+
+	return hiscore_idx;
+}
+
 int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
@@ -1577,13 +1599,39 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		if (idev)
 			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, idev, scores, hiscore_idx);
 	} else {
+		const struct net_device *master;
+		int master_idx = 0;
+
+		/* if dst_dev exists and is enslaved to an L3 device, then
+		 * prefer addresses from dst_dev and then the master over
+		 * any other enslaved devices in the L3 domain.
+		 */
+		master = l3mdev_master_dev_rcu(dst_dev);
+		if (master) {
+			master_idx = master->ifindex;
+
+			hiscore_idx = ipv6_get_saddr_master(net, dst_dev,
+							    master, &dst,
+							    scores, hiscore_idx);
+
+			if (scores[hiscore_idx].ifa)
+				goto out;
+		}
+
 		for_each_netdev_rcu(net, dev) {
+			/* only consider addresses on devices in the
+			 * same L3 domain
+			 */
+			if (l3mdev_master_ifindex_rcu(dev) != master_idx)
+				continue;
 			idev = __in6_dev_get(dev);
 			if (!idev)
 				continue;
 			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, idev, scores, hiscore_idx);
 		}
 	}
+
+out:
 	rcu_read_unlock();
 
 	hiscore = &scores[hiscore_idx];
-- 
2.1.4
