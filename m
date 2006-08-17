From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/15]: [XFRM]: Pull xfrm_state_byspi hash table knowledge
 out of afinfo.
Date: Thu, 17 Aug 2006 01:27:49 -0700 (PDT)
Message-ID: <20060817.012749.71089567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30138
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932313AbWHQI1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:27:47 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Pull xfrm_state_byspi hash table knowledge out of afinfo.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    2 -
 net/ipv4/xfrm4_state.c |   19 ------------
 net/ipv6/xfrm6_state.c |   19 ------------
 net/xfrm/xfrm_state.c  |   73 ++++++++++++++++++++++++++----------------------
 4 files changed, 39 insertions(+), 74 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e53819f..00ae025 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -235,12 +235,10 @@ extern int __xfrm_state_delete(struct xf
 
 struct xfrm_state_afinfo {
 	unsigned short		family;
-	struct list_head	*state_byspi;
 	int			(*init_flags)(struct xfrm_state *x);
 	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
 						struct xfrm_tmpl *tmpl,
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
-	struct xfrm_state	*(*state_lookup)(xfrm_address_t *daddr, u32 spi, u8 proto);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index f0a77fc..097cb5d 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -62,29 +62,10 @@ __xfrm4_init_tempsel(struct xfrm_state *
 	x->props.family = AF_INET;
 }
 
-static struct xfrm_state *
-__xfrm4_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto)
-{
-	unsigned h = __xfrm4_spi_hash(daddr, spi, proto);
-	struct xfrm_state *x;
-
-	list_for_each_entry(x, xfrm4_state_afinfo.state_byspi+h, byspi) {
-		if (x->props.family == AF_INET &&
-		    spi == x->id.spi &&
-		    daddr->a4 == x->id.daddr.a4 &&
-		    proto == x->id.proto) {
-			xfrm_state_hold(x);
-			return x;
-		}
-	}
-	return NULL;
-}
-
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
-	.state_lookup		= __xfrm4_state_lookup,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index c43e45d..90ad0a4 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -63,28 +63,9 @@ __xfrm6_init_tempsel(struct xfrm_state *
 	x->props.family = AF_INET6;
 }
 
-static struct xfrm_state *
-__xfrm6_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto)
-{
-	unsigned h = __xfrm6_spi_hash(daddr, spi, proto);
-	struct xfrm_state *x;
-
-	list_for_each_entry(x, xfrm6_state_afinfo.state_byspi+h, byspi) {
-		if (x->props.family == AF_INET6 &&
-		    spi == x->id.spi &&
-		    ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)x->id.daddr.a6) &&
-		    proto == x->id.proto) {
-			xfrm_state_hold(x);
-			return x;
-		}
-	}
-	return NULL;
-}
-
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.init_tempsel		= __xfrm6_init_tempsel,
-	.state_lookup		= __xfrm6_state_lookup,
 };
 
 void __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index da67054..9da47aa 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -355,6 +355,37 @@ xfrm_init_tempsel(struct xfrm_state *x, 
 	return 0;
 }
 
+static struct xfrm_state *__xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family)
+{
+	unsigned int h = xfrm_spi_hash(daddr, spi, proto, family);
+	struct xfrm_state *x;
+
+	list_for_each_entry(x, xfrm_state_byspi+h, byspi) {
+		if (x->props.family != family ||
+		    x->id.spi       != spi ||
+		    x->id.proto     != proto)
+			continue;
+
+		switch (family) {
+		case AF_INET:
+			if (x->id.daddr.a4 != daddr->a4)
+				continue;
+			break;
+		case AF_INET6:
+			if (!ipv6_addr_equal((struct in6_addr *)daddr,
+					     (struct in6_addr *)
+					     x->id.daddr.a6))
+				continue;
+			break;
+		};
+
+		xfrm_state_hold(x);
+		return x;
+	}
+
+	return NULL;
+}
+
 struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 		struct flowi *fl, struct xfrm_tmpl *tmpl,
@@ -366,14 +397,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 	int acquire_in_progress = 0;
 	int error = 0;
 	struct xfrm_state *best = NULL;
-	struct xfrm_state_afinfo *afinfo;
 	
-	afinfo = xfrm_state_get_afinfo(family);
-	if (afinfo == NULL) {
-		*err = -EAFNOSUPPORT;
-		return NULL;
-	}
-
 	spin_lock_bh(&xfrm_state_lock);
 	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
 		if (x->props.family == family &&
@@ -418,8 +442,8 @@ xfrm_state_find(xfrm_address_t *daddr, x
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
 		if (tmpl->id.spi &&
-		    (x0 = afinfo->state_lookup(daddr, tmpl->id.spi,
-		                               tmpl->id.proto)) != NULL) {
+		    (x0 = __xfrm_state_lookup(daddr, tmpl->id.spi,
+					      tmpl->id.proto, family)) != NULL) {
 			xfrm_state_put(x0);
 			error = -EEXIST;
 			goto out;
@@ -459,7 +483,6 @@ out:
 	else
 		*err = acquire_in_progress ? -EAGAIN : error;
 	spin_unlock_bh(&xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
 	return x;
 }
 
@@ -579,19 +602,15 @@ static struct xfrm_state *__xfrm_find_ac
 
 int xfrm_state_add(struct xfrm_state *x)
 {
-	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
 	int family;
 	int err;
 
 	family = x->props.family;
-	afinfo = xfrm_state_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
 
 	spin_lock_bh(&xfrm_state_lock);
 
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	x1 = __xfrm_state_lookup(&x->id.daddr, x->id.spi, x->id.proto, family);
 	if (x1) {
 		xfrm_state_put(x1);
 		x1 = NULL;
@@ -617,7 +636,6 @@ int xfrm_state_add(struct xfrm_state *x)
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
 
 	if (!err)
 		xfrm_flush_all_bundles();
@@ -633,16 +651,12 @@ EXPORT_SYMBOL(xfrm_state_add);
 
 int xfrm_state_update(struct xfrm_state *x)
 {
-	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
+	unsigned short family = x->props.family;
 	int err;
 
-	afinfo = xfrm_state_get_afinfo(x->props.family);
-	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
-
 	spin_lock_bh(&xfrm_state_lock);
-	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
+	x1 = __xfrm_state_lookup(&x->id.daddr, x->id.spi, x->id.proto, family);
 
 	err = -ESRCH;
 	if (!x1)
@@ -662,7 +676,6 @@ int xfrm_state_update(struct xfrm_state 
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
 
 	if (err)
 		return err;
@@ -750,14 +763,10 @@ xfrm_state_lookup(xfrm_address_t *daddr,
 		  unsigned short family)
 {
 	struct xfrm_state *x;
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
-	if (!afinfo)
-		return NULL;
 
 	spin_lock_bh(&xfrm_state_lock);
-	x = afinfo->state_lookup(daddr, spi, proto);
+	x = __xfrm_state_lookup(daddr, spi, proto, family);
 	spin_unlock_bh(&xfrm_state_lock);
-	xfrm_state_put_afinfo(afinfo);
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
@@ -1172,10 +1181,8 @@ int xfrm_state_register_afinfo(struct xf
 	write_lock_bh(&xfrm_state_afinfo_lock);
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
-	else {
-		afinfo->state_byspi = xfrm_state_byspi;
+	else
 		xfrm_state_afinfo[afinfo->family] = afinfo;
-	}
 	write_unlock_bh(&xfrm_state_afinfo_lock);
 	return err;
 }
@@ -1192,10 +1199,8 @@ int xfrm_state_unregister_afinfo(struct 
 	if (likely(xfrm_state_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_state_afinfo[afinfo->family] != afinfo))
 			err = -EINVAL;
-		else {
+		else
 			xfrm_state_afinfo[afinfo->family] = NULL;
-			afinfo->state_byspi = NULL;
-		}
 	}
 	write_unlock_bh(&xfrm_state_afinfo_lock);
 	return err;
-- 
1.4.2.rc2.g3e042

