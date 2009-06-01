From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 17:13:43 +0200
Message-ID: <4A23F027.3060907@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040908090504060905060800"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:36090 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbZFAPNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2009 11:13:50 -0400
Received: from smtp5-g21.free.fr (localhost [127.0.0.1])
	by smtp5-g21.free.fr (Postfix) with ESMTP id CE82AD4819C
	for <netdev@vger.kernel.org>; Mon,  1 Jun 2009 17:13:46 +0200 (CEST)
Received: from [192.168.1.1] (shm67-6-88-178-145-40.fbx.proxad.net [88.178.145.40])
	by smtp5-g21.free.fr (Postfix) with ESMTP id D0CA5D48125
	for <netdev@vger.kernel.org>; Mon,  1 Jun 2009 17:13:43 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040908090504060905060800
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

when network stack receives a packet, it didn't check value of ttl/hop limit
field. RFC indicates that a router must drop the packet if this field is 0.


Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>


--------------040908090504060905060800
Content-Type: text/x-diff;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 1a58a6f..9253b34 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -376,6 +376,7 @@ drop:
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct iphdr *iph;
+	struct in_device *in_dev;
 	u32 len;
 
 	/* When the interface is in promisc. mode, drop all the crap
@@ -415,6 +416,28 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	iph = ip_hdr(skb);
 
+	/*
+	 * RFC792 Page 6
+	 *    If the gateway processing a datagram finds the time to live field
+	 *    is zero it must discard the datagram.  The gateway may also notify
+	 *    the source host via the time exceeded message.
+	 */
+	if ((in_dev = in_dev_get(dev)) != NULL) {
+		if (iph->ttl == 0 && IPV4_DEVCONF(in_dev->cnf, FORWARDING)) {
+			if (likely(skb->dst == NULL)) {
+				int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
+							 skb->dev);
+				if (unlikely(err))
+					goto inhdr_error;
+			}
+			icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
+			goto inhdr_error;
+		}
+	} else {
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		goto drop;
+	}
+
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
 		goto inhdr_error;
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f171e8d..fee40f9 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -103,6 +103,19 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 		goto err;
 
 	/*
+	 * RFC4443 3.3
+	 *    If a router receives a packet with a Hop Limit of zero, or if a
+	 *    router decrements a packet's Hop Limit to zero, it MUST discard the
+	 *    packet and originate an ICMPv6 Time Exceeded message with Code 0 to
+	 *    the source of the packet.
+	 */
+	if (hdr->hop_limit == 0 && idev->cnf.forwarding) {
+		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
+			    0, skb->dev);
+		goto err;
+	}
+
+	/*
 	 * RFC4291 2.5.3
 	 * A packet received on an interface with a destination address
 	 * of loopback must be dropped.

--------------040908090504060905060800--
