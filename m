From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: [PATCH RFC] xfrm6: handling fragment
Date: Fri, 31 Oct 2008 18:18:01 +0100
Message-ID: <490B3DC9.906@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080200050401060606000004"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:60255 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbYJaRSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 13:18:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080200050401060606000004
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

RFC4301 Section 7.1 says:

"7.1.  Tunnel Mode SAs that Carry Initial and Non-Initial Fragments

     All implementations MUST support tunnel mode SAs that are configured
     to pass traffic without regard to port field (or ICMP type/code or
     Mobility Header type) values.  If the SA will carry traffic for
     specified protocols, the selector set for the SA MUST specify the
     port fields (or ICMP type/code or Mobility Header type) as ANY.  An
     SA defined in this fashion will carry all traffic including initial
     and non-initial fragments for the indicated Local/Remote addresses
     and specified Next Layer protocol(s)."

But for IPv6, fragment is treated as a protocol. Would the following patch be 
acceptable to catch protocol transported in fragmented packet?
In IPv4, there is no problem.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------080200050401060606000004
Content-Type: text/x-patch;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 08e4cbb..604bc0a 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -144,6 +144,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 static inline void
 _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
+	int onlyproto = 0;
 	u16 offset = skb_network_header_len(skb);
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct ipv6_opt_hdr *exthdr;
@@ -159,6 +160,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		exthdr = (struct ipv6_opt_hdr *)(nh + offset);
 
 		switch (nexthdr) {
+		case NEXTHDR_FRAGMENT:
+			onlyproto = 1;
 		case NEXTHDR_ROUTING:
 		case NEXTHDR_HOP:
 		case NEXTHDR_DEST:
@@ -172,7 +175,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
-			if (pskb_may_pull(skb, nh + offset + 4 - skb->data)) {
+			if (!onlyproto && pskb_may_pull(skb, nh + offset + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)exthdr;
 
 				fl->fl_ip_sport = ports[!!reverse];
@@ -182,7 +185,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			return;
 
 		case IPPROTO_ICMPV6:
-			if (pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
+			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
 				u8 *icmp = (u8 *)exthdr;
 
 				fl->fl_icmp_type = icmp[0];
@@ -193,7 +196,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 		case IPPROTO_MH:
-			if (pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
+			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
 				mh = (struct ip6_mh *)exthdr;
 

--------------080200050401060606000004--
