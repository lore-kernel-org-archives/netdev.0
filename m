From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv4: arp_notify address list bug
Date: Mon, 5 Oct 2009 19:15:05 -0700
Message-ID: <20091005191505.75c929a6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283AbZJFCPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 22:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a bug with arp_notify and also adds a small enhancement.

If arp_notify is enabled, kernel will crash if address is changed
and no IP address is assigned.
  http://bugzilla.kernel.org/show_bug.cgi?id=14330

The fix is to walk the (possibly empty) list when sending
the gratuitous ARP's.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This should go to stable kernel fixes as well.

--- a/net/ipv4/devinet.c	2009-10-05 17:31:35.759514625 -0700
+++ b/net/ipv4/devinet.c	2009-10-05 17:44:04.204494945 -0700
@@ -1077,12 +1077,15 @@ static int inetdev_event(struct notifier
 		ip_mc_up(in_dev);
 		/* fall through */
 	case NETDEV_CHANGEADDR:
-		if (IN_DEV_ARP_NOTIFY(in_dev))
-			arp_send(ARPOP_REQUEST, ETH_P_ARP,
-				 in_dev->ifa_list->ifa_address,
-				 dev,
-				 in_dev->ifa_list->ifa_address,
-				 NULL, dev->dev_addr, NULL);
+		/* Send gratitious ARP to notify of link change */
+		if (IN_DEV_ARP_NOTIFY(in_dev)) {
+			struct in_ifaddr *ifa;
+			for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next)
+				arp_send(ARPOP_REQUEST, ETH_P_ARP,
+					 ifa->ifa_address, dev,
+					 ifa->ifa_address, NULL,
+					 dev->dev_addr, NULL);
+		}
 		break;
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
