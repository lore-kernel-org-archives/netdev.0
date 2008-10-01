From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 10/16] Don't lookup the socket if there's a socket
	attached to the skb
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.69772.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261AbYJAPZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:42 -0400
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the socket cached in the TPROXY target if it's present.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/ipv4/tcp_ipv4.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1ac4d05..0029db9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1577,8 +1577,17 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
+#if defined(CONFIG_NETFILTER_TPROXY) || defined(CONFIG_NETFILTER_TPROXY_MODULE)
+	if (unlikely(skb->sk)) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else
+#endif
 	sk = __inet_lookup(net, &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
+
 	if (!sk)
 		goto no_tcp_socket;
 


