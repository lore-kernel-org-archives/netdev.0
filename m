From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 2/2] xfrm: Add a device independent napi instance
Date: Thu, 26 Jan 2017 07:50:56 +0100
Message-ID: <1485413456-31197-3-git-send-email-steffen.klassert@secunet.com>
References: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35536 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752106AbdAZGvU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 01:51:20 -0500
In-Reply-To: <1485413456-31197-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a napi instance for IPsec GRO.
With this, we handle IPsec GRO with no impact
on the generic networking code.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 86 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 6e3f025..c5fc12d 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -21,6 +21,90 @@
 static DEFINE_SPINLOCK(xfrm_input_afinfo_lock);
 static struct xfrm_input_afinfo __rcu *xfrm_input_afinfo[NPROTO];
 
+struct xfrm_napi {
+	struct sk_buff_head	napi_skbs;
+	struct napi_struct	napi;
+};
+
+static struct xfrm_napi __percpu *napis;
+
+static void xfrm_gro_receive(struct sk_buff *skb)
+{
+	struct xfrm_napi *xnapi;
+	struct net_device *dev = skb->dev;
+
+	if (!napis || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
+		netif_rx(skb);
+		return;
+	}
+
+	xnapi = this_cpu_ptr(napis);
+
+	if (skb_queue_len(&xnapi->napi_skbs) > netdev_max_backlog) {
+		atomic_long_inc(&dev->rx_dropped);
+		kfree_skb(skb);
+		return;
+	}
+
+	__skb_queue_tail(&xnapi->napi_skbs, skb);
+	if (skb_queue_len(&xnapi->napi_skbs) == 1)
+		napi_schedule(&xnapi->napi);
+}
+
+static int xfrm_gro_poll(struct napi_struct *napi, int budget)
+{
+	unsigned long flags;
+	struct sk_buff *skb;
+	int work_done = 0;
+	struct xfrm_napi *xnapi = container_of(napi, struct xfrm_napi, napi);
+
+	while (work_done < budget) {
+		skb = __skb_dequeue(&xnapi->napi_skbs);
+		if (!skb)
+			break;
+		napi_gro_receive(napi, skb);
+		work_done++;
+	}
+
+	if (work_done < budget) {
+		napi_gro_flush(napi, false);
+
+		if (likely(list_empty(&napi->poll_list))) {
+			WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &napi->state));
+		} else {
+			/* If n->poll_list is not empty, we need to mask irqs */
+			local_irq_save(flags);
+			__napi_complete(napi);
+			local_irq_restore(flags);
+		}
+	}
+
+	return work_done;
+}
+
+static void xfrm_gro_init(void)
+{
+	int i;
+
+	/* Napi remains disabled if we can't alloc memory. */
+	napis = alloc_percpu(struct xfrm_napi);
+
+	for_each_possible_cpu(i) {
+		struct xfrm_napi *xnapi = per_cpu_ptr(napis, i);
+
+		__skb_queue_head_init(&xnapi->napi_skbs);
+
+		set_bit(NAPI_STATE_NO_BUSY_POLL, &xnapi->napi.state);
+
+		INIT_LIST_HEAD(&xnapi->napi.poll_list);
+		xnapi->napi.poll = xfrm_gro_poll;
+		xnapi->napi.weight = 64;
+		xnapi->napi.gro_list = NULL;
+		xnapi->napi.gro_count = 0;
+		xnapi->napi.skb = NULL;
+	}
+}
+
 int xfrm_input_register_afinfo(struct xfrm_input_afinfo *afinfo)
 {
 	int err = 0;
@@ -371,7 +455,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	if (decaps) {
 		skb_dst_drop(skb);
-		netif_rx(skb);
+		xfrm_gro_receive(skb);
 		return 0;
 	} else {
 		return x->inner_mode->afinfo->transport_finish(skb, async);
@@ -394,6 +478,7 @@ int xfrm_input_resume(struct sk_buff *skb, int nexthdr)
 
 void __init xfrm_input_init(void)
 {
+	xfrm_gro_init();
 	secpath_cachep = kmem_cache_create("secpath_cache",
 					   sizeof(struct sec_path),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-- 
1.9.1
