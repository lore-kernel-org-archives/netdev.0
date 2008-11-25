From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 25/53] netns xfrm: state lookup in netns
Date: Tue, 25 Nov 2008 20:26:57 +0300
Message-ID: <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:35913 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbYKYRYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:39 -0500
Received: by ik-out-1112.google.com with SMTP id c29so47461ika.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:36 -0800 (PST)
In-Reply-To: <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    4 ++--
 net/ipv4/ah4.c         |    2 +-
 net/ipv4/esp4.c        |    2 +-
 net/ipv4/ipcomp.c      |    4 ++--
 net/ipv6/ah6.c         |    2 +-
 net/ipv6/esp6.c        |    2 +-
 net/ipv6/ipcomp6.c     |    4 ++--
 net/ipv6/xfrm6_input.c |    2 +-
 net/key/af_key.c       |    2 +-
 net/xfrm/xfrm_input.c  |    2 +-
 net/xfrm/xfrm_state.c  |   34 +++++++++++++++++++---------------
 net/xfrm/xfrm_user.c   |   12 ++++++------
 12 files changed, 38 insertions(+), 34 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e4bb672..15136c5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1323,8 +1323,8 @@ extern int xfrm_state_check_expire(struct xfrm_state *x);
 extern void xfrm_state_insert(struct xfrm_state *x);
 extern int xfrm_state_add(struct xfrm_state *x);
 extern int xfrm_state_update(struct xfrm_state *x);
-extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family);
-extern struct xfrm_state *xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
+extern struct xfrm_state *xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family);
+extern struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
 #ifdef CONFIG_XFRM_SUB_POLICY
 extern int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
 			  int n, unsigned short family);
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 992ecd8..750426b 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -209,7 +209,7 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 95a9c65..3595012 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -421,7 +421,7 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 	    icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
 		return;
 
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 0a35f1b..3262ce0 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -35,7 +35,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 		return;
 
 	spi = htonl(ntohs(ipch->cpi));
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
@@ -85,7 +85,7 @@ static int ipcomp_tunnel_attach(struct xfrm_state *x)
 	int err = 0;
 	struct xfrm_state *t;
 
-	t = xfrm_state_lookup((xfrm_address_t *)&x->id.daddr.a4,
+	t = xfrm_state_lookup(&init_net, (xfrm_address_t *)&x->id.daddr.a4,
 			      x->props.saddr.a4, IPPROTO_IPIP, AF_INET);
 	if (!t) {
 		t = ipcomp_tunnel_create(x);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 13e330d..6ae014b 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -415,7 +415,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
 	if (!x)
 		return;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c02a630..68f2af8 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -364,7 +364,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
 	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%pI6\n",
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index c369638..3a0b3be 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -63,7 +63,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
+	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
 
@@ -114,7 +114,7 @@ static int ipcomp6_tunnel_attach(struct xfrm_state *x)
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&x->props.saddr);
 	if (spi)
-		t = xfrm_state_lookup((xfrm_address_t *)&x->id.daddr,
+		t = xfrm_state_lookup(&init_net, (xfrm_address_t *)&x->id.daddr,
 					      spi, IPPROTO_IPV6, AF_INET6);
 	if (!t) {
 		t = ipcomp6_tunnel_create(x);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index a71c7dd..b69766a 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -100,7 +100,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			break;
 		}
 
-		x = xfrm_state_lookup_byaddr(dst, src, proto, AF_INET6);
+		x = xfrm_state_lookup_byaddr(&init_net, dst, src, proto, AF_INET6);
 		if (!x)
 			continue;
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index e5d595a..449a5d0 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -683,7 +683,7 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **
 	if (!xaddr)
 		return NULL;
 
-	return xfrm_state_lookup(xaddr, sa->sadb_sa_spi, proto, family);
+	return xfrm_state_lookup(&init_net, xaddr, sa->sadb_sa_spi, proto, family);
 }
 
 #define PFKEY_ALIGN8(a) (1 + (((a) - 1) | (8 - 1)))
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 7527940..c08a93e 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -151,7 +151,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 		}
 
-		x = xfrm_state_lookup(daddr, spi, nexthdr, family);
+		x = xfrm_state_lookup(&init_net, daddr, spi, nexthdr, family);
 		if (x == NULL) {
 			XFRM_INC_STATS(LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5f4c534..afde474 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -670,13 +670,13 @@ xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	return 0;
 }
 
-static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_spi_hash(&init_net, daddr, spi, proto, family);
+	unsigned int h = xfrm_spi_hash(net, daddr, spi, proto, family);
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_byspi+h, byspi) {
+	hlist_for_each_entry(x, entry, net->xfrm.state_byspi+h, byspi) {
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto)
@@ -702,13 +702,13 @@ static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi,
 	return NULL;
 }
 
-static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
+static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_src_hash(&init_net, daddr, saddr, family);
+	unsigned int h = xfrm_src_hash(net, daddr, saddr, family);
 	struct xfrm_state *x;
 	struct hlist_node *entry;
 
-	hlist_for_each_entry(x, entry, init_net.xfrm.state_bysrc+h, bysrc) {
+	hlist_for_each_entry(x, entry, net->xfrm.state_bysrc+h, bysrc) {
 		if (x->props.family != family ||
 		    x->id.proto     != proto)
 			continue;
@@ -740,11 +740,13 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm
 static inline struct xfrm_state *
 __xfrm_state_locate(struct xfrm_state *x, int use_spi, int family)
 {
+	struct net *net = xs_net(x);
+
 	if (use_spi)
-		return __xfrm_state_lookup(&x->id.daddr, x->id.spi,
+		return __xfrm_state_lookup(net, &x->id.daddr, x->id.spi,
 					   x->id.proto, family);
 	else
-		return __xfrm_state_lookup_byaddr(&x->id.daddr,
+		return __xfrm_state_lookup_byaddr(net, &x->id.daddr,
 						  &x->props.saddr,
 						  x->id.proto, family);
 }
@@ -818,7 +820,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
 		if (tmpl->id.spi &&
-		    (x0 = __xfrm_state_lookup(daddr, tmpl->id.spi,
+		    (x0 = __xfrm_state_lookup(&init_net, daddr, tmpl->id.spi,
 					      tmpl->id.proto, family)) != NULL) {
 			to_put = x0;
 			error = -EEXIST;
@@ -1361,26 +1363,27 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_check_expire);
 
 struct xfrm_state *
-xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi, u8 proto,
+xfrm_state_lookup(struct net *net, xfrm_address_t *daddr, __be32 spi, u8 proto,
 		  unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_state_lookup(daddr, spi, proto, family);
+	x = __xfrm_state_lookup(net, daddr, spi, proto, family);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
 
 struct xfrm_state *
-xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr,
+xfrm_state_lookup_byaddr(struct net *net,
+			 xfrm_address_t *daddr, xfrm_address_t *saddr,
 			 u8 proto, unsigned short family)
 {
 	struct xfrm_state *x;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = __xfrm_state_lookup_byaddr(daddr, saddr, proto, family);
+	x = __xfrm_state_lookup_byaddr(net, daddr, saddr, proto, family);
 	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
@@ -1486,6 +1489,7 @@ EXPORT_SYMBOL(xfrm_get_acqseq);
 
 int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 {
+	struct net *net = xs_net(x);
 	unsigned int h;
 	struct xfrm_state *x0;
 	int err = -ENOENT;
@@ -1503,7 +1507,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	err = -ENOENT;
 
 	if (minspi == maxspi) {
-		x0 = xfrm_state_lookup(&x->id.daddr, minspi, x->id.proto, x->props.family);
+		x0 = xfrm_state_lookup(net, &x->id.daddr, minspi, x->id.proto, x->props.family);
 		if (x0) {
 			xfrm_state_put(x0);
 			goto unlock;
@@ -1513,7 +1517,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 		u32 spi = 0;
 		for (h=0; h<high-low+1; h++) {
 			spi = low + net_random()%(high-low+1);
-			x0 = xfrm_state_lookup(&x->id.daddr, htonl(spi), x->id.proto, x->props.family);
+			x0 = xfrm_state_lookup(net, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL) {
 				x->id.spi = htonl(spi);
 				break;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 49a7e89..e02ef33 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -440,7 +440,7 @@ static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
 
 	if (xfrm_id_proto_match(p->proto, IPSEC_PROTO_ANY)) {
 		err = -ESRCH;
-		x = xfrm_state_lookup(&p->daddr, p->spi, p->proto, p->family);
+		x = xfrm_state_lookup(&init_net, &p->daddr, p->spi, p->proto, p->family);
 	} else {
 		xfrm_address_t *saddr = NULL;
 
@@ -451,8 +451,8 @@ static struct xfrm_state *xfrm_user_state_lookup(struct xfrm_usersa_id *p,
 		}
 
 		err = -ESRCH;
-		x = xfrm_state_lookup_byaddr(&p->daddr, saddr, p->proto,
-					     p->family);
+		x = xfrm_state_lookup_byaddr(&init_net, &p->daddr, saddr,
+					     p->proto, p->family);
 	}
 
  out:
@@ -1468,7 +1468,7 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	x = xfrm_state_lookup(&id->daddr, id->spi, id->proto, id->family);
+	x = xfrm_state_lookup(&init_net, &id->daddr, id->spi, id->proto, id->family);
 	if (x == NULL) {
 		kfree_skb(r_skb);
 		return -ESRCH;
@@ -1509,7 +1509,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!(nlh->nlmsg_flags&NLM_F_REPLACE))
 		return err;
 
-	x = xfrm_state_lookup(&p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
+	x = xfrm_state_lookup(&init_net, &p->sa_id.daddr, p->sa_id.spi, p->sa_id.proto, p->sa_id.family);
 	if (x == NULL)
 		return -ESRCH;
 
@@ -1628,7 +1628,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 
-	x = xfrm_state_lookup(&p->id.daddr, p->id.spi, p->id.proto, p->family);
+	x = xfrm_state_lookup(&init_net, &p->id.daddr, p->id.spi, p->id.proto, p->family);
 
 	err = -ENOENT;
 	if (x == NULL)
-- 
1.5.6.5

