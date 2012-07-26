From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: Early TCP socket demux
Date: Thu, 26 Jul 2012 12:34:28 +0200
Message-ID: <1343298868.2626.11348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60503 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab2GZKed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 06:34:33 -0400
Received: by bkwj10 with SMTP id j10so1172314bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 03:34:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This is the IPv6 missing bits for infratructure added in commit
41063e9dd1195 (ipv4: Early TCP socket demux.)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/protocol.h |    2 ++
 net/ipv6/ip6_input.c   |   13 +++++++++++--
 net/ipv6/tcp_ipv6.c    |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 057f2d3..929528c 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -52,6 +52,8 @@ struct net_protocol {
 
 #if IS_ENABLED(CONFIG_IPV6)
 struct inet6_protocol {
+	void	(*early_demux)(struct sk_buff *skb);
+
 	int	(*handler)(struct sk_buff *skb);
 
 	void	(*err_handler)(struct sk_buff *skb,
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 5ab923e..47975e3 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -47,9 +47,18 @@
 
 
 
-inline int ip6_rcv_finish( struct sk_buff *skb)
+int ip6_rcv_finish(struct sk_buff *skb)
 {
-	if (skb_dst(skb) == NULL)
+	if (sysctl_ip_early_demux && !skb_dst(skb)) {
+		const struct inet6_protocol *ipprot;
+
+		rcu_read_lock();
+		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
+		if (ipprot && ipprot->early_demux)
+			ipprot->early_demux(skb);
+		rcu_read_unlock();
+	}
+	if (!skb_dst(skb))
 		ip6_route_input(skb);
 
 	return dst_input(skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f49476e..221224e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1674,6 +1674,43 @@ do_time_wait:
 	goto discard_it;
 }
 
+static void tcp_v6_early_demux(struct sk_buff *skb)
+{
+	const struct ipv6hdr *hdr;
+	const struct tcphdr *th;
+	struct sock *sk;
+
+	if (skb->pkt_type != PACKET_HOST)
+		return;
+
+	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct tcphdr)))
+		return;
+
+	hdr = ipv6_hdr(skb);
+	th = tcp_hdr(skb);
+
+	if (th->doff < sizeof(struct tcphdr) / 4)
+		return;
+
+	sk = __inet6_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
+					&hdr->saddr, th->source,
+					&hdr->daddr, ntohs(th->dest),
+					inet6_iif(skb));
+	if (sk) {
+		skb->sk = sk;
+		skb->destructor = sock_edemux;
+		if (sk->sk_state != TCP_TIME_WAIT) {
+			struct dst_entry *dst = sk->sk_rx_dst;
+			struct inet_sock *icsk = inet_sk(sk);
+			if (dst)
+				dst = dst_check(dst, 0);
+			if (dst &&
+			    icsk->rx_dst_ifindex == inet6_iif(skb))
+				skb_dst_set_noref(skb, dst);
+		}
+	}
+}
+
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
@@ -1984,6 +2021,7 @@ struct proto tcpv6_prot = {
 };
 
 static const struct inet6_protocol tcpv6_protocol = {
+	.early_demux	=	tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
 	.gso_send_check	=	tcp_v6_gso_send_check,
