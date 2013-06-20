From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/8] vxlan: Fix error handling while creating device.
Date: Thu, 20 Jun 2013 00:26:25 -0700
Message-ID: <1371713185-8076-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:54763 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753840Ab3FTH0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:33 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so5954520pbc.4
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete vxlan-sock list entry from list before freeing the memory.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 284c6c0..173705f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1606,9 +1606,11 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	err = register_netdevice(dev);
 	if (err) {
 		if (--vs->refcnt == 0) {
+			hlist_del_rcu(&vs->hlist);
 			rtnl_unlock();
+
 			sk_release_kernel(vs->sock->sk);
-			kfree(vs);
+			kfree_rcu(vs, rcu);
 			rtnl_lock();
 		}
 		return err;
-- 
1.7.1
