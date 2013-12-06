From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 4/5] {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
Date: Fri, 6 Dec 2013 17:53:33 +0800
Message-ID: <1386323614-5077-5-git-send-email-fan.du@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55570 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235Ab3LFJxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:42 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce xfrm_state_lookup_byspi to find user specified by custom
from "pgset spi xxx". Using this scheme, any flow regardless its
saddr/daddr could be transform by SA specified with configurable
spi.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |    7 ++-----
 net/core/pktgen.c     |   13 +++++--------
 net/xfrm/xfrm_state.c |   43 +++++++++++++++++--------------------------
 3 files changed, 24 insertions(+), 39 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6b82fdf..68ad3f8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1417,11 +1417,8 @@ struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
 				   struct xfrm_tmpl *tmpl,
 				   struct xfrm_policy *pol, int *err,
 				   unsigned short family);
-struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
-				       xfrm_address_t *daddr,
-				       xfrm_address_t *saddr,
-				       unsigned short family,
-				       u8 mode, u8 proto, u32 reqid);
+struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
+					      unsigned short family);
 int xfrm_state_check_expire(struct xfrm_state *x);
 void xfrm_state_insert(struct xfrm_state *x);
 int xfrm_state_add(struct xfrm_state *x);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2f4f90c..f2a2a98 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2238,19 +2238,16 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 /* If there was already an IPSEC SA, we keep it as is, else
  * we go look for it ...
 */
-#define DUMMY_MARK 0
 static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 {
 	struct xfrm_state *x = pkt_dev->flows[flow].x;
 	struct pktgen_net *pn = net_generic(dev_net(pkt_dev->odev), pg_net_id);
 	if (!x) {
-		/*slow path: we dont already have xfrm_state*/
-		x = xfrm_stateonly_find(pn->net, DUMMY_MARK,
-					(xfrm_address_t *)&pkt_dev->cur_daddr,
-					(xfrm_address_t *)&pkt_dev->cur_saddr,
-					AF_INET,
-					pkt_dev->ipsmode,
-					pkt_dev->ipsproto, 0);
+		/* We need as quick as possible to find the right SA
+		 * Searching with minimum criteria to archieve this.
+		 */
+		x = xfrm_state_lookup_byspi(pn->net, htonl(pkt_dev->spi),
+						AF_INET);
 		if (x) {
 			pkt_dev->flows[flow].x = x;
 			set_pkt_overhead(pkt_dev);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 68c2f35..6a9c402 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -892,38 +892,29 @@ out:
 	return x;
 }
 
-struct xfrm_state *
-xfrm_stateonly_find(struct net *net, u32 mark,
-		    xfrm_address_t *daddr, xfrm_address_t *saddr,
-		    unsigned short family, u8 mode, u8 proto, u32 reqid)
+struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
+					      unsigned short family)
 {
-	unsigned int h;
-	struct xfrm_state *rx = NULL, *x = NULL;
+	struct xfrm_state *x;
+	struct xfrm_state_walk *w;
 
-	spin_lock(&xfrm_state_lock);
-	h = xfrm_dst_hash(net, daddr, saddr, reqid, family);
-	hlist_for_each_entry(x, net->xfrm.state_bydst+h, bydst) {
-		if (x->props.family == family &&
-		    x->props.reqid == reqid &&
-		    (mark & x->mark.m) == x->mark.v &&
-		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
-		    xfrm_state_addr_check(x, daddr, saddr, family) &&
-		    mode == x->props.mode &&
-		    proto == x->id.proto &&
-		    x->km.state == XFRM_STATE_VALID) {
-			rx = x;
-			break;
-		}
-	}
+	spin_lock_bh(&xfrm_state_lock);
+	list_for_each_entry(w, &net->xfrm.state_all, all) {
 
-	if (rx)
-		xfrm_state_hold(rx);
-	spin_unlock(&xfrm_state_lock);
+		x = container_of(w, struct xfrm_state, km);
+		if (x->props.family != family ||
+			x->id.spi != spi)
+			continue;
 
+		spin_unlock_bh(&xfrm_state_lock);
+		xfrm_state_hold(x);
+		return x;
+	}
+	spin_unlock_bh(&xfrm_state_lock);
 
-	return rx;
+	return NULL;
 }
-EXPORT_SYMBOL(xfrm_stateonly_find);
+EXPORT_SYMBOL(xfrm_state_lookup_byspi);
 
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
-- 
1.7.9.5
