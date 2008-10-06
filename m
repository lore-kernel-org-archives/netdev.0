From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vlan: propogate MTU changes
Date: Mon, 6 Oct 2008 17:30:24 +0200
Message-ID: <20081006173024.2741cc01@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51010 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbYJFPax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 11:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propogate MTU changes of underlying device to all related VLAN
devices.
see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
There might be some discussion about whether to preserve MTU changes
on the vlan device if done after startup, but this seems like the best,
most direct fix.

--- a/net/8021q/vlan.c	2008-10-06 17:03:58.000000000 +0200
+++ b/net/8021q/vlan.c	2008-10-06 17:08:33.000000000 +0200
@@ -477,6 +477,17 @@ static int vlan_device_event(struct noti
 
 		break;
 
+	case NETDEV_CHANGEMTU:
+		/* Propogate MTU of underlying device */
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			vlandev->mtu = dev->mtu;
+		}
+		break;
+
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
