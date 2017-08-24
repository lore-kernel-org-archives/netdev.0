From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V3 PATCH net-next 3/5] ixgbe: use return codes from ndo_xdp_xmit
 that are distinguishable
Date: Thu, 24 Aug 2017 12:33:13 +0200
Message-ID: <150357079360.26663.4569337848944080554.stgit@firesoul>
References: <150357074701.26663.4047992776649697788.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751342AbdHXKdP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 06:33:15 -0400
In-Reply-To: <150357074701.26663.4047992776649697788.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For XDP_REDIRECT the use of return code -EINVAL is confusing, as it is
used in three different cases.  (1) When the index or ifindex lookup
fails, and in the ixgbe driver (2) when link is down and (3) when XDP
have not been enabled.

The return code can be picked up by the tracepoint xdp:xdp_redirect
for diagnosing why XDP_REDIRECT isn't working.  Thus, there is a need
different return codes to tell the issues apart.

I'm considering using a specific err-code scheme for XDP_REDIRECT
instead of using these errno codes.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8d3224ad6434..d962368d08d0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9849,14 +9849,14 @@ static int ixgbe_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
 	int err;
 
 	if (unlikely(test_bit(__IXGBE_DOWN, &adapter->state)))
-		return -EINVAL;
+		return -ENETDOWN;
 
 	/* During program transitions its possible adapter->xdp_prog is assigned
 	 * but ring has not been configured yet. In this case simply abort xmit.
 	 */
 	ring = adapter->xdp_prog ? adapter->xdp_ring[smp_processor_id()] : NULL;
 	if (unlikely(!ring))
-		return -EINVAL;
+		return -ENXIO;
 
 	err = ixgbe_xmit_xdp_ring(adapter, xdp);
 	if (err != IXGBE_XDP_TX)
