From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 3/3] net: bridge: handle NETDEV_CHANGEROOM event
Date: Tue, 20 Aug 2013 13:45:52 +0100
Message-ID: <1377002752-4622-4-git-send-email-f.fainelli@gmail.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, jiri@resnulli.us, stephen@networkplumber.org,
	kaber@trash.net, davem@davemloft.net, vyasevic@redhat.com,
	johannes@sipsolutions.net, eric.dumazet@gmail.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4097 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329Ab3HTMqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 08:46:18 -0400
In-Reply-To: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device which is a port member of a bridge has
needed_headroom/tailroom requirement changes, we need to walk the list
of bridge members, compute the minimum headroom or tailroom value, and
update the parent bridge device with the new values.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/bridge/br_if.c      | 32 ++++++++++++++++++++++++++++++++
 net/bridge/br_notify.c  |  5 +++++
 net/bridge/br_private.h |  2 ++
 3 files changed, 39 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index aa6c9a8..017622b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -296,6 +296,38 @@ int br_min_mtu(const struct net_bridge *br)
 	return mtu;
 }
 
+int br_min_headroom(const struct net_bridge *br)
+{
+	const struct net_bridge_port *p;
+	unsigned short needed_headroom = 0;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (!needed_headroom ||
+			p->dev->needed_headroom < needed_headroom)
+			needed_headroom = p->dev->needed_headroom;
+	}
+
+	return needed_headroom;
+}
+
+int br_min_tailroom(const struct net_bridge *br)
+{
+	const struct net_bridge_port *p;
+	unsigned short needed_tailroom = 0;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (!needed_tailroom ||
+			p->dev->needed_tailroom < needed_tailroom)
+			needed_tailroom = p->dev->needed_tailroom;
+	}
+
+	return needed_tailroom;
+}
+
 /*
  * Recomputes features using slave's features
  */
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 2998dd1..1c7be7c 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -107,6 +107,11 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 		/* Propagate to master device */
 		call_netdevice_notifiers(event, br->dev);
 		break;
+
+	case NETDEV_CHANGEROOM:
+		dev_set_headroom(br->dev, br_min_headroom(br));
+		dev_set_tailroom(br->dev, br_min_tailroom(br));
+		break;
 	}
 
 	/* Events that may cause spanning tree to refresh */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d41283c..81dc7aa 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -421,6 +421,8 @@ extern int br_add_if(struct net_bridge *br,
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
 extern int br_min_mtu(const struct net_bridge *br);
+extern int br_min_headroom(const struct net_bridge *br);
+extern int br_min_tailroom(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
 
-- 
1.8.1.2
