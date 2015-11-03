From: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
Subject: [PATCH net-next] vlan: Invoke driver vlan hooks only if device is present
Date: Tue,  3 Nov 2015 20:25:59 +0530
Message-ID: <1446562559-7264-1-git-send-email-padmanabh.ratnakar@avagotech.com>
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:65237 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750817AbbKCPNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:13:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers mark device as detached during error recovery.
It expects no manangement hooks to be invoked in this state.
Invoke driver vlan hooks only if device is present.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
---
 net/8021q/vlan_core.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 61bf2a0..496b275 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -206,7 +206,10 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, __be16 proto, u16 vid,
 		return -ENOMEM;
 
 	if (vlan_hw_filter_capable(dev, vid_info)) {
-		err =  ops->ndo_vlan_rx_add_vid(dev, proto, vid);
+		if (netif_device_present(dev))
+			err = ops->ndo_vlan_rx_add_vid(dev, proto, vid);
+		else
+			err = -ENODEV;
 		if (err) {
 			kfree(vid_info);
 			return err;
@@ -264,7 +267,10 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 	int err;
 
 	if (vlan_hw_filter_capable(dev, vid_info)) {
-		err = ops->ndo_vlan_rx_kill_vid(dev, proto, vid);
+		if (netif_device_present(dev))
+			err = ops->ndo_vlan_rx_kill_vid(dev, proto, vid);
+		else
+			err = -ENODEV;
 		if (err) {
 			pr_warn("failed to kill vid %04x/%d for device %s\n",
 				proto, vid, dev->name);
-- 
1.7.1
