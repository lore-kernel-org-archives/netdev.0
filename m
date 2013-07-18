From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/2] vxlan: unregister on namespace exit
Date: Thu, 18 Jul 2013 08:38:26 -0700
Message-ID: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50734 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758607Ab3GRPqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 11:46:33 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so3341261pad.30
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 08:46:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory leaks and other badness from VXLAN network namespace
teardown. When network namespace is removed, all the vxlan devices should
be unregistered (not closed).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-07-17 16:32:10.826955800 -0700
+++ b/drivers/net/vxlan.c	2013-07-17 16:47:35.275690741 -0700
@@ -1878,10 +1878,12 @@ static __net_exit void vxlan_exit_net(st
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan;
+	LIST_HEAD(list);
 
 	rtnl_lock();
-	list_for_each_entry(vxlan, &vn->vxlan_list, next)
-		dev_close(vxlan->dev);
+	list_for_each_entry(vxlan, &vn->vxlan_list, next)
+		unregister_netdevice_queue(vxlan->dev, &list);
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
 
