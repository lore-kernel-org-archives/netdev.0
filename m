From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: Fix memory leak of aead algorithm name
Date: Wed, 21 Sep 2016 13:05:45 +0200
Message-ID: <1474455946-674-4-git-send-email-steffen.klassert@secunet.com>
References: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38341 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756637AbcIULF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:05:57 -0400
In-Reply-To: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

commit 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
introduced aead. The function attach_aead kmemdup()s the algorithm
name during xfrm_state_construct().
However this memory is never freed.
Implementation has since been slightly modified in
commit ee5c23176fcc ("xfrm: Clone states properly on migration")
without resolving this leak.
This patch adds a kfree() call for the aead algorithm name.

Fixes: 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Acked-by: Rami Rosen <roszenrami@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9895a8c..a30f898d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -332,6 +332,7 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
 	tasklet_hrtimer_cancel(&x->mtimer);
 	del_timer_sync(&x->rtimer);
+	kfree(x->aead);
 	kfree(x->aalg);
 	kfree(x->ealg);
 	kfree(x->calg);
-- 
1.9.1
