From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 22/50] BT: btusb: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:45 +0800
Message-ID: <1373533573-12272-23-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45434 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab3GKJJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:35 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: linux-bluetooth@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/bluetooth/btusb.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index ea63958..018b8b0 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -573,6 +573,7 @@ static void btusb_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *) skb->dev;
 	struct btusb_data *data = hci_get_drvdata(hdev);
+	unsigned long flags;
 
 	BT_DBG("%s urb %p status %d count %d", hdev->name,
 					urb, urb->status, urb->actual_length);
@@ -586,9 +587,9 @@ static void btusb_tx_complete(struct urb *urb)
 		hdev->stat.err_tx++;
 
 done:
-	spin_lock(&data->txlock);
+	spin_lock_irqsave(&data->txlock, flags);
 	data->tx_in_flight--;
-	spin_unlock(&data->txlock);
+	spin_unlock_irqrestore(&data->txlock, flags);
 
 	kfree(urb->setup_packet);
 
-- 
1.7.9.5
