From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum packets
Date: Thu,  7 Jul 2016 17:58:48 +0200
Message-ID: <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082AbcGGQAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 12:00:48 -0400
In-Reply-To: <cover.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

currently, UDP packets with zero checksum are not allowed to
use udp offload's GRO. This patch admits such packets to
GRO, if the related socket settings allow it: ipv6 packets
are not admitted if the sockets don't have the no_check6_rx
flag set.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp_offload.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 9c37338..ac783f4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -257,7 +257,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	struct sock *sk;
 
 	if (NAPI_GRO_CB(skb)->encap_mark ||
-	    (skb->ip_summed != CHECKSUM_PARTIAL &&
+	    (uh->check && skb->ip_summed != CHECKSUM_PARTIAL &&
 	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
 	     !NAPI_GRO_CB(skb)->csum_valid))
 		goto out;
@@ -271,6 +271,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	if (!sk || !udp_sk(sk)->gro_receive)
 		goto out_unlock;
 
+	if (!uh->check && skb->protocol == cpu_to_be16(ETH_P_IPV6) &&
+	    !udp_sk(sk)->no_check6_rx)
+		goto out_unlock;
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
1.8.3.1
