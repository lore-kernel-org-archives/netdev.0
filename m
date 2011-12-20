From: Wang Xingtong <wangxingtong@cn.fujitsu.com>
Subject: [PATCH] IPv6 : add multicast routing verify which net_device is lo
Date: Tue, 20 Dec 2011 14:13:46 +0800
Message-ID: <4EF0279A.30800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59867 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab1LTGOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 01:14:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In currently routing subsystem, when we lookup a multicast routing
to send muticast packets to outside, rt6_device_match will return
the rt6_info which it's match first. if we add a multicast route on
loopback devices beforce the others interface, rt6_device_match will
retrun the rt6_info which rt6i_dev->name is "lo". But, obviously,
we can't send a muticast packet to outside using loopback devices.
It case all multicast packets blocking.

Commit 4af04aba93f47699e disabled kernel add multicast route on lo
automatically. However,  we can't surmise the routing-add order or
interdict add multicast routing on loopback devices in user space.
The bug still exist. So, i think more stronger routing subsystem is
necessary.

Signed-off-by: Wang xingtong <wangxingtong@cn.fujitsu.com>

---
  net/ipv6/route.c |   19 ++++++++++++++++---
  1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b582a0a..3871ef4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -334,9 +334,16 @@ static inline struct rt6_info 
*rt6_device_match(struct net *net,
      struct rt6_info *local = NULL;
      struct rt6_info *sprt;

-    if (!oif && ipv6_addr_any(saddr))
+    if (!oif && ipv6_addr_any(saddr)){
+        if (unlikely(rt->rt6i_dev->flags & IFF_LOOPBACK &&
+            ipv6_addr_is_multicast(&rt->rt6i_dst.addr))){
+            rt=rt->dst.rt6_next;
+            goto match;
+        }
          goto out;
+    }

+match:
      for (sprt = rt; sprt; sprt = sprt->dst.rt6_next) {
          struct net_device *dev = sprt->rt6i_dev;

@@ -355,9 +362,15 @@ static inline struct rt6_info 
*rt6_device_match(struct net *net,
                  local = sprt;
              }
          } else {
-            if (ipv6_chk_addr(net, saddr, dev,
-                      flags & RT6_LOOKUP_F_IFACE))
+            if (ipv6_addr_any(saddr)){
+                if (unlikely(rt->rt6i_dev->flags & IFF_LOOPBACK &&
+                    ipv6_addr_is_multicast(&rt->rt6i_dst.addr))){
+                    continue;
                  return sprt;
+            }
+            else if (ipv6_chk_addr(net, saddr, dev,
+                      flags & RT6_LOOKUP_F_IFACE))
+                    return sprt;
          }
      }

-- 
1.7.1
