From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 3/3] ipv6: on reassembly, record frag_max_size
Date: Wed,  2 Nov 2016 11:02:18 -0400
Message-ID: <1478098938-124108-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: jdorfman@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33926 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755430AbcKBPC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:02:29 -0400
Received: by mail-qk0-f193.google.com with SMTP id o68so1407610qkf.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:02:28 -0700 (PDT)
In-Reply-To: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

IP6CB and IPCB have a frag_max_size field. In IPv6 this field is
filled in when packets are reassembled by the connection tracking
code. Also fill in when reassembling in the input path, to expose
it through cmsg IPV6_RECVFRAGSIZE in all cases.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/reassembly.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3815e85..e1da5b8 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -211,7 +211,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 {
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
-	int offset, end;
+	int offset, end, fragsize;
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	u8 ecn;
 
@@ -336,6 +336,10 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	fq->ecn |= ecn;
 	add_frag_mem_limit(fq->q.net, skb->truesize);
 
+	fragsize = -skb_network_offset(skb) + skb->len;
+	if (fragsize > fq->q.max_size)
+		fq->q.max_size = fragsize;
+
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
 	 */
@@ -495,6 +499,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	ipv6_change_dsfield(ipv6_hdr(head), 0xff, ecn);
 	IP6CB(head)->nhoff = nhoff;
 	IP6CB(head)->flags |= IP6SKB_FRAGMENTED;
+	IP6CB(head)->frag_max_size = fq->q.max_size;
 
 	/* Yes, and fold redundant checksum back. 8) */
 	skb_postpush_rcsum(head, skb_network_header(head),
-- 
2.8.0.rc3.226.g39d4020
