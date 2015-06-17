From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 27/43] x_tables: Add magical hook registration in the common case
Date: Wed, 17 Jun 2015 10:28:36 -0500
Message-ID: <1434554932-4552-27-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W Biederman <ebiederm@xmission.com>

Add a new field fn to struct xt_table that will hold the standard hook
function.  If that field is set the hook function is automatically
registered when as part of the table registration, and automatically
unregisted as part of table unregistration.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter/x_tables.h   |  8 +++++
 net/ipv4/netfilter/arptable_filter.c |  2 +-
 net/netfilter/x_tables.c             | 66 ++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 349d80b2c339..0803027b36a2 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -184,9 +184,14 @@ struct xt_target {
 	unsigned short family;
 };
 
+struct nf_hook_state;
+typedef unsigned int xt_hookfn(void *priv,
+			       struct sk_buff *skb,
+			       const struct nf_hook_state *state);
 /* Furniture shopping... */
 struct xt_table {
 	struct list_head list;
+	struct net *net;
 
 	/* What hooks you will enter on */
 	unsigned int valid_hooks;
@@ -200,6 +205,9 @@ struct xt_table {
 	u_int8_t af;		/* address/protocol family */
 	int priority;		/* hook order */
 
+	/* Default hook function */
+	xt_hookfn *fn;
+
 	/* A unique name... */
 	const char name[XT_TABLE_MAXNAMELEN];
 };
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 1897ee160920..40fd714dafd1 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -38,7 +38,7 @@ static struct nf_hook_ops *arpfilter_ops __read_mostly;
 static int __net_init arptable_filter_net_init(struct net *net)
 {
 	struct arpt_replace *repl;
-	
+
 	repl = arpt_alloc_initial_table(&packet_filter);
 	if (repl == NULL)
 		return -ENOMEM;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e703310121cf..f7ade70ef342 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -833,6 +833,57 @@ xt_replace_table(struct xt_table *table,
 }
 EXPORT_SYMBOL_GPL(xt_replace_table);
 
+static void xt_unregister_hooks(const struct xt_table *table)
+{
+	unsigned long bits = table->valid_hooks;
+	struct net *net = table->net;
+	struct nf_hook_ops ops = {
+		.hook     = table->fn,
+		.owner    = table->me,
+		.pf       = table->af,
+		.hooknum  = 0,
+		.priority = table->priority,
+	};
+	unsigned bit;
+
+	for_each_set_bit(bit, &bits, NF_MAX_HOOKS) {
+		ops.hooknum = bit;
+		nf_unregister_hook(net, &ops);
+	}
+}
+
+static int xt_register_hooks(const struct xt_table *table)
+{
+	unsigned long bits = table->valid_hooks;
+	unsigned long registered = 0;
+	struct net *net = table->net;
+	struct nf_hook_ops ops = {
+		.hook     = table->fn,
+		.owner    = table->me,
+		.pf       = table->af,
+		.hooknum  = 0,
+		.priority = table->priority,
+	};
+	unsigned bit;
+	int ret;
+
+	for_each_set_bit(bit, &bits, NF_MAX_HOOKS) {
+		ops.hooknum = bit;
+		ret = nf_register_hook(net, &ops);
+		if (ret)
+			goto cleanup;
+		registered |= 1 << bit;
+	}
+	return 0;
+
+cleanup:
+	for_each_set_bit(bit, &registered, NF_MAX_HOOKS) {
+		ops.hooknum = bit;
+		nf_unregister_hook(net, &ops);
+	}
+	return ret;
+}
+
 struct xt_table *xt_register_table(struct net *net,
 				   const struct xt_table *input_table,
 				   struct xt_table_info *bootstrap,
@@ -871,7 +922,15 @@ struct xt_table *xt_register_table(struct net *net,
 	private->initial_entries = private->number;
 
 	list_add(&table->list, &net->xt.tables[table->af]);
+	table->net = net;
 	mutex_unlock(&xt[table->af].mutex);
+
+	if (table->fn) {
+		ret = xt_register_hooks(table);
+		if (ret)
+			goto out_unregister;
+	}
+
 	return table;
 
 unlock:
@@ -879,6 +938,10 @@ unlock:
 	kfree(table);
 out:
 	return ERR_PTR(ret);
+out_unregister:
+	mutex_lock(&xt[table->af].mutex);
+	list_del(&table->list);
+	goto unlock;
 }
 EXPORT_SYMBOL_GPL(xt_register_table);
 
@@ -886,6 +949,9 @@ void *xt_unregister_table(struct xt_table *table)
 {
 	struct xt_table_info *private;
 
+	if (table->fn)
+		xt_unregister_hooks(table);
+
 	mutex_lock(&xt[table->af].mutex);
 	private = table->private;
 	list_del(&table->list);
-- 
2.2.1

