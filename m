From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/17] xfrm: state: use rcu_deref and assign_pointer helpers
Date: Thu, 8 Sep 2016 07:54:41 +0200
Message-ID: <1473314092-11319-7-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36345 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752897AbcIHGvY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:24 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Before xfrm_state_find() can use rcu_read_lock instead of xfrm_state_lock
we need to switch users of the hash table to assign/obtain the pointers
with the appropriate rcu helpers.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ac4037c..53e7867 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -28,6 +28,9 @@
 
 #include "xfrm_hash.h"
 
+#define xfrm_state_deref_prot(table, net) \
+	rcu_dereference_protected((table), lockdep_is_held(&(net)->xfrm.xfrm_state_lock))
+
 /* Each xfrm_state may be linked to two tables:
 
    1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
@@ -131,18 +134,17 @@ static void xfrm_hash_resize(struct work_struct *work)
 	write_seqcount_begin(&xfrm_state_hash_generation);
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
+	odst = xfrm_state_deref_prot(net->xfrm.state_bydst, net);
 	for (i = net->xfrm.state_hmask; i >= 0; i--)
-		xfrm_hash_transfer(net->xfrm.state_bydst+i, ndst, nsrc, nspi,
-				   nhashmask);
+		xfrm_hash_transfer(odst + i, ndst, nsrc, nspi, nhashmask);
 
-	odst = net->xfrm.state_bydst;
-	osrc = net->xfrm.state_bysrc;
-	ospi = net->xfrm.state_byspi;
+	osrc = xfrm_state_deref_prot(net->xfrm.state_bysrc, net);
+	ospi = xfrm_state_deref_prot(net->xfrm.state_byspi, net);
 	ohashmask = net->xfrm.state_hmask;
 
-	net->xfrm.state_bydst = ndst;
-	net->xfrm.state_bysrc = nsrc;
-	net->xfrm.state_byspi = nspi;
+	rcu_assign_pointer(net->xfrm.state_bydst, ndst);
+	rcu_assign_pointer(net->xfrm.state_bysrc, nsrc);
+	rcu_assign_pointer(net->xfrm.state_byspi, nspi);
 	net->xfrm.state_hmask = nhashmask;
 
 	write_seqcount_end(&xfrm_state_hash_generation);
-- 
1.9.1
