From: Koichiro Den <den@klaipeden.com>
Subject: [PATCH net] xfrm: fix null pointer dereference on state and tmpl sort
Date: Tue,  1 Aug 2017 23:21:46 +0900
Message-ID: <20170801142146.8588-1-den@klaipeden.com>
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21455 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751811AbdHAOWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:22:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating sub policy that matches the same outer flow as main policy does
leads to a null pointer dereference if the outer mode's family is ipv4.
For userspace compatibility, this patch just eliminates the crash i.e.,
does not introduce any new sorting rule, which would fruitlessly affect
all but the aforementioned case.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/xfrm/xfrm_state.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6c0956d10db6..a792effdb0b5 100644
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
2.9.4
