From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: rtnl_link: fix use-after-free
Date: Sun, 20 Jan 2008 18:21:27 +0100
Message-ID: <47938317.1070906@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070001090206020903020903"
Cc: Pavel Emelianov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbYATRVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:21:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070001090206020903020903
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070001090206020903020903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 6e470bd53fb50632fe1878bb74bb8531a21b6731
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Jan 20 18:19:15 2008 +0100

    [NET]: rtnl_link: fix use-after-free
    
    When unregistering the rtnl_link_ops, all existing devices using
    the ops are destroyed. With nested devices this may lead to a
    use-after-free despite the use of for_each_netdev_safe() in case
    the upper device is next in the device list and is destroyed
    by the NETDEV_UNREGISTER notifier.
    
    The easy fix is to restart scanning the device list after removing
    a device. Alternatively we could add new devices to the front of
    the list to avoid having dependant devices follow the device they
    depend on. A third option would be to only restart scanning if
    dev->iflink of the next device matches dev->ifindex of the current
    one. For now this seems like the safest solution.
    
    With this patch, the veth rtnl_link_ops unregistration can use
    rtnl_link_unregister() directly since it now also handles destruction
    of multiple devices at once.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 43af9e9..3f67a29 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -459,19 +459,7 @@ static __init int veth_init(void)
 
 static __exit void veth_exit(void)
 {
-	struct veth_priv *priv, *next;
-
-	rtnl_lock();
-	/*
-	 * cannot trust __rtnl_link_unregister() to unregister all
-	 * devices, as each ->dellink call will remove two devices
-	 * from the list at once.
-	 */
-	list_for_each_entry_safe(priv, next, &veth_list, list)
-		veth_dellink(priv->dev);
-
-	__rtnl_link_unregister(&veth_link_ops);
-	rtnl_unlock();
+	rtnl_link_unregister(&veth_link_ops);
 }
 
 module_init(veth_init);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e1ba26f..fed95a3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -308,9 +308,12 @@ void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 	struct net *net;
 
 	for_each_net(net) {
+restart:
 		for_each_netdev_safe(net, dev, n) {
-			if (dev->rtnl_link_ops == ops)
+			if (dev->rtnl_link_ops == ops) {
 				ops->dellink(dev);
+				goto restart;
+			}
 		}
 	}
 	list_del(&ops->list);

--------------070001090206020903020903--
