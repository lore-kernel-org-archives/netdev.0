From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/5] tg3: Fix std rx prod ring handling
Date: Tue, 12 Jan 2010 12:11:37 -0800
Message-ID: <1263327100-13554-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab0ALUMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 15:12:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some tg3 devices that require the driver to post new rx
buffers in smaller increments.  Commit
4361935afe3abc3e5a93006b99197fac1fabbd50, "tg3: Consider
rx_std_prod_idx a hw mailbox" changed how the driver tracks the rx
producer ring updates, but it does not make any special considerations
for the above-mentioned devices.  For those devices, it is possible for
the driver to hit the special case path, which updates the hardware
mailbox register but skips updating the shadow software mailbox member.
If the special case path represents the final mailbox update for this
ISR iteration, the hardware and software mailbox values will be out of
sync.  Ultimately, this will cause the driver to use a stale mailbox
value on the next iteration, which will appear to the hardware as a
large rx buffer update.  Bad things ensue.

The fix is to update the software shadow mailbox member when the special
case path is taken.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reported-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/net/tg3.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5c77e6a..4e8b87d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4693,8 +4693,9 @@ next_pkt:
 		(*post_ptr)++;
 
 		if (unlikely(rx_std_posted >= tp->rx_std_max_post)) {
-			u32 idx = *post_ptr % TG3_RX_RING_SIZE;
-			tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, idx);
+			tpr->rx_std_prod_idx = std_prod_idx % TG3_RX_RING_SIZE;
+			tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG,
+				     tpr->rx_std_prod_idx);
 			work_mask &= ~RXD_OPAQUE_RING_STD;
 			rx_std_posted = 0;
 		}
-- 
1.6.4.4


