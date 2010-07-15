From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 5/8] drivers: ixgbevf: fix unsigned underflow
Date: Thu, 15 Jul 2010 22:45:57 +0400
Message-ID: <1279219557-12525-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44479 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934243Ab0GOSq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:46:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'count' is unsigned. It is initialized to zero, then it can be increased
multiple times, and finally it is used in such a way:

   >>>> count--;
   |
   |    /* clear timestamp and dma mappings for remaining portion of packet */
   |    while (count >= 0) {
   |            count--;
   |            ...
   ^
If count is zero here (so, it was never increased), we would have a very
long loop :)

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 73f1e75..af49135 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2935,7 +2935,8 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
-	unsigned int offset = 0, size, count = 0;
+	unsigned int offset = 0, size;
+	int count = 0;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
 	int i;
-- 
1.7.0.4

