From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v3 net-next] rtnetlink: bridge: use ext_ack instead of printk
Date: Tue, 10 Oct 2017 16:44:27 +0200
Message-ID: <20171010144427.8341-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, David Ahern <dsahern@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34238 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751384AbdJJOoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can now piggyback error strings to userspace via extended acks
rather than using printk.

Before:
bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
RTNETLINK answers: Invalid argument

After:
bridge fdb add 01:02:03:04:05:06 dev br0 vlan 4095
Error: invalid vlan id.

v3: drop 'RTM_' prefixes, suggested by David Ahern, they
are not useful, the add/del in bridge command line is enough.

Also reword error in response to malformed/bad vlan id attribute
size.

Cc: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e84d108cfee4..af2dea45df33 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3066,21 +3066,21 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_add);
 
-static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
+static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid,
+			 struct netlink_ext_ack *extack)
 {
 	u16 vid = 0;
 
 	if (vlan_attr) {
 		if (nla_len(vlan_attr) != sizeof(u16)) {
-			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan\n");
+			NL_SET_ERR_MSG(extack, "invalid vlan attribute size");
 			return -EINVAL;
 		}
 
 		vid = nla_get_u16(vlan_attr);
 
 		if (!vid || vid >= VLAN_VID_MASK) {
-			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan id %d\n",
-				vid);
+			NL_SET_ERR_MSG(extack, "invalid vlan id");
 			return -EINVAL;
 		}
 	}
@@ -3105,24 +3105,24 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ifindex\n");
+		NL_SET_ERR_MSG(extack, "invalid ifindex");
 		return -EINVAL;
 	}
 
 	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 	if (dev == NULL) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "unknown ifindex");
 		return -ENODEV;
 	}
 
 	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid address\n");
+		NL_SET_ERR_MSG(extack, "invalid address");
 		return -EINVAL;
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
-	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid, extack);
 	if (err)
 		return err;
 
@@ -3209,24 +3209,24 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ifindex\n");
+		NL_SET_ERR_MSG(extack, "invalid ifindex");
 		return -EINVAL;
 	}
 
 	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
 	if (dev == NULL) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "unknown ifindex");
 		return -ENODEV;
 	}
 
 	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid address\n");
+		NL_SET_ERR_MSG(extack, "invalid address");
 		return -EINVAL;
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
-	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid, extack);
 	if (err)
 		return err;
 
@@ -3666,7 +3666,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev) {
-		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
 		return -ENODEV;
 	}
 
@@ -3741,7 +3741,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev) {
-		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
+		NL_SET_ERR_MSG(extack, "RTM_SETLINK with unknown ifindex");
 		return -ENODEV;
 	}
 
-- 
2.13.6
