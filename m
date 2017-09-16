From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 17:23:05 -0700
Message-ID: <20170916002305.2794-1-rosenp@gmail.com>
Cc: Rosen Penev <rosenp@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35946 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdIPAXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 20:23:18 -0400
Received: by mail-pf0-f193.google.com with SMTP id f84so1896853pfj.3
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 17:23:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a linksys E1200v1 (actually a crossflashed E1000v2), the offloading features give no measurable benefit to speed or latency. Furthermore, disabling GRO actually improves iperf performance by a whoppimg 3mbps. Results:

Currently:

[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52410
[ ID] Interval        Transfer    Bandwidth       Reads   Dist(bin=16.0K)
[  4] 0.00-10.02 sec  52.4 MBytes  43.8 Mbits/sec  641    75:181:12:1:1:0:0:371
[  5] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52412
[  5] 0.00-10.02 sec  52.4 MBytes  43.8 Mbits/sec  629    51:194:13:1:0:1:0:369
[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52414
[  4] 0.00-10.02 sec  51.9 MBytes  43.4 Mbits/sec  695    126:203:1:0:0:0:2:363
[  5] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52416
[  5] 0.00-10.01 sec  52.4 MBytes  43.9 Mbits/sec  626    57:186:10:0:0:0:0:373
[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52420
[  4] 0.00-10.02 sec  52.4 MBytes  43.8 Mbits/sec  605    36:179:16:1:0:1:0:372
[  5] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52422

After disabling everything - including GRO:

[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52440
[ ID] Interval        Transfer    Bandwidth       Reads   Dist(bin=16.0K)
[  4] 0.00-10.01 sec  55.1 MBytes  46.2 Mbits/sec  672    180:82:0:0:1:0:0:409
[  5] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52442
[  5] 0.00-10.01 sec  56.0 MBytes  46.9 Mbits/sec  636    117:96:0:0:1:0:0:422
[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52444
[  4] 0.00-10.01 sec  55.4 MBytes  46.4 Mbits/sec  675    172:92:0:0:1:0:0:410
[  5] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52446
[  5] 0.00-10.01 sec  56.0 MBytes  46.9 Mbits/sec  633    119:90:0:1:1:0:0:422
[  4] local 192.168.1.1 port 5001 connected with 192.168.1.100 port 52448
[  4] 0.00-10.01 sec  55.2 MBytes  46.3 Mbits/sec  688    157:123:0:0:2:0:0:406

v2: Changed napi_gro_receive to netif_receive_skb. Seems to have an identical result.

Signed-off-by: Rosen Penev <rosenp@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 48d672b204a4..1fb0053aeee7 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -483,7 +483,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
 			bgmac->net_dev->stats.rx_bytes += len;
 			bgmac->net_dev->stats.rx_packets++;
-			napi_gro_receive(&bgmac->napi, skb);
+			netif_receive_skb(skb);
 			handled++;
 		} while (0);
 
-- 
2.13.5
