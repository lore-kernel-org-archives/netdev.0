From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/2] nfp: don't tell FW about the reserved buffer space
Date: Thu,  2 Mar 2017 15:26:20 -0800
Message-ID: <20170302232621.39763-2-jakub.kicinski@netronome.com>
References: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35713 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751235AbdCCAXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 19:23:51 -0500
Received: by mail-pf0-f178.google.com with SMTP id j5so27215760pfb.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 16:23:44 -0800 (PST)
In-Reply-To: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c0f031bc8866 ("nfp_net: use alloc_frag() and build_skb()")
we are allocating buffers which have to hold both the data and skb to
be created in place by build_skb().

FW should only be told about the buffer space it can DMA to, that
is without the build_skb() headroom and tailroom.  Note: firmware
applications should validate the buffers against both MTU and
free list buffer size so oversized packets would not pass through
the NIC anyway.

Fixes: c0f031bc8866 ("nfp: use alloc_frag() and build_skb()")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 074259cc8e06..00a83218857a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2198,7 +2198,8 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	nfp_net_write_mac_addr(nn);
 
 	nn_writel(nn, NFP_NET_CFG_MTU, nn->netdev->mtu);
-	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, nn->fl_bufsz);
+	nn_writel(nn, NFP_NET_CFG_FLBUFSZ,
+		  nn->fl_bufsz - NFP_NET_RX_BUF_NON_DATA);
 
 	/* Enable device */
 	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
-- 
2.11.0
