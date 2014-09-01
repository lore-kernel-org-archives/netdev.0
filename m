From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/4] rtnl/do_setlink(): last arg is now a set of flags
Date: Mon,  1 Sep 2014 16:07:28 +0200
Message-ID: <1409580449-4562-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36486 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbaIAOQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:16:51 -0400
In-Reply-To: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no functional changes with this commit, it only prepares the next one.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2bd9fb15b987..7d84db3e0597 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1481,9 +1481,10 @@ static int do_set_master(struct net_device *dev, int ifindex)
 	return 0;
 }
 
+#define DO_SETLINK_MODIFIED	0x01
 static int do_setlink(const struct sk_buff *skb,
 		      struct net_device *dev, struct ifinfomsg *ifm,
-		      struct nlattr **tb, char *ifname, int modified)
+		      struct nlattr **tb, char *ifname, int status)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
@@ -1502,7 +1503,7 @@ static int do_setlink(const struct sk_buff *skb,
 		put_net(net);
 		if (err)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_MAP]) {
@@ -1531,7 +1532,7 @@ static int do_setlink(const struct sk_buff *skb,
 		if (err < 0)
 			goto errout;
 
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_ADDRESS]) {
@@ -1551,19 +1552,19 @@ static int do_setlink(const struct sk_buff *skb,
 		kfree(sa);
 		if (err)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_MTU]) {
 		err = dev_set_mtu(dev, nla_get_u32(tb[IFLA_MTU]));
 		if (err < 0)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_GROUP]) {
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	/*
@@ -1575,7 +1576,7 @@ static int do_setlink(const struct sk_buff *skb,
 		err = dev_change_name(dev, ifname);
 		if (err < 0)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_IFALIAS]) {
@@ -1583,7 +1584,7 @@ static int do_setlink(const struct sk_buff *skb,
 				    nla_len(tb[IFLA_IFALIAS]));
 		if (err < 0)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_BROADCAST]) {
@@ -1601,21 +1602,21 @@ static int do_setlink(const struct sk_buff *skb,
 		err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
 		if (err)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_CARRIER]) {
 		err = dev_change_carrier(dev, nla_get_u8(tb[IFLA_CARRIER]));
 		if (err)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_TXQLEN]) {
 		unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);
 
 		if (dev->tx_queue_len ^ value)
-			modified = 1;
+			status |= DO_SETLINK_MODIFIED;
 
 		dev->tx_queue_len = value;
 	}
@@ -1628,7 +1629,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 		write_lock_bh(&dev_base_lock);
 		if (dev->link_mode ^ value)
-			modified = 1;
+			status |= DO_SETLINK_MODIFIED;
 		dev->link_mode = value;
 		write_unlock_bh(&dev_base_lock);
 	}
@@ -1644,7 +1645,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = do_setvfinfo(dev, attr);
 			if (err < 0)
 				goto errout;
-			modified = 1;
+			status |= DO_SETLINK_MODIFIED;
 		}
 	}
 	err = 0;
@@ -1674,7 +1675,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = ops->ndo_set_vf_port(dev, vf, port);
 			if (err < 0)
 				goto errout;
-			modified = 1;
+			status |= DO_SETLINK_MODIFIED;
 		}
 	}
 	err = 0;
@@ -1692,7 +1693,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = ops->ndo_set_vf_port(dev, PORT_SELF_VF, port);
 		if (err < 0)
 			goto errout;
-		modified = 1;
+		status |= DO_SETLINK_MODIFIED;
 	}
 
 	if (tb[IFLA_AF_SPEC]) {
@@ -1709,13 +1710,13 @@ static int do_setlink(const struct sk_buff *skb,
 			if (err < 0)
 				goto errout;
 
-			modified = 1;
+			status |= DO_SETLINK_MODIFIED;
 		}
 	}
 	err = 0;
 
 errout:
-	if (err < 0 && modified)
+	if (err < 0 && status & DO_SETLINK_MODIFIED)
 		net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
 				     dev->name);
 
@@ -1999,7 +2000,7 @@ replay:
 		}
 
 		if (dev) {
-			int modified = 0;
+			int status = 0;
 
 			if (nlh->nlmsg_flags & NLM_F_EXCL)
 				return -EEXIST;
@@ -2014,7 +2015,7 @@ replay:
 				err = ops->changelink(dev, tb, data);
 				if (err < 0)
 					return err;
-				modified = 1;
+				status |= DO_SETLINK_MODIFIED;
 			}
 
 			if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
@@ -2025,10 +2026,10 @@ replay:
 							      tb, slave_data);
 				if (err < 0)
 					return err;
-				modified = 1;
+				status |= DO_SETLINK_MODIFIED;
 			}
 
-			return do_setlink(skb, dev, ifm, tb, ifname, modified);
+			return do_setlink(skb, dev, ifm, tb, ifname, status);
 		}
 
 		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
-- 
1.9.0
