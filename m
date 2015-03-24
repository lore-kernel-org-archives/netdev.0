From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] net: allow to delete a whole device group
Date: Tue, 24 Mar 2015 11:53:31 -0700
Message-ID: <1427223211-5781-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36148 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbbCXSxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:53:50 -0400
Received: by pdbcz9 with SMTP id cz9so1882438pdb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 11:53:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With dev group, we can change a batch of net devices,
so we should allow to delete them together too.

Group 0 is not allowed to be deleted since it is
the default group.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/rtnetlink.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e769510..b96ac21 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1836,6 +1836,42 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
+static int rtnl_group_dellink(const struct net *net, int group)
+{
+	struct net_device *dev, *aux;
+	LIST_HEAD(list_kill);
+	bool found = false;
+
+	if (!group)
+		return -EPERM;
+
+	for_each_netdev(net, dev) {
+		if (dev->group == group) {
+			const struct rtnl_link_ops *ops;
+
+			found = true;
+			ops = dev->rtnl_link_ops;
+			if (!ops || !ops->dellink)
+				return -EOPNOTSUPP;
+		}
+	}
+
+	if (!found)
+		return -ENODEV;
+
+	for_each_netdev_safe(net, dev, aux) {
+		if (dev->group == group) {
+			const struct rtnl_link_ops *ops;
+
+			ops = dev->rtnl_link_ops;
+			ops->dellink(dev, &list_kill);
+		}
+	}
+	unregister_netdevice_many(&list_kill);
+
+	return 0;
+}
+
 static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1859,6 +1895,8 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		dev = __dev_get_by_index(net, ifm->ifi_index);
 	else if (tb[IFLA_IFNAME])
 		dev = __dev_get_by_name(net, ifname);
+	else if (tb[IFLA_GROUP])
+		return rtnl_group_dellink(net, nla_get_u32(tb[IFLA_GROUP]));
 	else
 		return -EINVAL;
 
-- 
1.8.3.1
