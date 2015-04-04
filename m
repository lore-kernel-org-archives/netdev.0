From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/9] netfilter: Pass nf_hook_state through arpt_do_table().
Date: Fri, 03 Apr 2015 22:08:24 -0400 (EDT)
Message-ID: <20150403.220824.134582881561058399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netfilter_arp/arp_tables.h |  3 +--
 net/ipv4/netfilter/arp_tables.c          | 11 +++++------
 net/ipv4/netfilter/arptable_filter.c     |  2 +-
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index cfb7191..c22a7fb 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -54,8 +54,7 @@ extern struct xt_table *arpt_register_table(struct net *net,
 extern void arpt_unregister_table(struct xt_table *table);
 extern unsigned int arpt_do_table(struct sk_buff *skb,
 				  unsigned int hook,
-				  const struct net_device *in,
-				  const struct net_device *out,
+				  const struct nf_hook_state *state,
 				  struct xt_table *table);
 
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f95b6f9..13bfe84 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -248,8 +248,7 @@ struct arpt_entry *arpt_next_entry(const struct arpt_entry *entry)
 
 unsigned int arpt_do_table(struct sk_buff *skb,
 			   unsigned int hook,
-			   const struct net_device *in,
-			   const struct net_device *out,
+			   const struct nf_hook_state *state,
 			   struct xt_table *table)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
@@ -265,8 +264,8 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return NF_DROP;
 
-	indev = in ? in->name : nulldevname;
-	outdev = out ? out->name : nulldevname;
+	indev = state->in ? state->in->name : nulldevname;
+	outdev = state->out ? state->out->name : nulldevname;
 
 	local_bh_disable();
 	addend = xt_write_recseq_begin();
@@ -281,8 +280,8 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
-	acpar.in      = in;
-	acpar.out     = out;
+	acpar.in      = state->in;
+	acpar.out     = state->out;
 	acpar.hooknum = hook;
 	acpar.family  = NFPROTO_ARP;
 	acpar.hotdrop = false;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 6a641cb..93876d0 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -32,7 +32,7 @@ arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 {
 	const struct net *net = dev_net(state->in ? state->in : state->out);
 
-	return arpt_do_table(skb, ops->hooknum, state->in, state->out,
+	return arpt_do_table(skb, ops->hooknum, state,
 			     net->ipv4.arptable_filter);
 }
 
-- 
2.1.0

