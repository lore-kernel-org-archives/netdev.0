From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/44] [XFRM]: Add XFRM_MODE_xxx for future use.
Date: Thu, 24 Aug 2006 00:02:02 +0900
Message-ID: <11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:56456 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964913AbWHWPCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:49 -0400
To: davem@davemloft.net
In-Reply-To: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Transformation mode is used as either IPsec transport or tunnel.
It is required to add two more items, route optimization and inbound trigger
for Mobile IPv6.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h    |    6 ++++--
 include/net/xfrm.h      |    2 +-
 net/ipv4/ah4.c          |    2 +-
 net/ipv4/esp4.c         |    6 +++---
 net/ipv4/ipcomp.c       |    8 ++++----
 net/ipv4/xfrm4_input.c  |    2 +-
 net/ipv4/xfrm4_output.c |    4 ++--
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv4/xfrm4_state.c  |    2 +-
 net/ipv4/xfrm4_tunnel.c |    2 +-
 net/ipv6/ah6.c          |    2 +-
 net/ipv6/esp6.c         |    4 ++--
 net/ipv6/ipcomp6.c      |    6 +++---
 net/ipv6/xfrm6_input.c  |    2 +-
 net/ipv6/xfrm6_output.c |    4 ++--
 net/ipv6/xfrm6_policy.c |    2 +-
 net/ipv6/xfrm6_state.c  |    2 +-
 net/ipv6/xfrm6_tunnel.c |    2 +-
 net/key/af_key.c        |    6 +++---
 net/xfrm/xfrm_policy.c  |   11 ++++++-----
 net/xfrm/xfrm_user.c    |    4 ++--
 21 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 46a15c7..5154064 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -120,7 +120,9 @@ enum
 
 #define XFRM_MODE_TRANSPORT 0
 #define XFRM_MODE_TUNNEL 1
-#define XFRM_MODE_MAX 2
+#define XFRM_MODE_ROUTEOPTIMIZATION 2
+#define XFRM_MODE_IN_TRIGGER 3
+#define XFRM_MODE_MAX 4
 
 /* Netlink configuration messages.  */
 enum {
@@ -247,7 +249,7 @@ struct xfrm_usersa_info {
 	__u32				seq;
 	__u32				reqid;
 	__u16				family;
-	__u8				mode; /* 0=transport,1=tunnel */
+	__u8				mode;		/* XFRM_MODE_xxx */
 	__u8				replay_window;
 	__u8				flags;
 #define XFRM_STATE_NOECN	1
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f724d3f..f47965b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -299,7 +299,7 @@ struct xfrm_tmpl
 
 	__u32			reqid;
 
-/* Mode: transport/tunnel */
+/* Mode: transport, tunnel etc. */
 	__u8			mode;
 
 /* Sharing mode: unique, this session only, this user only etc. */
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 506d7a2..a82e2f0 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -253,7 +253,7 @@ static int ah_init_state(struct xfrm_sta
 		goto error;
 	
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_trunc_len);
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = ahp;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index fc2f8ce..f5057dc 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -237,7 +237,7 @@ static int esp_input(struct xfrm_state *
 		 *    as per draft-ietf-ipsec-udp-encaps-06,
 		 *    section 3.1.2
 		 */
-		if (!x->props.mode)
+		if (x->props.mode == XFRM_MODE_TRANSPORT)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
@@ -256,7 +256,7 @@ static u32 esp4_get_max_size(struct xfrm
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		mtu = ALIGN(mtu + 2, blksize);
 	} else {
 		/* The worst case. */
@@ -368,7 +368,7 @@ static int esp_init_state(struct xfrm_st
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index a0c28b2..b163ebc 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -176,7 +176,7 @@ static int ipcomp_output(struct xfrm_sta
 	return 0;
 
 out_ok:
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		ip_send_check(iph);
 	return 0;
 }
@@ -216,7 +216,7 @@ static struct xfrm_state *ipcomp_tunnel_
 	t->id.daddr.a4 = x->id.daddr.a4;
 	memcpy(&t->sel, &x->sel, sizeof(t->sel));
 	t->props.family = AF_INET;
-	t->props.mode = 1;
+	t->props.mode = XFRM_MODE_TUNNEL;
 	t->props.saddr.a4 = x->props.saddr.a4;
 	t->props.flags = x->props.flags;
 
@@ -415,7 +415,7 @@ static int ipcomp_init_state(struct xfrm
 		goto out;
 
 	x->props.header_len = 0;
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
 
 	mutex_lock(&ipcomp_resource_mutex);
@@ -427,7 +427,7 @@ static int ipcomp_init_state(struct xfrm
 		goto error;
 	mutex_unlock(&ipcomp_resource_mutex);
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp_tunnel_attach(x);
 		if (err)
 			goto error_tunnel;
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 817ed84..040e847 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -106,7 +106,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode) {
+		if (x->props.mode == XFRM_MODE_TUNNEL) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 4a96a9e..5fd115f 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -54,7 +54,7 @@ static int xfrm4_output_one(struct sk_bu
 			goto error_nolock;
 	}
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
@@ -85,7 +85,7 @@ static int xfrm4_output_one(struct sk_bu
 		}
 		dst = skb->dst;
 		x = dst->xfrm;
-	} while (x && !x->props.mode);
+	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
 
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = 0;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 8f50eae..a5bed74 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -96,7 +96,7 @@ __xfrm4_bundle_create(struct xfrm_policy
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-		if (xfrm[i]->props.mode) {
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			remote = xfrm[i]->id.daddr.a4;
 			local  = xfrm[i]->props.saddr.a4;
 			tunnel = 1;
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 81e1751..97b0c75 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -42,7 +42,7 @@ __xfrm4_init_tempsel(struct xfrm_state *
 	x->props.saddr = tmpl->saddr;
 	if (x->props.saddr.a4 == 0)
 		x->props.saddr.a4 = saddr->a4;
-	if (tmpl->mode && x->props.saddr.a4 == 0) {
+	if (tmpl->mode == XFRM_MODE_TUNNEL && x->props.saddr.a4 == 0) {
 		struct rtable *rt;
 	        struct flowi fl_tunnel = {
         	        .nl_u = {
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index f8ceaa1..f110af5 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -28,7 +28,7 @@ static int ipip_xfrm_rcv(struct xfrm_sta
 
 static int ipip_init_state(struct xfrm_state *x)
 {
-	if (!x->props.mode)
+	if (x->props.mode != XFRM_MODE_TUNNEL)
 		return -EINVAL;
 
 	if (x->encap)
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 9d4831b..b085562 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -387,7 +387,7 @@ static int ah6_init_state(struct xfrm_st
 		goto error;
 	
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len);
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = ahp;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index a278d5e..9231981 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -227,7 +227,7 @@ static u32 esp6_get_max_size(struct xfrm
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		mtu = ALIGN(mtu + 2, blksize);
 	} else {
 		/* The worst case. */
@@ -344,7 +344,7 @@ static int esp6_init_state(struct xfrm_s
 	if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
 		goto error;
 	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;
 	return 0;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 7e4d1c1..1578529 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -212,7 +212,7 @@ static struct xfrm_state *ipcomp6_tunnel
 	memcpy(t->id.daddr.a6, x->id.daddr.a6, sizeof(struct in6_addr));
 	memcpy(&t->sel, &x->sel, sizeof(t->sel));
 	t->props.family = AF_INET6;
-	t->props.mode = 1;
+	t->props.mode = XFRM_MODE_TUNNEL;
 	memcpy(t->props.saddr.a6, x->props.saddr.a6, sizeof(struct in6_addr));
 
 	if (xfrm_init_state(t))
@@ -416,7 +416,7 @@ static int ipcomp6_init_state(struct xfr
 		goto out;
 
 	x->props.header_len = 0;
-	if (x->props.mode)
+	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	
 	mutex_lock(&ipcomp6_resource_mutex);
@@ -428,7 +428,7 @@ static int ipcomp6_init_state(struct xfr
 		goto error;
 	mutex_unlock(&ipcomp6_resource_mutex);
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp6_tunnel_attach(x);
 		if (err)
 			goto error_tunnel;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 0405d74..ee2f6b3 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -72,7 +72,7 @@ int xfrm6_rcv_spi(struct sk_buff *skb, u
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode) { /* XXX */
+		if (x->props.mode == XFRM_MODE_TUNNEL) { /* XXX */
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6d11174..26f1886 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -47,7 +47,7 @@ static int xfrm6_output_one(struct sk_bu
 			goto error_nolock;
 	}
 
-	if (x->props.mode) {
+	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
@@ -80,7 +80,7 @@ static int xfrm6_output_one(struct sk_bu
 		}
 		dst = skb->dst;
 		x = dst->xfrm;
-	} while (x && !x->props.mode);
+	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
 
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = 0;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 73cd250..81355bb 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -114,7 +114,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-		if (xfrm[i]->props.mode) {
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
 			local  = (struct in6_addr*)&xfrm[i]->props.saddr;
 			tunnel = 1;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b33296b..a1a1f54 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -42,7 +42,7 @@ __xfrm6_init_tempsel(struct xfrm_state *
 	memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
 	if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
 		memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
-	if (tmpl->mode && ipv6_addr_any((struct in6_addr*)&x->props.saddr)) {
+	if (tmpl->mode == XFRM_MODE_TUNNEL && ipv6_addr_any((struct in6_addr*)&x->props.saddr)) {
 		struct rt6_info *rt;
 		struct flowi fl_tunnel = {
 			.nl_u = {
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index c8f9369..59685ee 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -307,7 +307,7 @@ static int xfrm6_tunnel_err(struct sk_bu
 
 static int xfrm6_tunnel_init_state(struct xfrm_state *x)
 {
-	if (!x->props.mode)
+	if (x->props.mode != XFRM_MODE_TUNNEL)
 		return -EINVAL;
 
 	if (x->encap)
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 797c744..19e047b 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1765,7 +1765,7 @@ #endif
 	}
 
 	/* addresses present only in tunnel mode */
-	if (t->mode) {
+	if (t->mode == XFRM_MODE_TUNNEL) {
 		switch (xp->family) {
 		case AF_INET:
 			sin = (void*)(rq+1);
@@ -1997,7 +1997,7 @@ #endif
 		int req_size;
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
-		if (t->mode)
+		if (t->mode == XFRM_MODE_TUNNEL)
 			req_size += 2*socklen;
 		else
 			size -= 2*socklen;
@@ -2013,7 +2013,7 @@ #endif
 		if (t->optional)
 			rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_USE;
 		rq->sadb_x_ipsecrequest_reqid = t->reqid;
-		if (t->mode) {
+		if (t->mode == XFRM_MODE_TUNNEL) {
 			switch (xp->family) {
 			case AF_INET:
 				sin = (void*)(rq+1);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5a86058..dd8e543 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -779,7 +779,7 @@ xfrm_tmpl_resolve(struct xfrm_policy *po
 		xfrm_address_t *local  = saddr;
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
-		if (tmpl->mode) {
+		if (tmpl->mode == XFRM_MODE_TUNNEL) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
 		}
@@ -1005,7 +1005,8 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
 		(x->props.reqid == tmpl->reqid || !tmpl->reqid) &&
 		x->props.mode == tmpl->mode &&
 		(tmpl->aalgos & (1<<x->props.aalgo)) &&
-		!(x->props.mode && xfrm_state_addr_cmp(tmpl, x, family));
+		!(x->props.mode != XFRM_MODE_TRANSPORT &&
+		  xfrm_state_addr_cmp(tmpl, x, family));
 }
 
 static inline int
@@ -1015,14 +1016,14 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
 	int idx = start;
 
 	if (tmpl->optional) {
-		if (!tmpl->mode)
+		if (tmpl->mode == XFRM_MODE_TRANSPORT)
 			return start;
 	} else
 		start = -1;
 	for (; idx < sp->len; idx++) {
 		if (xfrm_state_ok(tmpl, sp->xvec[idx], family))
 			return ++idx;
-		if (sp->xvec[idx]->props.mode)
+		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT)
 			break;
 	}
 	return start;
@@ -1047,7 +1048,7 @@ EXPORT_SYMBOL(xfrm_decode_session);
 static inline int secpath_has_tunnel(struct sec_path *sp, int k)
 {
 	for (; k < sp->len; k++) {
-		if (sp->xvec[k]->props.mode)
+		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT)
 			return 1;
 	}
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 82891a2..471439d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -173,8 +173,8 @@ #endif
 
 	err = -EINVAL;
 	switch (p->mode) {
-	case 0:
-	case 1:
+	case XFRM_MODE_TRANSPORT:
+	case XFRM_MODE_TUNNEL:
 		break;
 
 	default:
-- 
1.4.0

