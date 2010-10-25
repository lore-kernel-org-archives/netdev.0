From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/4] vlan: rcu annotations
Date: Mon, 25 Oct 2010 09:31:58 +0200
Message-ID: <1287991918.2658.5379.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45124 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab0JYHcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 03:32:08 -0400
Received: by wwe15 with SMTP id 15so3170539wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:32:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(struct net_device)->vlgrp is rcu protected :

add __rcu annotation and proper rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 +-
 net/8021q/vlan.c          |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fcd3dda..ceefb441 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -944,7 +944,7 @@ struct net_device {
 	/* Protocol specific pointers */
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-	struct vlan_group	*vlgrp;		/* VLAN group */
+	struct vlan_group __rcu	*vlgrp;		/* VLAN group */
 #endif
 #ifdef CONFIG_NET_DSA
 	void			*dsa_ptr;	/* dsa specific data */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 05b867e..52077ca 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -112,7 +112,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	ASSERT_RTNL();
 
-	grp = real_dev->vlgrp;
+	grp = rtnl_dereference(real_dev->vlgrp);
 	BUG_ON(!grp);
 
 	/* Take it out of our own structures, but be sure to interlock with
@@ -177,7 +177,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
 
-	grp = real_dev->vlgrp;
+	grp = rtnl_dereference(real_dev->vlgrp);
 	if (!grp) {
 		ngrp = grp = vlan_group_alloc(real_dev);
 		if (!grp)
@@ -385,7 +385,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
 	}
 
-	grp = dev->vlgrp;
+	grp = rtnl_dereference(dev->vlgrp);
 	if (!grp)
 		goto out;
 


