From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] fib_tries related Oops in 2.6.30
Date: Fri, 12 Jun 2009 09:25:58 +0200
Message-ID: <20090612072557.GA2761@ami.dom.local>
References: <4A31173D.6010504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yan Zheng <zheng.yan@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:42627 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660AbZFLH0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 03:26:24 -0400
Content-Disposition: inline
In-Reply-To: <4A31173D.6010504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/11/2009 04:39 PM:

> Cc Robert Olsson.
> 
> Jarek P.
> 
> Yan Zheng wrote, On 06/10/2009 06:05 PM:
> 
>> Hello,
>>
>> I pull linux-2.6.30 from linus-2.6 git tree. I got following oops
>> immediately after boot.
>>
>> # uname -a
>> Linux zhyan-cn 2.6.30 #1 SMP PREEMPT Wed Jun 10 23:37:22 CST 2009 i686
>> i686 i386 GNU/Linux
>>
>> ---
>> BUG: sleeping function called from invalid context at
...

Robert, probably I miss something, but since I don't understand this
last patch with preempt_disable(), I've looked a bit at this place and
found this parent update after IMHO possible child destruction quite
suspicious, so I wonder if you could check if this patch could change
anything with previous oops. (It's mainly to test the idea, not to
optimally fix it.)

Thanks,
Jarek P.
---

 net/ipv4/fib_trie.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 538d2a9..565fc1d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -989,16 +989,17 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	t_key cindex, key;
 	struct tnode *tp;
 
-	preempt_disable();
 	key = tn->key;
 
 	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
+		tnode_put_child_reorg((struct tnode *)tp, cindex, NULL,
+				      wasfull);
 		tn = (struct tnode *) resize(t, (struct tnode *)tn);
 
 		tnode_put_child_reorg((struct tnode *)tp, cindex,
-				      (struct node *)tn, wasfull);
+				      (struct node *)tn, -1);
 
 		tp = node_parent((struct node *) tn);
 		if (!tp)
@@ -1010,7 +1011,6 @@ static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 	if (IS_TNODE(tn))
 		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 
-	preempt_enable();
 	return (struct node *)tn;
 }
 
