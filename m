From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v3 [PATCH net-next 3/7] bridge: Check return of dev_set_promiscuity
Date: Mon, 07 Jul 2008 10:35:57 +0800
Message-ID: <4871810D.9040406@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61048 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbYGGCke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 22:40:34 -0400
In-Reply-To: <48718014.4030009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for promiscuity to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/bridge/br_if.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..58bbfb8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -375,6 +375,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto put_back;
+
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
@@ -389,7 +393,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
-	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -413,12 +416,12 @@ err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
 	kobject_del(&p->kobj);
-	goto put_back;
 err0:
 	kobject_put(&p->kobj);
-
+	dev_set_promiscuity(dev, -1);
 put_back:
 	dev_put(dev);
+	kfree(p);
 	return err;
 }
 

