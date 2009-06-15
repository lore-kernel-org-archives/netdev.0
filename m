From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/1] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Mon, 15 Jun 2009 17:25:42 +0200
Message-ID: <20090615152542.GB2767@ami.dom.local>
References: <20090615065333.GA4378@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	Yan Zheng <zheng.yan@oracle.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762493AbZFOP0e@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090615065333.GA4378@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv4: Fix fib_trie rebalancing, part 2

My previous patch, which explicitly delays freeing of tnodes by adding
them to the list to flushe them after the update is finished, isn't
strict enough. It treats exceptionally tnodes without parent, assuming
they are newly created, so "invisible" for the read side yet. But the
top tnode doesn't have parent as well, so we have to exclude all
exceptions (at least until a better way is found).

Reported-by: Yan Zheng <zheng.yan@oracle.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ipv4/fib_trie.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d1a39b1..64395b0 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -391,13 +391,8 @@ static inline void tnode_free(struct tnode *tn)
 static void tnode_free_safe(struct tnode *tn)
 {
 	BUG_ON(IS_LEAF(tn));
-
-	if (node_parent((struct node *) tn)) {
-		tn->tnode_free = tnode_free_head;
-		tnode_free_head = tn;
-	} else {
-		tnode_free(tn);
-	}
+	tn->tnode_free = tnode_free_head;
+	tnode_free_head = tn;
 }
 
 static void tnode_free_flush(void)
