From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] ipv6: release rt6->rt6i_idev properly during ifdown
Date: Mon, 14 Aug 2017 10:44:59 -0700
Message-ID: <20170814174459.3569-1-tracywwnj@gmail.com>
Cc: Martin KaFai Lau <kafai@fb.com>, David Ahern <dsahern@gmail.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35013 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdHNRpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 13:45:15 -0400
Received: by mail-pg0-f41.google.com with SMTP id v189so51468800pgd.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 10:45:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

When a dst is created by addrconf_dst_alloc() for a host route or an
anycast route, dst->dev points to loopback dev while rt6->rt6i_idev
points to a real device.
When the real device goes down, the current cleanup code only checks for
dst->dev and assumes rt6->rt6i_idev->dev is the same. This causes the
refcount leak on the real device in the above situation.
This patch makes sure to always release the refcount taken on
rt6->rt6i_idev during dst_dev_put().

Fixes: 587fea741134 ("ipv6: mark DST_NOGC and remove the operation of
dst_free()")
Reported-by: John Stultz <john.stultz@linaro.org>
Tested-by: John Stultz <john.stultz@linaro.org>
Tested-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96a819d..8d53abd96181 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -417,14 +417,11 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	struct net_device *loopback_dev =
 		dev_net(dev)->loopback_dev;
 
-	if (dev != loopback_dev) {
-		if (idev && idev->dev == dev) {
-			struct inet6_dev *loopback_idev =
-				in6_dev_get(loopback_dev);
-			if (loopback_idev) {
-				rt->rt6i_idev = loopback_idev;
-				in6_dev_put(idev);
-			}
+	if (idev && idev->dev != loopback_dev) {
+		struct inet6_dev *loopback_idev = in6_dev_get(loopback_dev);
+		if (loopback_idev) {
+			rt->rt6i_idev = loopback_idev;
+			in6_dev_put(idev);
 		}
 	}
 }
-- 
2.14.0.434.g98096fd7a8-goog
