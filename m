From: ilant@mellanox.com
Subject: [PATCH net-next 6/7] xfrm: Clear RX SKB secpath xfrm_offload
Date: Tue,  1 Aug 2017 12:49:09 +0300
Message-ID: <20170801094910.14895-7-ilant@mellanox.com>
References: <20170801094910.14895-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50051.outbound.protection.outlook.com ([40.107.5.51]:57152
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751769AbdHAJuF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 05:50:05 -0400
In-Reply-To: <20170801094910.14895-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

If an incoming packet undergoes XFRM crypto-offload, its secpath is
filled with xfrm_offload struct denoting offload information.

If the SKB is then forwarded to a device which supports crypto-
offload, the stack wrongfully attempts to offload it (even though
the output SA may not exist on the device) due to the leftover
secpath xo.

Clear the ingress xo by zeroizing secpath->olen just before
delivering the decapsulated packet to the network stack.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 net/xfrm/xfrm_input.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 923205e279f7..f07eec59dcae 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -424,6 +424,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	nf_reset(skb);
 
 	if (decaps) {
+		skb->sp->olen = 0;
 		skb_dst_drop(skb);
 		gro_cells_receive(&gro_cells, skb);
 		return 0;
@@ -434,6 +435,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		err = x->inner_mode->afinfo->transport_finish(skb, xfrm_gro || async);
 		if (xfrm_gro) {
+			skb->sp->olen = 0;
 			skb_dst_drop(skb);
 			gro_cells_receive(&gro_cells, skb);
 			return err;
-- 
2.11.0
