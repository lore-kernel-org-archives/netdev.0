From: Ilan Tayari <ilant@mellanox.com>
Subject: [PATCH net] xfrm: Fix memory leak of aead algorithm name
Date: Sun, 18 Sep 2016 07:42:53 +0000
Message-ID: <AM4PR0501MB19404B000E4D3A2CF3CB80DEDBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0043.outbound.protection.outlook.com ([104.47.2.43]:36678
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751581AbcIRRRg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 13:17:36 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
--=20
1.8.3.1
