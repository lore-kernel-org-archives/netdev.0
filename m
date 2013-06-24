From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] qeth: Fix crash on initial MTU size change
Date: Mon, 24 Jun 2013 13:21:51 +0200
Message-ID: <20130624112226.756049779@de.ibm.com>
References: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:51401 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab3FXLWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:31 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:17:37 +0100
Content-Disposition: inline; filename=603-qeth-initial-mtu-crash.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

When the initial MTU size is changed prior to any activity on the device
(e.g. by attaching a z/VM vNIC already configured in Linux to a guestLAN),
we call dev_kfree_skb_irq(NULL) which results in a kernel panic.
Adding a proper check for NULL pointers to address this issue.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <braunu@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1282,8 +1282,10 @@ static void qeth_free_qdio_buffers(struc
 
 	qeth_free_cq(card);
 	cancel_delayed_work_sync(&card->buffer_reclaim_work);
-	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
-		dev_kfree_skb_any(card->qdio.in_q->bufs[j].rx_skb);
+	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
+		if (card->qdio.in_q->bufs[j].rx_skb)
+			dev_kfree_skb_any(card->qdio.in_q->bufs[j].rx_skb);
+	}
 	kfree(card->qdio.in_q);
 	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
