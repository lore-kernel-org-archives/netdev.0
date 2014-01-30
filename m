From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH] rtnetlink: return the newly created link in response to newlink
Date: Thu, 30 Jan 2014 14:05:44 +0100
Message-ID: <1391087144-24490-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Tom Gundersen <teg@jklm.no>,
	Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace needs to reliably know the ifindex of the netdevs it creates,
as we cannot rely on the ifname staying unchanged.

Earlier, a simlpe NLMSG_ERROR would be returned, but this returns the
corresponding RTM_NEWLINK on success instead.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: David S. Miller <davem@davemloft.net>
---
 net/core/rtnetlink.c | 100 ++++++++++++++++++++++++++-------------------------
 1 file changed, 52 insertions(+), 48 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index cf67144..31c1322 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1725,6 +1725,54 @@ static int rtnl_group_changelink(struct net *net, int group,
 	return 0;
 }
 
+static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ifinfomsg *ifm;
+	char ifname[IFNAMSIZ];
+	struct nlattr *tb[IFLA_MAX+1];
+	struct net_device *dev = NULL;
+	struct sk_buff *nskb;
+	int err;
+	u32 ext_filter_mask = 0;
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
+
+	if (tb[IFLA_EXT_MASK])
+		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index > 0)
+		dev = __dev_get_by_index(net, ifm->ifi_index);
+	else if (tb[IFLA_IFNAME])
+		dev = __dev_get_by_name(net, ifname);
+	else
+		return -EINVAL;
+
+	if (dev == NULL)
+		return -ENODEV;
+
+	nskb = nlmsg_new(if_nlmsg_size(dev, ext_filter_mask), GFP_KERNEL);
+	if (nskb == NULL)
+		return -ENOBUFS;
+
+	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
+			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in if_nlmsg_size */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(nskb);
+	} else
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
+
+	return err;
+}
+
 static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1871,63 +1919,19 @@ replay:
 			goto out;
 		}
 
+		ifm->ifi_index = dev->ifindex;
+
 		err = rtnl_configure_link(dev, ifm);
 		if (err < 0)
 			unregister_netdevice(dev);
+		else
+			rtnl_getlink(skb, nlh);
 out:
 		put_net(dest_net);
 		return err;
 	}
 }
 
-static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
-{
-	struct net *net = sock_net(skb->sk);
-	struct ifinfomsg *ifm;
-	char ifname[IFNAMSIZ];
-	struct nlattr *tb[IFLA_MAX+1];
-	struct net_device *dev = NULL;
-	struct sk_buff *nskb;
-	int err;
-	u32 ext_filter_mask = 0;
-
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[IFLA_IFNAME])
-		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
-
-	if (tb[IFLA_EXT_MASK])
-		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
-
-	ifm = nlmsg_data(nlh);
-	if (ifm->ifi_index > 0)
-		dev = __dev_get_by_index(net, ifm->ifi_index);
-	else if (tb[IFLA_IFNAME])
-		dev = __dev_get_by_name(net, ifname);
-	else
-		return -EINVAL;
-
-	if (dev == NULL)
-		return -ENODEV;
-
-	nskb = nlmsg_new(if_nlmsg_size(dev, ext_filter_mask), GFP_KERNEL);
-	if (nskb == NULL)
-		return -ENOBUFS;
-
-	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
-			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
-	if (err < 0) {
-		/* -EMSGSIZE implies BUG in if_nlmsg_size */
-		WARN_ON(err == -EMSGSIZE);
-		kfree_skb(nskb);
-	} else
-		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
-
-	return err;
-}
-
 static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-- 
1.8.5.3
