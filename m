From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 03/13] Don't do the TCP socket lookup if we already have
	one attached
Date: Mon, 05 Mar 2007 16:45:21 +0100
Message-ID: <20070305154521.3471.67836.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3259 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933534AbXCEPpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:22 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id DFD47294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:21 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP input code path looks up the TCP socket hash tables to find a
socket matching the incoming packet. However, as iptable_tproxy does
socket lookups early the skb may already have the appropriate
reference attached, in that case we steal that reference instead of
doing the lookup.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/ipv4/tcp_ipv4.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..536db7b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1647,9 +1647,16 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
-			   skb->nh.iph->daddr, th->dest,
-			   inet_iif(skb));
+	if (unlikely(skb->sk)) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else {
+		sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
+				   skb->nh.iph->daddr, th->dest,
+				   inet_iif(skb));
+	}
 
 	if (!sk)
 		goto no_tcp_socket;

