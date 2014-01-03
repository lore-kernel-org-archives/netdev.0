From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 6/8] {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
Date: Fri, 3 Jan 2014 11:18:32 +0800
Message-ID: <1388719114-26244-7-git-send-email-fan.du@windriver.com>
References: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47842 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbaACDSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:48 -0500
In-Reply-To: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce xfrm_state_lookup_byspi to find user specified by custom
from "pgset spi xxx". Using this scheme, any flow regardless its
saddr/daddr could be transform by SA specified with configurable
spi.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |    2 ++
 net/core/pktgen.c     |   22 +++++++++++++++-------
 net/xfrm/xfrm_state.c |   22 ++++++++++++++++++++++
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6b82fdf..dfdfead 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1422,6 +1422,8 @@ struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
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
index f7cb4a3..d31a126 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -925,6 +925,28 @@ xfrm_stateonly_find(struct net *net, u32 mark,
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
