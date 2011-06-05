From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Sun, 05 Jun 2011 14:28:23 -0700 (PDT)
Message-ID: <20110605.142823.1727360496050285755.davem@davemloft.net>
References: <20110603200738.GA24804@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	pedro.netdev@dondevamos.com
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967Ab1FEV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:29:47 -0400
In-Reply-To: <20110603200738.GA24804@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 3 Jun 2011 22:07:38 +0200

> Commit ad1afb00 registers a VLAN with vid == 0 for every device to handle
> 802.1p frames.  This is currently done on every NETDEV_UP event and the special
> vlan is never unregistered.  This may have strange effects on drivers
> implementning ndo_vlan_rx_add_vid(). E.g. bonding will allocate a linked-list
> element each time, causing a memory leak.
> 
> Only register the special VLAN once on NETDEV_REGISTER.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

I recognize the problem, but this solution isn't all that good.

I am pretty sure that the hardware device driver methods that
implement ndo_vlan_rx_add_vid() assume that the device is up.
Because most drivers completely reset the chip when the
interface is brought up and this will likely clear out the
VLAN ID tables in the chip.

Second, now even devices which don't ever get brought up will
have the VLAN ID 0 thing allocated.

Probably the thing to do is to remove the VLAN ID 0 entry on
NETDEV_DOWN.

Something like:

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c7a581a..135019d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -379,6 +379,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
 	}
 
+	if ((event == NETDEV_DOWN) &&
+	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    dev->netdev_ops->ndo_vlan_rx_kill_vid) {
+		pr_info("8021q: removing VLAN 0 from HW filter on device %s\n",
+			dev->name);
+		dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, 0);
+	}
+
 	grp = rtnl_dereference(dev->vlgrp);
 	if (!grp)
 		goto out;
