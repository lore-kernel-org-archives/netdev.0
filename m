From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] nf_conntrack_reasm: add fast path for in-order fragments
Date: Thu,  1 Jul 2010 11:58:30 +0800
Message-ID: <1277956710-22313-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Mitchell Erblich <erblichs@earthlink.net>,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_conntrack_reasm: add fast path for in-order fragments

As the fragments are sent in order in most of OSes, such as Windows, Darwin and
FreeBSD, it is likely the new fragments are at the end of the inet_frag_queue.
In the fast path, we check if the skb at the end of the inet_frag_queue is the
prev we expect.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv6/netfilter/nf_conntrack_reasm.c |    9 +++++++++
 1 file changed, 9 insertions(+)
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
