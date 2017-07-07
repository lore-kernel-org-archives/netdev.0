From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 06/12] ixgbe: add initial support for xdp redirect
Date: Fri, 07 Jul 2017 10:36:30 -0700
Message-ID: <20170707173630.9984.92592.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36782 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdGGRgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:36:46 -0400
Received: by mail-pg0-f68.google.com with SMTP id u36so4803121pgn.3
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:36:45 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are optimizations we can add after the basic feature is
enabled. But, for now keep the patch simple.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   41 ++++++++++++++++++++++++-
 1 file changed, 40 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f1dbdf2..3db0473 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2214,7 +2214,7 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_adapter *adapter,
 				     struct ixgbe_ring *rx_ring,
 				     struct xdp_buff *xdp)
 {
-	int result = IXGBE_XDP_PASS;
+	int err, result = IXGBE_XDP_PASS;
 	struct bpf_prog *xdp_prog;
 	u32 act;
 
@@ -2231,6 +2231,13 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_adapter *adapter,
 	case XDP_TX:
 		result = ixgbe_xmit_xdp_ring(adapter, xdp);
 		break;
+	case XDP_REDIRECT:
+		err = xdp_do_redirect(adapter->netdev, xdp);
+		if (!err)
+			result = IXGBE_XDP_TX;
+		else
+			result = IXGBE_XDP_CONSUMED;
+		break;
 	default:
 		bpf_warn_invalid_xdp_action(act);
 		/* fallthrough */
@@ -9823,6 +9830,37 @@ static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	}
 }
 
+static int ixgbe_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_ring *ring;
+	int err;
+
+	if (unlikely(test_bit(__IXGBE_DOWN, &adapter->state)))
+		return -EINVAL;
+
+	/* During program transitions its possible adapter->xdp_prog is assigned
+	 * but ring has not been configured yet. In this case simply abort xmit.
+	 */
+	ring = adapter->xdp_prog ? adapter->xdp_ring[smp_processor_id()] : NULL;
+	if (unlikely(!ring))
+		return -EINVAL;
+
+	err = ixgbe_xmit_xdp_ring(adapter, xdp);
+	if (err != IXGBE_XDP_TX)
+		return -ENOMEM;
+
+	/* Force memory writes to complete before letting h/w know there
+	 * are new descriptors to fetch.
+	 */
+	wmb();
+
+	ring = adapter->xdp_ring[smp_processor_id()];
+	writel(ring->next_to_use, ring->tail);
+
+	return 0;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -9869,6 +9907,7 @@ static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	.ndo_udp_tunnel_del	= ixgbe_del_udp_tunnel_port,
 	.ndo_features_check	= ixgbe_features_check,
 	.ndo_xdp		= ixgbe_xdp,
+	.ndo_xdp_xmit		= ixgbe_xdp_xmit,
 };
 
 /**
