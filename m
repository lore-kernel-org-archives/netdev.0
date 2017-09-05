From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 2/8] net: bridge: Send notification when host join/leaves a group
Date: Wed,  6 Sep 2017 01:35:04 +0200
Message-ID: <1504654510-31004-3-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58191 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752717AbdIEXfb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:35:31 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The host can join or leave a multicast group on the brX interface, as
indicated by IGMP snooping.  This is tracked within the bridge
multicast code. Send a notification when this happens, in the same way
a notification is sent when a port of the bridge joins/leaves a group
because of IGMP snooping.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/bridge/br_mdb.c       | 9 ++++++---
 net/bridge/br_multicast.c | 6 +++++-
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 71885e251988..80fa91ccc50c 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -316,7 +316,7 @@ static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
 #endif
 
 	mdb.obj.orig_dev = port_dev;
-	if (port_dev && type == RTM_NEWMDB) {
+	if (p && port_dev && type == RTM_NEWMDB) {
 		complete_info = kmalloc(sizeof(*complete_info), GFP_ATOMIC);
 		if (complete_info) {
 			complete_info->port = p;
@@ -326,7 +326,7 @@ static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
 			if (switchdev_port_obj_add(port_dev, &mdb.obj))
 				kfree(complete_info);
 		}
-	} else if (port_dev && type == RTM_DELMDB) {
+	} else if (p && port_dev && type == RTM_DELMDB) {
 		switchdev_port_obj_del(port_dev, &mdb.obj);
 	}
 
@@ -352,7 +352,10 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 	struct br_mdb_entry entry;
 
 	memset(&entry, 0, sizeof(entry));
-	entry.ifindex = port->dev->ifindex;
+	if (port)
+		entry.ifindex = port->dev->ifindex;
+	else
+		entry.ifindex = dev->ifindex;
 	entry.addr.proto = group->proto;
 	entry.addr.u.ip4 = group->u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c6b2b8d419e7..955f340fe719 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -250,6 +250,7 @@ static void br_multicast_group_expired(unsigned long data)
 		goto out;
 
 	mp->host_joined = false;
+	br_mdb_notify(br->dev, NULL, &mp->addr, RTM_DELMDB, 0);
 
 	if (mp->ports)
 		goto out;
@@ -775,7 +776,10 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto err;
 
 	if (!port) {
-		mp->host_joined = true;
+		if (!mp->host_joined) {
+			mp->host_joined = true;
+			br_mdb_notify(br->dev, NULL, &mp->addr, RTM_NEWMDB, 0);
+		}
 		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
-- 
2.14.1
