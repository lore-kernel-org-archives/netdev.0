From: adobriyan@gmail.com
Subject: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 22 Aug 2008 02:04:32 +0400
Message-ID: <20080821220432.GT31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:2529 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759293AbYHUWDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:03:07 -0400
Received: by gv-out-0910.google.com with SMTP id e6so77754gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:03:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make untracked conntrack per-netns. Compare conntracks with relevant
untracked one.

The following code you'll start laughing at this code:

	if (ct == ct->ct_net->ct.untracked)
		...

let me remind you that ->ct_net is set in only one place, and never
overwritten later.

All of this requires some surgery with headers, otherwise horrible circular
dependencies. And we lost nf_ct_is_untracked() as function, it became macro.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter/x_tables.h     |    4 ++--
 include/net/netfilter/nf_conntrack.h   |    9 ++-------
 include/net/netns/conntrack.h          |    3 +++
 net/ipv4/netfilter/arptable_filter.c   |    1 +
 net/ipv4/netfilter/nf_nat_core.c       |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c |    2 +-
 net/netfilter/nf_conntrack_acct.c      |    1 +
 net/netfilter/nf_conntrack_core.c      |   13 +++++--------
 net/netfilter/nf_conntrack_netlink.c   |    3 ++-
 net/netfilter/xt_NOTRACK.c             |    3 ++-
 net/netfilter/xt_conntrack.c           |    4 ++--
 net/netfilter/xt_state.c               |    4 ++--
 12 files changed, 24 insertions(+), 25 deletions(-)

--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -171,7 +171,7 @@ struct xt_counters_info
 
 #ifdef __KERNEL__
 
-#include <linux/netdevice.h>
+struct net_device;
 
 struct xt_match
 {
@@ -295,7 +295,7 @@ struct xt_table
 	int af;		/* address/protocol family */
 };
 
-#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter.h>
 
 /* The table itself */
 struct xt_table_info
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -256,9 +256,6 @@ extern void nf_conntrack_tcp_update(const struct sk_buff *skb,
 				    struct nf_conn *ct,
 				    int dir);
 
-/* Fake conntrack entry for untracked connections */
-extern struct nf_conn nf_conntrack_untracked;
-
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
 nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data);
@@ -280,10 +277,8 @@ static inline int nf_ct_is_dying(struct nf_conn *ct)
 	return test_bit(IPS_DYING_BIT, &ct->status);
 }
 
-static inline int nf_ct_is_untracked(const struct sk_buff *skb)
-{
-	return (skb->nfct == &nf_conntrack_untracked.ct_general);
-}
+#define nf_ct_is_untracked(net, skb)	\
+	((skb)->nfct == &(net)->ct.untracked.ct_general)
 
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <asm/atomic.h>
+#include <net/netfilter/nf_conntrack.h>
 
 struct netns_ct {
 	atomic_t		count;
@@ -12,5 +13,7 @@ struct netns_ct {
 	struct hlist_head	*expect_hash;
 	int			expect_vmalloc;
 	struct hlist_head	unconfirmed;
+	/* Fake conntrack entry for untracked connections */
+	struct nf_conn		untracked;
 };
 #endif
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_arp/arp_tables.h>
 
 MODULE_LICENSE("GPL");
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -616,7 +616,7 @@ static int __init nf_nat_init(void)
 	spin_unlock_bh(&nf_nat_lock);
 
 	/* Initialize fake conntrack so that NAT will skip it */
-	nf_conntrack_untracked.status |= IPS_NAT_DONE_MASK;
+	init_net.ct.untracked.status |= IPS_NAT_DONE_MASK;
 
 	l3proto = nf_ct_l3proto_find_get((u_int16_t)AF_INET);
 
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -97,7 +97,7 @@ nf_nat_fn(unsigned int hooknum,
 		return NF_ACCEPT;
 
 	/* Don't try to NAT if this packet is not conntracked */
-	if (ct == &nf_conntrack_untracked)
+	if (ct == &nf_ct_net(ct)->ct.untracked)
 		return NF_ACCEPT;
 
 	nat = nfct_nat(ct);
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -11,6 +11,7 @@
 #include <linux/netfilter.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
+#include <linux/seq_file.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_extend.h>
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -50,9 +50,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
-struct nf_conn nf_conntrack_untracked __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
-
 unsigned int nf_ct_log_invalid __read_mostly;
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
@@ -1024,8 +1021,8 @@ void nf_conntrack_cleanup(struct net *net)
 		schedule();
 		goto i_see_dead_people;
 	}
-	/* wait until all references to nf_conntrack_untracked are dropped */
-	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
+	/* wait until all references to untracked conntrack are dropped */
+	while (atomic_read(&net->ct.untracked.ct_general.use) > 1)
 		schedule();
 
 	rcu_assign_pointer(nf_ct_destroy, NULL);
@@ -1190,11 +1187,11 @@ int nf_conntrack_init(struct net *net)
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
 #ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
+	net->ct.untracked.ct_net = net;
 #endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+	atomic_set(&net->ct.untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+	set_bit(IPS_CONFIRMED_BIT, &net->ct.untracked.status);
 
 	return ret;
 
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -30,6 +30,7 @@
 
 #include <linux/netfilter.h>
 #include <net/netlink.h>
+#include <net/net_namespace.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -427,7 +428,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	unsigned int flags = 0, group;
 
 	/* ignore our fake conntrack entry */
-	if (ct == &nf_conntrack_untracked)
+	if (ct == &nf_ct_net(ct)->ct.untracked)
 		return NOTIFY_DONE;
 
 	if (events & IPCT_DESTROY) {
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -2,6 +2,7 @@
  * on packets so that they are not seen by the conntrack/NAT code.
  */
 #include <linux/module.h>
+#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -25,7 +26,7 @@ notrack_tg(struct sk_buff *skb, const struct net_device *in,
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
 	   for performance reasons. JK */
-	skb->nfct = &nf_conntrack_untracked.ct_general;
+	skb->nfct = &dev_net(in ? in : out)->ct.untracked.ct_general;
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -39,7 +39,7 @@ conntrack_mt_v0(const struct sk_buff *skb, const struct net_device *in,
 
 #define FWINV(bool, invflg) ((bool) ^ !!(sinfo->invflags & (invflg)))
 
-	if (ct == &nf_conntrack_untracked)
+	if (ct == &nf_ct_net(ct)->ct.untracked)
 		statebit = XT_CONNTRACK_STATE_UNTRACKED;
 	else if (ct)
 		statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
@@ -217,7 +217,7 @@ conntrack_mt(const struct sk_buff *skb, const struct net_device *in,
 
 	ct = nf_ct_get(skb, &ctinfo);
 
-	if (ct == &nf_conntrack_untracked)
+	if (ct == &nf_ct_net(ct)->ct.untracked)
 		statebit = XT_CONNTRACK_STATE_UNTRACKED;
 	else if (ct != NULL)
 		statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -10,6 +10,7 @@
 
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_state.h>
@@ -30,7 +31,7 @@ state_mt(const struct sk_buff *skb, const struct net_device *in,
 	enum ip_conntrack_info ctinfo;
 	unsigned int statebit;
 
-	if (nf_ct_is_untracked(skb))
+	if (nf_ct_is_untracked(dev_net(in ? in : out), skb))
 		statebit = XT_STATE_UNTRACKED;
 	else if (!nf_ct_get(skb, &ctinfo))
 		statebit = XT_STATE_INVALID;
-- 
1.5.6.3


