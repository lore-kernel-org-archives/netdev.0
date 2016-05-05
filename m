From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/13] net: ipv6: tcp reset, icmp need to consider L3 domain
Date: Wed,  4 May 2016 20:33:21 -0700
Message-ID: <1462419210-10463-5-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36172 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817AbcEEDeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:12 -0400
Received: by mail-pf0-f177.google.com with SMTP id c189so33687744pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:12 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Responses for packets to unused ports are getting lost with L3 domains.

IPv4 has ip_send_unicast_reply for sending TCP responses which accounts
for L3 domains; update the IPv6 counterpart tcp_v6_send_response.
For icmp the L3 master check needs to be moved up in icmp6_send
to properly respond to UDP packets to a port with no listener.

Fixes: ca254490c8df ("net: Add VRF support to IPv6 stack")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/icmp.c     | 5 ++---
 net/ipv6/tcp_ipv6.c | 7 ++++++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9554b99a8508..4527285fcaa2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -446,6 +446,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	if (__ipv6_addr_needs_scope_id(addr_type))
 		iif = skb->dev->ifindex;
+	else
+		iif = l3mdev_master_ifindex(skb->dev);
 
 	/*
 	 *	Must not send error if the source does not uniquely
@@ -500,9 +502,6 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
-	if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = l3mdev_master_ifindex(skb->dev);
-
 	dst = icmpv6_route_lookup(net, skb, sk, &fl6);
 	if (IS_ERR(dst))
 		goto out;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7bdc9c9c231b..c4efaa97280c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -810,8 +810,13 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	fl6.flowi6_proto = IPPROTO_TCP;
 	if (rt6_need_strict(&fl6.daddr) && !oif)
 		fl6.flowi6_oif = tcp_v6_iif(skb);
-	else
+	else {
+		if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
+			oif = skb->skb_iif;
+
 		fl6.flowi6_oif = oif;
+	}
+
 	fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
 	fl6.fl6_dport = t1->dest;
 	fl6.fl6_sport = t1->source;
-- 
2.1.4
