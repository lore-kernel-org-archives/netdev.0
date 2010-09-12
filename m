From: David Miller <davem@davemloft.net>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call
 xfrm_find_acq_byseq?
Date: Sun, 12 Sep 2010 11:47:16 -0700 (PDT)
Message-ID: <20100912.114716.193704668.davem@davemloft.net>
References: <20100822.005353.260099324.davem@davemloft.net>
	<4C727806.3060102@6wind.com>
	<4C7289F6.3060802@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751435Ab0ILSq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 14:46:58 -0400
In-Reply-To: <4C7289F6.3060802@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>
Date: Mon, 23 Aug 2010 16:47:18 +0200

> Christophe Gouault wrote:
>>> The likelyhood of breaking something if you remove the call is very
>>> high.
>> Probably. I'm still interested in a concrete example ;-)

Christophe, digging deep into the tree history I found a
commit that should answer your question:

commit 4d9f62e953567482223b7110c5e8961c4d494c1f
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Sep 10 00:36:11 2004 -0700

    [IPSEC]: Find larval SAs by sequence number
    
    When larval states are generated along with ACQUIRE messages, we should
    use the sequence to find the corresponding larval state when creating
    states with ADD_SA or ALLOC_SPI.
    
    If we don't do that, then it may take down an unrelated larval state
    with the same parameters (think different TCP sessions).  This not only
    leaves behind a larval state that shouldn't be there, it may also cause
    another ACQUIRE message to be sent unnecessarily.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 40c65db..b5c9b10 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -896,4 +896,17 @@ typedef void (icv_update_fn_t)(struct crypto_tfm *, struct scatterlist *, unsign
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
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8ca25fd..b059fa2 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1156,7 +1156,16 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
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
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f45fa55..835c92a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -387,13 +387,17 @@ void xfrm_state_insert(struct xfrm_state *x)
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
 
@@ -407,9 +411,18 @@ int xfrm_state_add(struct xfrm_state *x)
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
@@ -570,12 +583,11 @@ xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
 
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
@@ -585,9 +597,18 @@ struct xfrm_state * xfrm_find_acq_byseq(u32 seq)
 			}
 		}
 	}
-	spin_unlock_bh(&xfrm_state_lock);
 	return NULL;
 }
+
+struct xfrm_state *xfrm_find_acq_byseq(u32 seq)
+{
+	struct xfrm_state *x;
+
+	spin_lock_bh(&xfrm_state_lock);
+	x = __xfrm_find_acq_byseq(seq);
+	spin_unlock_bh(&xfrm_state_lock);
+	return x;
+}
  
 u32 xfrm_get_acqseq(void)
 {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index be298cd..db2087c 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -470,16 +470,32 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh, void **
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
