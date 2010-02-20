From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 2/7] xfrm: SA lookups signature with mark
Date: Sat, 20 Feb 2010 15:55:35 -0500
Message-ID: <1266699340-5590-3-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-take2>
 <1266699340-5590-1-git-send-email-hadi@cyberus.ca>
 <1266699340-5590-2-git-send-email-hadi@cyberus.ca>
Cc: kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net, timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:43533 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756285Ab0BTUzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2010 15:55:52 -0500
Received: by qyk9 with SMTP id 9so233085qyk.21
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2010 12:55:51 -0800 (PST)
In-Reply-To: <1266699340-5590-2-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

pass mark to all SA lookups to prepare them for when we add code
to have them search.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 include/net/xfrm.h     |   23 +++++++++++++-----
 net/core/pktgen.c      |    3 +-
 net/ipv4/ah4.c         |    2 +-
 net/ipv4/esp4.c        |    2 +-
 net/ipv4/ipcomp.c      |    6 +++-
 net/ipv6/ah6.c         |    2 +-
 net/ipv6/esp6.c        |    2 +-
 net/ipv6/ipcomp6.c     |    6 +++-
 net/ipv6/xfrm6_input.c |    2 +-
 net/key/af_key.c       |   14 ++++++-----
 net/xfrm/xfrm_input.c  |    2 +-
 net/xfrm/xfrm_state.c  |   58 ++++++++++++++++++++++++++++-------------------
 net/xfrm/xfrm_user.c   |   17 ++++++++-----
 13 files changed, 84 insertions(+), 55 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4778520..047ae52 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1325,7 +1325,7 @@ extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
 					  unsigned short family);
-extern struct xfrm_state * xfrm_stateonly_find(struct net *net,
+extern struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
 					       xfrm_address_t *daddr,
 					       xfrm_address_t *saddr,
 					       unsigned short family,
@@ -1334,8 +1334,14 @@ extern int xfrm_state_check_expire(struct xfrm_state *x);
 extern void xfrm_state_insert(struct xfrm_state *x);
 extern int xfrm_state_add(struct xfrm_state *x);
 extern int xfrm_state_update(struct xfrm_state *x);
-extern struct xfrm_state *xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family);
-extern struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
+extern struct xfrm_state *xfrm_state_lookup(struct net *net, u32 mark,
+					    xfrm_address_t *daddr, __be32 spi,
+					    u8 proto, unsigned short family);
+extern struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, u32 mark,
+						   xfrm_address_t *daddr,
+						   xfrm_address_t *saddr,
+						   u8 proto,
+						   unsigned short family);
 #ifdef CONFIG_XFRM_SUB_POLICY
 extern int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
 			  int n, unsigned short family);
@@ -1372,7 +1378,8 @@ struct xfrmk_spdinfo {
 	u32 spdhmcnt;
 };
 
-extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 seq);
+extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark,
+					      u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
@@ -1457,9 +1464,11 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u8, int dir, u32 id, int d
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
-struct xfrm_state * xfrm_find_acq(struct net *net, u8 mode, u32 reqid, u8 proto,
-				  xfrm_address_t *daddr, xfrm_address_t *saddr,
-				  int create, unsigned short family);
+struct xfrm_state *xfrm_find_acq(struct net *net, struct xfrm_kmark *mark,
+				 u8 mode, u32 reqid, u8 proto,
+				 xfrm_address_t *daddr,
+				 xfrm_address_t *saddr, int create,
+				 unsigned short family);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 			  struct flowi *fl, int family, int strict);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2e692af..4392381 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2188,12 +2188,13 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 /* If there was already an IPSEC SA, we keep it as is, else
  * we go look for it ...
 */
+#define DUMMY_MARK 0
 static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 {
 	struct xfrm_state *x = pkt_dev->flows[flow].x;
 	if (!x) {
 		/*slow path: we dont already have xfrm_state*/
-		x = xfrm_stateonly_find(&init_net,
+		x = xfrm_stateonly_find(&init_net, DUMMY_MARK,
 					(xfrm_address_t *)&pkt_dev->cur_daddr,
 					(xfrm_address_t *)&pkt_dev->cur_saddr,
 					AF_INET,
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 7ed3e4a..987b47d 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -393,7 +393,7 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 1948895..14ca1f1 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -422,7 +422,7 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 83ed715..6290675 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -36,7 +36,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 		return;
 
 	spi = htonl(ntohs(ipch->cpi));
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
@@ -63,6 +63,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 	t->props.mode = x->props.mode;
 	t->props.saddr.a4 = x->props.saddr.a4;
 	t->props.flags = x->props.flags;
+	memcpy(&t->mark, &x->mark, sizeof(t->mark));
 
 	if (xfrm_init_state(t))
 		goto error;
@@ -87,8 +88,9 @@ static int ipcomp_tunnel_attach(struct xfrm_state *x)
 	struct net *net = xs_net(x);
 	int err = 0;
 	struct xfrm_state *t;
+	u32 mark = x->mark.v & x->mark.m;
 
-	t = xfrm_state_lookup(net, (xfrm_address_t *)&x->id.daddr.a4,
+	t = xfrm_state_lookup(net, mark, (xfrm_address_t *)&x->id.daddr.a4,
 			      x->props.saddr.a4, IPPROTO_IPIP, AF_INET);
 	if (!t) {
 		t = ipcomp_tunnel_create(x);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index c2f300c..5ac8902 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -614,7 +614,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
 	if (!x)
 		return;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 668a46b..ee9b93b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -365,7 +365,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index bb42f39..85cccd6 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -64,7 +64,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
-	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
+	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
 
@@ -92,6 +92,7 @@ static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 	t->props.family = AF_INET6;
 	t->props.mode = x->props.mode;
 	memcpy(t->props.saddr.a6, x->props.saddr.a6, sizeof(struct in6_addr));
+	memcpy(&t->mark, &x->mark, sizeof(t->mark));
 
 	if (xfrm_init_state(t))
 		goto error;
@@ -114,10 +115,11 @@ static int ipcomp6_tunnel_attach(struct xfrm_state *x)
 	int err = 0;
 	struct xfrm_state *t = NULL;
 	__be32 spi;
+	u32 mark = x->mark.m & x->mark.v;
 
 	spi = xfrm6_tunnel_spi_lookup(net, (xfrm_address_t *)&x->props.saddr);
 	if (spi)
-		t = xfrm_state_lookup(net, (xfrm_address_t *)&x->id.daddr,
+		t = xfrm_state_lookup(net, mark, (xfrm_address_t *)&x->id.daddr,
 					      spi, IPPROTO_IPV6, AF_INET6);
 	if (!t) {
 		t = ipcomp6_tunnel_create(x);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 9084582..2bc98ed 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -101,7 +101,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			break;
 		}
 
-		x = xfrm_state_lookup_byaddr(net, dst, src, proto, AF_INET6);
+		x = xfrm_state_lookup_byaddr(net, skb->mark, dst, src, proto, AF_INET6);
 		if (!x)
 			continue;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index a20d2fa..96598a9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -45,6 +45,8 @@ static DECLARE_WAIT_QUEUE_HEAD(pfkey_table_wait);
 static DEFINE_RWLOCK(pfkey_table_lock);
 static atomic_t pfkey_table_users = ATOMIC_INIT(0);
 
+#define DUMMY_MARK 0
+static struct xfrm_kmark dummy_mark = {0, 0};
 struct pfkey_sock {
 	/* struct sock must be the first member of struct pfkey_sock */
 	struct sock	sk;
@@ -691,7 +693,7 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct net *net, struct sadb_
 	if (!xaddr)
 		return NULL;
 
-	return xfrm_state_lookup(net, xaddr, sa->sadb_sa_spi, proto, family);
+	return xfrm_state_lookup(net, DUMMY_MARK, xaddr, sa->sadb_sa_spi, proto, family);
 }
 
 #define PFKEY_ALIGN8(a) (1 + (((a) - 1) | (8 - 1)))
@@ -1360,7 +1362,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	}
 
 	if (hdr->sadb_msg_seq) {
-		x = xfrm_find_acq_byseq(net, hdr->sadb_msg_seq);
+		x = xfrm_find_acq_byseq(net, DUMMY_MARK, hdr->sadb_msg_seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, xdaddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -1368,7 +1370,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	}
 
 	if (!x)
-		x = xfrm_find_acq(net, mode, reqid, proto, xdaddr, xsaddr, 1, family);
+		x = xfrm_find_acq(net, &dummy_mark, mode, reqid, proto, xdaddr, xsaddr, 1, family);
 
 	if (x == NULL)
 		return -ENOENT;
@@ -1417,7 +1419,7 @@ static int pfkey_acquire(struct sock *sk, struct sk_buff *skb, struct sadb_msg *
 	if (hdr->sadb_msg_seq == 0 || hdr->sadb_msg_errno == 0)
 		return 0;
 
-	x = xfrm_find_acq_byseq(net, hdr->sadb_msg_seq);
+	x = xfrm_find_acq_byseq(net, DUMMY_MARK, hdr->sadb_msg_seq);
 	if (x == NULL)
 		return 0;
 
@@ -2616,8 +2618,8 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 		return -EINVAL;
 
 	delete = (hdr->sadb_msg_type == SADB_X_SPDDELETE2);
-	xp = xfrm_policy_byid(net, XFRM_POLICY_TYPE_MAIN, dir,
-			      pol->sadb_x_policy_id, delete, &err);
+	xp = xfrm_policy_byid(net, XFRM_POLICY_TYPE_MAIN,
+			      dir, pol->sadb_x_policy_id, delete, &err);
 	if (xp == NULL)
 		return -ENOENT;
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index e0009c1..45f1c98 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -152,7 +152,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 		}
 
-		x = xfrm_state_lookup(net, daddr, spi, nexthdr, family);
+		x = xfrm_state_lookup(net, skb->mark, daddr, spi, nexthdr, family);
 		if (x == NULL) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9fa3322..5771008 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -669,7 +669,7 @@ xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	return 0;
 }
 
-static struct xfrm_state *__xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
 	unsigned int h = xfrm_spi_hash(net, daddr, spi, proto, family);
 	struct xfrm_state *x;
@@ -689,7 +689,7 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, xfrm_address_t *d
 	return NULL;
 }
 
-static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
 {
 	unsigned int h = xfrm_src_hash(net, daddr, saddr, family);
 	struct xfrm_state *x;
@@ -713,12 +713,14 @@ static inline struct xfrm_state *
 __xfrm_state_locate(struct xfrm_state *x, int use_spi, int family)
 {
 	struct net *net = xs_net(x);
+	u32 mark = x->mark.v & x->mark.m;
 
 	if (use_spi)
-		return __xfrm_state_lookup(net, &x->id.daddr, x->id.spi,
-					   x->id.proto, family);
+		return __xfrm_state_lookup(net, mark, &x->id.daddr,
+					   x->id.spi, x->id.proto, family);
 	else
-		return __xfrm_state_lookup_byaddr(net, &x->id.daddr,
+		return __xfrm_state_lookup_byaddr(net, mark,
+						  &x->id.daddr,
 						  &x->props.saddr,
 						  x->id.proto, family);
 }
@@ -783,6 +785,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	int acquire_in_progress = 0;
 	int error = 0;
 	struct xfrm_state *best = NULL;
+	u32 mark = pol->mark.v & pol->mark.m;
 
 	to_put = NULL;
 
@@ -819,7 +822,7 @@ found:
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
 		if (tmpl->id.spi &&
-		    (x0 = __xfrm_state_lookup(net, daddr, tmpl->id.spi,
+		    (x0 = __xfrm_state_lookup(net, mark, daddr, tmpl->id.spi,
 					      tmpl->id.proto, family)) != NULL) {
 			to_put = x0;
 			error = -EEXIST;
@@ -833,6 +836,7 @@ found:
 		/* Initialize temporary selector matching only
 		 * to current session. */
 		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
+		memcpy(&x->mark, &pol->mark, sizeof(x->mark));
 
 		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
 		if (error) {
@@ -875,7 +879,7 @@ out:
 }
 
 struct xfrm_state *
-xfrm_stateonly_find(struct net *net,
+xfrm_stateonly_find(struct net *net, u32 mark,
 		    xfrm_address_t *daddr, xfrm_address_t *saddr,
 		    unsigned short family, u8 mode, u8 proto, u32 reqid)
 {
@@ -971,7 +975,7 @@ void xfrm_state_insert(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_insert);
 
 /* xfrm_state_lock is held */
-static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
+static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_kmark *m, unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
 	unsigned int h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
 	struct hlist_node *entry;
@@ -1026,6 +1030,8 @@ static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family
 		x->props.family = family;
 		x->props.mode = mode;
 		x->props.reqid = reqid;
+		x->mark.v = m->v;
+		x->mark.m = m->m;
 		x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
 		tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
@@ -1042,7 +1048,7 @@ static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family
 	return x;
 }
 
-static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 seq);
+static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
 {
@@ -1050,6 +1056,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	struct xfrm_state *x1, *to_put;
 	int family;
 	int err;
+	u32 mark = x->mark.v & x->mark.m;
 	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 
 	family = x->props.family;
@@ -1067,7 +1074,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	}
 
 	if (use_spi && x->km.seq) {
-		x1 = __xfrm_find_acq_byseq(net, x->km.seq);
+		x1 = __xfrm_find_acq_byseq(net, mark, x->km.seq);
 		if (x1 && ((x1->id.proto != x->id.proto) ||
 		    xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family))) {
 			to_put = x1;
@@ -1076,8 +1083,8 @@ int xfrm_state_add(struct xfrm_state *x)
 	}
 
 	if (use_spi && !x1)
-		x1 = __find_acq_core(net, family, x->props.mode, x->props.reqid,
-				     x->id.proto,
+		x1 = __find_acq_core(net, &x->mark, family, x->props.mode,
+				     x->props.reqid, x->id.proto,
 				     &x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_bump_genids(x);
@@ -1151,6 +1158,8 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 			goto error;
 	}
 
+	memcpy(&x->mark, &orig->mark, sizeof(x->mark));
+
 	err = xfrm_init_state(x);
 	if (err)
 		goto error;
@@ -1342,41 +1351,41 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_check_expire);
 
 struct xfrm_state *
-xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto,
-		  unsigned short family)
+xfrm_state_lookup(struct net *net, u32 mark, xfrm_address_t *daddr, __be32 spi,
+		  u8 proto, unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_state_lookup(net, daddr, spi, proto, family);
+	x = __xfrm_state_lookup(net, mark, daddr, spi, proto, family);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
 
 struct xfrm_state *
-xfrm_state_lookup_byaddr(struct net *net,
+xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 			 xfrm_address_t *daddr, xfrm_address_t *saddr,
 			 u8 proto, unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_state_lookup_byaddr(net, daddr, saddr, proto, family);
+	x = __xfrm_state_lookup_byaddr(net, mark, daddr, saddr, proto, family);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup_byaddr);
 
 struct xfrm_state *
-xfrm_find_acq(struct net *net, u8 mode, u32 reqid, u8 proto,
+xfrm_find_acq(struct net *net, struct xfrm_kmark *mark, u8 mode, u32 reqid, u8 proto,
 	      xfrm_address_t *daddr, xfrm_address_t *saddr,
 	      int create, unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __find_acq_core(net, family, mode, reqid, proto, daddr, saddr, create);
+	x = __find_acq_core(net, mark, family, mode, reqid, proto, daddr, saddr, create);
 	spin_unlock_bh(&xfrm_state_lock);
 
 	return x;
@@ -1423,7 +1432,7 @@ EXPORT_SYMBOL(xfrm_state_sort);
 
 /* Silly enough, but I'm lazy to build resolution list */
 
-static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 seq)
+static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq)
 {
 	int i;
 
@@ -1442,12 +1451,12 @@ static struct xfrm_state *__xfrm_find_acq_byseq(struct net *net, u32 seq)
 	return NULL;
 }
 
-struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 seq)
+struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_find_acq_byseq(net, seq);
+	x = __xfrm_find_acq_byseq(net, mark, seq);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
@@ -1474,6 +1483,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	int err = -ENOENT;
 	__be32 minspi = htonl(low);
 	__be32 maxspi = htonl(high);
+	u32 mark = x->mark.v & x->mark.m;
 
 	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
@@ -1486,7 +1496,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	err = -ENOENT;
 
 	if (minspi == maxspi) {
-		x0 = xfrm_state_lookup(net, &x->id.daddr, minspi, x->id.proto, x->props.family);
+		x0 = xfrm_state_lookup(net, mark, &x->id.daddr, minspi, x->id.proto, x->props.family);
 		if (x0) {
 			xfrm_state_put(x0);
 			goto unlock;
@@ -1496,7 +1506,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 		u32 spi = 0;
 		for (h=0; h<high-low+1; h++) {
 			spi = low + net_random()%(high-low+1);
-			x0 = xfrm_state_lookup(net, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
+			x0 = xfrm_state_lookup(net, mark, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL) {
 				x->id.spi = htonl(spi);
 				break;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ee04e6b..1054754 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,6 +31,9 @@
 #include <linux/in6.h>
 #endif
 
+#define DUMMY_MARK 0
+static struct xfrm_kmark dummy_mark = {0, 0};
+
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -530,7 +533,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
 
 	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY)) {
 		err = -ESRCH;
-		x = xfrm_state_lookup(net, &p->daddr, p->spi, p->proto, p->family);
+		x = xfrm_state_lookup(net, DUMMY_MARK, &p->daddr, p->spi, p->proto, p->family);
 	} else {
 		xfrm_address_t *saddr = NULL;
 
@@ -541,7 +544,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct net *net,
 		}
 
 		err = -ESRCH;
-		x = xfrm_state_lookup_byaddr(net, &p->daddr, saddr,
+		x = xfrm_state_lookup_byaddr(net, DUMMY_MARK, &p->daddr, saddr,
 					     p->proto, p->family);
 	}
 
@@ -958,7 +961,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	x = NULL;
 	if (p->info.seq) {
-		x = xfrm_find_acq_byseq(net, p->info.seq);
+		x = xfrm_find_acq_byseq(net, DUMMY_MARK, p->info.seq);
 		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
@@ -966,7 +969,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	if (!x)
-		x = xfrm_find_acq(net, p->info.mode, p->info.reqid,
+		x = xfrm_find_acq(net, &dummy_mark, p->info.mode, p->info.reqid,
 				  p->info.id.proto, daddr,
 				  &p->info.saddr, 1,
 				  family);
@@ -1598,7 +1601,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	x = xfrm_state_lookup(net, &id->daddr, id->spi, id->proto, id->family);
+	x = xfrm_state_lookup(net, DUMMY_MARK, &id->daddr, id->spi, id->proto, id->family);
 	if (x == NULL) {
 		kfree_skb(r_skb);
 		return -ESRCH;
@@ -1640,7 +1643,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!(nlh->nlmsg_flags&NLM_F_REPLACE))
 		return err;
 
-	x = xfrm_state_lookup(net, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
+	x = xfrm_state_lookup(net, DUMMY_MARK, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
 	if (x == NULL)
 		return -ESRCH;
 
@@ -1767,7 +1770,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 
-	x = xfrm_state_lookup(net, &p->id.daddr, p->id.spi, p->id.proto, p->family);
+	x = xfrm_state_lookup(net, DUMMY_MARK, &p->id.daddr, p->id.spi, p->id.proto, p->family);
 
 	err = -ENOENT;
 	if (x == NULL)
-- 
1.6.0.4

