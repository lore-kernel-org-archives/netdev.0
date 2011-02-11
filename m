From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] arp_notify: unconditionally send gratuitous ARP for NETDEV_NOTIFY_PEERS.
Date: Fri, 11 Feb 2011 17:44:16 +0000
Message-ID: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18271 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756595Ab1BKRoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 12:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_NOTIFY_PEER is an explicit request by the driver to send a link
notification while NETDEV_UP/NETDEV_CHANGEADDR generate link
notifications as a sort of side effect.

In the later cases the sysctl option is present because link
notification events can have undesired effects e.g. if the link is
flapping. I don't think this applies in the case of an explicit
request from a driver.

This patch makes NETDEV_NOTIFY_PEER unconditional, if preferred we
could add a new sysctl for this case which defaults to on.

This change causes Xen post-migration ARP notifications (which cause
switches to relearn their MAC tables etc) to be sent by default.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 net/ipv4/devinet.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 748cb5b..df4616f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1030,6 +1030,21 @@ static inline bool inetdev_valid_mtu(unsigned mtu)
 	return mtu >= 68;
 }
 
+static void inetdev_send_gratuitous_arp(struct net_device *dev,
+					struct in_device *in_dev)
+
+{
+	struct in_ifaddr *ifa = in_dev->ifa_list;
+
+	if (!ifa)
+		return;
+
+	arp_send(ARPOP_REQUEST, ETH_P_ARP,
+		 ifa->ifa_address, dev,
+		 ifa->ifa_address, NULL,
+		 dev->dev_addr, NULL);
+}
+
 /* Called only under RTNL semaphore */
 
 static int inetdev_event(struct notifier_block *this, unsigned long event,
@@ -1082,18 +1097,13 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		}
 		ip_mc_up(in_dev);
 		/* fall through */
-	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEADDR:
+		if (!IN_DEV_ARP_NOTIFY(in_dev))
+			break;
+		/* fall through */
+	case NETDEV_NOTIFY_PEERS:
 		/* Send gratuitous ARP to notify of link change */
-		if (IN_DEV_ARP_NOTIFY(in_dev)) {
-			struct in_ifaddr *ifa = in_dev->ifa_list;
-
-			if (ifa)
-				arp_send(ARPOP_REQUEST, ETH_P_ARP,
-					 ifa->ifa_address, dev,
-					 ifa->ifa_address, NULL,
-					 dev->dev_addr, NULL);
-		}
+		inetdev_send_gratuitous_arp(dev, in_dev);
 		break;
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
-- 
1.5.6.5

