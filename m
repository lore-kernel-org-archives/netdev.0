From: sfeldma@gmail.com
Subject: [PATCH net-next] switchdev: fdb filter_dev is always NULL for self (device), so remove check
Date: Wed, 17 Jun 2015 16:08:31 -0700
Message-ID: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, sridhar.samudrala@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34037 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbbFQXGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 19:06:34 -0400
Received: by pabvl15 with SMTP id vl15so569167pab.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 16:06:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Remove the filter_dev check when dumping fdb entries, otherwise dump
returns empty list.  filter_dev is always passed as NULL when dumping fdbs
on SELF.  We want the fdbs installed on the device to be listed in the
dump.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Fixes: 45d4122c ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops")
---
 net/switchdev/switchdev.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a5d0f8e..7dda437 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -657,7 +657,6 @@ struct switchdev_fdb_dump {
 	struct switchdev_obj obj;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
-	struct net_device *filter_dev;
 	int idx;
 };
 
@@ -670,14 +669,10 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 	u32 seq = dump->cb->nlh->nlmsg_seq;
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
-	struct net_device *master = netdev_master_upper_dev_get(dev);
 
 	if (dump->idx < dump->cb->args[0])
 		goto skip;
 
-	if (master && dump->filter_dev != master)
-		goto skip;
-
 	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
 			sizeof(*ndm), NLM_F_MULTI);
 	if (!nlh)
@@ -731,7 +726,6 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		},
 		.skb = skb,
 		.cb = cb,
-		.filter_dev = filter_dev,
 		.idx = idx,
 	};
 	int err;
-- 
1.7.10.4
