From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] net: Fix memory leak - vlan_info struct
Date: Mon,  9 Jul 2012 23:47:19 -0700
Message-ID: <1341902839-13181-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24725 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab2GJGrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 02:47:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

In driver reload test there is a memory leak.
The structure vlan_info was not freed when the driver was removed.
It was not released since the nr_vids var is one after last vlan was removed.
The nr_vids is one, since vlan zero is added to the interface when the interface
is being set, but the vlan zero is not deleted at unregister.
Fix - delete vlan zero when we unregister the device.

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/8021q/vlan.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6089f0c..9096bcb 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -403,6 +403,9 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_DOWN:
+		if (dev->features & NETIF_F_HW_VLAN_FILTER)
+			vlan_vid_del(dev, 0);
+
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
-- 
1.7.10.4
