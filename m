From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 04/11] tg3: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:19:55 -0700
Message-ID: <87fvmppgkk.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37131 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbaCKDUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:20:00 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e12735fbdcdb..bbbd2a4bc161 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6593,7 +6593,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		pkts_compl++;
 		bytes_compl += skb->len;
 
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 		if (unlikely(tx_bug)) {
 			tg3_tx_recover(tp);
@@ -6924,7 +6924,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 		if (len > (tp->dev->mtu + ETH_HLEN) &&
 		    skb->protocol != htons(ETH_P_8021Q)) {
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			goto drop_it_no_recycle;
 		}
 
@@ -7807,7 +7807,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 					  PCI_DMA_TODEVICE);
 		/* Make sure the mapping succeeded */
 		if (pci_dma_mapping_error(tp->pdev, new_addr)) {
-			dev_kfree_skb(new_skb);
+			dev_kfree_skb_any(new_skb);
 			ret = -1;
 		} else {
 			u32 save_entry = *entry;
@@ -7822,13 +7822,13 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 					    new_skb->len, base_flags,
 					    mss, vlan)) {
 				tg3_tx_skb_unmap(tnapi, save_entry, -1);
-				dev_kfree_skb(new_skb);
+				dev_kfree_skb_any(new_skb);
 				ret = -1;
 			}
 		}
 	}
 
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	*pskb = new_skb;
 	return ret;
 }
@@ -7871,7 +7871,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 	} while (segs);
 
 tg3_tso_bug_end:
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -8093,7 +8093,7 @@ dma_error:
 	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, --i);
 	tnapi->tx_buffers[tnapi->tx_prod].skb = NULL;
 drop:
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 drop_nofree:
 	tp->tx_dropped++;
 	return NETDEV_TX_OK;
-- 
1.7.5.4
