From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net v2 2/2] net: bcmgenet: fix skb_len in bcmgenet_xmit_single()
Date: Thu, 24 Mar 2016 11:27:21 -0700
Message-ID: <1458844041-71532-2-git-send-email-pgynther@google.com>
References: <1458844041-71532-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com,
	edumazet@google.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33393 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbcCXS2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:28:09 -0400
Received: by mail-pf0-f169.google.com with SMTP id 4so64553972pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:28:08 -0700 (PDT)
In-Reply-To: <1458844041-71532-1-git-send-email-pgynther@google.com>
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

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Petri Gynther <pgynther@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c1c7c0e..cf6445d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1297,7 +1297,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 
 	tx_cb_ptr->skb = skb;
 
-	skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);
+	skb_len = skb_headlen(skb);
 
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
-- 
2.8.0.rc3.226.g39d4020
