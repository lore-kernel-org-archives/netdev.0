From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] vlan handling of up/down
Date: Tue, 11 Jul 2006 14:28:08 -0700
Message-ID: <20060711142808.1a6a47bb@dxpl.pdx.osdl.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org>
	<200607091049.31628.stefan@loplof.de>
	<20060710095603.0b197eec@dxpl.pdx.osdl.net>
	<200607110001.14812.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50318 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751319AbWGKV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 17:28:16 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200607110001.14812.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Untested, but here is the basic idea of how I think up/down should be
handled.  Basically, rather than changing the flags directly the VLAN code
should call dev_open/dev_close.  The notifier end's up recursively calling
but this is okay.


--- vlan.orig/net/8021q/vlan.c
+++ vlan/net/8021q/vlan.c
@@ -427,7 +427,7 @@ static struct net_device *register_vlan_
 	/* The real device must be up and operating in order to
 	 * assosciate a VLAN device with it.
 	 */
-	if (!(real_dev->flags & IFF_UP))
+	if (!netif_running(real_dev))
 		goto out_unlock;
 
 	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
@@ -476,10 +476,7 @@ static struct net_device *register_vlan_
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
 #endif
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	new_dev->flags = real_dev->flags;
-	new_dev->flags &= ~IFF_UP;
-
-	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
+	new_dev->flags = real_dev->flags & ~IFF_UP;
 
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
@@ -566,6 +563,9 @@ static struct net_device *register_vlan_
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
 
+	/* Real device is up so bring up the vlan */
+	dev_open(new_dev);
+
 	rtnl_unlock();
 
 
@@ -624,11 +624,7 @@ static int vlan_device_event(struct noti
 			if (!vlandev)
 				continue;
 
-			flgs = vlandev->flags;
-			if (!(flgs & IFF_UP))
-				continue;
-
-			dev_change_flags(vlandev, flgs & ~IFF_UP);
+			dev_close(vlandev);
 		}
 		break;
 
@@ -638,12 +634,8 @@ static int vlan_device_event(struct noti
 			vlandev = grp->vlan_devices[i];
 			if (!vlandev)
 				continue;
-				
-			flgs = vlandev->flags;
-			if (flgs & IFF_UP)
-				continue;
 
-			dev_change_flags(vlandev, flgs | IFF_UP);
+			dev_open(vlandev);
 		}
 		break;
 		


-- 
Stephen Hemminger <shemminger@osdl.org>
Quis custodiet ipsos custodes?
