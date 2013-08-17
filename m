From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 36/49] wireless: libertas_tf: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:25:01 +0800
Message-ID: <1376756714-25479-37-git-send-email-ming.lei@canonical.com>
References: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Ming Lei <ming.lei@canonical.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64528 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab3HQQbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 12:31:13 -0400
In-Reply-To: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: libertas-dev@lists.infradead.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/wireless/libertas_tf/if_usb.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index d576dd6..0e9e972 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -610,6 +610,8 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 				      struct if_usb_card *cardp,
 				      struct lbtf_private *priv)
 {
+	unsigned long flags;
+
 	if (recvlength > LBS_CMD_BUFFER_SIZE) {
 		lbtf_deb_usbd(&cardp->udev->dev,
 			     "The receive buffer is too large\n");
@@ -619,12 +621,12 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 
 	BUG_ON(!in_interrupt());
 
-	spin_lock(&priv->driver_lock);
+	spin_lock_irqsave(&priv->driver_lock, flags);
 	memcpy(priv->cmd_resp_buff, recvbuff + MESSAGE_HEADER_LEN,
 	       recvlength - MESSAGE_HEADER_LEN);
 	kfree_skb(skb);
 	lbtf_cmd_response_rx(priv);
-	spin_unlock(&priv->driver_lock);
+	spin_unlock_irqrestore(&priv->driver_lock, flags);
 }
 
 /**
-- 
1.7.9.5
