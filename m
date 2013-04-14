From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next] vxlan: don't bypass encapsulation for multi- and broadcasts
Date: Sun, 14 Apr 2013 12:21:51 +0300
Message-ID: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:48807 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750822Ab3DNJ2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 05:28:24 -0400
Received: by mail-fa0-f72.google.com with SMTP id t1so3646687fae.3
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 02:28:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
and therefore will be sent out bypassing encapsulation. This breaks
delivery of packets sent to the vxlan multicast group.
Disabling encapsulation bypass for multicasts and broadcasts fixes the
issue.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 725aba3..97a306c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1014,7 +1014,8 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	/* Bypass encapsulation if the destination is local */
-	if (rt->rt_flags & RTCF_LOCAL) {
+	if (rt->rt_flags & RTCF_LOCAL &&
+	    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
 		struct vxlan_dev *dst_vxlan;
 
 		ip_rt_put(rt);
-- 
1.8.1.5
