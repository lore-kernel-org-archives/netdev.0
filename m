From: Yan Burman <yanb@mellanox.com>
Subject: [PATCH net] net/vxlan: Use the underlying device index when joining/leaving multicast groups
Date: Thu, 20 Dec 2012 15:36:08 +0200
Message-ID: <1356010568-21644-1-git-send-email-yanb@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Yan Burman <yanb@mellanox.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:35017 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751744Ab2LTNgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 08:36:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket calls from vxlan to join/leave multicast group aren't
using the index of the underlying device, as a result the stack uses
the first interface that is up. This results in vxlan being non functional
over a device which isn't the 1st to be up.
Fix this by providing the iflink field to the vxlan instance
to the multicast calls.

Signed-off-by: Yan Burman <yanb@mellanox.com>
---
 drivers/net/vxlan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b3fdf6..40f2cc1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -505,7 +505,8 @@ static int vxlan_join_group(struct net_device *dev)
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct sock *sk = vn->sock->sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr = vxlan->gaddr,
+		.imr_multiaddr.s_addr	= vxlan->gaddr,
+		.imr_ifindex		= vxlan->link,
 	};
 	int err;
 
@@ -532,7 +533,8 @@ static int vxlan_leave_group(struct net_device *dev)
 	int err = 0;
 	struct sock *sk = vn->sock->sk;
 	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr = vxlan->gaddr,
+		.imr_multiaddr.s_addr	= vxlan->gaddr,
+		.imr_ifindex		= vxlan->link,
 	};
 
 	/* Only leave group when last vxlan is done. */
-- 
1.7.11.3
