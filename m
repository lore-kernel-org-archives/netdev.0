From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 06/12] ixgbe: add initial support for xdp redirect
Date: Mon, 17 Jul 2017 09:28:12 -0700
Message-ID: <20170717162812.24315.26884.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34628 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751310AbdGQQ23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:28:29 -0400
Received: by mail-pg0-f65.google.com with SMTP id v190so6249678pgv.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:28:29 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are optimizations we can add after the basic feature is
enabled. But, for now keep the patch simple.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
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
