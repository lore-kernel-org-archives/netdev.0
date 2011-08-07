From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] netfilter: TCP and raw fix for ip_route_me_harder
Date: Sun, 7 Aug 2011 22:11:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108072158050.1423@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	TCP in some cases uses different global (raw) socket
to send RST and ACK. The transparent flag is not set there.
Currently, it is a problem for rerouting after the previous
change.

	Fix it by simplifying the checks in ip_route_me_harder
and use FLOWI_FLAG_ANYSRC even for sockets. It looks safe
because the initial routing allowed this source address to
be used and now we just have to make sure the packet is rerouted.

	As a side effect this also allows rerouting for normal
raw sockets that use spoofed source addresses which was not possible
even before we eliminated the ip_route_input call.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v3.0/linux/net/ipv4/netfilter.c linux/net/ipv4/netfilter.c
--- v3.0/linux/net/ipv4/netfilter.c	2011-07-22 09:43:32.862081622 +0300
+++ linux/net/ipv4/netfilter.c	2011-08-07 19:22:05.772347388 +0300
@@ -18,17 +18,15 @@ int ip_route_me_harder(struct sk_buff *s
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
 	__be32 saddr = iph->saddr;
-	__u8 flags = 0;
+	__u8 flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
 	unsigned int hh_len;
 
-	if (!skb->sk && addr_type != RTN_LOCAL) {
-		if (addr_type == RTN_UNSPEC)
-			addr_type = inet_addr_type(net, saddr);
-		if (addr_type == RTN_LOCAL || addr_type == RTN_UNICAST)
-			flags |= FLOWI_FLAG_ANYSRC;
-		else
-			saddr = 0;
-	}
+	if (addr_type == RTN_UNSPEC)
+		addr_type = inet_addr_type(net, saddr);
+	if (addr_type == RTN_LOCAL || addr_type == RTN_UNICAST)
+		flags |= FLOWI_FLAG_ANYSRC;
+	else
+		saddr = 0;
 
 	/* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
 	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
@@ -38,7 +36,7 @@ int ip_route_me_harder(struct sk_buff *s
 	fl4.flowi4_tos = RT_TOS(iph->tos);
 	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 	fl4.flowi4_mark = skb->mark;
-	fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : flags;
+	fl4.flowi4_flags = flags;
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		return -1;
