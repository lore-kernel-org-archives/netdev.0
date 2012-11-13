From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/11] batman-adv: prevent using any virtual device created on batman-adv as hard-interface
Date: Tue, 13 Nov 2012 10:15:31 +0100
Message-ID: <1352798139-19458-4-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52596 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab2KMJQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:32 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any virtual device created on top of a batman-adv mesh interface must be
prevented to be used to create a new mesh network (this would lead to an
unwanted batman-over-batman configuration)

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c | 41 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 40 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 6b7a5d3..365ed74 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -59,6 +59,45 @@ out:
 	return hard_iface;
 }
 
+/**
+ * batadv_is_on_batman_iface - check if a device is a batman iface descendant
+ * @net_dev: the device to check
+ *
+ * If the user creates any virtual device on top of a batman-adv interface, it
+ * is important to prevent this new interface to be used to create a new mesh
+ * network (this behaviour would lead to a batman-over-batman configuration).
+ * This function recursively checks all the fathers of the device passed as
+ * argument looking for a batman-adv soft interface.
+ *
+ * Returns true if the device is descendant of a batman-adv mesh interface (or
+ * if it is a batman-adv interface itself), false otherwise
+ */
+static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
+{
+	struct net_device *parent_dev;
+	bool ret;
+
+	/* check if this is a batman-adv mesh interface */
+	if (batadv_softif_is_valid(net_dev))
+		return true;
+
+	/* no more parents..stop recursion */
+	if (net_dev->iflink == net_dev->ifindex)
+		return false;
+
+	/* recurse over the parent device */
+	parent_dev = dev_get_by_index(&init_net, net_dev->iflink);
+	/* if we got a NULL parent_dev there is something broken.. */
+	if (WARN(!parent_dev, "Cannot find parent device"))
+		return false;
+
+	ret = batadv_is_on_batman_iface(parent_dev);
+
+	if (parent_dev)
+		dev_put(parent_dev);
+	return ret;
+}
+
 static int batadv_is_valid_iface(const struct net_device *net_dev)
 {
 	if (net_dev->flags & IFF_LOOPBACK)
@@ -71,7 +110,7 @@ static int batadv_is_valid_iface(const struct net_device *net_dev)
 		return 0;
 
 	/* no batman over batman */
-	if (batadv_softif_is_valid(net_dev))
+	if (batadv_is_on_batman_iface(net_dev))
 		return 0;
 
 	return 1;
-- 
1.8.0
