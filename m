From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Wed, 13 Nov 2002 04:09:26 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211130109.EAA10034@sex.inr.ac.ru>
References: <20021112.143636.55033627.davem@redhat.com>
Mime-Version: 1.0
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20021112.143636.55033627.davem@redhat.com> from "David S. Miller" at Nov 12, 2 02:36:36 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>    The problem with expiration remains unsolved.

Patch #2. Bert, this is supposed to fix the first strange phenomenon
in your experiment. But I still do not know what will happen after that.
Please, check.

Dave, do not take this patch. It is a bit ugly and I would like
to finish with Bert's problem, which may require sequence of incremental
fixes to the same place.

Alexey


===== include/net/xfrm.h 1.5 vs edited =====
--- 1.5/include/net/xfrm.h	Tue Nov 12 02:37:12 2002
+++ edited/include/net/xfrm.h	Wed Nov 13 03:38:20 2002
@@ -473,7 +473,7 @@
 struct xfrm_policy *xfrm_policy_byid(int dir, u32 id, int delete);
 void xfrm_policy_flush(void);
 void xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
-struct xfrm_state * xfrm_find_acq(u8 mode, u16 reqid, u8 proto, u32 daddr, u32 saddr);
+struct xfrm_state * xfrm_find_acq(u8 mode, u16 reqid, u8 proto, u32 daddr, u32 saddr, int create);
 extern void xfrm_policy_flush(void);
 extern void xfrm_policy_kill(struct xfrm_policy *);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
===== net/ipv4/xfrm_state.c 1.6 vs edited =====
--- 1.6/net/ipv4/xfrm_state.c	Tue Nov 12 02:37:12 2002
+++ edited/net/ipv4/xfrm_state.c	Wed Nov 13 03:38:26 2002
@@ -386,7 +386,7 @@
 }
 
 struct xfrm_state *
-xfrm_find_acq(u8 mode, u16 reqid, u8 proto, u32 daddr, u32 saddr)
+xfrm_find_acq(u8 mode, u16 reqid, u8 proto, u32 daddr, u32 saddr, int create)
 {
 	struct xfrm_state *x, *x0;
 	unsigned h = ntohl(daddr);
@@ -411,7 +411,7 @@
 	}
 	if (x0) {
 		atomic_inc(&x0->refcnt);
-	} else if ((x0 = xfrm_state_alloc()) != NULL) {
+	} else if (create && (x0 = xfrm_state_alloc()) != NULL) {
 		x0->sel.daddr.xfrm4_addr = daddr;
 		x0->sel.daddr.xfrm4_mask = ~0;
 		x0->sel.saddr.xfrm4_addr = saddr;
===== net/key/af_key.c 1.7 vs edited =====
--- 1.7/net/key/af_key.c	Tue Nov 12 02:37:12 2002
+++ edited/net/key/af_key.c	Wed Nov 13 03:48:17 2002
@@ -528,8 +528,7 @@
 
 	switch (((struct sockaddr *)(addr + 1))->sa_family) {
 	case AF_INET:
-		x = xfrm_state_lookup(
-				      ((struct sockaddr_in*)(addr + 1))->sin_addr.s_addr,
+		x = xfrm_state_lookup(((struct sockaddr_in*)(addr + 1))->sin_addr.s_addr,
 				      sa->sadb_sa_spi, proto);
 		break;
 	case AF_INET6:
@@ -1043,7 +1042,7 @@
 	daddr = (struct sockaddr_in*)(addr + 1);
 
 	x = xfrm_find_acq(mode, reqid, proto, daddr->sin_addr.s_addr,
-			  saddr->sin_addr.s_addr);
+			  saddr->sin_addr.s_addr, 1);
 	if (x == NULL)
 		return -ENOENT;
 
@@ -1122,7 +1121,17 @@
 
 	/* XXX there is race condition */
 	x1 = pfkey_xfrm_state_lookup(hdr, ext_hdrs);
-	if (x1 && hdr->sadb_msg_type == SADB_ADD) {
+	if (!x1) {
+		x1 = xfrm_find_acq(x->props.mode, x->props.reqid, x->id.proto,
+				   x->id.daddr.xfrm4_addr,
+				   x->props.saddr.xfrm4_addr, 0);
+		if (x1 && x1->id.spi != x->id.spi && x1->id.spi) {
+			xfrm_state_put(x1);
+			x1 = NULL;
+		}
+	}
+
+	if (x1 && x1->id.spi && hdr->sadb_msg_type == SADB_ADD) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
 		xfrm_state_put(x1);
@@ -1131,7 +1140,7 @@
 
 	xfrm_state_insert(x);
 
-	if (x1 && hdr->sadb_msg_type != SADB_ADD) {
+	if (x1) {
 		xfrm_state_delete(x1);
 		xfrm_state_put(x1);
 	}
