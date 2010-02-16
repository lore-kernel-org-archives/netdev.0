From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 28/62: ctnetlink: support selective event delivery
Date: Tue, 16 Feb 2010 15:55:57 +0100 (MET)
Message-ID: <20100216145555.2796.24413.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52026 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442Ab0BPOz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:59 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0cebe4b4163b6373c9d24c1a192939777bc27e55
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 13:51:51 2010 +0100

    netfilter: ctnetlink: support selective event delivery
    
    Add two masks for conntrack end expectation events to struct nf_conntrack_ecache
    and use them to filter events. Their default value is "all events" when the
    event sysctl is on and "no events" when it is off. A following patch will add
    specific initializations. Expectation events depend on the ecache struct of
    their master conntrack.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index a374787..ebfed90 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -74,6 +74,24 @@ enum ip_conntrack_status {
 	IPS_FIXED_TIMEOUT = (1 << IPS_FIXED_TIMEOUT_BIT),
 };
 
+/* Connection tracking event types */
+enum ip_conntrack_events {
+	IPCT_NEW,		/* new conntrack */
+	IPCT_RELATED,		/* related conntrack */
+	IPCT_DESTROY,		/* destroyed conntrack */
+	IPCT_REPLY,		/* connection has seen two-way traffic */
+	IPCT_ASSURED,		/* connection status has changed to assured */
+	IPCT_PROTOINFO,		/* protocol information has changed */
+	IPCT_HELPER,		/* new helper has been set */
+	IPCT_MARK,		/* new mark has been set */
+	IPCT_NATSEQADJ,		/* NAT is doing sequence adjustment */
+	IPCT_SECMARK,		/* new security mark has been set */
+};
+
+enum ip_conntrack_expect_events {
+	IPEXP_NEW,		/* new expectation */
+};
+
 #ifdef __KERNEL__
 struct ip_conntrack_stat {
 	unsigned int searched;
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 5e05fb8..96ba5f7 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -12,28 +12,12 @@
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 
-/* Connection tracking event types */
-enum ip_conntrack_events {
-	IPCT_NEW,		/* new conntrack */
-	IPCT_RELATED,		/* related conntrack */
-	IPCT_DESTROY,		/* destroyed conntrack */
-	IPCT_REPLY,		/* connection has seen two-way traffic */
-	IPCT_ASSURED,		/* connection status has changed to assured */
-	IPCT_PROTOINFO,		/* protocol information has changed */
-	IPCT_HELPER,		/* new helper has been set */
-	IPCT_MARK,		/* new mark has been set */
-	IPCT_NATSEQADJ,		/* NAT is doing sequence adjustment */
-	IPCT_SECMARK,		/* new security mark has been set */
-};
-
-enum ip_conntrack_expect_events {
-	IPEXP_NEW,		/* new expectation */
-};
-
 struct nf_conntrack_ecache {
-	unsigned long cache;		/* bitops want long */
-	unsigned long missed;		/* missed events */
-	u32 pid;			/* netlink pid of destroyer */
+	unsigned long cache;	/* bitops want long */
+	unsigned long missed;	/* missed events */
+	u16 ctmask;		/* bitmask of ct events to be delivered */
+	u16 expmask;		/* bitmask of expect events to be delivered */
+	u32 pid;		/* netlink pid of destroyer */
 };
 
 static inline struct nf_conntrack_ecache *
@@ -43,14 +27,24 @@ nf_ct_ecache_find(const struct nf_conn *ct)
 }
 
 static inline struct nf_conntrack_ecache *
-nf_ct_ecache_ext_add(struct nf_conn *ct, gfp_t gfp)
+nf_ct_ecache_ext_add(struct nf_conn *ct, u16 ctmask, u16 expmask, gfp_t gfp)
 {
 	struct net *net = nf_ct_net(ct);
+	struct nf_conntrack_ecache *e;
 
-	if (!net->ct.sysctl_events)
+	if (!ctmask && !expmask && net->ct.sysctl_events) {
+		ctmask = ~0;
+		expmask = ~0;
+	}
+	if (!ctmask && !expmask)
 		return NULL;
 
-	return nf_ct_ext_add(ct, NF_CT_EXT_ECACHE, gfp);
+	e = nf_ct_ext_add(ct, NF_CT_EXT_ECACHE, gfp);
+	if (e) {
+		e->ctmask  = ctmask;
+		e->expmask = expmask;
+	}
+	return e;
 };
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
@@ -83,6 +77,9 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 	if (e == NULL)
 		return;
 
+	if (!(e->ctmask & (1 << event)))
+		return;
+
 	set_bit(event, &e->cache);
 }
 
@@ -93,7 +90,6 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 			      int report)
 {
 	int ret = 0;
-	struct net *net = nf_ct_net(ct);
 	struct nf_ct_event_notifier *notify;
 	struct nf_conntrack_ecache *e;
 
@@ -102,9 +98,6 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 	if (notify == NULL)
 		goto out_unlock;
 
-	if (!net->ct.sysctl_events)
-		goto out_unlock;
-
 	e = nf_ct_ecache_find(ct);
 	if (e == NULL)
 		goto out_unlock;
@@ -118,6 +111,9 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 		/* This is a resent of a destroy event? If so, skip missed */
 		unsigned long missed = e->pid ? 0 : e->missed;
 
+		if (!((eventmask | missed) & e->ctmask))
+			goto out_unlock;
+
 		ret = notify->fcn(eventmask | missed, &item);
 		if (unlikely(ret < 0 || missed)) {
 			spin_lock_bh(&ct->lock);
@@ -173,18 +169,19 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 			  u32 pid,
 			  int report)
 {
-	struct net *net = nf_ct_exp_net(exp);
 	struct nf_exp_event_notifier *notify;
+	struct nf_conntrack_ecache *e;
 
 	rcu_read_lock();
 	notify = rcu_dereference(nf_expect_event_cb);
 	if (notify == NULL)
 		goto out_unlock;
 
-	if (!net->ct.sysctl_events)
+	e = nf_ct_ecache_find(exp->master);
+	if (e == NULL)
 		goto out_unlock;
 
-	{
+	if (e->expmask & (1 << event)) {
 		struct nf_exp_event item = {
 			.exp	= exp,
 			.pid	= pid,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 091ff77..53b8da6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -648,7 +648,7 @@ init_conntrack(struct net *net,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-	nf_ct_ecache_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
 
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(net, tuple);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ff594eb..f5c0b09 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1281,7 +1281,7 @@ ctnetlink_create_conntrack(struct net *net,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
-	nf_ct_ecache_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
