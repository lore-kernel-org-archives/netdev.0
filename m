From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 48/50] staging: bcm: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:11 +0800
Message-ID: <1373533573-12272-49-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>, devel@driverdev.osuosl.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:39051 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932611Ab3GKJNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:13:02 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: devel@driverdev.osuosl.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/staging/bcm/InterfaceRx.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/bcm/InterfaceRx.c b/drivers/staging/bcm/InterfaceRx.c
index 26f5bc7..00af901 100644
--- a/drivers/staging/bcm/InterfaceRx.c
+++ b/drivers/staging/bcm/InterfaceRx.c
@@ -47,6 +47,7 @@ static void read_bulk_callback(struct urb *urb)
 	struct bcm_interface_adapter *psIntfAdapter = pRcb->psIntfAdapter;
 	struct bcm_mini_adapter *Adapter = psIntfAdapter->psAdapter;
 	struct bcm_leader *pLeader = urb->transfer_buffer;
+	unsigned long flags;
 
 	if (unlikely(netif_msg_rx_status(Adapter)))
 		pr_info(PFX "%s: rx urb status %d length %d\n",
@@ -129,9 +130,9 @@ static void read_bulk_callback(struct urb *urb)
 			(sizeof(struct bcm_leader)), pLeader->PLength);
 		skb->len = pLeader->PLength + sizeof(USHORT);
 
-		spin_lock(&Adapter->control_queue_lock);
+		spin_lock_irqsave(&Adapter->control_queue_lock, flags);
 		ENQUEUEPACKET(Adapter->RxControlHead,Adapter->RxControlTail,skb);
-		spin_unlock(&Adapter->control_queue_lock);
+		spin_unlock_irqretore(&Adapter->control_queue_lock, flags);
 
 		atomic_inc(&Adapter->cntrlpktCnt);
 		wake_up(&Adapter->process_rx_cntrlpkt);
-- 
1.7.9.5
