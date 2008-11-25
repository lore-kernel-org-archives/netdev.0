From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 27/53] netns xfrm: finding states in netns
Date: Tue, 25 Nov 2008 20:26:59 +0300
Message-ID: <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbYKYRYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:43 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:41 -0800 (PST)
In-Reply-To: <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h    |    7 +++--
 net/core/pktgen.c     |    3 +-
 net/key/af_key.c      |    6 ++--
 net/xfrm/xfrm_state.c |   73 +++++++++++++++++++++++++-----------------------
 net/xfrm/xfrm_user.c  |    4 +-
 5 files changed, 49 insertions(+), 44 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 15136c5..4cbd055 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1315,7 +1315,8 @@ extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
 					  unsigned short family);
-extern struct xfrm_state * xfrm_stateonly_find(xfrm_address_t *daddr,
+extern struct xfrm_state * xfrm_stateonly_find(struct net *net,
+					       xfrm_address_t *daddr,
 					       xfrm_address_t *saddr,
 					       unsigned short family,
 					       u8 mode, u8 proto, u32 reqid);
@@ -1361,7 +1362,7 @@ struct xfrmk_spdinfo {
 	u32 spdhmcnt;
 };
 
-extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
+extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
@@ -1446,7 +1447,7 @@ struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
 int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
-struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
+struct xfrm_state * xfrm_find_acq(struct net *net, u8 mode, u32 reqid, u8 proto,
 				  xfrm_address_t *daddr, xfrm_address_t *saddr,
 				  int create, unsigned short family);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 15e0c2c..6549848 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2165,7 +2165,8 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 	struct xfrm_state *x = pkt_dev->flows[flow].x;
 	if (!x) {
 		/*slow path: we dont already have xfrm_state*/
-		x = xfrm_stateonly_find((xfrm_address_t *)&pkt_dev->cur_daddr,
+		x = xfrm_stateonly_find(&init_net,
+					(xfrm_address_t *)&pkt_dev->cur_daddr,
 					(xfrm_address_t *)&pkt_dev->cur_saddr,
 					AF_INET,
 					pkt_dev->ipsmode,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 449a5d0..4ef0827 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1348,7 +1348,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	}
 
 	if (hdr->sadb_msg_seq) {
-		x = xfrm_find_acq_byseq(hdr->sadb_msg_seq);
+		x = xfrm_find_acq_byseq(&init_net, hdr->sadb_msg_seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, xdaddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -1356,7 +1356,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	}
 
 	if (!x)
-		x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 1, family);
+		x = xfrm_find_acq(&init_net, mode, reqid, proto, xdaddr, xsaddr, 1, family);
 
 	if (x == NULL)
 		return -ENOENT;
@@ -1404,7 +1404,7 @@ static int pfkey_acquire(struct sock *sk, struct sk_buff *skb, struct sadb_msg *
 	if (hdr->sadb_msg_seq == 0 || hdr->sadb_msg_errno == 0)
 		return 0;
 
-	x = xfrm_find_acq_byseq(hdr->sadb_msg_seq);
+	x = xfrm_find_acq_byseq(&init_net, hdr->sadb_msg_seq);
 	if (x == NULL)
 		return 0;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index cd51e4e..0d974fc 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -765,6 +765,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
+	struct net *net = xp_net(pol);
 	unsigned int h;
 	struct hlist_node *entry;
 	struct xfrm_state *x, *x0, *to_put;
@@ -775,8 +776,8 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	to_put = NULL;
 
 	spin_lock_bh(&xfrm_state_lock);
-	h = xfrm_dst_hash(&init_net, daddr, saddr, tmpl->reqid, family);
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
+	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, family);
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
@@ -820,13 +821,13 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
 		if (tmpl->id.spi &&
-		    (x0 = __xfrm_state_lookup(&init_net, daddr, tmpl->id.spi,
+		    (x0 = __xfrm_state_lookup(net, daddr, tmpl->id.spi,
 					      tmpl->id.proto, family)) != NULL) {
 			to_put = x0;
 			error = -EEXIST;
 			goto out;
 		}
-		x = xfrm_state_alloc(&init_net);
+		x = xfrm_state_alloc(net);
 		if (x == NULL) {
 			error = -ENOMEM;
 			goto out;
@@ -845,19 +846,19 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
-			list_add(&x->km.all, &init_net.xfrm.state_all);
-			hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
-			h = xfrm_src_hash(&init_net, daddr, saddr, family);
-			hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
+			list_add(&x->km.all, &net->xfrm.state_all);
+			hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
+			h = xfrm_src_hash(net, daddr, saddr, family);
+			hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 			if (x->id.spi) {
-				h = xfrm_spi_hash(&init_net, &x->id.daddr, x->id.spi, x->id.proto, family);
-				hlist_add_head(&x->byspi, init_net.xfrm.state_byspi+h);
+				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, family);
+				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 			add_timer(&x->timer);
-			init_net.xfrm.state_num++;
-			xfrm_hash_grow_check(&init_net, x->bydst.next != NULL);
+			net->xfrm.state_num++;
+			xfrm_hash_grow_check(net, x->bydst.next != NULL);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
 			to_put = x;
@@ -877,7 +878,8 @@ out:
 }
 
 struct xfrm_state *
-xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
+xfrm_stateonly_find(struct net *net,
+		    xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    unsigned short family, u8 mode, u8 proto, u32 reqid)
 {
 	unsigned int h;
@@ -885,8 +887,8 @@ xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	struct hlist_node *entry;
 
 	spin_lock(&xfrm_state_lock);
-	h = xfrm_dst_hash(&init_net, daddr, saddr, reqid, family);
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
+	h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == reqid &&
 		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
@@ -972,13 +974,13 @@ void xfrm_state_insert(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_insert);
 
 /* xfrm_state_lock is held */
-static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
+static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
-	unsigned int h = xfrm_dst_hash(&init_net, daddr, saddr, reqid, family);
+	unsigned int h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+h, bydst) {
+	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.reqid  != reqid ||
 		    x->props.mode   != mode ||
 		    x->props.family != family ||
@@ -1010,7 +1012,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 	if (!create)
 		return NULL;
 
-	x = xfrm_state_alloc(&init_net);
+	x = xfrm_state_alloc(net);
 	if (likely(x)) {
 		switch (family) {
 		case AF_INET:
@@ -1045,23 +1047,24 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		xfrm_state_hold(x);
 		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
-		list_add(&x->km.all, &init_net.xfrm.state_all);
-		hlist_add_head(&x->bydst, init_net.xfrm.state_bydst+h);
-		h = xfrm_src_hash(&init_net, daddr, saddr, family);
-		hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
+		list_add(&x->km.all, &net->xfrm.state_all);
+		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
+		h = xfrm_src_hash(net, daddr, saddr, family);
+		hlist_add_head(&x->bysrc, net->xfrm.state_bysrc+h);
 
-		init_net.xfrm.state_num++;
+		net->xfrm.state_num++;
 
-		xfrm_hash_grow_check(&init_net, x->bydst.next != NULL);
+		xfrm_hash_grow_check(net, x->bydst.next != NULL);
 	}
 
 	return x;
 }
 
-static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
+static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	struct xfrm_state *x1, *to_put;
 	int family;
 	int err;
@@ -1082,7 +1085,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	}
 
 	if (use_spi && x->km.seq) {
-		x1 = __xfrm_find_acq_byseq(x->km.seq);
+		x1 = __xfrm_find_acq_byseq(net, x->km.seq);
 		if (x1 && ((x1->id.proto != x->id.proto) ||
 		    xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family))) {
 			to_put = x1;
@@ -1091,7 +1094,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	}
 
 	if (use_spi && !x1)
-		x1 = __find_acq_core(family, x->props.mode, x->props.reqid,
+		x1 = __find_acq_core(net, family, x->props.mode, x->props.reqid,
 				     x->id.proto,
 				     &x->id.daddr, &x->props.saddr, 0);
 
@@ -1390,14 +1393,14 @@ xfrm_state_lookup_byaddr(struct net *net,
 EXPORT_SYMBOL(xfrm_state_lookup_byaddr);
 
 struct xfrm_state *
-xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
+xfrm_find_acq(struct net *net, u8 mode, u32 reqid, u8 proto,
 	      xfrm_address_t *daddr, xfrm_address_t *saddr,
 	      int create, unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __find_acq_core(family, mode, reqid, proto, daddr, saddr, create);
+	x = __find_acq_core(net, family, mode, reqid, proto, daddr, saddr, create);
 	spin_unlock_bh(&xfrm_state_lock);
 
 	return x;
@@ -1444,15 +1447,15 @@ EXPORT_SYMBOL(xfrm_state_sort);
 
 /* Silly enough, but I'm lazy to build resolution list */
 
-static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
+static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 seq)
 {
 	int i;
 
-	for (i = 0; i <= init_net.xfrm.state_hmask; i++) {
+	for (i = 0; i <= net->xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
-		hlist_for_each_entry(x, entry, init_net.xfrm.state_bydst+i, bydst) {
+		hlist_for_each_entry(x, entry, net->xfrm.state_bydst+i, bydst) {
 			if (x->km.seq == seq &&
 			    x->km.state == XFRM_STATE_ACQ) {
 				xfrm_state_hold(x);
@@ -1463,12 +1466,12 @@ static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
 	return NULL;
 }
 
-struct xfrm_state *xfrm_find_acq_byseq(u32 seq)
+struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 seq)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_find_acq_byseq(seq);
+	x = __xfrm_find_acq_byseq(net, seq);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e02ef33..3d57744 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -837,7 +837,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	x = NULL;
 	if (p->info.seq) {
-		x = xfrm_find_acq_byseq(p->info.seq);
+		x = xfrm_find_acq_byseq(&init_net, p->info.seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -845,7 +845,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	if (!x)
-		x = xfrm_find_acq(p->info.mode, p->info.reqid,
+		x = xfrm_find_acq(&init_net, p->info.mode, p->info.reqid,
 				  p->info.id.proto, daddr,
 				  &p->info.saddr, 1,
 				  family);
-- 
1.5.6.5

