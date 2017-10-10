From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net-next] rtnetlink: bridge: use ext_ack instead of printk
Date: Tue, 10 Oct 2017 13:32:36 +0200
Message-ID: <20171010113236.8889-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:32996 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751826AbdJJLcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 07:32:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can now piggyback error strings to userspace via extended acks
rather than using printk.

Before:
bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
RTNETLINK answers: Invalid argument

After:
bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
Error: RTM_NEWNEIGH with invalid vlan id.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 v2: forgot to refresh patch, v1 did not even compile.

 net/core/rtnetlink.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e84d108cfee4..19ea53a5210f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3066,21 +3066,22 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_add);
 
-static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
+static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid,
+			 struct netlink_ext_ack *exta)
 {
 	u16 vid = 0;
 
 	if (vlan_attr) {
 		if (nla_len(vlan_attr) != sizeof(u16)) {
-			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan\n");
+			NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with invalid vlan");
 			return -EINVAL;
 		}
 
 		vid = nla_get_u16(vlan_attr);
 
 		if (!vid || vid >= VLAN_VID_MASK) {
-			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan id %d\n",
-				vid);
+			NL_SET_ERR_MSG(exta,
+				       "RTM_NEWNEIGH with invalid vlan id");
 			return -EINVAL;
 		}
 	}
@@ -3089,7 +3090,7 @@ static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
 }
 
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
-			struct netlink_ext_ack *extack)
+			struct netlink_ext_ack *exta)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -3099,30 +3100,30 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u16 vid;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, extack);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, exta);
 	if (err < 0)
 		return err;
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ifindex\n");
+		NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with invalid ifindex");
 		return -EINVAL;
 	}
 
 	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 	if (dev == NULL) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with unknown ifindex\n");
+		NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with unknown ifindex");
 		return -ENODEV;
 	}
 
 	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid address\n");
+		NL_SET_ERR_MSG(exta, "RTM_NEWNEIGH with invalid address");
 		return -EINVAL;
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
-	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid, exta);
 	if (err)
 		return err;
 
@@ -3209,24 +3210,24 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_DELNEIGH with invalid ifindex");
 		return -EINVAL;
 	}
 
 	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 	if (dev == NULL) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_DELNEIGH with unknown ifindex");
 		return -ENODEV;
 	}
 
 	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid address\n");
+		NL_SET_ERR_MSG(extack, "RTM_DELNEIGH with invalid address");
 		return -EINVAL;
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
-	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid, extack);
 	if (err)
 		return err;
 
@@ -3666,7 +3667,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev) {
-		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
 		return -ENODEV;
 	}
 
@@ -3741,7 +3742,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev) {
-		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
 		return -ENODEV;
 	}
 
-- 
2.13.6
