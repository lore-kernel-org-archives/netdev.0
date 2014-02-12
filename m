From: Horia Geanta <horia.geanta@freescale.com>
Subject: [PATCH ipsec-next v2] xfrm: avoid creating temporary SA when there are no listeners
Date: Wed, 12 Feb 2014 16:00:09 +0200
Message-ID: <1392213609-20098-1-git-send-email-horia.geanta@freescale.com>
References: <20140212120914.GB3438@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:13134
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868AbaBLOAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:00:37 -0500
In-Reply-To: <20140212120914.GB3438@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case when KMs have no listeners, km_query() will fail and
temporary SAs are garbage collected immediately after their allocation.
This causes strain on memory allocation, leading even to OOM since
temporary SA alloc/free cycle is performed for every packet
and garbage collection does not keep up the pace.

The sane thing to do is to make sure we have audience before
temporary SA allocation.

Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
---
v2: rebased onto current ipsec-next and fixed build failure

 include/net/xfrm.h    | 15 +++++++++++++++
 net/key/af_key.c      | 19 +++++++++++++++++++
 net/xfrm/xfrm_state.c | 31 +++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c  |  6 ++++++
 4 files changed, 71 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afa5730..5313ccf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -594,6 +594,7 @@ struct xfrm_mgr {
 					   const struct xfrm_migrate *m,
 					   int num_bundles,
 					   const struct xfrm_kmaddress *k);
+	bool			(*is_alive)(const struct km_event *c);
 };
 
 int xfrm_register_km(struct xfrm_mgr *km);
@@ -1646,6 +1647,20 @@ static inline int xfrm_aevent_is_on(struct net *net)
 	rcu_read_unlock();
 	return ret;
 }
+
+static inline int xfrm_acquire_is_on(struct net *net)
+{
+	struct sock *nlsk;
+	int ret = 0;
+
+	rcu_read_lock();
+	nlsk = rcu_dereference(net->xfrm.nlsk);
+	if (nlsk)
+		ret = netlink_has_listeners(nlsk, XFRMNLGRP_ACQUIRE);
+	rcu_read_unlock();
+
+	return ret;
+}
 #endif
 
 static inline int xfrm_alg_len(const struct xfrm_algo *alg)
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1a04c13..e1c69d0 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3059,6 +3059,24 @@ static u32 get_acqseq(void)
 	return res;
 }
 
+static bool pfkey_is_alive(const struct km_event *c)
+{
+	struct netns_pfkey *net_pfkey = net_generic(c->net, pfkey_net_id);
+	struct sock *sk;
+	bool is_alive = false;
+
+	rcu_read_lock();
+	sk_for_each_rcu(sk, &net_pfkey->table) {
+		if (pfkey_sk(sk)->registered) {
+			is_alive = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return is_alive;
+}
+
 static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *xp)
 {
 	struct sk_buff *skb;
@@ -3784,6 +3802,7 @@ static struct xfrm_mgr pfkeyv2_mgr =
 	.new_mapping	= pfkey_send_new_mapping,
 	.notify_policy	= pfkey_send_policy_notify,
 	.migrate	= pfkey_send_migrate,
+	.is_alive	= pfkey_is_alive,
 };
 
 static int __net_init pfkey_net_init(struct net *net)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a26b7aa..cea0dad 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -161,6 +161,7 @@ static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 int __xfrm_state_delete(struct xfrm_state *x);
 
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
+bool km_is_alive(const struct km_event *c);
 void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 
 static DEFINE_SPINLOCK(xfrm_type_lock);
@@ -788,6 +789,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 	struct xfrm_state *best = NULL;
 	u32 mark = pol->mark.v & pol->mark.m;
 	unsigned short encap_family = tmpl->encap_family;
+	struct km_event c;
 
 	to_put = NULL;
 
@@ -832,6 +834,17 @@ found:
 			error = -EEXIST;
 			goto out;
 		}
+
+		c.net = net;
+		/* If the KMs have no listeners (yet...), avoid allocating an SA
+		 * for each and every packet - garbage collection might not
+		 * handle the flood.
+		 */
+		if (!km_is_alive(&c)) {
+			error = -ESRCH;
+			goto out;
+		}
+
 		x = xfrm_state_alloc(net);
 		if (x == NULL) {
 			error = -ENOMEM;
@@ -1793,6 +1806,24 @@ int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address
 }
 EXPORT_SYMBOL(km_report);
 
+bool km_is_alive(const struct km_event *c)
+{
+	struct xfrm_mgr *km;
+	bool is_alive = false;
+
+	rcu_read_lock();
+	list_for_each_entry(km, &xfrm_km_list, list) {
+		if (km->is_alive && km->is_alive(c)) {
+			is_alive = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return is_alive;
+}
+EXPORT_SYMBOL(km_is_alive);
+
 int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
 	int err;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ade9988..d7694f2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2982,6 +2982,11 @@ static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_MAPPING, GFP_ATOMIC);
 }
 
+static bool xfrm_is_alive(const struct km_event *c)
+{
+	return (bool)xfrm_acquire_is_on(c->net);
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
@@ -2991,6 +2996,7 @@ static struct xfrm_mgr netlink_mgr = {
 	.report		= xfrm_send_report,
 	.migrate	= xfrm_send_migrate,
 	.new_mapping	= xfrm_send_mapping,
+	.is_alive	= xfrm_is_alive,
 };
 
 static int __net_init xfrm_user_net_init(struct net *net)
-- 
1.8.3.1
