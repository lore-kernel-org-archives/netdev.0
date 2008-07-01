From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v2 [PATCH net-next 3/7] bridge: Check return of dev_set_promiscuity
Date: Tue, 01 Jul 2008 11:25:26 +0800
Message-ID: <4869A3A6.9010801@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65481 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbYGAD37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 23:29:59 -0400
In-Reply-To: <4869A251.108@cn.fujitsu.com>
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
 
-- 1.5.3.4

