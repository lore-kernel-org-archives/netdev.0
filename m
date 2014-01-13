From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: vxlan: properly cleanup devs on module unload
Date: Mon, 13 Jan 2014 18:41:20 +0100
Message-ID: <1389634880-4138-3-git-send-email-dborkman@redhat.com>
References: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbaAMRl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 12:41:27 -0500
In-Reply-To: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should use vxlan_dellink() handler in vxlan_exit_net(), since
i) we're not in fast-path and we should be consistent in dismantle
just as we would remove a device through rtnl ops, and more
importantly, ii) in case future code will kfree() memory in
vxlan_dellink(), we would leak it right here unnoticed. Therefore,
do not only half of the cleanup work, but make it properly.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/vxlan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 81c553f..d2acb6b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2711,13 +2711,13 @@ static __net_init int vxlan_init_net(struct net *net)
 static __net_exit void vxlan_exit_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_dev *vxlan;
-	LIST_HEAD(list);
+	struct vxlan_dev *vxlan, *next;
+	LIST_HEAD(list_kill);
 
 	rtnl_lock();
-	list_for_each_entry(vxlan, &vn->vxlan_list, next)
-		unregister_netdevice_queue(vxlan->dev, &list);
-	unregister_netdevice_many(&list);
+	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
+		vxlan_dellink(vxlan->dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
 	rtnl_unlock();
 }
 
-- 
1.7.11.7
