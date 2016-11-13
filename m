From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v2] ip6_output: ensure flow saddr actually
	belongs to device
Date: Sun, 13 Nov 2016 20:02:51 +0100
Message-ID: <20161113190251.1027-1-Jason@zx2c4.com>
References: <405b2e79-854d-4c30-07b0-bd524137d2f6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <405b2e79-854d-4c30-07b0-bd524137d2f6@cumulusnetworks.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

This puts the IPv6 routing functions in parity with the IPv4 routing
functions. Namely, we now check in v6 that if a flowi6 requests an
saddr, the returned dst actually corresponds to a net device that has
that saddr. This mirrors the v4 logic with __ip_dev_find in
__ip_route_output_key_hash. In the event that the returned dst is not
for a dst with a dev that has the saddr, we return -EINVAL, just like
v4; this makes it easy to use the same error handlers for both cases.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
---
Changes from v1:
   This moves the check to the top and now sees if it's a valid address
   on _any_ device, not just the one in dst.

 include/net/ipv6.h    |  2 ++
 net/ipv6/ip6_output.c | 28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8fed1cd..e5dc14f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -914,6 +914,8 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 					 const struct in6_addr *final_dst);
 struct dst_entry *ip6_blackhole_route(struct net *net,
 				      struct dst_entry *orig_dst);
+struct net_device *__ip6_dev_find(struct net *net, struct in6_addr *addr,
+				  bool devref);
 
 /*
  *	skb processing functions
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..371170b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -916,6 +916,30 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 	return dst;
 }
 
+/**
+ * __ip6_dev_find - find the first device with a given source address.
+ * @net: the net namespace
+ * @addr: the source address
+ * @devref: if true, take a reference on the found device
+ *
+ * If a caller uses devref=false, it should be protected by RCU, or RTNL
+ */
+struct net_device *__ip6_dev_find(struct net *net, struct in6_addr *addr, bool devref)
+{
+	struct net_device *result;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, result) {
+		if (ipv6_chk_addr(net, addr, result, 1))
+			break;
+	}
+	if (result && devref)
+		dev_hold(result);
+	rcu_read_unlock();
+	return result;
+}
+EXPORT_SYMBOL(__ip6_dev_find);
+
 static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 			       struct dst_entry **dst, struct flowi6 *fl6)
 {
@@ -926,6 +950,10 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	int err;
 	int flags = 0;
 
+	if (!ipv6_addr_any(&fl6->saddr) &&
+	    !__ip6_dev_find(net, &fl6->saddr, false))
+		return -EINVAL;
+
 	/* The correct way to handle this would be to do
 	 * ip6_route_get_saddr, and then ip6_route_output; however,
 	 * the route-specific preferred source forces the
-- 
2.10.2
