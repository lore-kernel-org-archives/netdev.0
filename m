From: kaber@trash.net
Subject: [PATCH 14/17] netfilter: defrag: remove one redundant atomic ops
Date: Tue, 15 Jun 2010 17:38:40 +0200
Message-ID: <1276616323-20880-15-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932280Ab0FOP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:56 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

Instead of doing one atomic operation per frag, we can factorize them.
Reported from Eric Dumazet.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6fb8901..bc5b86d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -442,7 +442,6 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &nf_init_frags.mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -452,8 +451,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &nf_init_frags.mem);
 	}
+	atomic_sub(head->truesize, &nf_init_frags.mem);
 
 	head->next = NULL;
 	head->dev = dev;
-- 
1.7.0.4

