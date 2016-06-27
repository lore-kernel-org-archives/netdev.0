From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 27 Jun 2016 11:46:23 +1000
Message-ID: <20160627114623.2c985be5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sched/sch_netem.c

between commit:

  21de12ee5568 ("netem: fix a use after free")

from the net tree and commit:

  520ac30f4551 ("net_sched: drop packets after root qdisc lock is released")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/sched/sch_netem.c
index 178f1630a036,ccca8ca4c722..000000000000
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@@ -650,14 -617,17 +617,17 @@@ deliver
  #endif
  
  			if (q->qdisc) {
 +				unsigned int pkt_len = qdisc_pkt_len(skb);
- 				int err = qdisc_enqueue(skb, q->qdisc);
+ 				struct sk_buff *to_free = NULL;
+ 				int err;
  
+ 				err = qdisc_enqueue(skb, q->qdisc, &to_free);
+ 				kfree_skb_list(to_free);
 -				if (unlikely(err != NET_XMIT_SUCCESS)) {
 -					if (net_xmit_drop_count(err)) {
 -						qdisc_qstats_drop(sch);
 -						qdisc_tree_reduce_backlog(sch, 1,
 -									  qdisc_pkt_len(skb));
 -					}
 +				if (err != NET_XMIT_SUCCESS &&
 +				    net_xmit_drop_count(err)) {
 +					qdisc_qstats_drop(sch);
 +					qdisc_tree_reduce_backlog(sch, 1,
 +								  pkt_len);
  				}
  				goto tfifo_dequeue;
  			}
