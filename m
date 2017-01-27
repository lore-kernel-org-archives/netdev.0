From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device for napi.
Date: Fri, 27 Jan 2017 08:19:32 +0100
Message-ID: <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
References: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
        "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39172 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754108AbdA0HTn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 02:19:43 -0500
In-Reply-To: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a dummy network device so that we can
use gro_cells for IPsec GRO. With this, we handle IPsec
GRO with no impact on the generic networking code.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 6e3f025..3213fe8 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -21,6 +21,9 @@
 static DEFINE_SPINLOCK(xfrm_input_afinfo_lock);
 static struct xfrm_input_afinfo __rcu *xfrm_input_afinfo[NPROTO];
 
+static struct gro_cells gro_cells;
+static struct net_device xfrm_napi_dev;
+
 int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
 {
 	int err = 0;
@@ -371,7 +374,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	if (decaps) {
 		skb_dst_drop(skb);
-		netif_rx(skb);
+		gro_cells_receive(&gro_cells, skb);
 		return 0;
 	} else {
 		return x->inner_mode->afinfo->transport_finish(skb, async);
@@ -394,6 +397,13 @@ int xfrm_input_resume(struct sk_buff *skb, int nexthdr)
 
 void __init xfrm_input_init(void)
 {
+	int err;
+
+	init_dummy_netdev(&xfrm_napi_dev);
+	err = gro_cells_init(&gro_cells, &xfrm_napi_dev);
+	if (err)
+		gro_cells.cells = NULL;
+
 	secpath_cachep = kmem_cache_create("secpath_cache",
 					   sizeof(struct sec_path),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-- 
1.9.1
