From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] vmxnet3: locking problems in xmit
Date: Mon, 20 Dec 2010 16:03:15 +0300
Message-ID: <20101220130315.GY1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33904 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab0LTND0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 08:03:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were several paths that didn't release their locks.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 23154cf..939e546 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -980,7 +980,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		}
 	} else {
 		tq->stats.drop_hdr_inspect_err++;
-		goto drop_pkt;
+		goto unlock_drop_pkt;
 	}
 
 	/* fill tx descs related to addr & len */
@@ -1052,6 +1052,8 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 
 hdr_too_big:
 	tq->stats.drop_oversized_hdr++;
+unlock_drop_pkt:
+	spin_unlock_irqrestore(&tq->tx_lock, flags);
 drop_pkt:
 	tq->stats.drop_total++;
 	dev_kfree_skb(skb);
