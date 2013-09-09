From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 25/26] vlan: link the upper neighbour only after registering
Date: Mon,  9 Sep 2013 22:16:43 +0200
Message-ID: <1378757804-3159-26-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514Ab3IIURS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:17:18 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise users might access it without being fully registered, as per
sysfs - it only inits in register_netdevice(), so is unusable till it is
called.

CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/8021q/vlan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 61fc573..69b4a35 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -169,13 +169,13 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_mvrp;
 
-	err = netdev_upper_dev_link(real_dev, dev);
-	if (err)
-		goto out_uninit_mvrp;
-
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto out_upper_dev_unlink;
+		goto out_uninit_mvrp;
+
+	err = netdev_upper_dev_link(real_dev, dev);
+	if (err)
+		goto out_unregister_netdev;
 
 	/* Account for reference in struct vlan_dev_priv */
 	dev_hold(real_dev);
@@ -191,8 +191,8 @@ int register_vlan_dev(struct net_device *dev)
 
 	return 0;
 
-out_upper_dev_unlink:
-	netdev_upper_dev_unlink(real_dev, dev);
+out_unregister_netdev:
+	unregister_netdevice(dev);
 out_uninit_mvrp:
 	if (grp->nr_vlan_devs == 0)
 		vlan_mvrp_uninit_applicant(real_dev);
-- 
1.8.4
