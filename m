From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 9/23] [PATCH] [XFRM] STATE: Support non-fragment outbound transformation headers.
Date: Sat, 29 Jul 2006 18:30:27 +0900
Message-ID: <11541654272961-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:20099 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S932071AbWG2Ja2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For originated outbound IPv6 packets which will fragment, ip6_append_data()
should know length of extension headers before sending them and
the length is carried by dst_entry.
IPv6 IPsec headers fragment then transformation was
designed to place all headers after fragment header.
OTOH Mobile IPv6 extension headers do not fragment then
it is a good idea to make dst_entry have non-fragment length to tell it
to ip6_append_data().
---
 include/net/dst.h       |    1 +
 include/net/xfrm.h      |    2 ++
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/ip6_output.c   |    2 +-
 net/ipv6/xfrm6_policy.c |   12 ++++++++++--
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5161e89..1ac2ee0 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -55,6 +55,7 @@ #define DST_BALANCED            0x10
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
+	unsigned short		nfheader_len;	/* more non-fragment space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
 	u32			metrics[RTAX_MAX];
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e14ae3c..46f8616 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -265,6 +265,8 @@ struct xfrm_type
 	char			*description;
 	struct module		*owner;
 	__u8			proto;
+	__u8			flags;
+#define XFRM_TYPE_NON_FRAGMENT	1
 
 	int			(*init_state)(struct xfrm_state *x);
 	void			(*destructor)(struct xfrm_state *);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index bf77489..03f17a0 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -138,6 +138,7 @@ __xfrm4_bundle_create(struct xfrm_policy
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
+		dst_prev->nfheader_len	= 0;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e460489..2d9ea9b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -915,7 +915,7 @@ int ip6_append_data(struct sock *sk, int
 
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
-	fragheaderlen = sizeof(struct ipv6hdr) + (opt ? opt->opt_nflen : 0);
+	fragheaderlen = sizeof(struct ipv6hdr) + rt->u.dst.nfheader_len + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 28bc272..eaa1b0d 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -86,6 +86,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 	int i;
 	int err = 0;
 	int header_len = 0;
+	int nfheader_len = 0;
 	int trailer_len = 0;
 
 	dst = dst_prev = NULL;
@@ -126,7 +127,10 @@ __xfrm6_bundle_create(struct xfrm_policy
 				(struct in6_addr*)&xfrm[i]->props.saddr;
 			tunnel = 1;
 		}
-		header_len += xfrm[i]->props.header_len;
+		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
+			nfheader_len += xfrm[i]->props.header_len;
+		else
+			header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (tunnel) {
@@ -161,6 +165,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
+		dst_prev->nfheader_len	= nfheader_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
@@ -179,7 +184,10 @@ __xfrm6_bundle_create(struct xfrm_policy
 		x->u.rt6.rt6i_src      = rt0->rt6i_src;	
 		x->u.rt6.rt6i_idev     = rt0->rt6i_idev;
 		in6_dev_hold(rt0->rt6i_idev);
-		header_len -= x->u.dst.xfrm->props.header_len;
+		if (dst_prev->xfrm->type->flags & XFRM_TYPE_NON_FRAGMENT)
+			nfheader_len -= x->u.dst.xfrm->props.header_len;
+		else
+			header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
 
-- 
1.4.1

