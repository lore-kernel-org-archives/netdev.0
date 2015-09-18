From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 01/15] ebtables: Simplify the arguments to ebt_do_table
Date: Fri, 18 Sep 2015 14:32:54 -0500
Message-ID: <1442604788-19718-1-git-send-email-ebiederm@xmission.com>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nearly everything thing of interest to ebt_do_table is already present
in nf_hook_state.  Simplify ebt_do_table by just passing in the skb,
nf_hook_state, and the table.  This make the code easier to read and
maintenance easier.

To support this create an nf_hook_state on the stack in ebt_broute
(the only caller without a nf_hook_state already available).  This new
nf_hook_state adds no new computations to ebt_broute, but does use a
few more bytes of stack.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter_bridge/ebtables.h |  6 +++---
 net/bridge/netfilter/ebtable_broute.c     |  8 ++++++--
 net/bridge/netfilter/ebtable_filter.c     |  6 ++----
 net/bridge/netfilter/ebtable_nat.c        |  6 ++----
 net/bridge/netfilter/ebtables.c           | 13 +++++++------
 5 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 8ca6d6464ea3..2ea517c7c6b9 100644
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
index d2cdf5d6e98c..ec94c6f1ae88 100644
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
index ab20d6ed6e2f..118ce40ac181 100644
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
index ad81a5a65644..56c3329d6c37 100644
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
index 48b6b01295de..8d5a3975b963 100644
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
2.2.1

