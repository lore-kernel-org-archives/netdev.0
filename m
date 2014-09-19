From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 1/2] tg3: Work around HW/FW limitations with vlan encapsulated frames
Date: Fri, 19 Sep 2014 18:23:08 -0400
Message-ID: <1411165389-21276-2-git-send-email-vyasevic@redhat.com>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35396 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467AbaISWXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:23:22 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so3884919qcx.26
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:23:21 -0700 (PDT)
In-Reply-To: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TG3 appears to have an issue performing TSO and checksum offloading
correctly when the frame has been vlan encapsulated (non-accelerated).
In these cases, tcp checksum is not correctly updated.

This patch attempts to work around this issue.  After the patch,
802.1ad vlans start working correctly over tg3 devices.

CC: Prashant Sreedharan <prashant@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
v2: - Moved segmentation call sooner
    - Preserve checksum txd flag for LSO.

 drivers/net/ethernet/broadcom/tg3.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cb77ae9..b78d043 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7924,6 +7924,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (skb_cow_head(skb, 0))
 			goto drop;
 
+		/* HW/FW can not correctly segment packets that have been
+		 * vlan encapsulated.
+		 */
+		if (skb->protocol == htons(ETH_P_8021Q) ||
+		    skb->protocol == htons(ETH_P_8021AD))
+			return tg3_tso_bug(tp, tnapi, txq, skb);
+
 		iph = ip_hdr(skb);
 		tcp_opt_len = tcp_optlen(skb);
 
@@ -7979,6 +7986,16 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				base_flags |= tsflags << 12;
 			}
 		}
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		/* HW/FW can not correctly checksum packets that have been
+		 * vlan encapsulated.
+		 */
+		if (skb->protocol == htons(ETH_P_8021Q) ||
+		    skb->protocol == htons(ETH_P_8021AD)) {
+			if (skb_checksum_help(skb))
+				goto drop;
+			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
+		}
 	}
 
 	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
-- 
1.9.3
