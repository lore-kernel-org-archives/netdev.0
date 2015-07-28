From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 28 Jul 2015 11:26:23 +1000
Message-ID: <20150728112623.3ec0b2b5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/ip_fragment.c

between commit:

  0e60d245a0be ("inet: frag: change *_frag_mem_limit functions to take netns_frags as argument")

from the net tree and commit:

  14fe22e33462 ("Revert "ipv4: use skb coalescing in defragmentation"")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ip_fragment.c
index 921138f6c97c,f44bccc42494..000000000000
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@@ -587,35 -586,22 +586,22 @@@ static int ip_frag_reasm(struct ipq *qp
  		head->len -= clone->len;
  		clone->csum = 0;
  		clone->ip_summed = head->ip_summed;
 -		add_frag_mem_limit(&qp->q, clone->truesize);
 +		add_frag_mem_limit(qp->q.net, clone->truesize);
  	}
  
+ 	skb_shinfo(head)->frag_list = head->next;
  	skb_push(head, head->data - skb_network_header(head));
  
- 	sum_truesize = head->truesize;
- 	for (fp = head->next; fp;) {
- 		bool headstolen;
- 		int delta;
- 		struct sk_buff *next = fp->next;
- 
- 		sum_truesize += fp->truesize;
+ 	for (fp=head->next; fp; fp = fp->next) {
+ 		head->data_len += fp->len;
+ 		head->len += fp->len;
  		if (head->ip_summed != fp->ip_summed)
  			head->ip_summed = CHECKSUM_NONE;
  		else if (head->ip_summed == CHECKSUM_COMPLETE)
  			head->csum = csum_add(head->csum, fp->csum);
- 
- 		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
- 			kfree_skb_partial(fp, headstolen);
- 		} else {
- 			if (!skb_shinfo(head)->frag_list)
- 				skb_shinfo(head)->frag_list = fp;
- 			head->data_len += fp->len;
- 			head->len += fp->len;
- 			head->truesize += fp->truesize;
- 		}
- 		fp = next;
+ 		head->truesize += fp->truesize;
  	}
- 	sub_frag_mem_limit(qp->q.net, sum_truesize);
 -	sub_frag_mem_limit(&qp->q, head->truesize);
++	sub_frag_mem_limit(qp->q.net, head->truesize);
  
  	head->next = NULL;
  	head->dev = dev;
