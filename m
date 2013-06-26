From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 2/8] vxlan: Fix vs->vni_list locking.
Date: Wed, 26 Jun 2013 13:13:34 -0700
Message-ID: <1372277614-17506-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:43662 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752360Ab3FZUOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:14:04 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so14550807pbc.21
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:13:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use rtnl lock to protect vs->vni_list updates.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0ba1e7e..f658d39 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1321,13 +1321,16 @@ static int vxlan_init(struct net_device *dev)
 		/* If we have a socket with same port already, reuse it */
 		atomic_inc(&vs->refcnt);
 		vxlan->vn_sock = vs;
+		spin_unlock(&vn->sock_lock);
+		rtnl_lock();
 		hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+		rtnl_unlock();
 	} else {
+		spin_unlock(&vn->sock_lock);
 		/* otherwise make new socket outside of RTNL */
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->sock_work);
 	}
-	spin_unlock(&vn->sock_lock);
 
 	return 0;
 }
@@ -1644,16 +1647,21 @@ static void vxlan_sock_work(struct work_struct *work)
 	if (ovs) {
 		atomic_inc(&ovs->refcnt);
 		vxlan->vn_sock = ovs;
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
 		spin_unlock(&vn->sock_lock);
 
+		rtnl_lock();
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
+		rtnl_unlock();
+
 		sk_release_kernel(nvs->sock->sk);
 		kfree(nvs);
 	} else {
 		vxlan->vn_sock = nvs;
 		hlist_add_head_rcu(&nvs->hlist, vs_head(net, port));
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
 		spin_unlock(&vn->sock_lock);
+		rtnl_lock();
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
+		rtnl_unlock();
 	}
 out:
 	dev_put(dev);
-- 
1.7.1
