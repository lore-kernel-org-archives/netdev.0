From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC WIP 1/5] net: rtnetlink: Handle bridge port without upper device
Date: Sat, 26 Aug 2017 22:56:06 +0200
Message-ID: <1503780970-10312-2-git-send-email-andrew@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45140 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHZU57 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Aug 2017 16:57:59 -0400
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The brX interface will with a following patch becomes a member of the
bridge. It however cannot be a slave interface, since it would have to
be a slave of itself. netdev_master_upper_dev_get() returns NULL as a
result. Handle this NULL, by knowing this bridge slave must also be
the master, i.e. what we are looking for.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/core/rtnetlink.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9201e3621351..2673eb430b6f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3093,8 +3093,12 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
-		const struct net_device_ops *ops = br_dev->netdev_ops;
+		const struct net_device_ops *ops;
 
+		if (!br_dev)
+			br_dev = dev;
+
+		ops = br_dev->netdev_ops;
 		err = ops->ndo_fdb_add(ndm, tb, dev, addr, vid,
 				       nlh->nlmsg_flags);
 		if (err)
@@ -3197,7 +3201,12 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
-		const struct net_device_ops *ops = br_dev->netdev_ops;
+		const struct net_device_ops *ops;
+
+		if (!br_dev)
+			br_dev = dev;
+
+		ops = br_dev->netdev_ops;
 
 		if (ops->ndo_fdb_del)
 			err = ops->ndo_fdb_del(ndm, tb, dev, addr, vid);
@@ -3332,6 +3341,8 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			if (!br_idx) { /* user did not specify a specific bridge */
 				if (dev->priv_flags & IFF_BRIDGE_PORT) {
 					br_dev = netdev_master_upper_dev_get(dev);
+					if (!br_dev)
+						br_dev = dev;
 					cops = br_dev->netdev_ops;
 				}
 			} else {
@@ -3410,6 +3421,9 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 	int err = 0;
 
+	if (!br_dev)
+		br_dev = dev;
+
 	nlh = nlmsg_put(skb, pid, seq, RTM_NEWLINK, sizeof(*ifm), nlflags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
@@ -3647,6 +3661,8 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+		if (!br_dev)
+			br_dev = dev;
 
 		if (!br_dev || !br_dev->netdev_ops->ndo_bridge_setlink) {
 			err = -EOPNOTSUPP;
@@ -3723,6 +3739,9 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
+		if (!br_dev)
+			br_dev = dev;
+
 		if (!br_dev || !br_dev->netdev_ops->ndo_bridge_dellink) {
 			err = -EOPNOTSUPP;
 			goto out;
-- 
2.14.1
