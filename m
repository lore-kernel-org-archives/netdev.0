From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net] bnxt_en: Fix TX push operation on ARM64.
Date: Mon,  5 Sep 2016 01:57:35 -0400
Message-ID: <1473055055-28605-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34455 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752861AbcIEF5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 01:57:42 -0400
Received: by mail-pa0-f54.google.com with SMTP id to9so20440562pac.1
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 22:57:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a code path where we are calling __iowrite64_copy() on
an address that is not 64-bit aligned.  This causes an exception on
some architectures such as arm64.  Fix that code path by using
__iowrite32_copy().

Reported-by: JD Zheng <jiandong.zheng@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---

Please consider this for stable as well.  Thanks.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2cf7910..228c964 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -353,8 +353,8 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		push_len = (length + sizeof(*tx_push) + 7) / 8;
 		if (push_len > 16) {
 			__iowrite64_copy(txr->tx_doorbell, tx_push_buf, 16);
-			__iowrite64_copy(txr->tx_doorbell + 4, tx_push_buf + 1,
-					 push_len - 16);
+			__iowrite32_copy(txr->tx_doorbell + 4, tx_push_buf + 1,
+					 (push_len - 16) << 1);
 		} else {
 			__iowrite64_copy(txr->tx_doorbell, tx_push_buf,
 					 push_len);
-- 
1.8.3.1
