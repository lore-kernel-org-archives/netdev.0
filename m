From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/6] xfrm: state: use rcu_deref and assign_pointer helpers
Date: Tue,  9 Aug 2016 12:16:08 +0200
Message-ID: <1470737769-30438-6-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43912 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before xfrm_state_find() can use rcu_read_lock instead of xfrm_state_lock
we need to switch users of the hash table to assign/obtain the pointers
with the appropriate rcu helpers.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
2.7.3
