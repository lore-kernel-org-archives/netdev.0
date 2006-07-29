From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 21/23] [PATCH] [XFRM]: Add sorting interface for state and template.
Date: Sat, 29 Jul 2006 18:30:53 +0900
Message-ID: <11541654532939-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:32387 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422701AbWG2Jay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:54 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under two transformation policies it is required to merge them.
This is a platform to sort state for outbound and templates
for inbound respectively.
Mobile IPv6 will use it.
---
 include/net/xfrm.h     |   22 ++++++++++++++++++++++
 net/xfrm/xfrm_policy.c |   16 ++++++++++++++--
 net/xfrm/xfrm_state.c  |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3fe621f..c1cc2f5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -258,6 +258,10 @@ #endif
 	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
 					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					     int create);
+#ifdef CONFIG_XFRM_SUB_POLICY
+	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
+	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
+#endif
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -996,6 +1000,24 @@ static inline struct xfrm_state *xfrm_st
 	return NULL;
 }
 #endif
+#ifdef CONFIG_XFRM_SUB_POLICY
+extern int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
+			  int n, unsigned short family);
+extern int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src,
+			   int n, unsigned short family);
+#else
+static inline int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
+				 int n, unsigned short family)
+{
+	return 0;
+}
+
+static inline int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src,
+				  int n, unsigned short family)
+{
+	return 0;
+}
+#endif
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d105e2e..3e7b5a6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -787,6 +787,8 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
 		  struct xfrm_state **xfrm,
 		  unsigned short family)
 {
+	struct xfrm_state *tp[XFRM_MAX_DEPTH];
+	struct xfrm_state **tpp = (npols > 1) ? tp : xfrm;
 	int cnx = 0;
 	int error;
 	int ret;
@@ -797,7 +799,8 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
 			error = -ENOBUFS;
 			goto fail;
 		}
-		ret = xfrm_tmpl_resolve_one(pols[i], fl, &xfrm[cnx], family);
+
+		ret = xfrm_tmpl_resolve_one(pols[i], fl, &tpp[cnx], family);
 		if (ret < 0) {
 			error = ret;
 			goto fail;
@@ -805,11 +808,15 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
 			cnx += ret;
 	}
 
+	/* found states are sorted for outbound processing */
+	if (npols > 1)
+		xfrm_state_sort(xfrm, tpp, cnx, family);
+
 	return cnx;
 
  fail:
 	for (cnx--; cnx>=0; cnx--)
-		xfrm_state_put(xfrm[cnx]);
+		xfrm_state_put(tpp[cnx]);
 	return error;
 
 }
@@ -1219,6 +1226,7 @@ #endif
 		struct sec_path *sp;
 		static struct sec_path dummy;
 		struct xfrm_tmpl *tp[XFRM_MAX_DEPTH];
+		struct xfrm_tmpl *stp[XFRM_MAX_DEPTH];
 		struct xfrm_tmpl **tpp = tp;
 		int ti = 0;
 		int i, k;
@@ -1236,6 +1244,10 @@ #endif
 				tpp[ti++] = &pols[pi]->xfrm_vec[i];
 		}
 		xfrm_nr = ti;
+		if (npols > 1) {
+			xfrm_tmpl_sort(stp, tpp, xfrm_nr, family);
+			tpp = stp;
+		}
 
 		/* For each tunnel xfrm, find the first matching tmpl.
 		 * For each tmpl before that, find corresponding xfrm.
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0c74e7c..8ef9831 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -750,6 +750,44 @@ xfrm_find_acq(u8 mode, u32 reqid, u8 pro
 }
 EXPORT_SYMBOL(xfrm_find_acq);
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+int
+xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
+	       unsigned short family)
+{
+	int err = 0;
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	if (!afinfo)
+		return -EAFNOSUPPORT;
+
+	spin_lock_bh(&xfrm_state_lock);
+	if (afinfo->tmpl_sort)
+		err = afinfo->tmpl_sort(dst, src, n);
+	spin_unlock_bh(&xfrm_state_lock);
+	xfrm_state_put_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_tmpl_sort);
+
+int
+xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
+		unsigned short family)
+{
+	int err = 0;
+	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
+	if (!afinfo)
+		return -EAFNOSUPPORT;
+
+	spin_lock_bh(&xfrm_state_lock);
+	if (afinfo->state_sort)
+		err = afinfo->state_sort(dst, src, n);
+	spin_unlock_bh(&xfrm_state_lock);
+	xfrm_state_put_afinfo(afinfo);
+	return err;
+}
+EXPORT_SYMBOL(xfrm_state_sort);
+#endif
+
 /* Silly enough, but I'm lazy to build resolution list */
 
 static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
-- 
1.4.1

