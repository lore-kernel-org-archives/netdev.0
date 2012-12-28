From: pablo@netfilter.org
Subject: [PATCH 04/12] netfilter: nf_ct_reasm: fix conntrack reassembly expire code
Date: Fri, 28 Dec 2012 12:52:43 +0100
Message-ID: <1356695571-3305-5-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51023 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530Ab2L1LxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:18 -0500
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haibo Xi <haibbo@gmail.com>

Commit b836c99fd6c9 (ipv6: unify conntrack reassembly expire
code with standard one) use the standard IPv6 reassembly
code(ip6_expire_frag_queue) to handle conntrack reassembly expire.

In ip6_expire_frag_queue, it invoke dev_get_by_index_rcu to get
which device received this expired packet.so we must save ifindex
when NF_conntrack get this packet.

With this patch applied, I can see ICMP Time Exceeded sent
from the receiver when the sender sent out 1/2 fragmented
IPv6 packet.

Signed-off-by: Haibo Xi <haibbo@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 22c8ea9..3dacecc 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -311,7 +311,10 @@ found:
 	else
 		fq->q.fragments = skb;
 
-	skb->dev = NULL;
+	if (skb->dev) {
+		fq->iif = skb->dev->ifindex;
+		skb->dev = NULL;
+	}
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
 	if (payload_len > fq->q.max_size)
-- 
1.7.10.4
