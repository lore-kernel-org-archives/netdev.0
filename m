From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/7] [IPSEC]: Move common code into xfrm_alloc_spi
Date: Tue, 09 Oct 2007 22:36:34 +0800
Message-ID: <E1IfGCI-0005M5-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4992 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752744AbXJIOgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move common code into xfrm_alloc_spi

This patch moves some common code that conceptually belongs to the xfrm core
from af_key/xfrm_user into xfrm_alloc_spi.

In particular, the spin lock on the state is now taken inside xfrm_alloc_spi.
Previously it also protected the construction of the response PF_KEY/XFRM
messages to user-space.  This is inconsistent as other identical constructions
are not protected by the state lock.  This is bad because they in fact should
be protected but only in certain spots (so as not to hold the lock for too
long which may cause packet drops).

The SPI byte order conversion has also been moved.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |   29 ++++++++++++-----------------
 net/xfrm/xfrm_state.c |   26 ++++++++++++++++++++------
 net/xfrm/xfrm_user.c  |   13 ++++---------
 4 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 064a4ca..1c116dc 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1084,7 +1084,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
 int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
-void xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi);
+extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state * xfrm_find_acq(u8 mode, u32 reqid, u8 proto,
 				  xfrm_address_t *daddr, xfrm_address_t *saddr,
 				  int create, unsigned short family);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index ff5c3d0..143d46f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1253,8 +1253,11 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	struct sadb_x_sa2 *sa2;
 	struct sadb_address *saddr, *daddr;
 	struct sadb_msg *out_hdr;
+	struct sadb_spirange *range;
 	struct xfrm_state *x = NULL;
 	int mode;
+	int err;
+	u32 min_spi, max_spi;
 	u32 reqid;
 	u8 proto;
 	unsigned short family;
@@ -1309,25 +1312,17 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	if (x == NULL)
 		return -ENOENT;
 
-	resp_skb = ERR_PTR(-ENOENT);
-
-	spin_lock_bh(&x->lock);
-	if (x->km.state != XFRM_STATE_DEAD) {
-		struct sadb_spirange *range = ext_hdrs[SADB_EXT_SPIRANGE-1];
-		u32 min_spi, max_spi;
+	min_spi = 0x100;
+	max_spi = 0x0fffffff;
 
-		if (range != NULL) {
-			min_spi = range->sadb_spirange_min;
-			max_spi = range->sadb_spirange_max;
-		} else {
-			min_spi = 0x100;
-			max_spi = 0x0fffffff;
-		}
-		xfrm_alloc_spi(x, htonl(min_spi), htonl(max_spi));
-		if (x->id.spi)
-			resp_skb = pfkey_xfrm_state2msg(x, 0, 3);
+	range = ext_hdrs[SADB_EXT_SPIRANGE-1];
+	if (range) {
+		min_spi = range->sadb_spirange_min;
+		max_spi = range->sadb_spirange_max;
 	}
-	spin_unlock_bh(&x->lock);
+
+	err = xfrm_alloc_spi(x, min_spi, max_spi);
+	resp_skb = err ? ERR_PTR(err) : pfkey_xfrm_state2msg(x, 0, 3);
 
 	if (IS_ERR(resp_skb)) {
 		xfrm_state_put(x);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0d07f6b..344f0a6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1275,26 +1275,33 @@ u32 xfrm_get_acqseq(void)
 }
 EXPORT_SYMBOL(xfrm_get_acqseq);
 
-void
-xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi)
+int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 {
 	unsigned int h;
 	struct xfrm_state *x0;
+	int err = -ENOENT;
+	__be32 minspi = htonl(low);
+	__be32 maxspi = htonl(high);
+
+	spin_lock_bh(&x->lock);
+	if (x->km.state == XFRM_STATE_DEAD)
+		goto unlock;
 
+	err = 0;
 	if (x->id.spi)
-		return;
+		goto unlock;
+
+	err = -ENOENT;
 
 	if (minspi == maxspi) {
 		x0 = xfrm_state_lookup(&x->id.daddr, minspi, x->id.proto, x->props.family);
 		if (x0) {
 			xfrm_state_put(x0);
-			return;
+			goto unlock;
 		}
 		x->id.spi = minspi;
 	} else {
 		u32 spi = 0;
-		u32 low = ntohl(minspi);
-		u32 high = ntohl(maxspi);
 		for (h=0; h<high-low+1; h++) {
 			spi = low + net_random()%(high-low+1);
 			x0 = xfrm_state_lookup(&x->id.daddr, htonl(spi), x->id.proto, x->props.family);
@@ -1310,7 +1317,14 @@ xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi)
 		h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
 		hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 		spin_unlock_bh(&xfrm_state_lock);
+
+		err = 0;
 	}
+
+unlock:
+	spin_unlock_bh(&x->lock);
+
+	return err;
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8e10e90..52c7fce 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -784,16 +784,11 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (x == NULL)
 		goto out_noput;
 
-	resp_skb = ERR_PTR(-ENOENT);
-
-	spin_lock_bh(&x->lock);
-	if (x->km.state != XFRM_STATE_DEAD) {
-		xfrm_alloc_spi(x, htonl(p->min), htonl(p->max));
-		if (x->id.spi)
-			resp_skb = xfrm_state_netlink(skb, x, nlh->nlmsg_seq);
-	}
-	spin_unlock_bh(&x->lock);
+	err = xfrm_alloc_spi(x, p->min, p->max);
+	if (err)
+		goto out;
 
+	resp_skb = xfrm_state_netlink(skb, x, nlh->nlmsg_seq);
 	if (IS_ERR(resp_skb)) {
 		err = PTR_ERR(resp_skb);
 		goto out;
