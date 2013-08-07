From: Cong Wang <amwang@redhat.com>
Subject: A soft lockup in vxlan module
Date: Wed, 07 Aug 2013 09:23:54 +0800
Message-ID: <1375838634.11370.13.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654Ab3HGBYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 21:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stephen

You introduced a soft lockup in vxlan module in

commit fe5c3561e6f0ac7c9546209f01351113c1b77ec8
Author: stephen hemminger <stephen@networkplumber.org>
Date:   Sat Jul 13 10:18:18 2013 -0700

    vxlan: add necessary locking on device removal

The problem is that vxlan_dellink(), which is called with RTNL lock
held, tries to flush the workqueue synchronously, but apparently
igmp_join and igmp_leave work need to hold RTNL lock too, therefore we
have a soft lockup! This is 100% reproducible on my 2.6.32 backport
while running `modprobe -r vxlan`.

A quick but perhaps ugly fix is just releasing RTNL lock before calling
flush_workqueue():

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bf31d9..581d3d5 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1837,7 +1837,9 @@ static void vxlan_dellink(struct net_device *dev,
struct list_head *head)
        struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
        struct vxlan_dev *vxlan = netdev_priv(dev);
 
+       rtnl_unlock();
        flush_workqueue(vxlan_wq);
+       rtnl_lock();
 
        spin_lock(&vn->sock_lock);
        hlist_del_rcu(&vxlan->hlist);

However, I think a better way is still what I did, that is, removing
RTNL lock from ip_mc_join_group() and ip_mc_leave_group().

What do you think? Any other idea to fix it?

Thanks.
