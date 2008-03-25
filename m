From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-2.6.26]: IPv6 Updates.
Date: Tue, 25 Mar 2008 10:38:46 +0900 (JST)
Message-ID: <20080325.103846.132932838.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54971 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbYCYBjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 21:39:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following changes on top of net-2.6.26 available at
    git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-2.6.26-20080325b

Thanks.

--- 

HEADLINES
---------

    [XFRM] IPV6: Use distribution counting sort for xfrm_state/xfrm_tmpl chain.
    [XFRM] IPV6: Optimize xfrm6_input_addr().
    [XFRM] IPV6: Optimize __xfrm_tunnel_alloc_spi().
    [XFRM] MIP6: Fix address keys for routing search.
    [IPV6] ADDRCONF: Clean-up ipv6_dev_get_saddr().
    [IPV4,IPV6]: Share cork.rt between IPv4 and IPv6.
    [IPV6]: Convert cork.hop_limit and cork.tclass into u8 instead of int.
    [IPV6]: Optimize hop-limit determination.
    [IPV6]: Use bitfields for hop_limit and mcast_hops.
    [IPV6]: Support Source Address Selection API (RFC5014).

DIFFSTAT
--------

 include/linux/in6.h      |   11 +
 include/linux/ipv6.h     |   39 +++-
 include/net/addrconf.h   |    3 
 include/net/inet_sock.h  |    2 
 include/net/ip6_route.h  |   11 +
 include/net/xfrm.h       |   17 ++
 net/ipv4/ip_output.c     |   14 +
 net/ipv6/addrconf.c      |  433 +++++++++++++++++++++++-----------------------
 net/ipv6/fib6_rules.c    |   12 +
 net/ipv6/icmp.c          |    8 -
 net/ipv6/ip6_output.c    |   20 +-
 net/ipv6/ipv6_sockglue.c |   82 ++++++++-
 net/ipv6/ndisc.c         |    4 
 net/ipv6/raw.c           |    4 
 net/ipv6/route.c         |   29 ++-
 net/ipv6/udp.c           |    4 
 net/ipv6/xfrm6_input.c   |   55 +-----
 net/ipv6/xfrm6_policy.c  |    2 
 net/ipv6/xfrm6_state.c   |  171 ++++++++----------
 net/ipv6/xfrm6_tunnel.c  |   45 ++---
 net/sctp/ipv6.c          |    4 
 net/xfrm/xfrm_policy.c   |   49 ++++-
 22 files changed, 575 insertions(+), 444 deletions(-)

CHANGESETS
----------

commit 3b6cdf94cd6dd0b64cc8646cf067a1ae0203276d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Feb 19 10:15:27 2008 +0900

    [XFRM] IPV6: Use distribution counting sort for xfrm_state/xfrm_tmpl chain.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index dc817e0..5a46bb9 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -49,125 +49,102 @@ __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	x->props.family = AF_INET6;
 }
 
+/* distribution counting sort function for xfrm_state and xfrm_tmpl */
 static int
-__xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
+__xfrm6_sort(void **dst, void **src, int n, int (*cmp)(void *p), int maxclass)
 {
 	int i;
-	int j = 0;
+	int class[XFRM_MAX_DEPTH];
+	int count[maxclass];
 
-	/* Rule 1: select IPsec transport except AH */
-	for (i = 0; i < n; i++) {
-		if (src[i]->props.mode == XFRM_MODE_TRANSPORT &&
-		    src[i]->id.proto != IPPROTO_AH) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
-	}
-	if (j == n)
-		goto end;
+	memset(count, 0, sizeof(count));
 
-	/* Rule 2: select MIPv6 RO or inbound trigger */
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 	for (i = 0; i < n; i++) {
-		if (src[i] &&
-		    (src[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION ||
-		     src[i]->props.mode == XFRM_MODE_IN_TRIGGER)) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
+		int c;
+		class[i] = c = cmp(src[i]);
+		count[c]++;
 	}
-	if (j == n)
-		goto end;
-#endif
 
-	/* Rule 3: select IPsec transport AH */
-	for (i = 0; i < n; i++) {
-		if (src[i] &&
-		    src[i]->props.mode == XFRM_MODE_TRANSPORT &&
-		    src[i]->id.proto == IPPROTO_AH) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
-	}
-	if (j == n)
-		goto end;
+	for (i = 2; i < maxclass; i++)
+		count[i] += count[i - 1];
 
-	/* Rule 4: select IPsec tunnel */
 	for (i = 0; i < n; i++) {
-		if (src[i] &&
-		    (src[i]->props.mode == XFRM_MODE_TUNNEL ||
-		     src[i]->props.mode == XFRM_MODE_BEET)) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
+		dst[count[class[i] - 1]++] = src[i];
+		src[i] = 0;
 	}
-	if (likely(j == n))
-		goto end;
 
-	/* Final rule */
-	for (i = 0; i < n; i++) {
-		if (src[i]) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
-	}
-
- end:
 	return 0;
 }
 
-static int
-__xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
+/*
+ * Rule for xfrm_state:
+ *
+ * rule 1: select IPsec transport except AH
+ * rule 2: select MIPv6 RO or inbound trigger
+ * rule 3: select IPsec transport AH
+ * rule 4: select IPsec tunnel
+ * rule 5: others
+ */
+static int __xfrm6_state_sort_cmp(void *p)
 {
-	int i;
-	int j = 0;
-
-	/* Rule 1: select IPsec transport */
-	for (i = 0; i < n; i++) {
-		if (src[i]->mode == XFRM_MODE_TRANSPORT) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
-	}
-	if (j == n)
-		goto end;
-
-	/* Rule 2: select MIPv6 RO or inbound trigger */
+	struct xfrm_state *v = p;
+
+	switch (v->props.mode) {
+	case XFRM_MODE_TRANSPORT:
+		if (v->id.proto != IPPROTO_AH)
+			return 1;
+		else
+			return 3;
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-	for (i = 0; i < n; i++) {
-		if (src[i] &&
-		    (src[i]->mode == XFRM_MODE_ROUTEOPTIMIZATION ||
-		     src[i]->mode == XFRM_MODE_IN_TRIGGER)) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
-	}
-	if (j == n)
-		goto end;
+	case XFRM_MODE_ROUTEOPTIMIZATION:
+	case XFRM_MODE_IN_TRIGGER:
+		return 2;
 #endif
-
-	/* Rule 3: select IPsec tunnel */
-	for (i = 0; i < n; i++) {
-		if (src[i] &&
-		    (src[i]->mode == XFRM_MODE_TUNNEL ||
-		     src[i]->mode == XFRM_MODE_BEET)) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
+	case XFRM_MODE_TUNNEL:
+	case XFRM_MODE_BEET:
+		return 4;
 	}
-	if (likely(j == n))
-		goto end;
+	return 5;
+}
 
-	/* Final rule */
-	for (i = 0; i < n; i++) {
-		if (src[i]) {
-			dst[j++] = src[i];
-			src[i] = NULL;
-		}
+static int
+__xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
+{
+	return __xfrm6_sort((void **)dst, (void **)src, n,
+			    __xfrm6_state_sort_cmp, 6);
+}
+
+/*
+ * Rule for xfrm_tmpl:
+ *
+ * rule 1: select IPsec transport
+ * rule 2: select MIPv6 RO or inbound trigger
+ * rule 3: select IPsec tunnel
+ * rule 4: others
+ */
+static int __xfrm6_tmpl_sort_cmp(void *p)
+{
+	struct xfrm_tmpl *v = p;
+	switch (v->mode) {
+	case XFRM_MODE_TRANSPORT:
+		return 1;
+#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+	case XFRM_MODE_ROUTEOPTIMIZATION:
+	case XFRM_MODE_IN_TRIGGER:
+		return 2;
+#endif
+	case XFRM_MODE_TUNNEL:
+	case XFRM_MODE_BEET:
+		return 3;
 	}
+	return 4;
+}
 
- end:
-	return 0;
+static int
+__xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
+{
+	return __xfrm6_sort((void **)dst, (void **)src, n,
+			    __xfrm6_tmpl_sort_cmp, 5);
 }
 
 int xfrm6_extract_header(struct sk_buff *skb)

---
commit a002c6fd714b1710aaf64e26db3f3f18bf8e8384
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Feb 19 17:24:33 2008 +0900

    [XFRM] IPV6: Optimize xfrm6_input_addr().
    
    | % size old/net/ipv6/xfrm6_input.o new/net/ipv6/xfrm6_input.o
    |    text	   data	    bss	    dec	    hex	filename
    |    1026	      0	      0	   1026	    402	old/net/ipv6/xfrm6_input.o
    |     947	      0	      0	    947	    3b3	new/net/ipv6/xfrm6_input.o
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index a4714d7..a71c7dd 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -59,9 +59,6 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		     xfrm_address_t *saddr, u8 proto)
 {
 	struct xfrm_state *x = NULL;
-	int wildcard = 0;
-	xfrm_address_t *xany;
-	int nh = 0;
 	int i = 0;
 
 	/* Allocate new secpath or COW existing one. */
@@ -83,10 +80,9 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		goto drop;
 	}
 
-	xany = (xfrm_address_t *)&in6addr_any;
-
 	for (i = 0; i < 3; i++) {
 		xfrm_address_t *dst, *src;
+
 		switch (i) {
 		case 0:
 			dst = daddr;
@@ -94,16 +90,13 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			break;
 		case 1:
 			/* lookup state with wild-card source address */
-			wildcard = 1;
 			dst = daddr;
-			src = xany;
+			src = (xfrm_address_t *)&in6addr_any;
 			break;
-		case 2:
 		default:
 			/* lookup state with wild-card addresses */
-			wildcard = 1; /* XXX */
-			dst = xany;
-			src = xany;
+			dst = (xfrm_address_t *)&in6addr_any;
+			src = (xfrm_address_t *)&in6addr_any;
 			break;
 		}
 
@@ -113,39 +106,19 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 
 		spin_lock(&x->lock);
 
-		if (wildcard) {
-			if ((x->props.flags & XFRM_STATE_WILDRECV) == 0) {
-				spin_unlock(&x->lock);
-				xfrm_state_put(x);
-				x = NULL;
-				continue;
-			}
-		}
-
-		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+		if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
+		    likely(x->km.state == XFRM_STATE_VALID) &&
+		    !xfrm_state_check_expire(x)) {
 			spin_unlock(&x->lock);
-			xfrm_state_put(x);
-			x = NULL;
-			continue;
-		}
-		if (xfrm_state_check_expire(x)) {
+			if (x->type->input(x, skb) > 0) {
+				/* found a valid state */
+				break;
+			}
+		} else
 			spin_unlock(&x->lock);
-			xfrm_state_put(x);
-			x = NULL;
-			continue;
-		}
-
-		spin_unlock(&x->lock);
-
-		nh = x->type->input(x, skb);
-		if (nh <= 0) {
-			xfrm_state_put(x);
-			x = NULL;
-			continue;
-		}
 
-		/* Found a state */
-		break;
+		xfrm_state_put(x);
+		x = NULL;
 	}
 
 	if (!x) {

---
commit df8ea19b5d2e7512095bb1e0737513b8da196d64
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Feb 19 22:54:00 2008 +0900

    [XFRM] IPV6: Optimize __xfrm_tunnel_alloc_spi().
    
    | % size old/net/ipv6/xfrm6_tunnel.o new/net/ipv6/xfrm6_tunnel.o
    |    text	   data	    bss	    dec	    hex	filename
    |    1606	     40	   2080	   3726	    e8e	old/net/ipv6/xfrm6_tunnel.o
    |    1574	     40	   2080	   3694	    e6e	new/net/ipv6/xfrm6_tunnel.o
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 639fe8a..c2b2781 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -140,12 +140,26 @@ __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr)
 
 EXPORT_SYMBOL(xfrm6_tunnel_spi_lookup);
 
+static int __xfrm6_tunnel_spi_check(u32 spi)
+{
+	struct xfrm6_tunnel_spi *x6spi;
+	int index = xfrm6_tunnel_spi_hash_byspi(spi);
+	struct hlist_node *pos;
+
+	hlist_for_each_entry(x6spi, pos,
+			     &xfrm6_tunnel_spi_byspi[index],
+			     list_byspi) {
+		if (x6spi->spi == spi)
+			return -1;
+	}
+	return index;
+}
+
 static u32 __xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr)
 {
 	u32 spi;
 	struct xfrm6_tunnel_spi *x6spi;
-	struct hlist_node *pos;
-	unsigned index;
+	int index;
 
 	if (xfrm6_tunnel_spi < XFRM6_TUNNEL_SPI_MIN ||
 	    xfrm6_tunnel_spi >= XFRM6_TUNNEL_SPI_MAX)
@@ -154,32 +168,19 @@ static u32 __xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr)
 		xfrm6_tunnel_spi++;
 
 	for (spi = xfrm6_tunnel_spi; spi <= XFRM6_TUNNEL_SPI_MAX; spi++) {
-		index = xfrm6_tunnel_spi_hash_byspi(spi);
-		hlist_for_each_entry(x6spi, pos,
-				     &xfrm6_tunnel_spi_byspi[index],
-				     list_byspi) {
-			if (x6spi->spi == spi)
-				goto try_next_1;
-		}
-		xfrm6_tunnel_spi = spi;
-		goto alloc_spi;
-try_next_1:;
+		index = __xfrm6_tunnel_spi_check(spi);
+		if (index >= 0)
+			goto alloc_spi;
 	}
 	for (spi = XFRM6_TUNNEL_SPI_MIN; spi < xfrm6_tunnel_spi; spi++) {
-		index = xfrm6_tunnel_spi_hash_byspi(spi);
-		hlist_for_each_entry(x6spi, pos,
-				     &xfrm6_tunnel_spi_byspi[index],
-				     list_byspi) {
-			if (x6spi->spi == spi)
-				goto try_next_2;
-		}
-		xfrm6_tunnel_spi = spi;
-		goto alloc_spi;
-try_next_2:;
+		index = __xfrm6_tunnel_spi_check(spi);
+		if (index >= 0)
+			goto alloc_spi;
 	}
 	spi = 0;
 	goto out;
 alloc_spi:
+	xfrm6_tunnel_spi = spi;
 	x6spi = kmem_cache_alloc(xfrm6_tunnel_spi_kmem, GFP_ATOMIC);
 	if (!x6spi)
 		goto out;

---
commit 9bb182a7007515239091b237fe7169b1328a61d3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Feb 22 14:48:22 2008 +0900

    [XFRM] MIP6: Fix address keys for routing search.
    
    Each MIPv6 XFRM state (DSTOPT/RH2) holds either destination or source
    address to be mangled in the IPv6 header (that is "CoA").
    On Inter-MN communication after both nodes binds each other,
    they use route optimized traffic two MIPv6 states applied, and
    both source and destination address in the IPv6 header
    are replaced by the states respectively.
    The packet format is correct, however, next-hop routing search
    are not.
    This patch fixes it by remembering address pairs for later states.
    
    Based on patch from Masahide NAKAMURA <nakam@linux-ipv6.org>.
    
    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c435620..bed7d43 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1045,6 +1045,23 @@ xfrm_address_t *xfrm_flowi_saddr(struct flowi *fl, unsigned short family)
 	return NULL;
 }
 
+static __inline__
+void xfrm_flowi_addr_get(struct flowi *fl,
+			 xfrm_address_t *saddr, xfrm_address_t *daddr,
+			 unsigned short family)
+{
+	switch(family) {
+	case AF_INET:
+		memcpy(&saddr->a4, &fl->fl4_src, sizeof(saddr->a4));
+		memcpy(&daddr->a4, &fl->fl4_dst, sizeof(daddr->a4));
+		break;
+	case AF_INET6:
+		ipv6_addr_copy((struct in6_addr *)&saddr->a6, &fl->fl6_src);
+		ipv6_addr_copy((struct in6_addr *)&daddr->a6, &fl->fl6_dst);
+		break;
+	}
+}
+
 static __inline__ int
 __xfrm4_state_addr_check(struct xfrm_state *x,
 			 xfrm_address_t *daddr, xfrm_address_t *saddr)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index bae94a8..8e588f2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -97,25 +97,52 @@ int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 	return 0;
 }
 
+static inline struct dst_entry *__xfrm_dst_lookup(int tos,
+						  xfrm_address_t *saddr,
+						  xfrm_address_t *daddr,
+						  int family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+	struct dst_entry *dst;
+
+	afinfo = xfrm_policy_get_afinfo(family);
+	if (unlikely(afinfo == NULL))
+		return ERR_PTR(-EAFNOSUPPORT);
+
+	dst = afinfo->dst_lookup(tos, saddr, daddr);
+
+	xfrm_policy_put_afinfo(afinfo);
+
+	return dst;
+}
+
 static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
+						xfrm_address_t *prev_saddr,
+						xfrm_address_t *prev_daddr,
 						int family)
 {
 	xfrm_address_t *saddr = &x->props.saddr;
 	xfrm_address_t *daddr = &x->id.daddr;
-	struct xfrm_policy_afinfo *afinfo;
 	struct dst_entry *dst;
 
-	if (x->type->flags & XFRM_TYPE_LOCAL_COADDR)
+	if (x->type->flags & XFRM_TYPE_LOCAL_COADDR) {
 		saddr = x->coaddr;
-	if (x->type->flags & XFRM_TYPE_REMOTE_COADDR)
+		daddr = prev_daddr;
+	}
+	if (x->type->flags & XFRM_TYPE_REMOTE_COADDR) {
+		saddr = prev_saddr;
 		daddr = x->coaddr;
+	}
 
-	afinfo = xfrm_policy_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
-		return ERR_PTR(-EAFNOSUPPORT);
+	dst = __xfrm_dst_lookup(tos, saddr, daddr, family);
+
+	if (!IS_ERR(dst)) {
+		if (prev_saddr != saddr)
+			memcpy(prev_saddr, saddr,  sizeof(*prev_saddr));
+		if (prev_daddr != daddr)
+			memcpy(prev_daddr, daddr,  sizeof(*prev_daddr));
+	}
 
-	dst = afinfo->dst_lookup(tos, saddr, daddr);
-	xfrm_policy_put_afinfo(afinfo);
 	return dst;
 }
 
@@ -1354,6 +1381,9 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	int trailer_len = 0;
 	int tos;
 	int family = policy->selector.family;
+	xfrm_address_t saddr, daddr;
+
+	xfrm_flowi_addr_get(fl, &saddr, &daddr, family);
 
 	tos = xfrm_get_tos(fl, family);
 	err = tos;
@@ -1384,7 +1414,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			family = xfrm[i]->props.family;
-			dst = xfrm_dst_lookup(xfrm[i], tos, family);
+			dst = xfrm_dst_lookup(xfrm[i], tos, &saddr, &daddr,
+					      family);
 			err = PTR_ERR(dst);
 			if (IS_ERR(dst))
 				goto put_states;

---
commit a9b05723ffa2e427b0257b81ea74363fcd7c304f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Mar 2 10:48:21 2008 +0900

    [IPV6] ADDRCONF: Clean-up ipv6_dev_get_saddr().
    
    old:
    |    text	   data	    bss	    dec	    hex	filename
    |   28599	   1416	     96	  30111	   759f	net/ipv6/addrconf.o
    
    new:
    |    text	   data	    bss	    dec	    hex	filename
    |   28007	   1416	     96	  29519	   734f	net/ipv6/addrconf.o
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b86d38..787e90a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -877,20 +877,39 @@ out:
 /*
  *	Choose an appropriate source address (RFC3484)
  */
+enum {
+	IPV6_SADDR_RULE_INIT = 0,
+	IPV6_SADDR_RULE_LOCAL,
+	IPV6_SADDR_RULE_SCOPE,
+	IPV6_SADDR_RULE_PREFERRED,
+#ifdef CONFIG_IPV6_MIP6
+	IPV6_SADDR_RULE_HOA,
+#endif
+	IPV6_SADDR_RULE_OIF,
+	IPV6_SADDR_RULE_LABEL,
+#ifdef CONFIG_IPV6_PRIVACY
+	IPV6_SADDR_RULE_PRIVACY,
+#endif
+	IPV6_SADDR_RULE_ORCHID,
+	IPV6_SADDR_RULE_PREFIX,
+	IPV6_SADDR_RULE_MAX
+};
+
 struct ipv6_saddr_score {
-	int		addr_type;
-	unsigned int	attrs;
-	int		matchlen;
-	int		scope;
-	unsigned int	rule;
+	int			rule;
+	int			addr_type;
+	struct inet6_ifaddr	*ifa;
+	DECLARE_BITMAP(scorebits, IPV6_SADDR_RULE_MAX);
+	int			scopedist;
+	int			matchlen;
 };
 
-#define IPV6_SADDR_SCORE_LOCAL		0x0001
-#define IPV6_SADDR_SCORE_PREFERRED	0x0004
-#define IPV6_SADDR_SCORE_HOA		0x0008
-#define IPV6_SADDR_SCORE_OIF		0x0010
-#define IPV6_SADDR_SCORE_LABEL		0x0020
-#define IPV6_SADDR_SCORE_PRIVACY	0x0040
+struct ipv6_saddr_dst {
+	struct in6_addr *addr;
+	int ifindex;
+	int scope;
+	int label;
+};
 
 static inline int ipv6_saddr_preferred(int type)
 {
@@ -900,28 +919,142 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
-int ipv6_dev_get_saddr(struct net_device *daddr_dev,
+static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
+			       struct ipv6_saddr_dst *dst,
+			       int i)
+{
+	int ret;
+
+	if (i <= score->rule) {
+		switch (i) {
+		case IPV6_SADDR_RULE_SCOPE:
+			ret = score->scopedist;
+			break;
+		case IPV6_SADDR_RULE_PREFIX:
+			ret = score->matchlen;
+			break;
+		default:
+			ret = !!test_bit(i, score->scorebits);
+		}
+		goto out;
+	}
+
+	switch (i) {
+	case IPV6_SADDR_RULE_INIT:
+		/* Rule 0: remember if hiscore is not ready yet */
+		ret = !!score->ifa;
+		break;
+	case IPV6_SADDR_RULE_LOCAL:
+		/* Rule 1: Prefer same address */
+		ret = ipv6_addr_equal(&score->ifa->addr, dst->addr);
+		break;
+	case IPV6_SADDR_RULE_SCOPE:
+		/* Rule 2: Prefer appropriate scope
+		 *
+		 *      ret
+		 *       ^
+		 *    -1 |  d 15
+		 *    ---+--+-+---> scope
+		 *       |
+		 *       |             d is scope of the destination.
+		 *  B-d  |  \
+		 *       |   \      <- smaller scope is better if
+		 *  B-15 |    \        if scope is enough for destinaion.
+		 *       |             ret = B - scope (-1 <= scope >= d <= 15).
+		 * d-C-1 | /
+		 *       |/         <- greater is better
+		 *   -C  /             if scope is not enough for destination.
+		 *      /|             ret = scope - C (-1 <= d < scope <= 15).
+		 *
+		 * d - C - 1 < B -15 (for all -1 <= d <= 15).
+		 * C > d + 14 - B >= 15 + 14 - B = 29 - B.
+		 * Assume B = 0 and we get C > 29.
+		 */
+		ret = __ipv6_addr_src_scope(score->addr_type);
+		if (ret >= dst->scope)
+			ret = -ret;
+		else
+			ret -= 128;	/* 30 is enough */
+		score->scopedist = ret;
+		break;
+	case IPV6_SADDR_RULE_PREFERRED:
+		/* Rule 3: Avoid deprecated and optimistic addresses */
+		ret = ipv6_saddr_preferred(score->addr_type) ||
+		      !(score->ifa->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
+		break;
+#ifdef CONFIG_IPV6_MIP6
+	case IPV6_SADDR_RULE_HOA:
+		/* Rule 4: Prefer home address */
+		ret = !!(score->ifa->flags & IFA_F_HOMEADDRESS);
+		break;
+#endif
+	case IPV6_SADDR_RULE_OIF:
+		/* Rule 5: Prefer outgoing interface */
+		ret = (!dst->ifindex ||
+		       dst->ifindex == score->ifa->idev->dev->ifindex);
+		break;
+	case IPV6_SADDR_RULE_LABEL:
+		/* Rule 6: Prefer matching label */
+		ret = ipv6_addr_label(&score->ifa->addr, score->addr_type,
+				      score->ifa->idev->dev->ifindex) == dst->label;
+		break;
+#ifdef CONFIG_IPV6_PRIVACY
+	case IPV6_SADDR_RULE_PRIVACY:
+		/* Rule 7: Prefer public address
+		 * Note: prefer temprary address if use_tempaddr >= 2
+		 */
+		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ (score->ifa->idev->cnf.use_tempaddr >= 2);
+		break;
+#endif
+	case IPV6_SADDR_RULE_ORCHID:
+		/* Rule 8-: Prefer ORCHID vs ORCHID or
+		 *	    non-ORCHID vs non-ORCHID
+		 */
+		ret = !(ipv6_addr_orchid(&score->ifa->addr) ^
+			ipv6_addr_orchid(dst->addr));
+		break;
+	case IPV6_SADDR_RULE_PREFIX:
+		/* Rule 8: Use longest matching prefix */
+		score->matchlen = ret = ipv6_addr_diff(&score->ifa->addr,
+						       dst->addr);
+		break;
+	default:
+		ret = 0;
+	}
+
+	if (ret)
+		__set_bit(i, score->scorebits);
+	score->rule = i;
+out:
+	return ret;
+}
+
+int ipv6_dev_get_saddr(struct net_device *dst_dev,
 		       struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	struct ipv6_saddr_score hiscore;
-	struct inet6_ifaddr *ifa_result = NULL;
-	struct net *net = daddr_dev->nd_net;
-	int daddr_type = __ipv6_addr_type(daddr);
-	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
-	int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;
-	u32 daddr_label = ipv6_addr_label(daddr, daddr_type, daddr_ifindex);
+	struct ipv6_saddr_score scores[2],
+				*score = &scores[0], *hiscore = &scores[1];
+	struct net *net = dst_dev->nd_net;
+	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
+	int dst_type;
+
+	dst_type = __ipv6_addr_type(daddr);
+	dst.addr = daddr;
+	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
+	dst.scope = __ipv6_addr_src_scope(dst_type);
+	dst.label = ipv6_addr_label(daddr, dst_type, dst.ifindex);
 
-	memset(&hiscore, 0, sizeof(hiscore));
+	hiscore->rule = -1;
+	hiscore->ifa = NULL;
 
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
 
 	for_each_netdev(net, dev) {
 		struct inet6_dev *idev;
-		struct inet6_ifaddr *ifa;
 
-		/* Rule 0: Candidate Source Address (section 4)
+		/* Candidate Source Address (section 4)
 		 *  - multicast and link-local destination address,
 		 *    the set of candidate source address MUST only
 		 *    include addresses assigned to interfaces
@@ -933,9 +1066,9 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 		 *    belonging to the same site as the outgoing
 		 *    interface.)
 		 */
-		if ((daddr_type & IPV6_ADDR_MULTICAST ||
-		     daddr_scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
-		    daddr_dev && dev != daddr_dev)
+		if (((dst_type & IPV6_ADDR_MULTICAST) ||
+		     dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
+		    dst.ifindex && dev->ifindex != dst.ifindex)
 			continue;
 
 		idev = __in6_dev_get(dev);
@@ -943,12 +1076,10 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			continue;
 
 		read_lock_bh(&idev->lock);
-		for (ifa = idev->addr_list; ifa; ifa = ifa->if_next) {
-			struct ipv6_saddr_score score;
+		for (score->ifa = idev->addr_list; score->ifa; score->ifa = score->ifa->if_next) {
+			int i;
 
-			score.addr_type = __ipv6_addr_type(&ifa->addr);
-
-			/* Rule 0:
+			/*
 			 * - Tentative Address (RFC2462 section 5.4)
 			 *  - A tentative address is not considered
 			 *    "assigned to an interface" in the traditional
@@ -958,11 +1089,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			 *    addresses, and the unspecified address MUST
 			 *    NOT be included in a candidate set.
 			 */
-			if ((ifa->flags & IFA_F_TENTATIVE) &&
-			    (!(ifa->flags & IFA_F_OPTIMISTIC)))
+			if ((score->ifa->flags & IFA_F_TENTATIVE) &&
+			    (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
 				continue;
-			if (unlikely(score.addr_type == IPV6_ADDR_ANY ||
-				     score.addr_type & IPV6_ADDR_MULTICAST)) {
+
+			score->addr_type = __ipv6_addr_type(&score->ifa->addr);
+
+			if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
+				     score->addr_type & IPV6_ADDR_MULTICAST)) {
 				LIMIT_NETDEBUG(KERN_DEBUG
 					       "ADDRCONF: unspecified / multicast address "
 					       "assigned as unicast address on %s",
@@ -970,201 +1104,59 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 				continue;
 			}
 
-			score.attrs = 0;
-			score.matchlen = 0;
-			score.scope = 0;
-			score.rule = 0;
-
-			if (ifa_result == NULL) {
-				/* record it if the first available entry */
-				goto record_it;
-			}
-
-			/* Rule 1: Prefer same address */
-			if (hiscore.rule < 1) {
-				if (ipv6_addr_equal(&ifa_result->addr, daddr))
-					hiscore.attrs |= IPV6_SADDR_SCORE_LOCAL;
-				hiscore.rule++;
-			}
-			if (ipv6_addr_equal(&ifa->addr, daddr)) {
-				score.attrs |= IPV6_SADDR_SCORE_LOCAL;
-				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LOCAL)) {
-					score.rule = 1;
-					goto record_it;
-				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_LOCAL)
-					continue;
-			}
+			score->rule = -1;
+			bitmap_zero(score->scorebits, IPV6_SADDR_RULE_MAX);
+
+			for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
+				int minihiscore, miniscore;
+
+				minihiscore = ipv6_get_saddr_eval(hiscore, &dst, i);
+				miniscore = ipv6_get_saddr_eval(score, &dst, i);
+
+				if (minihiscore > miniscore) {
+					if (i == IPV6_SADDR_RULE_SCOPE &&
+					    score->scopedist > 0) {
+						/*
+						 * special case:
+						 * each remaining entry
+						 * has too small (not enough)
+						 * scope, because ifa entries
+						 * are sorted by their scope
+						 * values.
+						 */
+						goto try_nextdev;
+					}
+					break;
+				} else if (minihiscore < miniscore) {
+					struct ipv6_saddr_score *tmp;
 
-			/* Rule 2: Prefer appropriate scope */
-			if (hiscore.rule < 2) {
-				hiscore.scope = __ipv6_addr_src_scope(hiscore.addr_type);
-				hiscore.rule++;
-			}
-			score.scope = __ipv6_addr_src_scope(score.addr_type);
-			if (hiscore.scope < score.scope) {
-				if (hiscore.scope < daddr_scope) {
-					score.rule = 2;
-					goto record_it;
-				} else
-					continue;
-			} else if (score.scope < hiscore.scope) {
-				if (score.scope < daddr_scope)
-					break; /* addresses sorted by scope */
-				else {
-					score.rule = 2;
-					goto record_it;
-				}
-			}
+					if (hiscore->ifa)
+						in6_ifa_put(hiscore->ifa);
 
-			/* Rule 3: Avoid deprecated and optimistic addresses */
-			if (hiscore.rule < 3) {
-				if (ipv6_saddr_preferred(hiscore.addr_type) ||
-				   (((ifa_result->flags &
-				    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0)))
-					hiscore.attrs |= IPV6_SADDR_SCORE_PREFERRED;
-				hiscore.rule++;
-			}
-			if (ipv6_saddr_preferred(score.addr_type) ||
-			   (((ifa->flags &
-			    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0))) {
-				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
-				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
-					score.rule = 3;
-					goto record_it;
-				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)
-					continue;
-			}
+					in6_ifa_hold(score->ifa);
 
-			/* Rule 4: Prefer home address */
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-			if (hiscore.rule < 4) {
-				if (ifa_result->flags & IFA_F_HOMEADDRESS)
-					hiscore.attrs |= IPV6_SADDR_SCORE_HOA;
-				hiscore.rule++;
-			}
-			if (ifa->flags & IFA_F_HOMEADDRESS) {
-				score.attrs |= IPV6_SADDR_SCORE_HOA;
-				if (!(ifa_result->flags & IFA_F_HOMEADDRESS)) {
-					score.rule = 4;
-					goto record_it;
-				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_HOA)
-					continue;
-			}
-#else
-			if (hiscore.rule < 4)
-				hiscore.rule++;
-#endif
+					tmp = hiscore;
+					hiscore = score;
+					score = tmp;
 
-			/* Rule 5: Prefer outgoing interface */
-			if (hiscore.rule < 5) {
-				if (daddr_dev == NULL ||
-				    daddr_dev == ifa_result->idev->dev)
-					hiscore.attrs |= IPV6_SADDR_SCORE_OIF;
-				hiscore.rule++;
-			}
-			if (daddr_dev == NULL ||
-			    daddr_dev == ifa->idev->dev) {
-				score.attrs |= IPV6_SADDR_SCORE_OIF;
-				if (!(hiscore.attrs & IPV6_SADDR_SCORE_OIF)) {
-					score.rule = 5;
-					goto record_it;
-				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_OIF)
-					continue;
-			}
-
-			/* Rule 6: Prefer matching label */
-			if (hiscore.rule < 6) {
-				if (ipv6_addr_label(&ifa_result->addr,
-						    hiscore.addr_type,
-						    ifa_result->idev->dev->ifindex) == daddr_label)
-					hiscore.attrs |= IPV6_SADDR_SCORE_LABEL;
-				hiscore.rule++;
-			}
-			if (ipv6_addr_label(&ifa->addr,
-					    score.addr_type,
-					    ifa->idev->dev->ifindex) == daddr_label) {
-				score.attrs |= IPV6_SADDR_SCORE_LABEL;
-				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LABEL)) {
-					score.rule = 6;
-					goto record_it;
-				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_LABEL)
-					continue;
-			}
+					/* restore our iterator */
+					score->ifa = hiscore->ifa;
 
-#ifdef CONFIG_IPV6_PRIVACY
-			/* Rule 7: Prefer public address
-			 * Note: prefer temprary address if use_tempaddr >= 2
-			 */
-			if (hiscore.rule < 7) {
-				if ((!(ifa_result->flags & IFA_F_TEMPORARY)) ^
-				    (ifa_result->idev->cnf.use_tempaddr >= 2))
-					hiscore.attrs |= IPV6_SADDR_SCORE_PRIVACY;
-				hiscore.rule++;
-			}
-			if ((!(ifa->flags & IFA_F_TEMPORARY)) ^
-			    (ifa->idev->cnf.use_tempaddr >= 2)) {
-				score.attrs |= IPV6_SADDR_SCORE_PRIVACY;
-				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PRIVACY)) {
-					score.rule = 7;
-					goto record_it;
+					break;
 				}
-			} else {
-				if (hiscore.attrs & IPV6_SADDR_SCORE_PRIVACY)
-					continue;
-			}
-#else
-			if (hiscore.rule < 7)
-				hiscore.rule++;
-#endif
-
-			/* Skip rule 8 for orchid -> non-orchid address pairs. */
-			if (ipv6_addr_orchid(&ifa->addr) && !ipv6_addr_orchid(daddr))
-				continue;
-
-			/* Rule 8: Use longest matching prefix */
-			if (hiscore.rule < 8) {
-				hiscore.matchlen = ipv6_addr_diff(&ifa_result->addr, daddr);
-				hiscore.rule++;
-			}
-			score.matchlen = ipv6_addr_diff(&ifa->addr, daddr);
-			if (score.matchlen > hiscore.matchlen) {
-				score.rule = 8;
-				goto record_it;
 			}
-#if 0
-			else if (score.matchlen < hiscore.matchlen)
-				continue;
-#endif
-
-			/* Final Rule: choose first available one */
-			continue;
-record_it:
-			if (ifa_result)
-				in6_ifa_put(ifa_result);
-			in6_ifa_hold(ifa);
-			ifa_result = ifa;
-			hiscore = score;
 		}
+try_nextdev:
 		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
 	read_unlock(&dev_base_lock);
 
-	if (!ifa_result)
+	if (!hiscore->ifa)
 		return -EADDRNOTAVAIL;
 
-	ipv6_addr_copy(saddr, &ifa_result->addr);
-	in6_ifa_put(ifa_result);
+	ipv6_addr_copy(saddr, &hiscore->ifa->addr);
+	in6_ifa_put(hiscore->ifa);
 	return 0;
 }
 

---
commit c8cdaf998df221b01134a051aba38c570105061b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 10 04:30:37 2008 -0400

    [IPV4,IPV6]: Share cork.rt between IPv4 and IPv6.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4aaefc3..2102d8b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -315,7 +315,6 @@ struct ipv6_pinfo {
 	struct sk_buff		*pktoptions;
 	struct {
 		struct ipv6_txoptions *opt;
-		struct rt6_info	*rt;
 		int hop_limit;
 		int tclass;
 	} cork;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b6db16d..a42cd63 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -136,7 +136,7 @@ struct inet_sock {
 		unsigned int		flags;
 		unsigned int		fragsize;
 		struct ip_options	*opt;
-		struct rtable		*rt;
+		struct dst_entry	*dst;
 		int			length; /* Total length of all frames */
 		__be32			addr;
 		struct flowi		fl;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 349fae5..913266c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -825,7 +825,7 @@ int ip_append_data(struct sock *sk,
 		inet->cork.fragsize = mtu = inet->pmtudisc == IP_PMTUDISC_PROBE ?
 					    rt->u.dst.dev->mtu :
 					    dst_mtu(rt->u.dst.path);
-		inet->cork.rt = rt;
+		inet->cork.dst = &rt->u.dst;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
@@ -834,7 +834,7 @@ int ip_append_data(struct sock *sk,
 			transhdrlen += exthdrlen;
 		}
 	} else {
-		rt = inet->cork.rt;
+		rt = (struct rtable *)inet->cork.dst;
 		if (inet->cork.flags & IPCORK_OPT)
 			opt = inet->cork.opt;
 
@@ -1083,7 +1083,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	if (skb_queue_empty(&sk->sk_write_queue))
 		return -EINVAL;
 
-	rt = inet->cork.rt;
+	rt = (struct rtable *)inet->cork.dst;
 	if (inet->cork.flags & IPCORK_OPT)
 		opt = inet->cork.opt;
 
@@ -1208,10 +1208,8 @@ static void ip_cork_release(struct inet_sock *inet)
 	inet->cork.flags &= ~IPCORK_OPT;
 	kfree(inet->cork.opt);
 	inet->cork.opt = NULL;
-	if (inet->cork.rt) {
-		ip_rt_put(inet->cork.rt);
-		inet->cork.rt = NULL;
-	}
+	dst_release(inet->cork.dst);
+	inet->cork.dst = NULL;
 }
 
 /*
@@ -1224,7 +1222,7 @@ int ip_push_pending_frames(struct sock *sk)
 	struct sk_buff **tail_skb;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options *opt = NULL;
-	struct rtable *rt = inet->cork.rt;
+	struct rtable *rt = (struct rtable *)inet->cork.dst;
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 98762fd..ed64826 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1115,7 +1115,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			/* need source address above miyazawa*/
 		}
 		dst_hold(&rt->u.dst);
-		np->cork.rt = rt;
+		inet->cork.dst = &rt->u.dst;
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		np->cork.tclass = tclass;
@@ -1136,7 +1136,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
-		rt = np->cork.rt;
+		rt = (struct rt6_info *)inet->cork.dst;
 		fl = &inet->cork.fl;
 		if (inet->cork.flags & IPCORK_OPT)
 			opt = np->cork.opt;
@@ -1381,9 +1381,9 @@ static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 	inet->cork.flags &= ~IPCORK_OPT;
 	kfree(np->cork.opt);
 	np->cork.opt = NULL;
-	if (np->cork.rt) {
-		dst_release(&np->cork.rt->u.dst);
-		np->cork.rt = NULL;
+	if (inet->cork.dst) {
+		dst_release(inet->cork.dst);
+		inet->cork.dst = NULL;
 		inet->cork.flags &= ~IPCORK_ALLFRAG;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
@@ -1398,7 +1398,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
-	struct rt6_info *rt = np->cork.rt;
+	struct rt6_info *rt = (struct rt6_info *)inet->cork.dst;
 	struct flowi *fl = &inet->cork.fl;
 	unsigned char proto = fl->proto;
 	int err = 0;

---
commit 4725474584d6aa2f07b3d47442dfbc4f6544f65e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 10 04:41:33 2008 -0400

    [IPV6]: Convert cork.hop_limit and cork.tclass into u8 instead of int.
    
    Values of those fields are always between 0 and 255 (inclusive),
    so use u8 and save some memory on 32bit systems.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2102d8b..9b59e37 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -315,8 +315,8 @@ struct ipv6_pinfo {
 	struct sk_buff		*pktoptions;
 	struct {
 		struct ipv6_txoptions *opt;
-		int hop_limit;
-		int tclass;
+		u8 hop_limit;
+		u8 tclass;
 	} cork;
 };
 

---
commit 6b75d0908185bf853b188afa6f269426f6554c5b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 10 06:00:30 2008 -0400

    [IPV6]: Optimize hop-limit determination.
    
    Last part of hop-limit determination is always:
        hoplimit = dst_metric(dst, RTAX_HOPLIMIT);
        if (hoplimit < 0)
            hoplimit = ipv6_get_hoplimit(dst->dev).
    
    Let's consolidate it as ip6_dst_hoplimit(dst).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 232da20..edcb4bb 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -123,8 +123,6 @@ extern int ipv6_is_mld(struct sk_buff *skb, int nexthdr);
 
 extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len);
 
-extern int ipv6_get_hoplimit(struct net_device *dev);
-
 /*
  *	anycast prototypes (anycast.c)
  */
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 0e2895c..5c3b67c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -88,6 +88,8 @@ extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					   const struct in6_addr *addr,
 					   int anycast);
 
+extern int			ip6_dst_hoplimit(struct dst_entry *dst);
+
 /*
  *	support functions for ND
  *
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 6b5391a..8633241 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -464,9 +464,7 @@ route_done:
 	else
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
-		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-	if (hlimit < 0)
-		hlimit = ipv6_get_hoplimit(dst->dev);
+		hlimit = ip6_dst_hoplimit(dst);
 
 	tclass = np->tclass;
 	if (tclass < 0)
@@ -560,9 +558,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	else
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
-		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-	if (hlimit < 0)
-		hlimit = ipv6_get_hoplimit(dst->dev);
+		hlimit = ip6_dst_hoplimit(dst);
 
 	tclass = np->tclass;
 	if (tclass < 0)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ed64826..2a4f08c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -237,9 +237,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if (np)
 		hlimit = np->hop_limit;
 	if (hlimit < 0)
-		hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-	if (hlimit < 0)
-		hlimit = ipv6_get_hoplimit(dst->dev);
+		hlimit = ip6_dst_hoplimit(dst);
 
 	tclass = -1;
 	if (np)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index c11c76c..8e29fb1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -904,9 +904,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		dst = sk_dst_get(sk);
 		if (dst) {
 			if (val < 0)
-				val = dst_metric(dst, RTAX_HOPLIMIT);
-			if (val < 0)
-				val = ipv6_get_hoplimit(dst->dev);
+				val = ip6_dst_hoplimit(dst);
 			dst_release(dst);
 		}
 		if (val < 0)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a9e4235..548d076 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -885,9 +885,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		else
 			hlimit = np->hop_limit;
 		if (hlimit < 0)
-			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-		if (hlimit < 0)
-			hlimit = ipv6_get_hoplimit(dst->dev);
+			hlimit = ip6_dst_hoplimit(dst);
 	}
 
 	if (tclass < 0) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a4b5aee..aa3f087 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1034,15 +1034,17 @@ static int ipv6_get_mtu(struct net_device *dev)
 	return mtu;
 }
 
-int ipv6_get_hoplimit(struct net_device *dev)
-{
-	int hoplimit = ipv6_devconf.hop_limit;
-	struct inet6_dev *idev;
-
-	idev = in6_dev_get(dev);
-	if (idev) {
-		hoplimit = idev->cnf.hop_limit;
-		in6_dev_put(idev);
+int ip6_dst_hoplimit(struct dst_entry *dst)
+{
+	int hoplimit = dst_metric(dst, RTAX_HOPLIMIT);
+	if (hoplimit < 0) {
+		struct net_device *dev = dst->dev;
+		struct inet6_dev *idev = in6_dev_get(dev);
+		if (idev) {
+			hoplimit = idev->cnf.hop_limit;
+			in6_dev_put(idev);
+		} else
+			hoplimit = ipv6_devconf.hop_limit;
 	}
 	return hoplimit;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5f5d121..593d3ef 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -792,9 +792,7 @@ do_udp_sendmsg:
 		else
 			hlimit = np->hop_limit;
 		if (hlimit < 0)
-			hlimit = dst_metric(dst, RTAX_HOPLIMIT);
-		if (hlimit < 0)
-			hlimit = ipv6_get_hoplimit(dst->dev);
+			hlimit = ip6_dst_hoplimit(dst);
 	}
 
 	if (tclass < 0) {

---
commit 1d5d236d309ab90fa6aedf712f586b3595721373
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 10 10:56:55 2008 -0400

    [IPV6]: Use bitfields for hop_limit and mcast_hops.
    
    Save some bits for future extensions.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 9b59e37..87ae4e3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -274,8 +274,29 @@ struct ipv6_pinfo {
 
 	__be32			flow_label;
 	__u32			frag_size;
-	__s16			hop_limit;
-	__s16			mcast_hops;
+
+	/*
+	 * Packed in 16bits.
+	 * Omit one shift by by putting the signed field at MSB.
+	 */
+#if defined(__BIG_ENDIAN_BITFIELD)
+	__s16			hop_limit:9;
+	__u16			__unused_1:7;
+#else
+	__u16			__unused_1:7;
+	__s16			hop_limit:9;
+#endif
+
+#if defined(__BIG_ENDIAN_BITFIELD)
+	/* Packed in 16bits. */
+	__s16			mcast_hops:9;
+	__u16			__unused_2:6,
+				mc_loop:1;
+#else
+	__u16			mc_loop:1,
+				__unused_2:6;
+	__s16			mcast_hops:9;
+#endif
 	int			mcast_oif;
 
 	/* pktoption flags */
@@ -298,8 +319,7 @@ struct ipv6_pinfo {
 	} rxopt;
 
 	/* sockopt flags */
-	__u8			mc_loop:1,
-	                        recverr:1,
+	__u8			recverr:1,
 	                        sndflow:1,
 				pmtudisc:2,
 				ipv6only:1;

---
commit 7cbca67c073263c179f605bdbbdc565ab29d801d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Mar 25 09:37:42 2008 +0900

    [IPV6]: Support Source Address Selection API (RFC5014).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in6.h b/include/linux/in6.h
index 2a61c82..f674000 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -249,4 +249,15 @@ struct in6_flowlabel_req
  * IP6T_SO_GET_REVISION_TARGET	69
  */
 
+/* RFC5014: Source address selection */
+#define IPV6_ADDR_PREFERENCES	72
+
+#define IPV6_PREFER_SRC_TMP		0x0001
+#define IPV6_PREFER_SRC_PUBLIC		0x0002
+#define IPV6_PREFER_SRC_PUBTMP_DEFAULT	0x0100
+#define IPV6_PREFER_SRC_COA		0x0004
+#define IPV6_PREFER_SRC_HOME		0x0400
+#define IPV6_PREFER_SRC_CGA		0x0008
+#define IPV6_PREFER_SRC_NONCGA		0x0800
+
 #endif
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 87ae4e3..c9ba0da 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -322,7 +322,11 @@ struct ipv6_pinfo {
 	__u8			recverr:1,
 	                        sndflow:1,
 				pmtudisc:2,
-				ipv6only:1;
+				ipv6only:1,
+				srcprefs:3;	/* 001: prefer temporary address
+						 * 010: prefer public address
+						 * 100: prefer care-of address
+						 */
 	__u8			tclass;
 
 	__u32			dst_cookie;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index edcb4bb..c9276c7 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -78,6 +78,7 @@ extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
 					       struct in6_addr *daddr,
+					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
 extern int			ipv6_get_lladdr(struct net_device *dev,
 						struct in6_addr *addr,
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5c3b67c..3ae6799 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -30,9 +30,12 @@ struct route_info {
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 
-#define RT6_LOOKUP_F_IFACE	0x1
-#define RT6_LOOKUP_F_REACHABLE	0x2
-#define RT6_LOOKUP_F_HAS_SADDR	0x4
+#define RT6_LOOKUP_F_IFACE		0x00000001
+#define RT6_LOOKUP_F_REACHABLE		0x00000002
+#define RT6_LOOKUP_F_HAS_SADDR		0x00000004
+#define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
+#define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
+#define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
 
 extern struct rt6_info	*ip6_null_entry;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 787e90a..8995488 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -909,6 +909,7 @@ struct ipv6_saddr_dst {
 	int ifindex;
 	int scope;
 	int label;
+	unsigned int prefs;
 };
 
 static inline int ipv6_saddr_preferred(int type)
@@ -984,9 +985,12 @@ static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
 		break;
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SADDR_RULE_HOA:
+	    {
 		/* Rule 4: Prefer home address */
-		ret = !!(score->ifa->flags & IFA_F_HOMEADDRESS);
+		int prefhome = !(dst->prefs & IPV6_PREFER_SRC_COA);
+		ret = !(score->ifa->flags & IFA_F_HOMEADDRESS) ^ prefhome;
 		break;
+	    }
 #endif
 	case IPV6_SADDR_RULE_OIF:
 		/* Rule 5: Prefer outgoing interface */
@@ -1000,11 +1004,16 @@ static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
 		break;
 #ifdef CONFIG_IPV6_PRIVACY
 	case IPV6_SADDR_RULE_PRIVACY:
+	    {
 		/* Rule 7: Prefer public address
 		 * Note: prefer temprary address if use_tempaddr >= 2
 		 */
-		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ (score->ifa->idev->cnf.use_tempaddr >= 2);
+		int preftmp = dst->prefs & (IPV6_PREFER_SRC_PUBLIC|IPV6_PREFER_SRC_TMP) ?
+				!!(dst->prefs & IPV6_PREFER_SRC_TMP) :
+				score->ifa->idev->cnf.use_tempaddr >= 2;
+		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ preftmp;
 		break;
+	    }
 #endif
 	case IPV6_SADDR_RULE_ORCHID:
 		/* Rule 8-: Prefer ORCHID vs ORCHID or
@@ -1030,7 +1039,8 @@ out:
 }
 
 int ipv6_dev_get_saddr(struct net_device *dst_dev,
-		       struct in6_addr *daddr, struct in6_addr *saddr)
+		       struct in6_addr *daddr, unsigned int prefs,
+		       struct in6_addr *saddr)
 {
 	struct ipv6_saddr_score scores[2],
 				*score = &scores[0], *hiscore = &scores[1];
@@ -1044,6 +1054,7 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
 	dst.scope = __ipv6_addr_src_scope(dst_type);
 	dst.label = ipv6_addr_label(daddr, dst_type, dst.ifindex);
+	dst.prefs = prefs;
 
 	hiscore->rule = -1;
 	hiscore->ifa = NULL;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 5513740..e7a7fe2 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -84,8 +84,18 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		if ((rule->flags & FIB_RULE_FIND_SADDR) &&
 		    r->src.plen && !(flags & RT6_LOOKUP_F_HAS_SADDR)) {
 			struct in6_addr saddr;
+			unsigned int srcprefs = 0;
+
+			if (flags & RT6_LOOKUP_F_SRCPREF_TMP)
+				srcprefs |= IPV6_PREFER_SRC_TMP;
+			if (flags & RT6_LOOKUP_F_SRCPREF_PUBLIC)
+				srcprefs |= IPV6_PREFER_SRC_PUBLIC;
+			if (flags & RT6_LOOKUP_F_SRCPREF_COA)
+				srcprefs |= IPV6_PREFER_SRC_COA;
+
 			if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-					       &flp->fl6_dst, &saddr))
+					       &flp->fl6_dst, srcprefs,
+					       &saddr))
 				goto again;
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
 					       r->src.plen))
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 2a4f08c..d34aa61 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -920,7 +920,9 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 
 	if (ipv6_addr_any(&fl->fl6_src)) {
 		err = ipv6_dev_get_saddr(ip6_dst_idev(*dst)->dev,
-					 &fl->fl6_dst, &fl->fl6_src);
+					 &fl->fl6_dst,
+					 sk ? inet6_sk(sk)->srcprefs : 0,
+					 &fl->fl6_src);
 		if (err)
 			goto out_err_release;
 	}
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 8e29fb1..dc6695c 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -617,7 +617,67 @@ done:
 		retv = xfrm_user_policy(sk, optname, optval, optlen);
 		break;
 
+	case IPV6_ADDR_PREFERENCES:
+	    {
+		unsigned int pref = 0;
+		unsigned int prefmask = ~0;
+
+		retv = -EINVAL;
+
+		/* check PUBLIC/TMP/PUBTMP_DEFAULT conflicts */
+		switch (val & (IPV6_PREFER_SRC_PUBLIC|
+			       IPV6_PREFER_SRC_TMP|
+			       IPV6_PREFER_SRC_PUBTMP_DEFAULT)) {
+		case IPV6_PREFER_SRC_PUBLIC:
+			pref |= IPV6_PREFER_SRC_PUBLIC;
+			break;
+		case IPV6_PREFER_SRC_TMP:
+			pref |= IPV6_PREFER_SRC_TMP;
+			break;
+		case IPV6_PREFER_SRC_PUBTMP_DEFAULT:
+			break;
+		case 0:
+			goto pref_skip_pubtmp;
+		default:
+			goto e_inval;
+		}
+
+		prefmask &= ~(IPV6_PREFER_SRC_PUBLIC|
+			      IPV6_PREFER_SRC_TMP);
+pref_skip_pubtmp:
+
+		/* check HOME/COA conflicts */
+		switch (val & (IPV6_PREFER_SRC_HOME|IPV6_PREFER_SRC_COA)) {
+		case IPV6_PREFER_SRC_HOME:
+			break;
+		case IPV6_PREFER_SRC_COA:
+			pref |= IPV6_PREFER_SRC_COA;
+		case 0:
+			goto pref_skip_coa;
+		default:
+			goto e_inval;
+		}
+
+		prefmask &= ~IPV6_PREFER_SRC_COA;
+pref_skip_coa:
+
+		/* check CGA/NONCGA conflicts */
+		switch (val & (IPV6_PREFER_SRC_CGA|IPV6_PREFER_SRC_NONCGA)) {
+		case IPV6_PREFER_SRC_CGA:
+		case IPV6_PREFER_SRC_NONCGA:
+		case 0:
+			break;
+		default:
+			goto e_inval;
+		}
+
+		np->srcprefs = (np->srcprefs & prefmask) | pref;
+		retv = 0;
+
+		break;
+	    }
 	}
+
 	release_sock(sk);
 
 	return retv;
@@ -932,6 +992,24 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->sndflow;
 		break;
 
+	case IPV6_ADDR_PREFERENCES:
+		val = 0;
+
+		if (np->srcprefs & IPV6_PREFER_SRC_TMP)
+			val |= IPV6_PREFER_SRC_TMP;
+		else if (np->srcprefs & IPV6_PREFER_SRC_PUBLIC)
+			val |= IPV6_PREFER_SRC_PUBLIC;
+		else {
+			/* XXX: should we return system default? */
+			val |= IPV6_PREFER_SRC_PUBTMP_DEFAULT;
+		}
+
+		if (np->srcprefs & IPV6_PREFER_SRC_COA)
+			val |= IPV6_PREFER_SRC_COA;
+		else
+			val |= IPV6_PREFER_SRC_HOME;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e7d8e74..3f68a6e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -546,7 +546,9 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			override = 0;
 		in6_ifa_put(ifp);
 	} else {
-		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
+		if (ipv6_dev_get_saddr(dev, daddr,
+				       inet6_sk(dev->nd_net->ipv6.ndisc_sk)->srcprefs,
+				       &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aa3f087..06faa46 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -782,6 +782,15 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 
 	if (!ipv6_addr_any(&fl->fl6_src))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
+	else if (sk) {
+		unsigned int prefs = inet6_sk(sk)->srcprefs;
+		if (prefs & IPV6_PREFER_SRC_TMP)
+			flags |= RT6_LOOKUP_F_SRCPREF_TMP;
+		if (prefs & IPV6_PREFER_SRC_PUBLIC)
+			flags |= RT6_LOOKUP_F_SRCPREF_PUBLIC;
+		if (prefs & IPV6_PREFER_SRC_COA)
+			flags |= RT6_LOOKUP_F_SRCPREF_COA;
+	}
 
 	return fib6_rule_lookup(net, fl, flags, ip6_pol_route_output);
 }
@@ -2162,7 +2171,7 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 	else if (dst) {
 		struct in6_addr saddr_buf;
 		if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
-				       dst, &saddr_buf) == 0)
+				       dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index e96dafd..d92d1fc 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -58,7 +58,7 @@ static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 		return -EHOSTUNREACH;
 
 	ipv6_dev_get_saddr(ip6_dst_idev(dst)->dev,
-			   (struct in6_addr *)&daddr->a6,
+			   (struct in6_addr *)&daddr->a6, 0,
 			   (struct in6_addr *)&saddr->a6);
 	dst_release(dst);
 	return 0;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 46c5b3c..dc71d0d 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -316,7 +316,9 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
 
 	if (!asoc) {
 		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
-				   &daddr->v6.sin6_addr, &saddr->v6.sin6_addr);
+				   &daddr->v6.sin6_addr,
+				   inet6_sk(asoc->base.sk)->srcprefs,
+				   &saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT "\n",
 				  NIP6(saddr->v6.sin6_addr));
 		return;

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
