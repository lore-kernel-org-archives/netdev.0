From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: Check return of dev_set_promiscuity (v2)
Date: Fri, 20 Jun 2008 20:48:55 -0700
Message-ID: <20080620204855.351c3cbb@extreme>
References: <485AFFE4.4000300@cn.fujitsu.com>
	<20080619181819.15b2cc9d@extreme>
	<485B16BB.1000604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162AbYFUDtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 23:49:03 -0400
In-Reply-To: <485B16BB.1000604@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alternate version of Wang Chen's patch to handle dev_set_promiscuity
errors.  I tried and make unwinds clearer here. The kobject_put can
just be replace by immediate kfree since object never gets registered
if going through that path.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_if.c	2008-06-20 15:57:51.000000000 -0700
+++ b/net/bridge/br_if.c	2008-06-20 16:15:47.000000000 -0700
@@ -373,10 +373,15 @@ int br_add_if(struct net_bridge *br, str
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto err_free;
+
+
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
-		goto err0;
+		goto err_unset_promiscuity;
 
 	err = br_fdb_insert(br, p, dev->dev_addr);
 	if (err)
@@ -388,7 +393,6 @@ int br_add_if(struct net_bridge *br, str
 
 	rcu_assign_pointer(dev->br_port, p);
 	dev_disable_lro(dev);
-	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -408,14 +412,17 @@ int br_add_if(struct net_bridge *br, str
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
+
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
 	kobject_del(&p->kobj);
 	goto put_back;
-err0:
-	kobject_put(&p->kobj);
 
+err_unset_promiscuity:
+	dev_set_promiscuity(dev, -1);
+err_free:
+	kfree(p);
 put_back:
 	dev_put(dev);
 	return err;
