From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v2] rtnetlink: catch -EOPNOTSUPP errors from ndo_bridge_getlink
Date: Tue, 15 Sep 2015 14:44:29 -0700
Message-ID: <1442353469-4861-1-git-send-email-roopa@cumulusnetworks.com>
Cc: aderumier@odiso.com, sfeldma@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36177 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbbIOVod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 17:44:33 -0400
Received: by padhk3 with SMTP id hk3so187340290pad.3
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:44:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

problem reported:
	kernel 4.1.3
	------------
	# bridge vlan
	port	vlan ids
	eth0	 1 PVID Egress Untagged
	 	90
	 	91
	 	92
	 	93
	 	94
	 	95
	 	96
	 	97
	 	98
	 	99
	 	100

	vmbr0	 1 PVID Egress Untagged
	 	94

	kernel 4.2
	-----------
	# bridge vlan
	port	vlan ids

ndo_bridge_getlink can return -EOPNOTSUPP when an interfaces
ndo_bridge_getlink op is set to switchdev_port_bridge_getlink
and CONFIG_SWITCHDEV is not defined. This today can happen to
bond, rocker and team devices. This patch adds -EOPNOTSUPP
checks after calls to ndo_bridge_getlink.

Fixes: 85fdb956726ff2a ("switchdev: cut over to new switchdev_port_bridge_getlink")
Reported-by: Alexandre DERUMIER <aderumier@odiso.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
v2: fix checkpatch errors

 net/core/rtnetlink.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a466821..0ec4840 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3047,6 +3047,7 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	u32 portid = NETLINK_CB(cb->skb).portid;
 	u32 seq = cb->nlh->nlmsg_seq;
 	u32 filter_mask = 0;
+	int err;
 
 	if (nlmsg_len(cb->nlh) > sizeof(struct ifinfomsg)) {
 		struct nlattr *extfilt;
@@ -3067,20 +3068,25 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
 		if (br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-			if (idx >= cb->args[0] &&
-			    br_dev->netdev_ops->ndo_bridge_getlink(
-				    skb, portid, seq, dev, filter_mask,
-				    NLM_F_MULTI) < 0)
-				break;
+			if (idx >= cb->args[0]) {
+				err = br_dev->netdev_ops->ndo_bridge_getlink(
+						skb, portid, seq, dev,
+						filter_mask, NLM_F_MULTI);
+				if (err < 0 && err != -EOPNOTSUPP)
+					break;
+			}
 			idx++;
 		}
 
 		if (ops->ndo_bridge_getlink) {
-			if (idx >= cb->args[0] &&
-			    ops->ndo_bridge_getlink(skb, portid, seq, dev,
-						    filter_mask,
-						    NLM_F_MULTI) < 0)
-				break;
+			if (idx >= cb->args[0]) {
+				err = ops->ndo_bridge_getlink(skb, portid,
+							      seq, dev,
+							      filter_mask,
+							      NLM_F_MULTI);
+				if (err < 0 && err != -EOPNOTSUPP)
+					break;
+			}
 			idx++;
 		}
 	}
-- 
1.9.1
