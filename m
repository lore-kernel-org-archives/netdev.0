From: Ryder Lee <ryder.lee@mediatek.com>
Subject: [PATCH net-next v2] macsec: fix validation failed in asynchronous operation.
Date: Tue, 21 Feb 2017 17:40:45 +0800
Message-ID: <1487670045-54641-1-git-send-email-ryder.lee@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
        Ryder Lee <ryder.lee@mediatek.com>
To: "David S. Miller" <davem@davemloft.net>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:32647 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751069AbdBUJky (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 04:40:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MACSec test failed when asynchronous crypto operations is used. It
encounters packet validation failed since macsec_skb_cb(skb)->valid
is always 'false'.

This patch adds missing "macsec_skb_cb(skb)->valid = true" in
macsec_decrypt_done() when "err == 0".

Signed-off-by: Ryder Lee <ryder.lee@mediatek.com>
---
Changes since v2:
- fix indentation and replace "err == 0" with "!err".
Changes since v1:
- add "err == 0" to check decrypt status.

 drivers/net/macsec.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index f83cf66..899853a 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -879,6 +879,9 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 
 	aead_request_free(macsec_skb_cb(skb)->req);
 
+	if (!err)
+		macsec_skb_cb(skb)->valid = true;
+
 	rcu_read_lock_bh();
 	pn = ntohl(macsec_ethhdr(skb)->packet_number);
 	if (!macsec_post_decrypt(skb, &macsec->secy, pn)) {
-- 
1.9.1
