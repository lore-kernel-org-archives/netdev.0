From: kaber@trash.net
Subject: [PATCH 01/28] netfilter: nf_conntrack_reasm: add fast path for in-order fragments
Date: Mon,  2 Aug 2010 21:57:18 +0200
Message-ID: <1280779065-9333-2-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

As the fragments are sent in order in most of OSes, such as Windows, Darwin and
FreeBSD, it is likely the new fragments are at the end of the inet_frag_queue.
In the fast path, we check if the skb at the end of the inet_frag_queue is the
prev we expect.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 9254008..098a050 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -269,6 +269,11 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	 * in the chain of fragments so far.  We must know where to put
 	 * this fragment, right?
 	 */
+	prev = fq->q.fragments_tail;
+	if (!prev || NFCT_FRAG6_CB(prev)->offset < offset) {
+		next = NULL;
+		goto found;
+	}
 	prev = NULL;
 	for (next = fq->q.fragments; next != NULL; next = next->next) {
 		if (NFCT_FRAG6_CB(next)->offset >= offset)
@@ -276,6 +281,7 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 		prev = next;
 	}
 
+found:
 	/* We found where to put this one.  Check for overlap with
 	 * preceding fragment, and, if needed, align things so that
 	 * any overlaps are eliminated.
@@ -341,6 +347,8 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 
 	/* Insert this fragment in the chain of fragments. */
 	skb->next = next;
+	if (!next)
+		fq->q.fragments_tail = skb;
 	if (prev)
 		prev->next = skb;
 	else
@@ -464,6 +472,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 					  head->csum);
 
 	fq->q.fragments = NULL;
+	fq->q.fragments_tail = NULL;
 
 	/* all original skbs are linked into the NFCT_FRAG6_CB(head).orig */
 	fp = skb_shinfo(head)->frag_list;
-- 
1.7.1

