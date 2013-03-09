From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 1/3] bridge: fix mdb info leaks
Date: Sat,  9 Mar 2013 16:52:19 +0100
Message-ID: <1362844341-12591-2-git-send-email-minipli@googlemail.com>
References: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:52243 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113Ab3CIPwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:52:44 -0500
Received: by mail-bk0-f43.google.com with SMTP id jm19so1150704bkc.30
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 07:52:42 -0800 (PST)
In-Reply-To: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridging code discloses heap and stack bytes via the RTM_GETMDB
netlink interface and via the notify messages send to group RTNLGRP_MDB
afer a successful add/del.

Fix both cases by initializing all unset members/padding bytes with
memset(0).

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/bridge/br_mdb.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 9f97b85..ee79f3f 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -80,6 +80,7 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 				port = p->port;
 				if (port) {
 					struct br_mdb_entry e;
+					memset(&e, 0, sizeof(e));
 					e.ifindex = port->dev->ifindex;
 					e.state = p->state;
 					if (p->addr.proto == htons(ETH_P_IP))
@@ -136,6 +137,7 @@ static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				break;
 
 			bpm = nlmsg_data(nlh);
+			memset(bpm, 0, sizeof(*bpm));
 			bpm->ifindex = dev->ifindex;
 			if (br_mdb_fill_info(skb, cb, dev) < 0)
 				goto out;
@@ -171,6 +173,7 @@ static int nlmsg_populate_mdb_fill(struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	bpm = nlmsg_data(nlh);
+	memset(bpm, 0, sizeof(*bpm));
 	bpm->family  = AF_BRIDGE;
 	bpm->ifindex = dev->ifindex;
 	nest = nla_nest_start(skb, MDBA_MDB);
@@ -228,6 +231,7 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 {
 	struct br_mdb_entry entry;
 
+	memset(&entry, 0, sizeof(entry));
 	entry.ifindex = port->dev->ifindex;
 	entry.addr.proto = group->proto;
 	entry.addr.u.ip4 = group->u.ip4;
-- 
1.7.10.4
