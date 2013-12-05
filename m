From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 2/2] vxlan: leave multicast group when vxlan device down
Date: Thu, 5 Dec 2013 17:01:36 +0800
Message-ID: <1386234096-18441-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754352Ab3LEJP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 04:15:27 -0500
In-Reply-To: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_group_used only allows device to leave multicast group
when the remote_ip of this vxlan device is difference from
other vxlan devices' remote_ip. this will cause device not
leave multicast group untile the vn_sock of this vxlan deivce
being released.

The check in vxlan_group_used is not quite precise. since even
the remote_ip is same, but these vxlan devices may use different
lower devices, and they may use different vn_socks.

Only when some vxlan devices use the same vn_sock,same lower
device and same remote_ip, the mc_list of the vn_sock should
not be changed.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/vxlan.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8c40254..d28a3f4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -916,17 +916,32 @@ static bool vxlan_snoop(struct net_device *dev,
 }
 
 /* See if multicast group is already in use by other ID */
-static bool vxlan_group_used(struct vxlan_net *vn, union vxlan_addr *remote_ip)
+static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 {
 	struct vxlan_dev *vxlan;
 
+	/* The vxlan_sock is only used by dev, leaving group has
+	 * no effect on other vxlan devices.
+	 */
+	if (atomic_read(&dev->vn_sock->refcnt) == 1)
+		return false;
+
 	list_for_each_entry(vxlan, &vn->vxlan_list, next) {
-		if (!netif_running(vxlan->dev))
+		if (!netif_running(vxlan->dev) || vxlan == dev)
 			continue;
 
-		if (vxlan_addr_equal(&vxlan->default_dst.remote_ip,
-				     remote_ip))
-			return true;
+		if (vxlan->vn_sock != dev->vn_sock)
+			continue;
+
+		if (!vxlan_addr_equal(&vxlan->default_dst.remote_ip,
+				      &dev->default_dst.remote_ip))
+			continue;
+
+		if (vxlan->default_dst.remote_ifindex !=
+		    dev->default_dst.remote_ifindex)
+			continue;
+
+		return true;
 	}
 
 	return false;
@@ -1982,7 +1997,7 @@ static int vxlan_stop(struct net_device *dev)
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	if (vs && vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
-	    ! vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
+	    !vxlan_group_used(vn, vxlan)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_leave);
-- 
1.8.3.1
