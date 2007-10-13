From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 12/14] Don't lookup the socket if there's a socket attached to
	the skb
Date: Sat, 13 Oct 2007 19:35:09 +0200
Message-ID: <20071013173509.22517.683.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:58852 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450AbXJMRjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 13:39:00 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV0090Q23MZM30@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:33:22 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the socket cached in the TPROXY target if it's present.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/ipv4/tcp_ipv4.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fb471b0..90ee2ca 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1662,6 +1662,14 @@ int tcp_v4_rcv(struct sk_buff *skb)
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
 	sk = __inet_lookup(&tcp_hashinfo, iph->saddr, th->source,
 			   iph->daddr, th->dest, inet_iif(skb));
 	if (!sk)

