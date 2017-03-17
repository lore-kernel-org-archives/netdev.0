From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: vrf: Reset rt6i_idev in local dst after put
Date: Fri, 17 Mar 2017 16:07:11 -0700
Message-ID: <1489792031-13547-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32856 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdCRA6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 20:58:15 -0400
Received: by mail-pf0-f172.google.com with SMTP id e129so5317015pfh.0
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 17:57:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF driver takes a reference to the inet6_dev on the VRF device for
its rt6_local dst when handling local traffic through the VRF device as
a loopback. When the device is deleted the driver does a put on the idev
but does not reset rt6i_idev in the rt6_info struct. When the dst is
destroyed, dst_destroy calls ip6_dst_destroy which does a second put for
what is essentially the same reference causing it to be prematurely freed.
Reset rt6i_idev after the put in the vrf driver.

Fixes: b4869aa2f881e ("net: vrf: ipv6 support for local traffic to
                       local addresses")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7f28021d9d93..761ea041b018 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -462,8 +462,10 @@ static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 	}
 
 	if (rt6_local) {
-		if (rt6_local->rt6i_idev)
+		if (rt6_local->rt6i_idev) {
 			in6_dev_put(rt6_local->rt6i_idev);
+			rt6_local->rt6i_idev = NULL;
+		}
 
 		dst = &rt6_local->dst;
 		dev_put(dst->dev);
-- 
2.1.4
