From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Find larval SAs by sequence number
Date: Thu, 9 Sep 2004 22:13:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909121332.GA31902@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@davemloft.net, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

When larval states are generated along with ACQUIRE messages, we should
use the sequence to find the corresponding larval state when creating
states with ADD_SA or ALLOC_SPI.

If we don't do that, then it may take down an unrelated larval state
with the same parameters (think different TCP sessions).  This not only
leaves behind a larval state that shouldn't be there, it may also cause
another ACQUIRE message to be sent unnecessarily.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="byseq.patch"

===== include/net/xfrm.h 1.70 vs edited =====
--- 1.70/include/net/xfrm.h	2004-08-25 20:48:11 +10:00
+++ edited/include/net/xfrm.h	2004-09-09 22:05:12 +10:00
@@ -896,4 +896,17 @@
 extern void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
 			 int offset, int len, icv_update_fn_t icv_update);
 
+static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
+				int family)
+{
+	switch (family) {
+	default:
+	case AF_INET:
+		return a->a4 - b->a4;
+	case AF_INET6:
+		return ipv6_addr_cmp((struct in6_addr *)a,
+				     (struct in6_addr *)b);
+	}
+}
+
 #endif	/* _NET_XFRM_H */
===== net/key/af_key.c 1.68 vs edited =====
--- 1.68/net/key/af_key.c	2004-08-25 20:48:13 +10:00
+++ edited/net/key/af_key.c	2004-09-09 22:05:05 +10:00
@@ -1156,7 +1156,16 @@
 		break;
 #endif
 	}
-	if (xdaddr)
+
+	if (hdr->sadb_msg_seq) {
+		x = xfrm_find_acq_byseq(hdr->sadb_msg_seq);
+		if (x && xfrm_addr_cmp(&x->id.daddr, xdaddr, family)) {
+			xfrm_state_put(x);
+			x = NULL;
+		}
+	}
+
+	if (!x)
 		x = xfrm_find_acq(mode, reqid, proto, xdaddr, xsaddr, 1, family);
 
 	if (x == NULL)
===== net/xfrm/xfrm_state.c 1.51 vs edited =====
--- 1.51/net/xfrm/xfrm_state.c	2004-08-02 07:15:03 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-09-09 22:05:05 +10:00
@@ -387,13 +387,17 @@
 	spin_unlock_bh(&xfrm_state_lock);
 }
 
+static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
+
 int xfrm_state_add(struct xfrm_state *x)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_state *x1;
+	int family;
 	int err;
 
-	afinfo = xfrm_state_get_afinfo(x->props.family);
+	family = x->props.family;
+	afinfo = xfrm_state_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
@@ -407,9 +411,18 @@
 		goto out;
 	}
 
-	x1 = afinfo->find_acq(
-		x->props.mode, x->props.reqid, x->id.proto,
-		&x->id.daddr, &x->props.saddr, 0);
+	if (x->km.seq) {
+		x1 = __xfrm_find_acq_byseq(x->km.seq);
+		if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {
+			xfrm_state_put(x1);
+			x1 = NULL;
+		}
+	}
+
+	if (!x1)
+		x1 = afinfo->find_acq(
+			x->props.mode, x->props.reqid, x->id.proto,
+			&x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_insert(x);
 	err = 0;
@@ -570,12 +583,11 @@
 
 /* Silly enough, but I'm lazy to build resolution list */
 
-struct xfrm_state * xfrm_find_acq_byseq(u32 seq)
+static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq)
 {
 	int i;
 	struct xfrm_state *x;
 
-	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
 			if (x->km.seq == seq) {
@@ -585,8 +597,17 @@
 			}
 		}
 	}
-	spin_unlock_bh(&xfrm_state_lock);
 	return NULL;
+}
+
+struct xfrm_state *xfrm_find_acq_byseq(u32 seq)
+{
+	struct xfrm_state *x;
+
+	spin_lock_bh(&xfrm_state_lock);
+	x = __xfrm_find_acq_byseq(seq);
+	spin_unlock_bh(&xfrm_state_lock);
+	return x;
 }
  
 u32 xfrm_get_acqseq(void)
===== net/xfrm/xfrm_user.c 1.50 vs edited =====
--- 1.50/net/xfrm/xfrm_user.c	2004-08-25 20:48:13 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-09-09 22:05:05 +10:00
@@ -470,16 +470,32 @@
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
 	struct sk_buff *resp_skb;
+	xfrm_address_t *daddr;
+	int family;
 	int err;
 
 	p = NLMSG_DATA(nlh);
 	err = verify_userspi_info(p);
 	if (err)
 		goto out_noput;
-	x = xfrm_find_acq(p->info.mode, p->info.reqid, p->info.id.proto,
-			  &p->info.id.daddr,
-			  &p->info.saddr, 1,
-			  p->info.family);
+
+	family = p->info.family;
+	daddr = &p->info.id.daddr;
+
+	x = NULL;
+	if (p->info.seq) {
+		x = xfrm_find_acq_byseq(p->info.seq);
+		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
+			xfrm_state_put(x);
+			x = NULL;
+		}
+	}
+
+	if (!x)
+		x = xfrm_find_acq(p->info.mode, p->info.reqid,
+				  p->info.id.proto, daddr,
+				  &p->info.saddr, 1,
+				  family);
 	err = -ENOENT;
 	if (x == NULL)
 		goto out_noput;

--yrj/dFKFPuw6o+aM--
