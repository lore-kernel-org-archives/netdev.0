From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: clean up tcp_v4_early_demux()
Date: Tue, 23 Oct 2012 09:42:47 +0200
Message-ID: <1350978167.8609.1545.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39443 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab2JWHmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:42:51 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1377431bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 00:42:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use same header helpers than tcp_v6_early_demux() because they
are a bit faster, and as they make IPv4/IPv6 versions look
the same.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_ipv4.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef998b0..694ea4c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1918,7 +1918,6 @@ EXPORT_SYMBOL(tcp_v4_do_rcv);
 
 void tcp_v4_early_demux(struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
@@ -1926,16 +1925,16 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		return;
 
-	if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
+	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct tcphdr)))
 		return;
 
 	iph = ip_hdr(skb);
-	th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));
+	th = tcp_hdr(skb);
 
 	if (th->doff < sizeof(struct tcphdr) / 4)
 		return;
 
-	sk = __inet_lookup_established(net, &tcp_hashinfo,
+	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
 				       iph->saddr, th->source,
 				       iph->daddr, ntohs(th->dest),
 				       skb->skb_iif);
