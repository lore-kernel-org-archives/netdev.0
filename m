From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] vxlan: fix a soft lockup in vxlan module removal
Date: Wed,  7 Aug 2013 16:43:22 +0800
Message-ID: <1375865002-8732-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023Ab3HGInc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 04:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This is a regression introduced by:

	commit fe5c3561e6f0ac7c9546209f01351113c1b77ec8
	Author: stephen hemminger <stephen@networkplumber.org>
	Date:   Sat Jul 13 10:18:18 2013 -0700

	    vxlan: add necessary locking on device removal

The problem is that vxlan_dellink(), which is called with RTNL lock
held, tries to flush the workqueue synchronously, but apparently
igmp_join and igmp_leave work need to hold RTNL lock too, therefore we
have a soft lockup! 

As suggested by Stephen, probably the flush_workqueue can just be
removed and let the normal refcounting work. The workqueue has a
reference to device and socket, therefore the cleanups should work
correctly.

Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Tested-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bf31d9..c51ef9b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1837,8 +1837,6 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	flush_workqueue(vxlan_wq);
-
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
