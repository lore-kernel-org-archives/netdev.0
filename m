From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC] e1000: Send XDP_TX packets using dev_queue_xmit
Date: Mon, 12 Sep 2016 09:21:10 -0700
Message-ID: <1473697270-3906793-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33589 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751120AbcILQV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:21:26 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8CGL23B002445
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 09:21:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25dva8215v-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 09:21:25 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 ef5d4184790411e6945f24be0593f280-f65f7a50 for <netdev@vger.kernel.org>;        Mon,
 12 Sep 2016 09:21:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to use XDP with non multi-queue drivers (such as e1000) we need
a method to handle XDP_TX return code from xdp program. Since there is
only one queue the XDP transmit path needs to share that queue with the
normal stack path, and in order to do that we can't break the existing
stack's mechanisms of locking, qdiscs, and BQL for the queue.

This patch allocates an skbuff when XDP_TX is returned from the XDP
program and call dev_queue_xmit to transmit the skbuff.

Note that this is expected to be a performance hit (which needs to be
quantified) relative to a MQ XDP implementation where we can reserve
queues to be used by XDP. The first intent of these patches is
correctness. This should not affect performance in the XDP_DROP path.

This patch needs to be applied after "e1000: add initial XDP support".

Tested: I've only built this, need to see if I can find some e1000
machines. John, if you could try this that would be much appreciated.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 29 ++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 91d5c87..f457ea8 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4338,13 +4338,28 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				dma_sync_single_for_device(&pdev->dev,
-							   dma,
-							   length,
-							   DMA_TO_DEVICE);
-				e1000_xmit_raw_frame(buffer_info, length,
-						     netdev, adapter);
-				buffer_info->rxbuf.page = NULL;
+				/* There is only one transmit queue so we need
+				 * to inject the packet at the qdisc layer
+				 * to maintain sanity in the stack. We allocate
+				 * an skbuff, set up frags with the page, and
+				 * then do dev_queue_xmit.
+				 */
+				skb = alloc_skb(0, GFP_ATOMIC);
+				if (skb) {
+					dma_unmap_page(&pdev->dev,
+						       buffer_info->dma,
+						       adapter->rx_buffer_len,
+						       DMA_FROM_DEVICE);
+					skb->dev = netdev;
+					skb_fill_page_desc(skb, 0,
+						buffer_info->rxbuf.page,
+						0, length);
+					dev_queue_xmit(skb);
+					goto next_desc;
+				}
+				/* Fallthrough, if we are unable to handle
+				 * XDP_TX then we need to drop.
+				 */
 			case XDP_DROP:
 			default:
 				/* re-use mapped page. keep buffer_info->dma
-- 
2.8.0.rc2
