From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH] bonding: extend bond_arp_send_all to bridge devices
Date: Tue, 30 Oct 2012 18:07:45 +0100
Message-ID: <50900961.7010907@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090708090401070401010306"
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49445 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759908Ab2J3RHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 13:07:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090708090401070401010306
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi, please accept this patch that fixes the following issues:
http://bugzilla.kernel.org/show_bug.cgi?id=31822
http://launchpad.net/bugs/736226

I've done a bit of testing with the setup identified in the bugs, and
this patch fixes the issue for me and others that have tested this.

Thanks,
--chris j arges

--------------090708090401070401010306
Content-Type: text/x-patch;
 name="0001-bonding-extend-bond_arp_send_all-to-bridge-devices.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-bonding-extend-bond_arp_send_all-to-bridge-devices.patc";
 filename*1="h"

>From bc58ecc70aecc68497fe54228ebe8630777b53a0 Mon Sep 17 00:00:00 2001
From: Chris J Arges <chris.j.arges@canonical.com>
Date: Thu, 6 Sep 2012 14:17:40 -0500
Subject: [PATCH] bonding: extend bond_arp_send_all to bridge devices

ARP monitoring does not work when we have a network in the
following configuration:

eth0----+ +----bond0.100----br0-100---{+virtual machines
          | |
          +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
          | |
eth1----+ +----bond0.200----br0-200---{+virtual machines

This patch extends bond_arp_send_all to also check if a device
is also in a bridge.

This is related to the following issues:
http://launchpad.net/bugs/736226
http://bugzilla.kernel.org/show_bug.cgi?id=31822

Thanks to help from Andy Gospodarek.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 drivers/net/bonding/bond_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2530b0..cb791f6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2708,6 +2708,18 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			continue;
 		}
 
+		/*
+		 * Check if the target is part of a bridge.
+		 */
+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
+			/* Confirm addr is part of the bridge */
+			addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
+
+			/* Send ARP request */
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
+			continue;
+		}
+
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &targets[i],
-- 
1.7.10.4



--------------090708090401070401010306--
