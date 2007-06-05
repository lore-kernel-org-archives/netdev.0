From: Patrick McHardy <kaber@trash.net>
Subject: [RFC RTNETLINK 03/09]: Split up rtnl_setlink
Date: Tue,  5 Jun 2007 16:12:55 +0200 (MEST)
Message-ID: <20070605141255.15650.74711.sendpatchset@localhost.localdomain>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Cc: socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru,
	Patrick McHardy <kaber@trash.net>, ebiederm@xmission.com,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763203AbXFEOM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:12:57 -0400
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: Split up rtnl_setlink

Split up rtnl_setlink into a function performing validation and a function
performing the actual changes. This allows to share the modifcation logic
with rtnl_newlink, which is introduced by the next patch.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 40b0b8787c1057d055baa6e3d11ff6db7783c982
tree 625d2bb4401e72882e6e5907d4aded9d2dcb416e
parent 72104442408666a0ff9395a5c62a23e96a3845ef
author Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 23:28:24 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 23:28:24 +0200

 net/core/rtnetlink.c |  105 +++++++++++++++++++++++++++-----------------------
 1 files changed, 57 insertions(+), 48 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 02e8bf0..25ca219 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -561,44 +561,11 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
 };
 
-static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
+		      struct nlattr **tb, char *ifname)
 {
-	struct ifinfomsg *ifm;
-	struct net_device *dev;
-	int err, send_addr_notify = 0, modified = 0;
-	struct nlattr *tb[IFLA_MAX+1];
-	char ifname[IFNAMSIZ];
-
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
-	if (err < 0)
-		goto errout;
-
-	if (tb[IFLA_IFNAME])
-		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
-	else
-		ifname[0] = '\0';
-
-	err = -EINVAL;
-	ifm = nlmsg_data(nlh);
-	if (ifm->ifi_index > 0)
-		dev = dev_get_by_index(ifm->ifi_index);
-	else if (tb[IFLA_IFNAME])
-		dev = dev_get_by_name(ifname);
-	else
-		goto errout;
-
-	if (dev == NULL) {
-		err = -ENODEV;
-		goto errout;
-	}
-
-	if (tb[IFLA_ADDRESS] &&
-	    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
-		goto errout_dev;
-
-	if (tb[IFLA_BROADCAST] &&
-	    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
-		goto errout_dev;
+	int modified = 0, send_addr_notify = 0;
+	int err;
 
 	if (tb[IFLA_MAP]) {
 		struct rtnl_link_ifmap *u_map;
@@ -606,12 +573,12 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 		if (!dev->set_config) {
 			err = -EOPNOTSUPP;
-			goto errout_dev;
+			goto errout;
 		}
 
 		if (!netif_device_present(dev)) {
 			err = -ENODEV;
-			goto errout_dev;
+			goto errout;
 		}
 
 		u_map = nla_data(tb[IFLA_MAP]);
@@ -624,7 +591,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 		err = dev->set_config(dev, &k_map);
 		if (err < 0)
-			goto errout_dev;
+			goto errout;
 
 		modified = 1;
 	}
@@ -635,19 +602,19 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 		if (!dev->set_mac_address) {
 			err = -EOPNOTSUPP;
-			goto errout_dev;
+			goto errout;
 		}
 
 		if (!netif_device_present(dev)) {
 			err = -ENODEV;
-			goto errout_dev;
+			goto errout;
 		}
 
 		len = sizeof(sa_family_t) + dev->addr_len;
 		sa = kmalloc(len, GFP_KERNEL);
 		if (!sa) {
 			err = -ENOMEM;
-			goto errout_dev;
+			goto errout;
 		}
 		sa->sa_family = dev->type;
 		memcpy(sa->sa_data, nla_data(tb[IFLA_ADDRESS]),
@@ -655,7 +622,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		err = dev->set_mac_address(dev, sa);
 		kfree(sa);
 		if (err)
-			goto errout_dev;
+			goto errout;
 		send_addr_notify = 1;
 		modified = 1;
 	}
@@ -663,7 +630,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (tb[IFLA_MTU]) {
 		err = dev_set_mtu(dev, nla_get_u32(tb[IFLA_MTU]));
 		if (err < 0)
-			goto errout_dev;
+			goto errout;
 		modified = 1;
 	}
 
@@ -675,7 +642,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (ifm->ifi_index > 0 && ifname[0]) {
 		err = dev_change_name(dev, ifname);
 		if (err < 0)
-			goto errout_dev;
+			goto errout;
 		modified = 1;
 	}
 
@@ -684,7 +651,6 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		send_addr_notify = 1;
 	}
 
-
 	if (ifm->ifi_flags || ifm->ifi_change) {
 		unsigned int flags = ifm->ifi_flags;
 
@@ -712,7 +678,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	err = 0;
 
-errout_dev:
+errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "
 		       "some changes comitted already. Interface %s may "
@@ -721,7 +687,50 @@ errout_dev:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	return err;
+}
 
+static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct ifinfomsg *ifm;
+	struct net_device *dev;
+	int err;
+	struct nlattr *tb[IFLA_MAX+1];
+	char ifname[IFNAMSIZ];
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		goto errout;
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
+	else
+		ifname[0] = '\0';
+
+	err = -EINVAL;
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = dev_get_by_index(ifm->ifi_index);
+	else if (tb[IFLA_IFNAME])
+		dev = dev_get_by_name(ifname);
+	else
+		goto errout;
+
+	if (dev == NULL) {
+		err = -ENODEV;
+		goto errout;
+	}
+
+	if (tb[IFLA_ADDRESS] &&
+	    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
+		goto errout_dev;
+
+	if (tb[IFLA_BROADCAST] &&
+	    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
+		goto errout_dev;
+
+	err = do_setlink(dev, ifm, tb, ifname);
+errout_dev:
 	dev_put(dev);
 errout:
 	return err;
