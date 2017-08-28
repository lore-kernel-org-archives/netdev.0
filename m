From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] ipv6: Use rt6i_idev index for echo replies to a local address
Date: Mon, 28 Aug 2017 13:53:34 -0700
Message-ID: <1503953614-32395-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37988 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1Uxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 16:53:45 -0400
Received: by mail-pg0-f68.google.com with SMTP id t3so1154549pgt.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 13:53:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tariq repored local pings to linklocal address is failing:
$ ifconfig ens8
ens8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 11.141.16.6  netmask 255.255.0.0  broadcast 11.141.255.255
        inet6 fe80::7efe:90ff:fecb:7502  prefixlen 64  scopeid 0x20<link>
        ether 7c:fe:90:cb:75:02  txqueuelen 1000  (Ethernet)
        RX packets 12  bytes 1164 (1.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 30  bytes 2484 (2.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

$  /bin/ping6 -c 3 fe80::7efe:90ff:fecb:7502%ens8
PING fe80::7efe:90ff:fecb:7502%ens8(fe80::7efe:90ff:fecb:7502) 56 data bytes

--- fe80::7efe:90ff:fecb:7502%ens8 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2043ms

icmpv6_echo_reply needs to use the rt6i_idev dev index for local traffic
similar to how icmp6_send does. Convert the change for icmp6_send into a
helper that can be used in both places. Add the long over due
skb_rt6_info helper to convert dst on an skb to rt6_info similar to
skb_rtable for ipv4.

Fixes: 4832c30d5458 ("net: ipv6: put host and anycast routes on
       device with address")
Reported-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip6_route.h | 10 ++++++++++
 net/ipv6/icmp.c         | 33 ++++++++++++++++++++-------------
 2 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 882bc3c7ccde..ee96f402cb75 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -164,6 +164,16 @@ void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
 
+static inline const struct rt6_info *skb_rt6_info(const struct sk_buff *skb)
+{
+	const struct dst_entry *dst = skb_dst(skb);
+	const struct rt6_info *rt6 = NULL;
+
+	if (dst)
+		rt6 = container_of(dst, struct rt6_info, dst);
+
+	return rt6;
+}
 
 /*
  *	Store a destination cache entry in a socket
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index dd7608cf1d72..c25b5954cfbb 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -399,6 +399,24 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	return ERR_PTR(err);
 }
 
+static int icmp6_iif(const struct sk_buff *skb)
+{
+	int iif = skb->dev->ifindex;
+
+	/* for local traffic to local address, skb dev is the loopback
+	 * device. Check if there is a dst attached to the skb and if so
+	 * get the real device index.
+	 */
+	if (unlikely(iif == LOOPBACK_IFINDEX)) {
+		const struct rt6_info *rt6 = skb_rt6_info(skb);
+
+		if (rt6)
+			iif = rt6->rt6i_idev->dev->ifindex;
+	}
+
+	return iif;
+}
+
 /*
  *	Send an ICMP message in response to a packet in error
  */
@@ -460,18 +478,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	 */
 
 	if (__ipv6_addr_needs_scope_id(addr_type)) {
-		iif = skb->dev->ifindex;
-
-		/* for local packets, get the real device index */
-		if (iif == LOOPBACK_IFINDEX) {
-			dst = skb_dst(skb);
-			if (dst) {
-				struct rt6_info *rt;
-
-				rt = container_of(dst, struct rt6_info, dst);
-				iif = rt->rt6i_idev->dev->ifindex;
-			}
-		}
+		iif = icmp6_iif(skb);
 	} else {
 		dst = skb_dst(skb);
 		iif = l3mdev_master_ifindex(dst ? dst->dev : skb->dev);
@@ -694,7 +701,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.daddr = ipv6_hdr(skb)->saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
-	fl6.flowi6_oif = skb->dev->ifindex;
+	fl6.flowi6_oif = icmp6_iif(skb);
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	fl6.flowi6_mark = mark;
 	fl6.flowi6_uid = sock_net_uid(net, NULL);
-- 
2.1.4
