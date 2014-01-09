From: hannes@stressinduktion.org
Subject: [PATCH net-next v3 2/3] ipv6: introduce ip6_dst_mtu_forward and protect forwarding path with it
Date: Thu,  9 Jan 2014 10:01:16 +0100
Message-ID: <1389258077-23282-3-git-send-email-hannes@stressinduktion.org>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbaAIJBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 04:01:33 -0500
In-Reply-To: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

In the IPv6 forwarding path we are only concerend about the outgoing
interface MTU, but also respect locked MTUs on routes. Tunnel provider
or IPSEC already have to recheck and if needed send PtB notifications
to the sending host in case the data does not fit into the packet with
added headers (we only know the final header sizes there, while also
using path MTU information).

The reason for this change is, that path MTU information can be injected
into the kernel via e.g. icmp_err protocol handler without verification
of local sockets. As such, this could cause the IPv6 forwarding path to
wrongfully emit Packet-too-Big errors and drop IPv6 packets.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: John Heffner <johnwheffner@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d1de956..ef02b26 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -321,6 +321,27 @@ static inline int ip6_forward_finish(struct sk_buff *skb)
 	return dst_output(skb);
 }
 
+static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
+{
+	unsigned int mtu;
+	struct inet6_dev *idev;
+
+	if (dst_metric_locked(dst, RTAX_MTU)) {
+		mtu = dst_metric_raw(dst, RTAX_MTU);
+		if (mtu)
+			return mtu;
+	}
+
+	mtu = IPV6_MIN_MTU;
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
+	if (idev)
+		mtu = idev->cnf.mtu6;
+	rcu_read_unlock();
+
+	return mtu;
+}
+
 int ip6_forward(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -441,7 +462,7 @@ int ip6_forward(struct sk_buff *skb)
 		}
 	}
 
-	mtu = dst_mtu(dst);
+	mtu = ip6_dst_mtu_forward(dst);
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
-- 
1.8.4.2
