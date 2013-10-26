From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: gso: fix truesize tracking
Date: Fri, 25 Oct 2013 17:26:17 -0700
Message-ID: <1382747177.4032.21.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:61622 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab3JZA0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 20:26:21 -0400
Received: by mail-ee0-f52.google.com with SMTP id d51so2350002eek.39
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 17:26:20 -0700 (PDT)
In-Reply-To: <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 6ff50cd55545 ("tcp: gso: do not generate out of order packets")
had an heuristic that can trigger a warning in skb_try_coalesce(),
because skb->truesize of the gso segments were exactly set to mss.

This breaks the requirement that

skb->truesize >= skb->len + truesizeof(struct sk_buff);

It can trivially be reproduced by :

ifconfig lo mtu 1500
ethtool -K lo tso off
netperf

As the skbs are looped into the TCP networking stack, skb_try_coalesce()
warns us of these skb under-estimating their truesize.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Alexei Starovoitov <ast@plumgrid.com>
---
Based on net-next but applies as well on net tree with some fuzz.

David, we might backport this one to 3.12 and stable later, I let you
decide.

 net/ipv4/tcp_offload.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index a7a5583e..a2b68a1 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -18,6 +18,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int sum_truesize = 0;
 	struct tcphdr *th;
 	unsigned int thlen;
 	unsigned int seq;
@@ -104,13 +105,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		if (copy_destructor) {
 			skb->destructor = gso_skb->destructor;
 			skb->sk = gso_skb->sk;
-			/* {tcp|sock}_wfree() use exact truesize accounting :
-			 * sum(skb->truesize) MUST be exactly be gso_skb->truesize
-			 * So we account mss bytes of 'true size' for each segment.
-			 * The last segment will contain the remaining.
-			 */
-			skb->truesize = mss;
-			gso_skb->truesize -= mss;
+			sum_truesize += skb->truesize;
 		}
 		skb = skb->next;
 		th = tcp_hdr(skb);
@@ -127,7 +122,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	if (copy_destructor) {
 		swap(gso_skb->sk, skb->sk);
 		swap(gso_skb->destructor, skb->destructor);
-		swap(gso_skb->truesize, skb->truesize);
+		sum_truesize += skb->truesize;
+		atomic_add(sum_truesize - gso_skb->truesize,
+			   &skb->sk->sk_wmem_alloc);
 	}
 
 	delta = htonl(oldlen + (skb_tail_pointer(skb) -
