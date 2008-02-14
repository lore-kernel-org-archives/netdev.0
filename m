From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with type/macro safety
Date: Wed, 13 Feb 2008 17:34:27 -0800
Message-ID: <20080214013427.GT12393@linux.vnet.ibm.com>
References: <20080213220024.GA30729@linux.vnet.ibm.com> <20080213143537.1b806790@extreme> <20080213224134.GK12393@linux.vnet.ibm.com> <20080213144233.05e860cb@extreme> <20080213233744.GO12393@linux.vnet.ibm.com> <20080213155158.1b621359@extreme> <20080214001404.GQ12393@linux.vnet.ibm.com> <20080213162700.0a32000d@extreme> <20080214004253.GR12393@linux.vnet.ibm.com> <20080213165356.11d02092@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger
	<"stephen.hemminger@vyatta.com"@mail.vyatta.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:32956 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483AbYBNBen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 20:34:43 -0500
Content-Disposition: inline
In-Reply-To: <20080213165356.11d02092@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2008 at 04:53:56PM -0800, Stephen Hemminger wrote:
> On Wed, 13 Feb 2008 16:42:53 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Feb 13, 2008 at 04:27:00PM -0800, Stephen Hemminger wrote:

[ . . . ]

> > > That is heading towards ugly...  Maybe not using the macro at all (for this case) would be best:
> > > 
> > > static inline void node_set_parent(struct node *node, struct tnode *ptr)
> > > {
> > > 	smp_wmb();
> > > 	node->parent = (unsigned long)ptr | NODE_TYPE(node);
> > > }
> > 
> > Or, alternatively, the rcu_assign_index() patch sent earlier to avoid
> > the bare memory barrier?
> > 
> > 							Thanx, Paul
> 
> I am fine with rcu_assign_index(), and add a comment in node_set_parent.

OK, how about the following?

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 fib_trie.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff -urpNa -X dontdiff linux-2.6.25-rc1/net/ipv4/fib_trie.c linux-2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c
--- linux-2.6.25-rc1/net/ipv4/fib_trie.c	2008-02-13 14:38:12.000000000 -0800
+++ linux-2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c	2008-02-13 17:31:16.000000000 -0800
@@ -96,6 +96,14 @@ typedef unsigned int t_key;
 #define IS_TNODE(n) (!(n->parent & T_LEAF))
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
+/*
+ * The "parent" fields in struct node and struct leaf are really pointers,
+ * but with the possibility that the T_LEAF bit is set.  Therefore, both
+ * the C compiler and RCU see them as integers rather than pointers.
+ * This in turn means that rcu_assign_index() must be used to assign
+ * values to these fields, rather than the usual rcu_assign_pointer().
+ */
+
 struct node {
 	unsigned long parent;
 	t_key key;
@@ -179,8 +187,7 @@ static inline struct tnode *node_parent_
 
 static inline void node_set_parent(struct node *node, struct tnode *ptr)
 {
-	rcu_assign_pointer(node->parent,
-			   (unsigned long)ptr | NODE_TYPE(node));
+	rcu_assign_index(node->parent, (unsigned long)ptr | NODE_TYPE(node));
 }
 
 static inline struct node *tnode_get_child(struct tnode *tn, unsigned int i)
