From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 11/15] {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
Date: Tue, 14 Jan 2014 07:49:15 +0100
Message-ID: <1389682159-3260-12-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60084 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbaANGtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:41 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

Introduce xfrm_state_lookup_byspi to find user specified by custom
from "pgset spi xxx". Using this scheme, any flow regardless its
saddr/daddr could be transform by SA specified with configurable
spi.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |    2 ++
 net/core/pktgen.c     |   22 +++++++++++++++-------
 net/xfrm/xfrm_state.c |   22 ++++++++++++++++++++++
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b7635ef..cd7c46f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1421,6 +1421,8 @@ struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
 				       xfrm_address_t *saddr,
 				       unsigned short family,
 				       u8 mode, u8 proto, u32 reqid);
+struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
+					      unsigned short family);
 int xfrm_state_check_expire(struct xfrm_state *x);
 void xfrm_state_insert(struct xfrm_state *x);
 int xfrm_state_add(struct xfrm_state *x);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 628f7c5..b553c36 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2247,13 +2247,21 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
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
+
+		if (pkt_dev->spi) {
+			/* We need as quick as possible to find the right SA
+			 * Searching with minimum criteria to archieve this.
+			 */
+			x = xfrm_state_lookup_byspi(pn->net, htonl(pkt_dev->spi), AF_INET);
+		} else {
+			/* slow path: we dont already have xfrm_state */
+			x = xfrm_stateonly_find(pn->net, DUMMY_MARK,
+						(xfrm_address_t *)&pkt_dev->cur_daddr,
+						(xfrm_address_t *)&pkt_dev->cur_saddr,
+						AF_INET,
+						pkt_dev->ipsmode,
+						pkt_dev->ipsproto, 0);
+		}
 		if (x) {
 			pkt_dev->flows[flow].x = x;
 			set_pkt_overhead(pkt_dev);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3007440..6218148 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -915,6 +915,28 @@ xfrm_stateonly_find(struct net *net, u32 mark,
 }
 EXPORT_SYMBOL(xfrm_stateonly_find);
 
+struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
+					      unsigned short family)
+{
+	struct xfrm_state *x;
+	struct xfrm_state_walk *w;
+
+	spin_lock_bh(&net->xfrm.xfrm_state_lock);
+	list_for_each_entry(w, &net->xfrm.state_all, all) {
+		x = container_of(w, struct xfrm_state, km);
+		if (x->props.family != family ||
+			x->id.spi != spi)
+			continue;
+
+		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+		xfrm_state_hold(x);
+		return x;
+	}
+	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+	return NULL;
+}
+EXPORT_SYMBOL(xfrm_state_lookup_byspi);
+
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
 	struct net *net = xs_net(x);
-- 
1.7.9.5
