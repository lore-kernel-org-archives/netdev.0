From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/8] bridge: Reflect MDB entries to hardware
Date: Sun, 10 Jan 2016 21:06:23 +0100
Message-ID: <1452456389-2833-3-git-send-email-jiri@resnulli.us>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33043 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJUGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:06:35 -0500
Received: by mail-wm0-f67.google.com with SMTP id u188so23428799wmu.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:06:34 -0800 (PST)
In-Reply-To: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Offload MDB changes per port to hardware

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_mdb.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index cd8deea..30e105f 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -7,6 +7,7 @@
 #include <linux/if_ether.h>
 #include <net/ip.h>
 #include <net/netlink.h>
+#include <net/switchdev.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -210,10 +211,32 @@ static inline size_t rtnl_mdb_nlmsg_size(void)
 static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
 			    int type)
 {
+	struct switchdev_obj_port_mdb mdb = {
+		.obj = {
+			.id = SWITCHDEV_OBJ_ID_PORT_MDB,
+			.flags = SWITCHDEV_F_DEFER,
+		},
+		.vid = entry->vid,
+	};
+	struct net_device *port_dev;
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
+	port_dev = __dev_get_by_index(net, entry->ifindex);
+	if (entry->addr.proto == htons(ETH_P_IP))
+		ip_eth_mc_map(entry->addr.u.ip4, mdb.addr);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		ipv6_eth_mc_map(&entry->addr.u.ip6, mdb.addr);
+#endif
+
+	mdb.obj.orig_dev = port_dev;
+	if (port_dev && type == RTM_NEWMDB)
+		switchdev_port_obj_add(port_dev, &mdb.obj);
+	else if (port_dev && type == RTM_DELMDB)
+		switchdev_port_obj_del(port_dev, &mdb.obj);
+
 	skb = nlmsg_new(rtnl_mdb_nlmsg_size(), GFP_ATOMIC);
 	if (!skb)
 		goto errout;
-- 
1.9.3
