From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net 2/2] net: bcmgenet: fix skb_len in bcmgenet_xmit_single()
Date: Wed, 23 Mar 2016 13:01:29 -0700
Message-ID: <1458763289-95167-2-git-send-email-pgynther@google.com>
References: <1458763289-95167-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com,
	edumazet@google.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32878 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbcCWUCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 16:02:18 -0400
Received: by mail-pf0-f171.google.com with SMTP id 4so38627706pfd.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 13:02:18 -0700 (PDT)
In-Reply-To: <1458763289-95167-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_len needs to be skb_headlen(skb) in bcmgenet_xmit_single().

Fragmented skbs can have only Ethernet + IP + TCP headers (14+20+20=54 bytes)
in the linear buffer, followed by the rest in fragments. Bumping skb_len to
ETH_ZLEN would be incorrect for this case, as it would introduce garbage
between TCP header and the fragment data.

This also works with regular/non-fragmented small packets < ETH_ZLEN bytes.
Successfully tested this on GENETv3 with 42-byte ARP frames.

For testing, I used:
ethtool -K eth0 tx-checksum-ipv4 off
ethtool -K eth0 tx-checksum-ipv6 off
echo 0 > /proc/sys/net/ipv4/tcp_timestamps

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9990582..00da239 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1298,7 +1298,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 
 	tx_cb_ptr->skb = skb;
 
-	skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);
+	skb_len = skb_headlen(skb);
 
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
-- 
2.8.0.rc3.226.g39d4020
