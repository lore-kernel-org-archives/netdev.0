From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/2] vxlan: lock RCU on TX path
Date: Fri, 24 Feb 2017 11:43:36 -0800
Message-ID: <20170224194337.67538-2-jakub.kicinski@netronome.com>
References: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Benc <jbenc@redhat.com>,
        "John W . Linville" <linville@tuxdriver.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35941 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdBXTug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:50:36 -0500
Received: by mail-pg0-f42.google.com with SMTP id s67so15092223pgb.3
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 11:50:27 -0800 (PST)
In-Reply-To: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no guarantees that callers of the TX path will hold
the RCU lock.  Grab it explicitly.

Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/vxlan.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4e27c5b09600..e53ee696c962 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2108,6 +2108,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
 				     vxlan->cfg.port_max, true);
 
+	rcu_read_lock();
 	if (dst->sa.sa_family == AF_INET) {
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
 		struct rtable *rt;
@@ -2130,7 +2131,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    dst_port, vni, &rt->dst,
 						    rt->rt_flags);
 			if (err)
-				return;
+				goto out_unlock;
 		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
 			df = htons(IP_DF);
 		}
@@ -2169,7 +2170,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 						    dst_port, vni, ndst,
 						    rt6i_flags);
 			if (err)
-				return;
+				goto out_unlock;
 		}
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
@@ -2186,6 +2187,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     label, src_port, dst_port, !udp_sum);
 #endif
 	}
+out_unlock:
+	rcu_read_unlock();
 	return;
 
 drop:
@@ -2194,6 +2197,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	return;
 
 tx_error:
+	rcu_read_unlock();
 	if (err == -ELOOP)
 		dev->stats.collisions++;
 	else if (err == -ENETUNREACH)
-- 
2.11.0
