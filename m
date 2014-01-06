From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 2/3] ipv6: use interface or locked route MTU for determination whether packet is too large
Date: Mon, 6 Jan 2014 09:48:32 +0100
Message-ID: <20140106084832.GA5805@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbaAFIsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 03:48:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the IPv6 forwarding path we are only concerend about the outgoing
interface MTU, but also respect locked MTUs on routes. Tunnel provider
or IPSEC already have to recheck and if needed send PtB notifications
to the sending host in case the data does not fit into the packet with
added headers (we only know the header sizes there, while also using
path MTU information there).

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
v2)
* default disabled
v3)
* complete rewrite
* always only honor interface mtu
* no knob anymore

 net/ipv6/ip6_output.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 788c01a..9ab013ba 100644
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
