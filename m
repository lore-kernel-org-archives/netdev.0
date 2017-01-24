From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/2] vxlan: don't flush static fdb entries on admin down
Date: Mon, 23 Jan 2017 20:44:32 -0800
Message-ID: <1485233073-11391-2-git-send-email-roopa@cumulusnetworks.com>
References: <1485233073-11391-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34280 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdAXEop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:44:45 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so51221296pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:44:45 -0800 (PST)
In-Reply-To: <1485233073-11391-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch skips flushing static fdb entries in
ndo_stop, but flushes all fdb entries during vxlan
device delete. This is consistent with the bridge
driver fdb

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 19b1653..b34822f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2354,7 +2354,7 @@ static int vxlan_open(struct net_device *dev)
 }
 
 /* Purge the forwarding table */
-static void vxlan_flush(struct vxlan_dev *vxlan)
+static void vxlan_flush(struct vxlan_dev *vxlan, bool do_all)
 {
 	unsigned int h;
 
@@ -2364,6 +2364,8 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 		hlist_for_each_safe(p, n, &vxlan->fdb_head[h]) {
 			struct vxlan_fdb *f
 				= container_of(p, struct vxlan_fdb, hlist);
+			if (!do_all && (f->state & (NUD_PERMANENT | NUD_NOARP)))
+				continue;
 			/* the all_zeros_mac entry is deleted at vxlan_uninit */
 			if (!is_zero_ether_addr(f->eth_addr))
 				vxlan_fdb_destroy(vxlan, f);
@@ -2385,7 +2387,7 @@ static int vxlan_stop(struct net_device *dev)
 
 	del_timer_sync(&vxlan->age_timer);
 
-	vxlan_flush(vxlan);
+	vxlan_flush(vxlan, false);
 	vxlan_sock_release(vxlan);
 
 	return ret;
@@ -3058,6 +3060,8 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
+	vxlan_flush(vxlan, true);
+
 	spin_lock(&vn->sock_lock);
 	if (!hlist_unhashed(&vxlan->hlist))
 		hlist_del_rcu(&vxlan->hlist);
-- 
1.9.1
