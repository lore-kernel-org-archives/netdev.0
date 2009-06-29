From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root. Now=15
	size=11 bits
Date: Mon, 29 Jun 2009 08:33:15 +0000
Message-ID: <20090629083315.GA4712@ff.dom.local>
References: <20090628213602.GA4584@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9VVEYtOD9CP1VHRjNaY1dDSUZOMFlYTjZaWGR6YTJrPT89?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:43438 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZF2IdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 04:33:18 -0400
Received: by fxm18 with SMTP id 18so802601fxm.37
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 01:33:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090628213602.GA4584@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-06-2009 23:36, Jarek Poplawski wrote:
> To David Miller:
> since among patches tested negatively by Pawel are current 2 fixes
> from 2.6.31-rc, I hope they weren't sent to -stable yet. Otherwise,
> please withdraw them until they are tested alone. Thanks.

David, IMHO this fix is needed in net-2.6 even if it doesn't fix the
problem reported by Pawel (there could be still something more).

Pawel, I see you decided to test my previous patch, but try to add
this one on top.

Thanks,
Jarek P.
------------------->
ipv4: Fix fib_trie rebalancing, part 3

Alas current delaying of freeing old tnodes by RCU in trie_rebalance
is still not enough because we can free a top tnode before updating a
t->trie pointer.

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ipv4/fib_trie.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..00a54b2 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1021,6 +1021,9 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 				      (struct node *)tn, wasfull);
 
 		tp = node_parent((struct node *) tn);
+		if (!tp)
+			rcu_assign_pointer(t->trie, (struct node *)tn);
+
 		tnode_free_flush();
 		if (!tp)
 			break;
