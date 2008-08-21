From: adobriyan@gmail.com
Subject: [PATCH 21/25] netns ct: per-netns event cache
Date: Fri, 22 Aug 2008 02:04:45 +0400
Message-ID: <20080821220445.GU31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_ecache.h    |   27 +++++++++++++++++--------
 include/net/netns/conntrack.h                  |    5 ++++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    4 ++-
 net/ipv4/netfilter/nf_nat_helper.c             |    2 -
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 ++-
 net/netfilter/nf_conntrack_core.c              |   23 +++++++++++++--------
 net/netfilter/nf_conntrack_ecache.c            |   26 +++++++++++++++++-------
 net/netfilter/nf_conntrack_ftp.c               |    9 ++++----
 net/netfilter/nf_conntrack_proto_gre.c         |    4 ++-
 net/netfilter/nf_conntrack_proto_sctp.c        |    5 ++--
 net/netfilter/nf_conntrack_proto_tcp.c         |    7 +++---
 net/netfilter/nf_conntrack_proto_udp.c         |    4 ++-
 net/netfilter/nf_conntrack_proto_udplite.c     |    4 ++-
 net/netfilter/xt_CONNMARK.c                    |   12 +++++++----
 net/netfilter/xt_CONNSECMARK.c                 |    3 --
 15 files changed, 95 insertions(+), 44 deletions(-)

--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -8,6 +8,7 @@
 
 #include <linux/notifier.h>
 #include <linux/interrupt.h>
+#include <net/net_namespace.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
@@ -15,9 +16,6 @@ struct nf_conntrack_ecache {
 	struct nf_conn *ct;
 	unsigned int events;
 };
-DECLARE_PER_CPU(struct nf_conntrack_ecache, nf_conntrack_ecache);
-
-#define CONNTRACK_ECACHE(x)	(__get_cpu_var(nf_conntrack_ecache).x)
 
 extern struct atomic_notifier_head nf_conntrack_chain;
 extern int nf_conntrack_register_notifier(struct notifier_block *nb);
@@ -25,17 +23,17 @@ extern int nf_conntrack_unregister_notifier(struct notifier_block *nb);
 
 extern void nf_ct_deliver_cached_events(const struct nf_conn *ct);
 extern void __nf_ct_event_cache_init(struct nf_conn *ct);
-extern void nf_ct_event_cache_flush(void);
+extern void nf_ct_event_cache_flush(struct net *net);
 
 static inline void
-nf_conntrack_event_cache(enum ip_conntrack_events event,
+nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
 			 const struct sk_buff *skb)
 {
 	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 	struct nf_conntrack_ecache *ecache;
 
 	local_bh_disable();
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	if (ct != ecache->ct)
 		__nf_ct_event_cache_init(ct);
 	ecache->events |= event;
@@ -60,16 +58,29 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
 	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
 }
 
+int nf_conntrack_ecache_init(struct net *net);
+void nf_conntrack_ecache_fini(struct net *net);
+
 #else /* CONFIG_NF_CONNTRACK_EVENTS */
 
-static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
+static inline void nf_conntrack_event_cache(struct net *net,
+					    enum ip_conntrack_events event,
 					    const struct sk_buff *skb) {}
 static inline void nf_conntrack_event(enum ip_conntrack_events event,
 				      struct nf_conn *ct) {}
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
 static inline void nf_ct_expect_event(enum ip_conntrack_expect_events event,
 				      struct nf_conntrack_expect *exp) {}
-static inline void nf_ct_event_cache_flush(void) {}
+static inline void nf_ct_event_cache_flush(struct net *net) {}
+
+static inline int nf_conntrack_ecache_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void nf_conntrack_ecache_fini(struct net *net)
+{
+}
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
 
 #endif /*_NF_CONNTRACK_ECACHE_H*/
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -5,6 +5,8 @@
 #include <asm/atomic.h>
 #include <net/netfilter/nf_conntrack.h>
 
+struct nf_conntrack_ecache;
+
 struct netns_ct {
 	atomic_t		count;
 	struct hlist_head	*hash;
@@ -15,5 +17,8 @@ struct netns_ct {
 	struct hlist_head	unconfirmed;
 	/* Fake conntrack entry for untracked connections */
 	struct nf_conn		untracked;
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	struct nf_conntrack_ecache *ecache;
+#endif
 };
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -82,6 +82,8 @@ static int icmp_packet(struct nf_conn *ct,
 		       int pf,
 		       unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
+
 	/* Try to delete connection immediately after all replies:
 	   won't actually vanish as we still have skb, and del_timer
 	   means this will only run once even if count hits zero twice
@@ -91,7 +93,7 @@ static int icmp_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(net, IPCT_PROTOINFO_VOLATILE, skb);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
 	}
 
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -192,7 +192,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 		nf_conntrack_tcp_update(skb, ip_hdrlen(skb),
 					ct, CTINFO2DIR(ctinfo));
 
-		nf_conntrack_event_cache(IPCT_NATSEQADJ, skb);
+		nf_conntrack_event_cache(nf_ct_net(ct), IPCT_NATSEQADJ, skb);
 	}
 	return 1;
 }
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -84,6 +84,8 @@ static int icmpv6_packet(struct nf_conn *ct,
 		       int pf,
 		       unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
+
 	/* Try to delete connection immediately after all replies:
 	   won't actually vanish as we still have skb, and del_timer
 	   means this will only run once even if count hits zero twice
@@ -93,7 +95,7 @@ static int icmpv6_packet(struct nf_conn *ct,
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
 		atomic_inc(&ct->proto.icmp.count);
-		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(net, IPCT_PROTOINFO_VOLATILE, skb);
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmpv6_timeout);
 	}
 
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -367,13 +367,13 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	spin_unlock_bh(&nf_conntrack_lock);
 	help = nfct_help(ct);
 	if (help && help->helper)
-		nf_conntrack_event_cache(IPCT_HELPER, skb);
+		nf_conntrack_event_cache(net, IPCT_HELPER, skb);
 #ifdef CONFIG_NF_NAT_NEEDED
 	if (test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status) ||
 	    test_bit(IPS_DST_NAT_DONE_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_NATINFO, skb);
+		nf_conntrack_event_cache(net, IPCT_NATINFO, skb);
 #endif
-	nf_conntrack_event_cache(master_ct(ct) ?
+	nf_conntrack_event_cache(net, master_ct(ct) ?
 				 IPCT_RELATED : IPCT_NEW, skb);
 	return NF_ACCEPT;
 
@@ -732,7 +732,7 @@ nf_conntrack_in(struct net *net, int pf, unsigned int hooknum, struct sk_buff *s
 	}
 
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 
 	return ret;
 }
@@ -800,6 +800,7 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 			  unsigned long extra_jiffies,
 			  int do_acct)
 {
+	struct net *net = nf_ct_net(ct);
 	int event = 0;
 
 	NF_CT_ASSERT(ct->timeout.data == (unsigned long)ct);
@@ -845,7 +846,7 @@ acct:
 
 	/* must be unlocked when calling event cache */
 	if (event)
-		nf_conntrack_event_cache(event, skb);
+		nf_conntrack_event_cache(net, event, skb);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
@@ -1014,7 +1015,8 @@ void nf_conntrack_cleanup(struct net *net)
 	   delete... */
 	synchronize_net();
 
-	nf_ct_event_cache_flush();
+	nf_ct_event_cache_flush(net);
+	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
 	nf_conntrack_flush(net);
 	if (atomic_read(&net->ct.count) != 0) {
@@ -1142,11 +1144,14 @@ int nf_conntrack_init(struct net *net)
 		max_factor = 4;
 	}
 	atomic_set(&net->ct.count, 0);
+	ret = nf_conntrack_ecache_init(net);
+	if (ret < 0)
+		goto err_ecache;
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 						  &net->ct.hash_vmalloc);
 	if (!net->ct.hash) {
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
-		goto err_out;
+		goto err_hash;
 	}
 	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
@@ -1206,6 +1211,8 @@ err_free_conntrack_slab:
 err_free_hash:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
-err_out:
+err_hash:
+	nf_conntrack_ecache_fini(net);
+err_ecache:
 	return -ENOMEM;
 }
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -29,9 +29,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_chain);
 ATOMIC_NOTIFIER_HEAD(nf_ct_expect_chain);
 EXPORT_SYMBOL_GPL(nf_ct_expect_chain);
 
-DEFINE_PER_CPU(struct nf_conntrack_ecache, nf_conntrack_ecache);
-EXPORT_PER_CPU_SYMBOL_GPL(nf_conntrack_ecache);
-
 /* deliver cached events and clear cache entry - must be called with locally
  * disabled softirqs */
 static inline void
@@ -51,10 +48,11 @@ __nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
  * by code prior to async packet handling for freeing the skb */
 void nf_ct_deliver_cached_events(const struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
 
 	local_bh_disable();
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	if (ecache->ct == ct)
 		__nf_ct_deliver_cached_events(ecache);
 	local_bh_enable();
@@ -64,10 +62,11 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 /* Deliver cached events for old pending events, if current conntrack != old */
 void __nf_ct_event_cache_init(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
 
 	/* take care of delivering potentially old events */
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	BUG_ON(ecache->ct == ct);
 	if (ecache->ct)
 		__nf_ct_deliver_cached_events(ecache);
@@ -79,18 +78,31 @@ EXPORT_SYMBOL_GPL(__nf_ct_event_cache_init);
 
 /* flush the event cache - touches other CPU's data and must not be called
  * while packets are still passing through the code */
-void nf_ct_event_cache_flush(void)
+void nf_ct_event_cache_flush(struct net *net)
 {
 	struct nf_conntrack_ecache *ecache;
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		ecache = &per_cpu(nf_conntrack_ecache, cpu);
+		ecache = per_cpu_ptr(net->ct.ecache, cpu);
 		if (ecache->ct)
 			nf_ct_put(ecache->ct);
 	}
 }
 
+int nf_conntrack_ecache_init(struct net *net)
+{
+	net->ct.ecache = alloc_percpu(struct nf_conntrack_ecache);
+	if (!net->ct.ecache)
+		return -ENOMEM;
+	return 0;
+}
+
+void nf_conntrack_ecache_fini(struct net *net)
+{
+	free_percpu(net->ct.ecache);
+}
+
 int nf_conntrack_register_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_register(&nf_conntrack_chain, nb);
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -318,7 +318,8 @@ static int find_nl_seq(u32 seq, const struct nf_ct_ftp_master *info, int dir)
 }
 
 /* We don't update if it's older than what we have. */
-static void update_nl_seq(u32 nl_seq, struct nf_ct_ftp_master *info, int dir,
+static void update_nl_seq(struct net *net, u32 nl_seq,
+			  struct nf_ct_ftp_master *info, int dir,
 			  struct sk_buff *skb)
 {
 	unsigned int i, oldest = NUM_SEQ_TO_REMEMBER;
@@ -336,11 +337,11 @@ static void update_nl_seq(u32 nl_seq, struct nf_ct_ftp_master *info, int dir,
 
 	if (info->seq_aft_nl_num[dir] < NUM_SEQ_TO_REMEMBER) {
 		info->seq_aft_nl[dir][info->seq_aft_nl_num[dir]++] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(net, IPCT_HELPINFO_VOLATILE, skb);
 	} else if (oldest != NUM_SEQ_TO_REMEMBER &&
 		   after(nl_seq, info->seq_aft_nl[dir][oldest])) {
 		info->seq_aft_nl[dir][oldest] = nl_seq;
-		nf_conntrack_event_cache(IPCT_HELPINFO_VOLATILE, skb);
+		nf_conntrack_event_cache(net, IPCT_HELPINFO_VOLATILE, skb);
 	}
 }
 
@@ -509,7 +510,7 @@ out_update_nl:
 	/* Now if this ends in \n, update ftp info.  Seq may have been
 	 * adjusted by NAT code. */
 	if (ends_in_nl)
-		update_nl_seq(seq, ct_ftp_info, dir, skb);
+		update_nl_seq(nf_ct_net(ct), seq, ct_ftp_info, dir, skb);
  out:
 	spin_unlock_bh(&nf_ftp_lock);
 	return ret;
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -222,6 +222,8 @@ static int gre_packet(struct nf_conn *ct,
 		      int pf,
 		      unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
+
 	/* If we've seen traffic both ways, this is a GRE connection.
 	 * Extend timeout. */
 	if (ct->status & IPS_SEEN_REPLY) {
@@ -229,7 +231,7 @@ static int gre_packet(struct nf_conn *ct,
 				   ct->proto.gre.stream_timeout);
 		/* Also, more likely to be important, and not a probe. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb,
 				   ct->proto.gre.timeout);
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -290,6 +290,7 @@ static int sctp_packet(struct nf_conn *ct,
 		       int pf,
 		       unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
 	enum sctp_conntrack new_state, old_state;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	const struct sctphdr *sh;
@@ -369,7 +370,7 @@ static int sctp_packet(struct nf_conn *ct,
 
 		ct->proto.sctp.state = new_state;
 		if (old_state != new_state)
-			nf_conntrack_event_cache(IPCT_PROTOINFO, skb);
+			nf_conntrack_event_cache(net, IPCT_PROTOINFO, skb);
 	}
 	write_unlock_bh(&sctp_lock);
 
@@ -380,7 +381,7 @@ static int sctp_packet(struct nf_conn *ct,
 	    new_state == SCTP_CONNTRACK_ESTABLISHED) {
 		pr_debug("Setting assured bit\n");
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 	}
 
 	return NF_ACCEPT;
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -807,6 +807,7 @@ static int tcp_packet(struct nf_conn *ct,
 		      int pf,
 		      unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple *tuple;
 	enum tcp_conntrack new_state, old_state;
 	enum ip_conntrack_dir dir;
@@ -968,9 +969,9 @@ static int tcp_packet(struct nf_conn *ct,
 		timeout = tcp_timeouts[new_state];
 	write_unlock_bh(&tcp_lock);
 
-	nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, skb);
+	nf_conntrack_event_cache(net, IPCT_PROTOINFO_VOLATILE, skb);
 	if (new_state != old_state)
-		nf_conntrack_event_cache(IPCT_PROTOINFO, skb);
+		nf_conntrack_event_cache(net, IPCT_PROTOINFO, skb);
 
 	if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		/* If only reply is a RST, we can consider ourselves not to
@@ -989,7 +990,7 @@ static int tcp_packet(struct nf_conn *ct,
 		   after SYN_RECV or a valid answer for a picked up
 		   connection. */
 		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_STATUS, skb);
+		nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 	}
 	nf_ct_refresh_acct(ct, ctinfo, skb, timeout);
 
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -69,13 +69,15 @@ static int udp_packet(struct nf_conn *ct,
 		      int pf,
 		      unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
+
 	/* If we've seen traffic both ways, this is some kind of UDP
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, skb);
+			nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udp_timeout);
 
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -68,6 +68,8 @@ static int udplite_packet(struct nf_conn *ct,
 			  int pf,
 			  unsigned int hooknum)
 {
+	struct net *net = nf_ct_net(ct);
+
 	/* If we've seen traffic both ways, this is some kind of UDP
 	   stream.  Extend timeout. */
 	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
@@ -75,7 +77,7 @@ static int udplite_packet(struct nf_conn *ct,
 				   nf_ct_udplite_timeout_stream);
 		/* Also, more likely to be important, and not a probe */
 		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
-			nf_conntrack_event_cache(IPCT_STATUS, skb);
+			nf_conntrack_event_cache(net, IPCT_STATUS, skb);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_udplite_timeout);
 
--- a/net/netfilter/xt_CONNMARK.c
+++ b/net/netfilter/xt_CONNMARK.c
@@ -49,12 +49,14 @@ connmark_tg_v0(struct sk_buff *skb, const struct net_device *in,
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
+		struct net *net = nf_ct_net(ct);
+
 		switch(markinfo->mode) {
 		case XT_CONNMARK_SET:
 			newmark = (ct->mark & ~markinfo->mask) | markinfo->mark;
 			if (newmark != ct->mark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, skb);
+				nf_conntrack_event_cache(net, IPCT_MARK, skb);
 			}
 			break;
 		case XT_CONNMARK_SAVE:
@@ -62,7 +64,7 @@ connmark_tg_v0(struct sk_buff *skb, const struct net_device *in,
 				  (skb->mark & markinfo->mask);
 			if (ct->mark != newmark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, skb);
+				nf_conntrack_event_cache(net, IPCT_MARK, skb);
 			}
 			break;
 		case XT_CONNMARK_RESTORE:
@@ -84,18 +86,20 @@ connmark_tg(struct sk_buff *skb, const struct net_device *in,
 	const struct xt_connmark_tginfo1 *info = targinfo;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
+	struct net *net;
 	u_int32_t newmark;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct == NULL)
 		return XT_CONTINUE;
+	net = nf_ct_net(ct);
 
 	switch (info->mode) {
 	case XT_CONNMARK_SET:
 		newmark = (ct->mark & ~info->ctmask) ^ info->ctmark;
 		if (ct->mark != newmark) {
 			ct->mark = newmark;
-			nf_conntrack_event_cache(IPCT_MARK, skb);
+			nf_conntrack_event_cache(net, IPCT_MARK, skb);
 		}
 		break;
 	case XT_CONNMARK_SAVE:
@@ -103,7 +107,7 @@ connmark_tg(struct sk_buff *skb, const struct net_device *in,
 		          (skb->mark & info->nfmask);
 		if (ct->mark != newmark) {
 			ct->mark = newmark;
-			nf_conntrack_event_cache(IPCT_MARK, skb);
+			nf_conntrack_event_cache(net, IPCT_MARK, skb);
 		}
 		break;
 	case XT_CONNMARK_RESTORE:
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -43,7 +43,7 @@ static void secmark_save(const struct sk_buff *skb)
 		ct = nf_ct_get(skb, &ctinfo);
 		if (ct && !ct->secmark) {
 			ct->secmark = skb->secmark;
-			nf_conntrack_event_cache(IPCT_SECMARK, skb);
+			nf_conntrack_event_cache(nf_ct_net(ct), IPCT_SECMARK, skb);
 		}
 	}
 }
-- 
1.5.6.3


