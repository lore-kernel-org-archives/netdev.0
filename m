From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] vxlan: fix a regression of igmp join
Date: Wed,  7 Aug 2013 16:35:45 +0800
Message-ID: <1375864545-5721-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756506Ab3HGIgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 04:36:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This is a regression introduced by:

	commit 3fc2de2faba387218bdf9dbc6b13f513ac3b060a
	Author: stephen hemminger <stephen@networkplumber.org>
	Date:   Thu Jul 18 08:40:15 2013 -0700

	    vxlan: fix igmp races

Before this commit, the old code was:

       if (vxlan_group_used(vn, vxlan->default_dst.remote_ip))
               ip_mc_join_group(sk, &mreq);
       else
               ip_mc_leave_group(sk, &mreq);

therefore we shoud check vxlan_group_used(), not its opposite,
for igmp_join.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bf31d9..f3ba986 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1430,7 +1430,7 @@ static int vxlan_open(struct net_device *dev)
 		return -ENOTCONN;
 
 	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)) &&
-	    ! vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
+	    vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_join);
