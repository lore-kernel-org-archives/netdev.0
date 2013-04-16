From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: drop dst before queueing fragments
Date: Tue, 16 Apr 2013 15:55:41 -0700
Message-ID: <1366152941.3205.11.camel@edumazet-glaptop>
References: <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop>
	 <1365697961.3887.176.camel@edumazet-glaptop>
	 <1365702804.3887.180.camel@edumazet-glaptop> <20130416202022.GB2545@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:49675 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965533Ab3DPWzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 18:55:44 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl13so586330pab.32
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 15:55:44 -0700 (PDT)
In-Reply-To: <20130416202022.GB2545@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
added a bug in IP defragmentation handling, as non refcounted
dst could escape an RCU protected section.

Commit 64f3b9e203bd068 (net: ip_expire() must revalidate route) fixed
the case of timeouts, but not the general problem.

Tom Parkin noticed crashes in UDP stack and provided a patch,
but further analysis permitted us to pinpoint the root cause.

Before queueing a packet into a frag list, we must drop its dst,
as this dst has limited lifetime (RCU protected)

When/if a packet is finally reassembled, we use the dst of the very
last skb, still protected by RCU and valid, as the dst of the
reassembled packet.

Use same logic in IPv6, as there is no need to hold dst references.

Reported-by: Tom Parkin <tparkin@katalix.com>
Tested-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_fragment.c |   14 ++++++++++----
 net/ipv6/reassembly.c  |   12 ++++++++++--
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a6445b8..52c273e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -248,8 +248,7 @@ static void ip_expire(unsigned long arg)
 		if (!head->dev)
 			goto out_rcu_unlock;
 
-		/* skb dst is stale, drop it, and perform route lookup again */
-		skb_dst_drop(head);
+		/* skb has no dst, perform route lookup again */
 		iph = ip_hdr(head);
 		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
 					   iph->tos, head->dev);
@@ -523,9 +522,16 @@ found:
 		qp->q.max_size = skb->len + ihl;
 
 	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
-	    qp->q.meat == qp->q.len)
-		return ip_frag_reasm(qp, prev, dev);
+	    qp->q.meat == qp->q.len) {
+		unsigned long orefdst = skb->_skb_refdst;
 
+		skb->_skb_refdst = 0UL;
+		err = ip_frag_reasm(qp, prev, dev);
+		skb->_skb_refdst = orefdst;
+		return err;
+	}
+
+	skb_dst_drop(skb);
 	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 196ab93..0ba10e5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -330,9 +330,17 @@ found:
 	}
 
 	if (fq->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
-	    fq->q.meat == fq->q.len)
-		return ip6_frag_reasm(fq, prev, dev);
+	    fq->q.meat == fq->q.len) {
+		int res;
+		unsigned long orefdst = skb->_skb_refdst;
+
+		skb->_skb_refdst = 0UL;
+		res = ip6_frag_reasm(fq, prev, dev);
+		skb->_skb_refdst = orefdst;
+		return res;
+	}
 
+	skb_dst_drop(skb);
 	inet_frag_lru_move(&fq->q);
 	return -1;
 
