From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/30] netfilter: ebtables: Simplify the arguments to ebt_do_table
Date: Tue, 22 Sep 2015 11:14:06 +0200
Message-ID: <1442913260-3925-17-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35052 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757712AbbIVJHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:53 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Nearly everything thing of interest to ebt_do_table is already present
in nf_hook_state.  Simplify ebt_do_table by just passing in the skb,
nf_hook_state, and the table.  This make the code easier to read and
maintenance easier.

To support this create an nf_hook_state on the stack in ebt_broute
(the only caller without a nf_hook_state already available).  This new
nf_hook_state adds no new computations to ebt_broute, but does use a
few more bytes of stack.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge/ebtables.h |    6 +++---
 net/bridge/netfilter/ebtable_broute.c     |    8 ++++++--
 net/bridge/netfilter/ebtable_filter.c     |    6 ++----
 net/bridge/netfilter/ebtable_nat.c        |    6 ++----
 net/bridge/netfilter/ebtables.c           |   13 +++++++------
 5 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 8ca6d64..2ea517c 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -111,9 +111,9 @@ struct ebt_table {
 extern struct ebt_table *ebt_register_table(struct net *net,
 					    const struct ebt_table *table);
 extern void ebt_unregister_table(struct net *net, struct ebt_table *table);
-extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
-   const struct net_device *in, const struct net_device *out,
-   struct ebt_table *table);
+extern unsigned int ebt_do_table(struct sk_buff *skb,
+				 const struct nf_hook_state *state,
+				 struct ebt_table *table);
 
 /* Used in the kernel match() functions */
 #define FWINV(bool,invflg) ((bool) ^ !!(info->invflags & invflg))
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index d2cdf5d..ec94c6f 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -50,10 +50,14 @@ static const struct ebt_table broute_table = {
 
 static int ebt_broute(struct sk_buff *skb)
 {
+	struct nf_hook_state state;
 	int ret;
 
-	ret = ebt_do_table(NF_BR_BROUTING, skb, skb->dev, NULL,
-			   dev_net(skb->dev)->xt.broute_table);
+	nf_hook_state_init(&state, NULL, NF_BR_BROUTING, INT_MIN,
+			   NFPROTO_BRIDGE, skb->dev, NULL, NULL,
+			   dev_net(skb->dev), NULL);
+
+	ret = ebt_do_table(skb, &state, state.net->xt.broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
 	return 0; /* bridge it */
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index ab20d6e..118ce40 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -60,16 +60,14 @@ static unsigned int
 ebt_in_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    state->net->xt.frame_filter);
+	return ebt_do_table(skb, state, state->net->xt.frame_filter);
 }
 
 static unsigned int
 ebt_out_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    state->net->xt.frame_filter);
+	return ebt_do_table(skb, state, state->net->xt.frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index ad81a5a..56c3329 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -60,16 +60,14 @@ static unsigned int
 ebt_nat_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	   const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    state->net->xt.frame_nat);
+	return ebt_do_table(skb, state, state->net->xt.frame_nat);
 }
 
 static unsigned int
 ebt_nat_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
-	return ebt_do_table(ops->hooknum, skb, state->in, state->out,
-			    state->net->xt.frame_nat);
+	return ebt_do_table(skb, state, state->net->xt.frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 48b6b01..8d5a3975 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -183,10 +183,11 @@ struct ebt_entry *ebt_next_entry(const struct ebt_entry *entry)
 }
 
 /* Do some firewalling */
-unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
-   const struct net_device *in, const struct net_device *out,
-   struct ebt_table *table)
+unsigned int ebt_do_table(struct sk_buff *skb,
+			  const struct nf_hook_state *state,
+			  struct ebt_table *table)
 {
+	unsigned int hook = state->hook;
 	int i, nentries;
 	struct ebt_entry *point;
 	struct ebt_counter *counter_base, *cb_base;
@@ -199,8 +200,8 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	struct xt_action_param acpar;
 
 	acpar.family  = NFPROTO_BRIDGE;
-	acpar.in      = in;
-	acpar.out     = out;
+	acpar.in      = state->in;
+	acpar.out     = state->out;
 	acpar.hotdrop = false;
 	acpar.hooknum = hook;
 
@@ -220,7 +221,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	base = private->entries;
 	i = 0;
 	while (i < nentries) {
-		if (ebt_basic_match(point, skb, in, out))
+		if (ebt_basic_match(point, skb, state->in, state->out))
 			goto letscontinue;
 
 		if (EBT_MATCH_ITERATE(point, ebt_do_match, skb, &acpar) != 0)
-- 
1.7.10.4
