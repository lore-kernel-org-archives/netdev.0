From: roopa@cumulusnetworks.com
Subject: [PATCH 6/6] bridge: add vlan info to bridge setlink and dellink notification messages
Date: Mon, 29 Dec 2014 13:05:32 -0800
Message-ID: <1419887132-7084-7-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:37680 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbaL2VFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:45 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so18327709pab.40
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

vlan add/deletes are not notified to userspace today. This patch fixes it.
Notifications will contain vlans compressed into ranges whereever applicable.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |    3 ++-
 net/core/rtnetlink.c    |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 16bdd5a..cebfb03 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -303,7 +303,8 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, 0, port->dev);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0,
+			     RTEXT_FILTER_BRVLAN_COMPRESSED, port->dev);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..dad5fb6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2878,7 +2878,8 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 
 	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
 	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
+		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev,
+					RTEXT_FILTER_BRVLAN_COMPRESSED);
 		if (err < 0)
 			goto errout;
 	}
-- 
1.7.10.4
