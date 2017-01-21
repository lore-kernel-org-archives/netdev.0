From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH cumulus-4.1.y 4/5] vxlan: don't flush static fdb entries on admin down
Date: Fri, 20 Jan 2017 23:40:09 -0800
Message-ID: <1484984410-3304-4-git-send-email-roopa@cumulusnetworks.com>
References: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34470 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbdAUHlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:41:06 -0500
Received: by mail-pf0-f171.google.com with SMTP id e4so28013230pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:40:21 -0800 (PST)
In-Reply-To: <1484984410-3304-1-git-send-email-roopa@cumulusnetworks.com>
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
index 7300586..3314090 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2365,7 +2365,7 @@ static int vxlan_open(struct net_device *dev)
 }
 
 /* Purge the forwarding table */
-static void vxlan_flush(struct vxlan_dev *vxlan)
+static void vxlan_flush(struct vxlan_dev *vxlan, int do_all)
 {
 	unsigned int h;
 
@@ -2375,6 +2375,8 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 		hlist_for_each_safe(p, n, &vxlan->fdb_head[h]) {
 			struct vxlan_fdb *f
 				= container_of(p, struct vxlan_fdb, hlist);
+			if (!do_all && (f->state & (NUD_PERMANENT | NUD_NOARP)))
+				continue;
 			/* the all_zeros_mac entry is deleted at vxlan_uninit */
 			if (!is_zero_ether_addr(f->eth_addr))
 				vxlan_fdb_destroy(vxlan, f);
@@ -2396,7 +2398,7 @@ static int vxlan_stop(struct net_device *dev)
 
 	del_timer_sync(&vxlan->age_timer);
 
-	vxlan_flush(vxlan);
+	vxlan_flush(vxlan, 0);
 	vxlan_sock_release(vxlan);
 
 	return ret;
@@ -3069,6 +3071,8 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
+	vxlan_flush(vxlan, 1);
+
 	spin_lock(&vn->sock_lock);
 	if (!hlist_unhashed(&vxlan->hlist))
 		hlist_del_rcu(&vxlan->hlist);
-- 
1.9.1
