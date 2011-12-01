From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: use a 64bit load/store in output path
Date: Thu, 01 Dec 2011 06:00:53 +0100
Message-ID: <1322715653.2577.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38499 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LAFA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 00:00:58 -0500
Received: by eaak14 with SMTP id k14so1631689eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 21:00:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc compiler is smart enough to use a single load/store if we
memcpy(dptr, sptr, 8) on x86_64, regardless of
CONFIG_CC_OPTIMIZE_FOR_SIZE
    
In IP header, daddr immediately follows saddr, this wont change in the
future. We only need to make sure our flowi4 (saddr,daddr) fields wont
break the rule.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Next step is to speedup route lookup in input path

 include/net/flow.h   |    5 ++++-
 net/ipv4/ip_output.c |   21 +++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index a094477..9192d69 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -59,8 +59,11 @@ struct flowi4 {
 #define flowi4_proto		__fl_common.flowic_proto
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
-	__be32			daddr;
+
+	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
+	__be32			daddr;
+
 	union flowi_uli		uli;
 #define fl4_sport		uli.ports.sport
 #define fl4_dport		uli.ports.dport
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0bc95f3..0d5e567 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -319,6 +319,20 @@ int ip_output(struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
+/*
+ * copy saddr and daddr, possibly using 64bit load/stores
+ * Equivalent to :
+ *   iph->saddr = fl4->saddr;
+ *   iph->daddr = fl4->daddr;
+ */
+static void ip_copy_addrs(struct iphdr *iph, const struct flowi4 *fl4)
+{
+	BUILD_BUG_ON(offsetof(typeof(*fl4), daddr) !=
+		     offsetof(typeof(*fl4), saddr) + sizeof(fl4->saddr));
+	memcpy(&iph->saddr, &fl4->saddr,
+	       sizeof(fl4->saddr) + sizeof(fl4->daddr));
+}
+
 int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 {
 	struct sock *sk = skb->sk;
@@ -381,8 +395,8 @@ packet_routed:
 		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->protocol = sk->sk_protocol;
-	iph->saddr    = fl4->saddr;
-	iph->daddr    = fl4->daddr;
+	ip_copy_addrs(iph, fl4);
+
 	/* Transport layer set skb->h.foo itself. */
 
 	if (inet_opt && inet_opt->opt.optlen) {
@@ -1337,8 +1351,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	ip_select_ident(iph, &rt->dst, sk);
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
-	iph->saddr = fl4->saddr;
-	iph->daddr = fl4->daddr;
+	ip_copy_addrs(iph, fl4);
 
 	if (opt) {
 		iph->ihl += opt->optlen>>2;
