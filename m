From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH][XFRM] Fixes for net-2.6
Date: Tue, 03 Oct 2006 12:29:54 +0900
Message-ID: <4521D932.8050502@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:36748 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S932157AbWJCD35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 23:29:57 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have two patches to fix XFRM. Can you check and apply them?


HEADLINES
---------

    [XFRM] POLICY: Fix per-direction policy counter after flushing.
    [XFRM] STATE: Use destination address for src hash.

DIFFSTAT
--------

 net/xfrm/xfrm_hash.h   |    7 ++++---
 net/xfrm/xfrm_policy.c |    4 ++--
 net/xfrm/xfrm_state.c  |   16 +++++++++-------
 3 files changed, 15 insertions(+), 12 deletions(-)

CHANGESETS
----------

commit 90c1f7d3e1019b2885844b03088588268e38cec5
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sun Sep 24 14:46:59 2006 +0900

    [XFRM] POLICY: Fix per-direction policy counter after flushing.

    Currently when xfrm_policy_flush() is called per-direction
    policy counter is cleared. However flusing policy is performed
    for each type (i.e. main or sub) then it is not always true
    to make the counter zero.

    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b6e2e79..048e248 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -787,6 +787,7 @@ void xfrm_policy_flush(u8 type)
 				continue;
 			hlist_del(&pol->bydst);
 			hlist_del(&pol->byidx);
+			xfrm_policy_count[dir]--;
 			write_unlock_bh(&xfrm_policy_lock);

 			xfrm_policy_kill(pol);
@@ -804,6 +805,7 @@ void xfrm_policy_flush(u8 type)
 					continue;
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
+				xfrm_policy_count[dir]--;
 				write_unlock_bh(&xfrm_policy_lock);

 				xfrm_policy_kill(pol);
@@ -812,8 +814,6 @@ void xfrm_policy_flush(u8 type)
 				goto again2;
 			}
 		}
-
-		xfrm_policy_count[dir] = 0;
 	}
 	atomic_inc(&flow_cache_genid);
 	write_unlock_bh(&xfrm_policy_lock);

---
commit e517421855d241f0b85a186b25e85d00eafa129f
Author: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date:   Sat Sep 23 16:41:34 2006 +0900

    [XFRM] STATE: Use destination address for src hash.

    Src hash is introduced for Mobile IPv6 route optimization usage.
    On current kenrel code it is calculated with source address only.
    It results we uses the same hash value for outbound state (when
    the node has only one address for Mobile IPv6).
    This patch use also destination address as peer information for
    src hash to be dispersed.

    Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 6ac4e4f..d401dc8 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -41,17 +41,18 @@ static inline unsigned int __xfrm_dst_ha
 	return (h ^ (h >> 16)) & hmask;
 }

-static inline unsigned __xfrm_src_hash(xfrm_address_t *saddr,
+static inline unsigned __xfrm_src_hash(xfrm_address_t *daddr,
+				       xfrm_address_t *saddr,
 				       unsigned short family,
 				       unsigned int hmask)
 {
 	unsigned int h = family;
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_addr_hash(saddr);
+		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_addr_hash(saddr);
+		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
 		break;
 	};
 	return (h ^ (h >> 16)) & hmask;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f927b73..39b8bf3 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -63,10 +63,11 @@ static inline unsigned int xfrm_dst_hash
 	return __xfrm_dst_hash(daddr, saddr, reqid, family, xfrm_state_hmask);
 }

-static inline unsigned int xfrm_src_hash(xfrm_address_t *addr,
+static inline unsigned int xfrm_src_hash(xfrm_address_t *daddr,
+					 xfrm_address_t *saddr,
 					 unsigned short family)
 {
-	return __xfrm_src_hash(addr, family, xfrm_state_hmask);
+	return __xfrm_src_hash(daddr, saddr, family, xfrm_state_hmask);
 }

 static inline unsigned int
@@ -92,7 +93,8 @@ static void xfrm_hash_transfer(struct hl
 				    nhashmask);
 		hlist_add_head(&x->bydst, ndsttable+h);

-		h = __xfrm_src_hash(&x->props.saddr, x->props.family,
+		h = __xfrm_src_hash(&x->id.daddr, &x->props.saddr,
+				    x->props.family,
 				    nhashmask);
 		hlist_add_head(&x->bysrc, nsrctable+h);

@@ -458,7 +460,7 @@ static struct xfrm_state *__xfrm_state_l

 static struct xfrm_state *__xfrm_state_lookup_byaddr(xfrm_address_t *daddr, xfrm_address_t *saddr, u8 proto, unsigned short family)
 {
-	unsigned int h = xfrm_src_hash(saddr, family);
+	unsigned int h = xfrm_src_hash(daddr, saddr, family);
 	struct xfrm_state *x;
 	struct hlist_node *entry;

@@ -587,7 +589,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
-			h = xfrm_src_hash(saddr, family);
+			h = xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
 			if (x->id.spi) {
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
@@ -622,7 +624,7 @@ static void __xfrm_state_insert(struct x
 			  x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);

-	h = xfrm_src_hash(&x->props.saddr, x->props.family);
+	h = xfrm_src_hash(&x->id.daddr, &x->props.saddr, x->props.family);
 	hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);

 	if (x->id.spi) {
@@ -748,7 +750,7 @@ static struct xfrm_state *__find_acq_cor
 		x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 		add_timer(&x->timer);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
-		h = xfrm_src_hash(saddr, family);
+		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
 		wake_up(&km_waitq);
 	}

---


-- 
Masahide NAKAMURA
