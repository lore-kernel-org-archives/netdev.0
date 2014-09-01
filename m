From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/4] rtnl/do_setlink(): notify when a netdev is modified
Date: Mon,  1 Sep 2014 16:07:29 +0200
Message-ID: <1409580449-4562-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36487 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbaIAOQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:16:51 -0400
In-Reply-To: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on which parameters were updated, the changes were not propagated via
the notifier chain and netlink.

The new flag has been set only when the change did not cause a call to the
notifier chain and/or to the netlink notification functions.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7d84db3e0597..a6882686ca3a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1482,6 +1482,8 @@ static int do_set_master(struct net_device *dev, int ifindex)
 }
 
 #define DO_SETLINK_MODIFIED	0x01
+/* notify flag means notify + modified. */
+#define DO_SETLINK_NOTIFY	0x03
 static int do_setlink(const struct sk_buff *skb,
 		      struct net_device *dev, struct ifinfomsg *ifm,
 		      struct nlattr **tb, char *ifname, int status)
@@ -1532,7 +1534,7 @@ static int do_setlink(const struct sk_buff *skb,
 		if (err < 0)
 			goto errout;
 
-		status |= DO_SETLINK_MODIFIED;
+		status |= DO_SETLINK_NOTIFY;
 	}
 
 	if (tb[IFLA_ADDRESS]) {
@@ -1564,7 +1566,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 	if (tb[IFLA_GROUP]) {
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
-		status |= DO_SETLINK_MODIFIED;
+		status |= DO_SETLINK_NOTIFY;
 	}
 
 	/*
@@ -1584,7 +1586,7 @@ static int do_setlink(const struct sk_buff *skb,
 				    nla_len(tb[IFLA_IFALIAS]));
 		if (err < 0)
 			goto errout;
-		status |= DO_SETLINK_MODIFIED;
+		status |= DO_SETLINK_NOTIFY;
 	}
 
 	if (tb[IFLA_BROADCAST]) {
@@ -1616,7 +1618,7 @@ static int do_setlink(const struct sk_buff *skb,
 		unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);
 
 		if (dev->tx_queue_len ^ value)
-			status |= DO_SETLINK_MODIFIED;
+			status |= DO_SETLINK_NOTIFY;
 
 		dev->tx_queue_len = value;
 	}
@@ -1629,7 +1631,7 @@ static int do_setlink(const struct sk_buff *skb,
 
 		write_lock_bh(&dev_base_lock);
 		if (dev->link_mode ^ value)
-			status |= DO_SETLINK_MODIFIED;
+			status |= DO_SETLINK_NOTIFY;
 		dev->link_mode = value;
 		write_unlock_bh(&dev_base_lock);
 	}
@@ -1645,7 +1647,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = do_setvfinfo(dev, attr);
 			if (err < 0)
 				goto errout;
-			status |= DO_SETLINK_MODIFIED;
+			status |= DO_SETLINK_NOTIFY;
 		}
 	}
 	err = 0;
@@ -1675,7 +1677,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = ops->ndo_set_vf_port(dev, vf, port);
 			if (err < 0)
 				goto errout;
-			status |= DO_SETLINK_MODIFIED;
+			status |= DO_SETLINK_NOTIFY;
 		}
 	}
 	err = 0;
@@ -1693,7 +1695,7 @@ static int do_setlink(const struct sk_buff *skb,
 			err = ops->ndo_set_vf_port(dev, PORT_SELF_VF, port);
 		if (err < 0)
 			goto errout;
-		status |= DO_SETLINK_MODIFIED;
+		status |= DO_SETLINK_NOTIFY;
 	}
 
 	if (tb[IFLA_AF_SPEC]) {
@@ -1710,15 +1712,20 @@ static int do_setlink(const struct sk_buff *skb,
 			if (err < 0)
 				goto errout;
 
-			status |= DO_SETLINK_MODIFIED;
+			status |= DO_SETLINK_NOTIFY;
 		}
 	}
 	err = 0;
 
 errout:
-	if (err < 0 && status & DO_SETLINK_MODIFIED)
-		net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
-				     dev->name);
+	if (status & DO_SETLINK_MODIFIED) {
+		if (status & DO_SETLINK_NOTIFY)
+			netdev_state_change(dev);
+
+		if (err < 0)
+			net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
+					     dev->name);
+	}
 
 	return err;
 }
@@ -2015,7 +2022,7 @@ replay:
 				err = ops->changelink(dev, tb, data);
 				if (err < 0)
 					return err;
-				status |= DO_SETLINK_MODIFIED;
+				status |= DO_SETLINK_NOTIFY;
 			}
 
 			if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
@@ -2026,7 +2033,7 @@ replay:
 							      tb, slave_data);
 				if (err < 0)
 					return err;
-				status |= DO_SETLINK_MODIFIED;
+				status |= DO_SETLINK_NOTIFY;
 			}
 
 			return do_setlink(skb, dev, ifm, tb, ifname, status);
-- 
1.9.0
