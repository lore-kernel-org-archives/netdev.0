From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v2 2/3] net: Use fwmark reflection in PMTU discovery.
Date: Sat, 10 May 2014 12:08:17 +0900
Message-ID: <1399691298-2531-2-git-send-email-lorenzo@google.com>
References: <1399691298-2531-1-git-send-email-lorenzo@google.com>
Cc: jpa@google.com, davem@davemloft.net, ja@ssi.bg,
	hannes@stressinduktion.org, eric.dumazet@gmail.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34938 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbaEJDIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 23:08:30 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so5078668pab.40
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 20:08:29 -0700 (PDT)
In-Reply-To: <1399691298-2531-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, routing lookups used for Path PMTU Discovery in
absence of a socket or on unmarked sockets use a mark of 0.
This causes PMTUD not to work when using routing based on
netfilter fwmark mangling and fwmark ip rules, such as:

  iptables -j MARK --set-mark 17
  ip rule add fwmark 17 lookup 100

This patch causes these route lookups to use the fwmark from the
received ICMP error when the fwmark_reflect sysctl is enabled.
This allows the administrator to make PMTUD work by configuring
appropriate fwmark rules to mark the inbound ICMP packets.

Black-box tested using user-mode linux by pointing different
fwmarks at routing tables egressing on different interfaces, and
using iptables mangling to mark packets inbound on each interface
with the interface's fwmark. ICMPv4 and ICMPv6 PMTU discovery
work as expected when mark reflection is enabled and fail when
it is disabled.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++--
 net/ipv4/route.c                       | 7 +++++++
 net/ipv6/route.c                       | 2 +-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 83e51a5..03c4bde 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -60,7 +60,9 @@ fwmark_reflect - BOOLEAN
 	Controls the fwmark of kernel-generated IPv4 reply packets that are not
 	associated with a socket for example, TCP RSTs or ICMP echo replies).
 	If unset, these packets have a fwmark of zero. If set, they have the
-	fwmark of the packet they are replying to.
+	fwmark of the packet they are replying to. Similarly affects the fwmark
+	used by internal routing lookups triggered by incoming packets, such as
+	the ones used for Path MTU Discovery.
 	Default: 0
 
 route/max_size - INTEGER
@@ -1192,7 +1194,9 @@ fwmark_reflect - BOOLEAN
 	Controls the fwmark of kernel-generated IPv6 reply packets that are not
 	associated with a socket for example, TCP RSTs or ICMPv6 echo replies).
 	If unset, these packets have a fwmark of zero. If set, they have the
-	fwmark of the packet they are replying to.
+	fwmark of the packet they are replying to. Similarly affects the fwmark
+	used by internal routing lookups triggered by incoming packets, such as
+	the ones used for Path MTU Discovery.
 	Default: 0
 
 conf/interface/*:
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index db1e0da..50e1e0f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -993,6 +993,9 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 	struct flowi4 fl4;
 	struct rtable *rt;
 
+	if (!mark)
+		mark = IP4_REPLY_MARK(net, skb->mark);
+
 	__build_flow_key(&fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
@@ -1010,6 +1013,10 @@ static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct rtable *rt;
 
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+
+	if (!fl4.flowi4_mark)
+		fl4.flowi4_mark = IP4_REPLY_MARK(sock_net(sk), skb->mark);
+
 	rt = __ip_route_output_key(sock_net(sk), &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_rt_update_pmtu(rt, &fl4, mtu);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4011617..63fbddb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1176,7 +1176,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = oif;
-	fl6.flowi6_mark = mark;
+	fl6.flowi6_mark = mark ? mark : IP6_REPLY_MARK(net, skb->mark);
 	fl6.daddr = iph->daddr;
 	fl6.saddr = iph->saddr;
 	fl6.flowlabel = ip6_flowinfo(iph);
-- 
1.9.1.423.g4596e3a
