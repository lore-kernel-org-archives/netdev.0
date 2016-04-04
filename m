From: Michal Kazior <michal.kazior@tieto.com>
Subject: [RFC] ipv6: allow bypassing cross-intf routing limits
Date: Mon,  4 Apr 2016 10:15:55 +0200
Message-ID: <1459757755-25424-1-git-send-email-michal.kazior@tieto.com>
References: <CA+BoTQnC-OKZ8eRohBYetfyW6-xo31kJtS8Lh+svxC=fkVsrXw@mail.gmail.com>
Cc: Michal Kazior <michal.kazior@tieto.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:34303 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682AbcDDIOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 04:14:34 -0400
Received: by mail-lb0-f171.google.com with SMTP id vo2so148738329lbb.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 01:14:34 -0700 (PDT)
In-Reply-To: <CA+BoTQnC-OKZ8eRohBYetfyW6-xo31kJtS8Lh+svxC=fkVsrXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some use-cases to allow link-local
routing for bridging purposes.

One of these is allowing transparent 802.11
bridging. Due to 802.11 framing limitations many
Access Points make it impossible to create bridges
on Client endpoints because they can't maintain
Destination/Source/Transmitter/Receiver address
distinction with only 3 addresses in frame header.

The default behavior, i.e. link-local traffic
being non-routable, remains. The user has to
explicitly enable the bypass when defining a given
route.

Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---
For more background see:

  http://www.spinics.net/lists/netdev/msg371022.html



 include/uapi/linux/rtnetlink.h |  8 ++++++--
 net/ipv6/ip6_output.c          | 11 +++++++++--
 net/ipv6/route.c               |  4 ++++
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index ca764b5da86d..a577eec0e56e 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -424,9 +424,13 @@ enum {
 #define RTAX_FEATURE_SACK	(1 << 1)
 #define RTAX_FEATURE_TIMESTAMP	(1 << 2)
 #define RTAX_FEATURE_ALLFRAG	(1 << 3)
+#define RTAX_FEATURE_XFACE	(1 << 4)
 
-#define RTAX_FEATURE_MASK	(RTAX_FEATURE_ECN | RTAX_FEATURE_SACK | \
-				 RTAX_FEATURE_TIMESTAMP | RTAX_FEATURE_ALLFRAG)
+#define RTAX_FEATURE_MASK	(RTAX_FEATURE_ECN | \
+				 RTAX_FEATURE_SACK | \
+				 RTAX_FEATURE_TIMESTAMP | \
+				 RTAX_FEATURE_ALLFRAG | \
+				 RTAX_FEATURE_XFACE)
 
 struct rta_session {
 	__u8	proto;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9428345d3a07..9abb42acb6ad 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -283,6 +283,7 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	u8 nexthdr = hdr->nexthdr;
 	__be16 frag_off;
 	int offset;
+	int feat = dst_metric_raw(skb_dst(skb), RTAX_FEATURES);
 
 	if (ipv6_ext_hdr(nexthdr)) {
 		offset = ipv6_skip_exthdr(skb, sizeof(*hdr), &nexthdr, &frag_off);
@@ -320,8 +321,11 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	 * The proxying router can't forward traffic sent to a link-local
 	 * address, so signal the sender and discard the packet. This
 	 * behavior is clarified by the MIPv6 specification.
+	 *
+	 * It's useful to allow an override for transparent traffic relay.
 	 */
-	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) {
+	if ((ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
+	    !(feat & RTAX_FEATURE_XFACE)) {
 		dst_link_failure(skb);
 		return -1;
 	}
@@ -485,12 +489,15 @@ int ip6_forward(struct sk_buff *skb)
 			inet_putpeer(peer);
 	} else {
 		int addrtype = ipv6_addr_type(&hdr->saddr);
+		int feat = dst_metric_raw(dst, RTAX_FEATURES);
 
 		/* This check is security critical. */
 		if (addrtype == IPV6_ADDR_ANY ||
 		    addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
 			goto error;
-		if (addrtype & IPV6_ADDR_LINKLOCAL) {
+
+		if ((addrtype & IPV6_ADDR_LINKLOCAL) &&
+		    !(feat & RTAX_FEATURE_XFACE)) {
 			icmpv6_send(skb, ICMPV6_DEST_UNREACH,
 				    ICMPV6_NOT_NEIGHBOUR, 0);
 			goto error;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed446639219c..560c99853907 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -629,8 +629,12 @@ static inline enum rt6_nud_state rt6_check_neigh(struct rt6_info *rt)
 static int rt6_score_route(struct rt6_info *rt, int oif,
 			   int strict)
 {
+	int feat = dst_metric_raw(&rt->dst, RTAX_FEATURES);
 	int m;
 
+	if (feat & RTAX_FEATURE_XFACE)
+		strict &= ~RT6_LOOKUP_F_IFACE;
+
 	m = rt6_check_dev(rt, oif);
 	if (!m && (strict & RT6_LOOKUP_F_IFACE))
 		return RT6_NUD_FAIL_HARD;
-- 
2.1.4
