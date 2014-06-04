From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 2/3] macvlan: Support bonding events
Date: Wed,  4 Jun 2014 16:23:37 -0400
Message-ID: <1401913418-31307-3-git-send-email-vyasevic@redhat.com>
References: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	kaber@trash.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaFDUXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 16:23:48 -0400
In-Reply-To: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bonding and team drivers generate specific events during failover
that trigger switch updates.  When a macvlan device is configured
on top of bonding, we want switches to learn about the macvlan
devices as well.   This patch adds a handler to macvlan driver to
propagate these events to all macvlan devices.  We let the generic
inetdev event handler do the work.

This allows macvlan to operated correctly over active-backup
mode bond.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index eee9106..453d55a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1209,6 +1209,13 @@ static int macvlan_device_event(struct notifier_block *unused,
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
 		return NOTIFY_BAD;
+
+	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_RESEND_IGMP:
+		/* Propagate to all vlans */
+		list_for_each_entry(vlan, &port->vlans, list)
+			call_netdevice_notifiers(event, vlan->dev);
 	}
 	return NOTIFY_DONE;
 }
-- 
1.9.0
