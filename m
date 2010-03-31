From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 13:17:03 +0300
Message-ID: <1270030626-16687-3-git-send-email-timo.teras@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:57950 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933195Ab0CaKRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:17:25 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so1817145ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 03:17:25 -0700 (PDT)
In-Reply-To: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__xfrm_state_bump_genids() is used to update the genid of all
matching xfrm_state's, so any bundle using the state would get
refreshed with the newly inserted state.

However, since __xfrm_state_bump_genids() is called before the
__xfrm_state_insert() which actually bumps the genid counter,
it is possible that the genid was not updated at all (if there
was no state inserts previously).

This is fixed by moving the genid incrementation to
__xfrm_state_bump_genids() so the older states are guaranteed
to get different genid.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/xfrm/xfrm_state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 17d5b96..b4efc28 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -923,7 +923,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 	struct net *net = xs_net(x);
 	unsigned int h;
 
-	x->genid = ++xfrm_state_genid;
+	x->genid = xfrm_state_genid;
 
 	list_add(&x->km.all, &net->xfrm.state_all);
 
@@ -963,6 +963,7 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 	unsigned int h;
 	u32 mark = xnew->mark.v & xnew->mark.m;
 
+	xfrm_state_genid++;
 	h = xfrm_dst_hash(net, &xnew->id.daddr, &xnew->props.saddr, reqid, family);
 	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
 		if (x->props.family	== family &&
-- 
1.6.3.3

