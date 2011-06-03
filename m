From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Fri, 3 Jun 2011 22:07:38 +0200
Message-ID: <20110603200738.GA24804@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49485 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756046Ab1FCUHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 16:07:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ad1afb00 registers a VLAN with vid == 0 for every device to handle
802.1p frames.  This is currently done on every NETDEV_UP event and the special
vlan is never unregistered.  This may have strange effects on drivers
implementning ndo_vlan_rx_add_vid(). E.g. bonding will allocate a linked-list
element each time, causing a memory leak.

Only register the special VLAN once on NETDEV_REGISTER.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c7a581a..bf89565 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -371,7 +371,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	if (is_vlan_dev(dev))
 		__vlan_device_event(dev, event);
 
-	if ((event == NETDEV_UP) &&
+	if ((event == NETDEV_REGISTER) &&
 	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_add_vid) {
 		pr_info("8021q: adding VLAN 0 to HW filter on device %s\n",

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

