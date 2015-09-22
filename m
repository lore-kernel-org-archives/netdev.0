From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/30] inet netfilter: Remove hook from ip6t_do_table, arp_do_table, ipt_do_table
Date: Tue, 22 Sep 2015 11:14:07 +0200
Message-ID: <1442913260-3925-18-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

The values of ops->hooknum and state->hook are guaraneted to be equal
making the hook argument to ip6t_do_table, arp_do_table, and
ipt_do_table is unnecessary. Remove the unnecessary hook argument.

In the callers use state->hook instead of ops->hooknum for clarity and
to reduce the number of cachelines the callers touch.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_arp/arp_tables.h  |    1 -
 include/linux/netfilter_ipv4/ip_tables.h  |    1 -
 include/linux/netfilter_ipv6/ip6_tables.h |    1 -
 net/ipv4/netfilter/arp_tables.c           |    2 +-
 net/ipv4/netfilter/arptable_filter.c      |    3 +--
 net/ipv4/netfilter/ip_tables.c            |    2 +-
 net/ipv4/netfilter/iptable_filter.c       |    5 ++---
 net/ipv4/netfilter/iptable_mangle.c       |   12 +++++-------
 net/ipv4/netfilter/iptable_nat.c          |    3 +--
 net/ipv4/netfilter/iptable_raw.c          |    5 ++---
 net/ipv4/netfilter/iptable_security.c     |    5 ++---
 net/ipv6/netfilter/ip6_tables.c           |    2 +-
 net/ipv6/netfilter/ip6table_filter.c      |    3 +--
 net/ipv6/netfilter/ip6table_mangle.c      |   12 +++++-------
 net/ipv6/netfilter/ip6table_nat.c         |    3 +--
 net/ipv6/netfilter/ip6table_raw.c         |    3 +--
 net/ipv6/netfilter/ip6table_security.c    |    3 +--
 17 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index c22a7fb..6f074db 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -53,7 +53,6 @@ extern struct xt_table *arpt_register_table(struct net *net,
 					    const struct arpt_replace *repl);
 extern void arpt_unregister_table(struct xt_table *table);
 extern unsigned int arpt_do_table(struct sk_buff *skb,
-				  unsigned int hook,
 				  const struct nf_hook_state *state,
 				  struct xt_table *table);
 
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 4073510..aa598f9 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -64,7 +64,6 @@ struct ipt_error {
 
 extern void *ipt_alloc_initial_table(const struct xt_table *);
 extern unsigned int ipt_do_table(struct sk_buff *skb,
-				 unsigned int hook,
 				 const struct nf_hook_state *state,
 				 struct xt_table *table);
 
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index b40d2b6..0f76e5c 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -30,7 +30,6 @@ extern struct xt_table *ip6t_register_table(struct net *net,
 					    const struct ip6t_replace *repl);
 extern void ip6t_unregister_table(struct net *net, struct xt_table *table);
 extern unsigned int ip6t_do_table(struct sk_buff *skb,
-				  unsigned int hook,
 				  const struct nf_hook_state *state,
 				  struct xt_table *table);
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8f87fc3..10eb2b2 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -247,10 +247,10 @@ struct arpt_entry *arpt_next_entry(const struct arpt_entry *entry)
 }
 
 unsigned int arpt_do_table(struct sk_buff *skb,
-			   unsigned int hook,
 			   const struct nf_hook_state *state,
 			   struct xt_table *table)
 {
+	unsigned int hook = state->hook;
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	unsigned int verdict = NF_DROP;
 	const struct arphdr *arp;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index d217e4c..1352e12 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -30,8 +30,7 @@ static unsigned int
 arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return arpt_do_table(skb, ops->hooknum, state,
-			     state->net->ipv4.arptable_filter);
+	return arpt_do_table(skb, state, state->net->ipv4.arptable_filter);
 }
 
 static struct nf_hook_ops *arpfilter_ops __read_mostly;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 5d514ea..2b049e1 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -285,10 +285,10 @@ struct ipt_entry *ipt_next_entry(const struct ipt_entry *entry)
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ipt_do_table(struct sk_buff *skb,
-	     unsigned int hook,
 	     const struct nf_hook_state *state,
 	     struct xt_table *table)
 {
+	unsigned int hook = state->hook;
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 32feff3..02d4c53 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -36,14 +36,13 @@ static unsigned int
 iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		    const struct nf_hook_state *state)
 {
-	if (ops->hooknum == NF_INET_LOCAL_OUT &&
+	if (state->hook == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	return ipt_do_table(skb, ops->hooknum, state,
-			    state->net->ipv4.iptable_filter);
+	return ipt_do_table(skb, state, state->net->ipv4.iptable_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 4a5150f..dc2ff68 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -58,8 +58,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, state,
-			   state->net->ipv4.iptable_mangle);
+	ret = ipt_do_table(skb, state, state->net->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN) {
 		iph = ip_hdr(skb);
@@ -83,14 +82,13 @@ iptable_mangle_hook(const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	if (ops->hooknum == NF_INET_LOCAL_OUT)
+	if (state->hook == NF_INET_LOCAL_OUT)
 		return ipt_mangle_out(skb, state);
-	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ipt_do_table(skb, ops->hooknum, state,
+	if (state->hook == NF_INET_POST_ROUTING)
+		return ipt_do_table(skb, state,
 				    state->net->ipv4.iptable_mangle);
 	/* PREROUTING/INPUT/FORWARD: */
-	return ipt_do_table(skb, ops->hooknum, state,
-			    state->net->ipv4.iptable_mangle);
+	return ipt_do_table(skb, state, state->net->ipv4.iptable_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 4f4c64f..8ff63ac 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -33,8 +33,7 @@ static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 					 const struct nf_hook_state *state,
 					 struct nf_conn *ct)
 {
-	return ipt_do_table(skb, ops->hooknum, state,
-			    state->net->ipv4.nat_table);
+	return ipt_do_table(skb, state, state->net->ipv4.nat_table);
 }
 
 static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 20126e4..bbb0523 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -23,14 +23,13 @@ static unsigned int
 iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		 const struct nf_hook_state *state)
 {
-	if (ops->hooknum == NF_INET_LOCAL_OUT &&
+	if (state->hook == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	return ipt_do_table(skb, ops->hooknum, state,
-			    state->net->ipv4.iptable_raw);
+	return ipt_do_table(skb, state, state->net->ipv4.iptable_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 82fefd6..b924170 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -40,14 +40,13 @@ static unsigned int
 iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
-	if (ops->hooknum == NF_INET_LOCAL_OUT &&
+	if (state->hook == NF_INET_LOCAL_OUT &&
 	    (skb->len < sizeof(struct iphdr) ||
 	     ip_hdrlen(skb) < sizeof(struct iphdr)))
 		/* Somebody is playing with raw sockets. */
 		return NF_ACCEPT;
 
-	return ipt_do_table(skb, ops->hooknum, state,
-			    state->net->ipv4.iptable_security);
+	return ipt_do_table(skb, state, state->net->ipv4.iptable_security);
 }
 
 static struct nf_hook_ops *sectbl_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index cd9b401..da6446b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -314,10 +314,10 @@ ip6t_next_entry(const struct ip6t_entry *entry)
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ip6t_do_table(struct sk_buff *skb,
-	      unsigned int hook,
 	      const struct nf_hook_state *state,
 	      struct xt_table *table)
 {
+	unsigned int hook = state->hook;
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 2449005..a7327f6 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -35,8 +35,7 @@ static unsigned int
 ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	return ip6t_do_table(skb, ops->hooknum, state,
-			     state->net->ipv6.ip6table_filter);
+	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops *filter_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index a46dbf0..c2e061d 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -57,8 +57,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, NF_INET_LOCAL_OUT, state,
-			    state->net->ipv6.ip6table_mangle);
+	ret = ip6t_do_table(skb, state, state->net->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (!ipv6_addr_equal(&ipv6_hdr(skb)->saddr, &saddr) ||
@@ -79,14 +78,13 @@ static unsigned int
 ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
-	if (ops->hooknum == NF_INET_LOCAL_OUT)
+	if (state->hook == NF_INET_LOCAL_OUT)
 		return ip6t_mangle_out(skb, state);
-	if (ops->hooknum == NF_INET_POST_ROUTING)
-		return ip6t_do_table(skb, ops->hooknum, state,
+	if (state->hook == NF_INET_POST_ROUTING)
+		return ip6t_do_table(skb, state,
 				     state->net->ipv6.ip6table_mangle);
 	/* INPUT/FORWARD */
-	return ip6t_do_table(skb, ops->hooknum, state,
-			     state->net->ipv6.ip6table_mangle);
+	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_mangle);
 }
 
 static struct nf_hook_ops *mangle_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index a56451d..efa6754 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -35,8 +35,7 @@ static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 					  const struct nf_hook_state *state,
 					  struct nf_conn *ct)
 {
-	return ip6t_do_table(skb, ops->hooknum, state,
-			     state->net->ipv6.ip6table_nat);
+	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_nat);
 }
 
 static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 18e831e..fac6ad7 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -22,8 +22,7 @@ static unsigned int
 ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		  const struct nf_hook_state *state)
 {
-	return ip6t_do_table(skb, ops->hooknum, state,
-			     state->net->ipv6.ip6table_raw);
+	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops *rawtable_ops __read_mostly;
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 83bc96a..96c94fc 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -39,8 +39,7 @@ static unsigned int
 ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		       const struct nf_hook_state *state)
 {
-	return ip6t_do_table(skb, ops->hooknum, state,
-			     state->net->ipv6.ip6table_security);
+	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_security);
 }
 
 static struct nf_hook_ops *sectbl_ops __read_mostly;
-- 
1.7.10.4

