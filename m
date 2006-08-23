From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 41/44] [XFRM]: Add sorting interface for state and template.
Date: Thu, 24 Aug 2006 00:02:42 +0900
Message-ID: <11563453674024-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org> <11563453671463-git-send-email-yoshfuji@linux-ipv6.org> <11563453672872-git-send-email-yoshfuji@linux-ipv6.org> <11563453671273-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:11657 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964954AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453671273-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Under two transformation policies it is required to merge them.
This is a platform to sort state for outbound and templates
for inbound respectively.
It will be used when Mobile IPv6 and IPsec are used at the same time.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h     |   20 ++++++++++++++++++++
 net/xfrm/xfrm_policy.c |   16 ++++++++++++++--
 net/xfrm/xfrm_state.c  |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5bd6beb..aab31a2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -255,6 +255,8 @@ struct xfrm_state_afinfo {
 	struct xfrm_state	*(*find_acq)(u8 mode, u32 reqid, u8 proto, 
 					     xfrm_address_t *daddr, xfrm_address_t *saddr, 
 					     int create);
+	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
+	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -1002,6 +1004,24 @@ extern int xfrm_state_add(struct xfrm_st
 extern int xfrm_state_update(struct xfrm_state *x);
 extern struct xfrm_state *xfrm_state_lookup(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family);
 extern struct xfrm_state *xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family);
+#ifdef CONFIG_XFRM_SUB_POLICY
+extern int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
+			  int n, unsigned short family);
+extern int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src,
+			   int n, unsigned short family);
+#else
+static inline int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
+				 int n, unsigned short family)
+{
+	return -ENOSYS;
+}
+
+static inline int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src,
+				  int n, unsigned short family)
+{
+	return -ENOSYS;
+}
+#endif
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 65e84b1..a1be1b5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -861,6 +861,8 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
 		  struct xfrm_state **xfrm,
 		  unsigned short family)
 {
+	struct xfrm_state *tp[XFRM_MAX_DEPTH];
+	struct xfrm_state **tpp = (npols > 1) ? tp : xfrm;
 	int cnx = 0;
 	int error;
 	int ret;
@@ -871,7 +873,8 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
 			error = -ENOBUFS;
 			goto fail;
 		}
-		ret = xfrm_tmpl_resolve_one(pols[i], fl, &xfrm[cnx], family);
+
+		ret = xfrm_tmpl_resolve_one(pols[i], fl, &tpp[cnx], family);
 		if (ret < 0) {
 			error = ret;
 			goto fail;
@@ -879,11 +882,15 @@ xfrm_tmpl_resolve(struct xfrm_policy **p
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
@@ -1280,6 +1287,7 @@ #endif
 		struct sec_path *sp;
 		static struct sec_path dummy;
 		struct xfrm_tmpl *tp[XFRM_MAX_DEPTH];
+		struct xfrm_tmpl *stp[XFRM_MAX_DEPTH];
 		struct xfrm_tmpl **tpp = tp;
 		int ti = 0;
 		int i, k;
@@ -1297,6 +1305,10 @@ #endif
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
index a26ef69..622e92a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -728,6 +728,44 @@ xfrm_find_acq(u8 mode, u32 reqid, u8 pro
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
1.4.0

