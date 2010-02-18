From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [PATCH net-next-2.6] be2net: free tx buffers when completions
 never arrive
Date: Thu, 18 Feb 2010 16:07:17 +0530
Message-ID: <20100218103717.GA15679@serverengines.com>
References: <20100218093603.GA28912@serverengines.com>
 <20100218.021616.127015823.davem@davemloft.net>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sathyap@serverengines.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:20577 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756787Ab0BRKhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 05:37:34 -0500
Content-Disposition: inline
In-Reply-To: <20100218.021616.127015823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18/02/10 02:16 -0800, David Miller wrote:
<snip>
> > +        bool dummy_wrb;
> 
> Some of your lines start with tabs, some with spaces.   You
> have to use tabs consistently.
> 
<snip>

Sorry, mistake fixed; patch below. Thanks a lot...

-Sathya

>From 8f9134221833d4d00da1482f3051751b625649ca Mon Sep 17 00:00:00 2001
From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 18 Feb 2010 14:57:35 +0530
Subject: [PATCH net-next-2.6] be2net: free tx buffers when completions never arrive

In cases like when a pci device is disconnected on an error,
pending tx completions will never arrive. Unmap and free such
buffers in the tx cleanup path.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 68e7848..545c841 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1128,6 +1128,9 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_eth_tx_compl *txcp;
 	u16 end_idx, cmpl = 0, timeo = 0;
+	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
+	struct sk_buff *sent_skb;
+	bool dummy_wrb;
 
 	/* Wait for a max of 200ms for all the tx-completions to arrive. */
 	do {
@@ -1151,6 +1154,15 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 	if (atomic_read(&txq->used))
 		dev_err(&adapter->pdev->dev, "%d pending tx-completions\n",
 			atomic_read(&txq->used));
+
+	/* free posted tx for which compls will never arrive */
+	while (atomic_read(&txq->used)) {
+		sent_skb = sent_skbs[txq->tail];
+		end_idx = txq->tail;
+		index_adv(&end_idx,
+			wrb_cnt_for_skb(sent_skb, &dummy_wrb) - 1, txq->len);
+		be_tx_compl_process(adapter, end_idx);
+	}
 }
 
 static void be_mcc_queues_destroy(struct be_adapter *adapter)
-- 
1.6.3.3



