From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Resent][PATCH 1/2] inet6: Conversion from u8 to int
Date: Sun,  9 Aug 2009 20:12:48 +0200
Message-ID: <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <resolve_IPV6_TCLASS>
 <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51966 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752541AbZHISNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 14:13:06 -0400
In-Reply-To: <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces assignments of the type "int on LHS" = "u8 on RHS" with
simpler code. The LHS can express all of the unsigned right hand side
values, hence the assigned value can not be negative.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/icmp.c          |   17 ++++-------------
 net/ipv6/ip6_output.c    |   15 +++++----------
 net/ipv6/ipv6_sockglue.c |    2 --
 net/ipv6/raw.c           |    5 +----
 net/ipv6/udp.c           |    5 +----
 5 files changed, 11 insertions(+), 33 deletions(-)

--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1037,8 +1037,6 @@ static int do_ipv6_getsockopt(struct soc
 
 	case IPV6_TCLASS:
 		val = np->tclass;
-		if (val < 0)
-			val = 0;
 		break;
 
 	case IPV6_RECVTCLASS:
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -877,11 +877,8 @@ static int rawv6_sendmsg(struct kiocb *i
 			hlimit = ip6_dst_hoplimit(dst);
 	}
 
-	if (tclass < 0) {
+	if (tclass < 0)
 		tclass = np->tclass;
-		if (tclass < 0)
-			tclass = 0;
-	}
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -900,11 +900,8 @@ do_udp_sendmsg:
 			hlimit = ip6_dst_hoplimit(dst);
 	}
 
-	if (tclass < 0) {
+	if (tclass < 0)
 		tclass = np->tclass;
-		if (tclass < 0)
-			tclass = 0;
-	}
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -323,7 +323,7 @@ void icmpv6_send(struct sk_buff *skb, u8
 	int iif = 0;
 	int addr_type = 0;
 	int len;
-	int hlimit, tclass;
+	int hlimit;
 	int err = 0;
 
 	if ((u8 *)hdr < skb->head ||
@@ -469,10 +469,6 @@ route_done:
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	tclass = np->tclass;
-	if (tclass < 0)
-		tclass = 0;
-
 	msg.skb = skb;
 	msg.offset = skb_network_offset(skb);
 	msg.type = type;
@@ -488,8 +484,8 @@ route_done:
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
 			      len + sizeof(struct icmp6hdr),
-			      sizeof(struct icmp6hdr),
-			      hlimit, tclass, NULL, &fl, (struct rt6_info*)dst,
+			      sizeof(struct icmp6hdr), hlimit,
+			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
 			      MSG_DONTWAIT);
 	if (err) {
 		ip6_flush_pending_frames(sk);
@@ -522,7 +518,6 @@ static void icmpv6_echo_reply(struct sk_
 	struct dst_entry *dst;
 	int err = 0;
 	int hlimit;
-	int tclass;
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
@@ -562,10 +557,6 @@ static void icmpv6_echo_reply(struct sk_
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	tclass = np->tclass;
-	if (tclass < 0)
-		tclass = 0;
-
 	idev = in6_dev_get(skb->dev);
 
 	msg.skb = skb;
@@ -573,7 +564,7 @@ static void icmpv6_echo_reply(struct sk_
 	msg.type = ICMPV6_ECHO_REPLY;
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), hlimit, tclass, NULL, &fl,
+				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl,
 				(struct rt6_info*)dst, MSG_DONTWAIT);
 
 	if (err) {
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -206,7 +206,8 @@ int ip6_xmit(struct sock *sk, struct sk_
 	struct ipv6hdr *hdr;
 	u8  proto = fl->proto;
 	int seg_len = skb->len;
-	int hlimit, tclass;
+	int hlimit = -1;
+	int tclass = 0;
 	u32 mtu;
 
 	if (opt) {
@@ -249,19 +250,13 @@ int ip6_xmit(struct sock *sk, struct sk_
 	/*
 	 *	Fill in the IPv6 header
 	 */
-
-	hlimit = -1;
-	if (np)
+	if (np) {
+		tclass = np->tclass;
 		hlimit = np->hop_limit;
+	}
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	tclass = -1;
-	if (np)
-		tclass = np->tclass;
-	if (tclass < 0)
-		tclass = 0;
-
 	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | fl->fl6_flowlabel;
 
 	hdr->payload_len = htons(seg_len);
