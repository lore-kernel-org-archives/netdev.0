From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: fix null pointer dereference on state and tmpl sort
Date: Mon, 21 Aug 2017 08:08:01 +0200
Message-ID: <1503295683-19153-3-git-send-email-steffen.klassert@secunet.com>
References: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35468 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751073AbdHUGIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:08:10 -0400
In-Reply-To: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koichiro Den <den@klaipeden.com>

Creating sub policy that matches the same outer flow as main policy does
leads to a null pointer dereference if the outer mode's family is ipv4.
For userspace compatibility, this patch just eliminates the crash i.e.,
does not introduce any new sorting rule, which would fruitlessly affect
all but the aforementioned case.

Signed-off-by: Koichiro Den <den@klaipeden.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6c0956d..a792eff 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1620,6 +1620,7 @@ int
 xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
 	       unsigned short family, struct net *net)
 {
+	int i;
 	int err = 0;
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	if (!afinfo)
@@ -1628,6 +1629,9 @@ xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
 	spin_lock_bh(&net->xfrm.xfrm_state_lock); /*FIXME*/
 	if (afinfo->tmpl_sort)
 		err = afinfo->tmpl_sort(dst, src, n);
+	else
+		for (i = 0; i < n; i++)
+			dst[i] = src[i];
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	rcu_read_unlock();
 	return err;
@@ -1638,6 +1642,7 @@ int
 xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 		unsigned short family)
 {
+	int i;
 	int err = 0;
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	struct net *net = xs_net(*src);
@@ -1648,6 +1653,9 @@ xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	if (afinfo->state_sort)
 		err = afinfo->state_sort(dst, src, n);
+	else
+		for (i = 0; i < n; i++)
+			dst[i] = src[i];
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	rcu_read_unlock();
 	return err;
-- 
2.7.4
