From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 13/44] [XFRM] STATE: Support non-fragment outbound transformation headers.
Date: Thu, 24 Aug 2006 00:02:14 +0900
Message-ID: <1156345366857-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:64904 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964916AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

For originated outbound IPv6 packets which will fragment, ip6_append_data()
should know length of extension headers before sending them and
the length is carried by dst_entry.
IPv6 IPsec headers fragment then transformation was
designed to place all headers after fragment header.
OTOH Mobile IPv6 extension headers do not fragment then
it is a good idea to make dst_entry have non-fragment length to tell it
to ip6_append_data().

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/dst.h       |    1 +
 include/net/xfrm.h      |    2 ++
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/ip6_output.c   |    2 +-
 net/ipv6/xfrm6_policy.c |   24 ++++++++++++++++++++++--
 5 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 36d54fc..a8d825f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -54,6 +54,7 @@ #define DST_BALANCED            0x10
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
+	unsigned short		nfheader_len;	/* more non-fragment space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
 	u32			metrics[RTAX_MAX];
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index cbfacdb..e451fed 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -261,6 +261,8 @@ struct xfrm_type
 	char			*description;
 	struct module		*owner;
 	__u8			proto;
+	__u8			flags;
+#define XFRM_TYPE_NON_FRAGMENT	1
 
 	int			(*init_state)(struct xfrm_state *x);
 	void			(*destructor)(struct xfrm_state *);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a5bed74..e517981 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -135,6 +135,7 @@ __xfrm4_bundle_create(struct xfrm_policy
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
+		dst_prev->nfheader_len	= 0;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 686c07a..ebb23db 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -963,7 +963,7 @@ int ip6_append_data(struct sock *sk, int
 
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
-	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
+	fragheaderlen = sizeof(struct ipv6hdr) + rt->u.dst.nfheader_len + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 9328fc8..a3f68c8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -75,6 +75,24 @@ __xfrm6_bundle_addr_local(struct xfrm_st
 		(struct in6_addr*)&x->props.saddr;
 }
 
+static inline void
+__xfrm6_bundle_len_inc(int *len, int *nflen, struct xfrm_state *x)
+{
+	if (x->type->flags & XFRM_TYPE_NON_FRAGMENT)
+		*nflen += x->props.header_len;
+	else
+		*len += x->props.header_len;
+}
+
+static inline void
+__xfrm6_bundle_len_dec(int *len, int *nflen, struct xfrm_state *x)
+{
+	if (x->type->flags & XFRM_TYPE_NON_FRAGMENT)
+		*nflen -= x->props.header_len;
+	else
+		*len -= x->props.header_len;
+}
+
 /* Allocate chain of dst_entry's, attach known xfrm's, calculate
  * all the metrics... Shortly, bundle a bundle.
  */
@@ -99,6 +117,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 	int i;
 	int err = 0;
 	int header_len = 0;
+	int nfheader_len = 0;
 	int trailer_len = 0;
 
 	dst = dst_prev = NULL;
@@ -135,7 +154,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 			local  = __xfrm6_bundle_addr_local(xfrm[i], local);
 			tunnel = 1;
 		}
-		header_len += xfrm[i]->props.header_len;
+		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (tunnel) {
@@ -170,6 +189,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
+		dst_prev->nfheader_len	= nfheader_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
@@ -188,7 +208,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 		x->u.rt6.rt6i_src      = rt0->rt6i_src;	
 		x->u.rt6.rt6i_idev     = rt0->rt6i_idev;
 		in6_dev_hold(rt0->rt6i_idev);
-		header_len -= x->u.dst.xfrm->props.header_len;
+		__xfrm6_bundle_len_dec(&header_len, &nfheader_len, x->u.dst.xfrm);
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
 
-- 
1.4.0

