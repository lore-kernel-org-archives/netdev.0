From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] bnx2x: add TSO support for IPIP
Date: Sat, 19 Oct 2013 11:42:58 -0700
Message-ID: <1382208178-22347-7-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:55929 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3JSSnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:43:10 -0400
Received: by mail-ob0-f202.google.com with SMTP id va2so311830obc.3
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:43:09 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x driver already handles TSO for GRE, current code
is the same for IPIP.

Performance results : (Note we are now limited by receiver,
as it does not support GRO for IPIP yet)

Before patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      7710.19   4.52     6.62     1.152   1.687

After patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      8532.40   2.55     7.73     0.588   1.781

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 8fd3432..6e5b35f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12260,10 +12260,12 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!CHIP_IS_E1x(bp)) {
-		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
+		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_GSO_IPIP;
 		dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
+			NETIF_F_GSO_IPIP |
 			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 	}
 
-- 
1.8.4
