From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: vrf: Fix dev refcnt leak due to IPv6 prefix route
Date: Thu,  7 Apr 2016 11:10:41 -0700
Message-ID: <1460052641-1155-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35025 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790AbcDGSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:10:49 -0400
Received: by mail-pf0-f182.google.com with SMTP id n1so60116389pfn.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:10:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifupdown2 found a kernel bug with IPv6 routes and movement from the main
table to the VRF table. Sequence of events:

Create the interface and add addresses:
    ip link add dev eth4.105 link eth4 type vlan id 105
    ip addr add dev eth4.105 8.105.105.10/24
    ip -6 addr add dev eth4.105 2008:105:105::10/64

At this point IPv6 has inserted a prefix route in the main table even
though the interface is 'down'. From there the VRF device is created:
    ip link add dev vrf105 type vrf table 105
    ip addr add dev vrf105 9.9.105.10/32
    ip -6 addr add dev vrf105 2000:9:105::10/128
    ip link set vrf105 up

Then the interface is enslaved, while still in the 'down' state:
    ip link set dev eth4.105 master vrf105

Since the device is down the VRF driver cycling the device does not
send the NETDEV_UP and NETDEV_DOWN but rather the NETDEV_CHANGE event
which does not flush the routes inserted prior.

When the link is brought up
    ip link set dev eth4.105 up

the prefix route is added in the VRF table, but does not remove
the route from the main table.

Fix by handling the NETDEV_CHANGEUPPER event similar what was implemented
for IPv4 in 7f49e7a38b77 ("net: Flush local routes when device changes vrf
association")

Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27aed1afcf81..2db2116d3e6b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3255,6 +3255,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_changeupper_info *info;
 	struct inet6_dev *idev = __in6_dev_get(dev);
 	int run_pending = 0;
 	int err;
@@ -3413,6 +3414,15 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		if (idev)
 			addrconf_type_change(dev, event);
 		break;
+
+	case NETDEV_CHANGEUPPER:
+		info = ptr;
+
+		/* flush all routes if dev is linked to or unlinked from
+		 * an L3 master device (e.g., VRF)
+		 */
+		if (info->upper_dev && netif_is_l3_master(info->upper_dev))
+			addrconf_ifdown(dev, 0);
 	}
 
 	return NOTIFY_OK;
-- 
2.1.4
