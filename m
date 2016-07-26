From: Beniamino Galvani <bgalvani@redhat.com>
Subject: [PATCH] macsec: ensure rx_sa is set when validation is disabled
Date: Tue, 26 Jul 2016 12:24:53 +0200
Message-ID: <1469528693-6578-1-git-send-email-bgalvani@redhat.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbcGZKZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 06:25:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macsec_decrypt() is not called when validation is disabled and so
macsec_skb_cb(skb)->rx_sa is not set; but it is used later in
macsec_post_decrypt(), ensure that it's always initialized.

Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>
---
 drivers/net/macsec.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 8bcd78f..a70b6c4 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -942,7 +942,6 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	}
 
 	macsec_skb_cb(skb)->req = req;
-	macsec_skb_cb(skb)->rx_sa = rx_sa;
 	skb->dev = dev;
 	aead_request_set_callback(req, 0, macsec_decrypt_done, skb);
 
@@ -1169,6 +1168,8 @@ static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
 		}
 	}
 
+	macsec_skb_cb(skb)->rx_sa = rx_sa;
+
 	/* Disabled && !changed text => skip validation */
 	if (hdr->tci_an & MACSEC_TCI_C ||
 	    secy->validate_frames != MACSEC_VALIDATE_DISABLED)
-- 
2.5.5
