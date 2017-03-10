From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] mpls: Do not decrement alive counter for unregister events
Date: Fri, 10 Mar 2017 14:11:39 -0800
Message-ID: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35725 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932482AbdCJWLq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 17:11:46 -0500
Received: by mail-pf0-f176.google.com with SMTP id j5so46608473pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 14:11:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multipath routes can be rendered usesless when a device in one of the
paths is deleted. For example:

$ ip -f mpls ro ls
100
	nexthop as to 200 via inet 172.16.2.2  dev virt12
	nexthop as to 300 via inet 172.16.3.2  dev br0
101
	nexthop as to 201 via inet6 2000:2::2  dev virt12
	nexthop as to 301 via inet6 2000:3::2  dev br0

$ ip li del br0

When br0 is deleted the other hop is not considered in
mpls_select_multipath because of the alive check -- rt_nhn_alive
is 0.

rt_nhn_alive is decremented once in mpls_ifdown when the device is taken
down (NETDEV_DOWN) and again when it is deleted (NETDEV_UNREGISTER). For
a 2 hop route, deleting one device drops the alive count to 0. Since
devices are taken down before unregistering, the decrement on
NETDEV_UNREGISTER is redundant.

Fixes: c89359a42e2a4 ("mpls: support for dead routes")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index ccdac9c44fdc..22a9971aa484 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1288,7 +1288,8 @@ static void mpls_ifdown(struct net_device *dev, int event)
 				/* fall through */
 			case NETDEV_CHANGE:
 				nh->nh_flags |= RTNH_F_LINKDOWN;
-				ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;
+				if (event != NETDEV_UNREGISTER)
+					ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;
 				break;
 			}
 			if (event == NETDEV_UNREGISTER)
-- 
2.1.4
