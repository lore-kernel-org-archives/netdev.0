From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2] net: fix the counter ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS
Date: Thu, 31 Jul 2014 17:54:32 +0800
Message-ID: <53DA1258.90203@cn.fujitsu.com>
References: <53D75922.2090106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<eric.dumazet@gmail.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:32151 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756171AbaGaJzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 05:55:01 -0400
In-Reply-To: <53D75922.2090106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When dealing with ICMPv[46] Error Message, function icmp_socket_deliver()
and icmpv6_notify() do some valid checks on packet's length, but then some
protocols check packet's length redaudantly. So remove those duplicated
statements, and increase counter ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS in
function icmp_socket_deliver() and icmpv6_notify() respectively.

In addition, add missed counter in udp6/udplite6 when socket is NULL.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---

v2: remove nested rcu_read_lock from icmpv6_notify

 net/ipv4/icmp.c     |  4 +++-
 net/ipv4/tcp_ipv4.c |  5 -----
 net/ipv6/icmp.c     | 13 ++++++++-----
 net/ipv6/udp.c      |  8 ++++++--
 net/sctp/input.c    |  5 -----
 5 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 42b7bcf..092400e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -663,8 +663,10 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 	/* Checkin full IP header plus 8 bytes of protocol to
 	 * avoid additional coding at protocol handlers.
 	 */
-	if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
+	if (!pskb_may_pull(skb, iph->ihl * 4 + 8)) {
+		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
 		return;
+	}
 
 	raw_icmp_error(skb, protocol, info);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77cccda..715cf6b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -342,11 +342,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	int err;
 	struct net *net = dev_net(icmp_skb->dev);
 
-	if (icmp_skb->len < (iph->ihl << 2) + 8) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
-		return;
-	}
-
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(icmp_skb));
 	if (!sk) {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f6c84a6..06ba3e5 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -626,9 +626,10 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 	int inner_offset;
 	__be16 frag_off;
 	u8 nexthdr;
+	struct net *net = dev_net(skb->dev);
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		return;
+		goto out;
 
 	nexthdr = ((struct ipv6hdr *)skb->data)->nexthdr;
 	if (ipv6_ext_hdr(nexthdr)) {
@@ -636,14 +637,14 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 		inner_offset = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
 						&nexthdr, &frag_off);
 		if (inner_offset<0)
-			return;
+			goto out;
 	} else {
 		inner_offset = sizeof(struct ipv6hdr);
 	}
 
 	/* Checkin header including 8 bytes of inner protocol header. */
 	if (!pskb_may_pull(skb, inner_offset+8))
-		return;
+		goto out;
 
 	/* BUGGG_FUTURE: we should try to parse exthdrs in this packet.
 	   Without this we will not able f.e. to make source routed
@@ -652,13 +653,15 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 	   --ANK (980726)
 	 */
 
-	rcu_read_lock();
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
 	if (ipprot && ipprot->err_handler)
 		ipprot->err_handler(skb, NULL, type, code, inner_offset, info);
-	rcu_read_unlock();
 
 	raw6_icmp_error(skb, nexthdr, type, code, inner_offset, info);
+	return;
+
+out:
+	ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
 }
 
 /*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7092ff7..f13d297 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -534,11 +534,15 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
 	struct sock *sk;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
-	sk = __udp6_lib_lookup(dev_net(skb->dev), daddr, uh->dest,
+	sk = __udp6_lib_lookup(net, daddr, uh->dest,
 			       saddr, uh->source, inet6_iif(skb), udptable);
-	if (sk == NULL)
+	if (sk == NULL) {
+		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
+				   ICMP6_MIB_INERRORS);
 		return;
+	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
 		if (!ip6_sk_accept_pmtu(sk))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index f2e2cbd..c1b9912 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -575,11 +575,6 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < ihlen + 8) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
-		return;
-	}
-
 	/* Fix up skb to look at the embedded net header. */
 	saveip = skb->network_header;
 	savesctp = skb->transport_header;
-- 
1.8.3.1
