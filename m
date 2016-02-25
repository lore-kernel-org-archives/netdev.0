From: =?iso-2022-jp?B?TUlOT1VSQSBNYWtvdG8gLyAbJEJMJzE6GyhCIBskQj8/GyhC?=
	<minoura@valinux.co.jp>
Subject: [PATCH] net: ndo_fdb_dump should report -EMSGSIZE to rtnl_fdb_dump.
Date: Thu, 25 Feb 2016 14:20:48 +0900
Message-ID: <kk537sh1i33.fsf@brer.local.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:47466 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbcBYFUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 00:20:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.valinux.co.jp (Postfix) with ESMTP id F00E1ADFCC
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 14:20:51 +0900 (JST)
Received: from mail.valinux.co.jp ([127.0.0.1])
	by localhost (mail.valinux.co.jp [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sLob43QaSBJL for <netdev@vger.kernel.org>;
	Thu, 25 Feb 2016 14:20:51 +0900 (JST)
Received: from brer (vagw.valinux.co.jp [210.128.90.14])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.valinux.co.jp (Postfix) with ESMTPSA id DB940ADC3B
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 14:20:51 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the send skbuff reaches the end, nlmsg_put and friends returns
-EMSGSIZE but it is silently thrown away in ndo_fdb_dump. It is called
within a for_each_netdev loop and the first fdb entry of a following
netdev could fit in the remaining skbuff.  This breaks the mechanism
of cb->args[0] and idx to keep track of the entries that are already
dumped, which results missing entries in bridge fdb show command.

Signed-off-by: Minoura Makoto <minoura@valinux.co.jp>
---
 drivers/net/vxlan.c       |  4 +++-
 net/bridge/br_fdb.c       | 15 ++++++++++-----
 net/core/rtnetlink.c      |  6 ++++++
 net/switchdev/switchdev.c |  5 ++++-
 4 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a31cd95..3b11518 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -931,8 +931,10 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGH,
 						     NLM_F_MULTI, rd);
-				if (err < 0)
+				if (err < 0) {
+					cb->args[1] = err;
 					goto out;
+				}
 skip:
 				++idx;
 			}
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 82e3e97..dcea4f4 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -723,6 +723,8 @@ int br_fdb_dump(struct sk_buff *skb,
 		struct net_bridge_fdb_entry *f;
 
 		hlist_for_each_entry_rcu(f, &br->hash[i], hlist) {
+			int err;
+
 			if (idx < cb->args[0])
 				goto skip;
 
@@ -741,12 +743,15 @@ int br_fdb_dump(struct sk_buff *skb,
 			if (!filter_dev && f->dst)
 				goto skip;
 
-			if (fdb_fill_info(skb, br, f,
-					  NETLINK_CB(cb->skb).portid,
-					  cb->nlh->nlmsg_seq,
-					  RTM_NEWNEIGH,
-					  NLM_F_MULTI) < 0)
+			err = fdb_fill_info(skb, br, f,
+					    NETLINK_CB(cb->skb).portid,
+					    cb->nlh->nlmsg_seq,
+					    RTM_NEWNEIGH,
+					    NLM_F_MULTI);
+			if (err < 0) {
+				cb->args[1] = err;
 				break;
+			}
 skip:
 			++idx;
 		}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d735e85..8261d95 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2911,6 +2911,7 @@ int ndo_dflt_fdb_dump(struct sk_buff *skb,
 	nlmsg_populate_fdb(skb, cb, dev, &idx, &dev->mc);
 out:
 	netif_addr_unlock_bh(dev);
+	cb->args[1] = err;
 	return idx;
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_dump);
@@ -2944,6 +2945,7 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		ops = br_dev->netdev_ops;
 	}
 
+	cb->args[1] = 0;
 	for_each_netdev(net, dev) {
 		if (brport_idx && (dev->ifindex != brport_idx))
 			continue;
@@ -2971,12 +2973,16 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev,
 							 idx);
 		}
+		if (cb->args[1] == -EMSGSIZE)
+			break;
 
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
 							    idx);
 		else
 			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+		if (cb->args[1] == -EMSGSIZE)
+			break;
 
 		cops = NULL;
 	}
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 47f7da5..8b5833c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1093,8 +1093,11 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		.cb = cb,
 		.idx = idx,
 	};
+	int err;
 
-	switchdev_port_obj_dump(dev, &dump.fdb.obj, switchdev_port_fdb_dump_cb);
+	err = switchdev_port_obj_dump(dev, &dump.fdb.obj,
+				      switchdev_port_fdb_dump_cb);
+	cb->args[1] = err;
 	return dump.idx;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
-- 
2.5.0
