From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Fix a race condition in sky2_poll
Date: Sat, 20 Jun 2009 17:01:25 +0900
Message-ID: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:49251 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbZFTIBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 04:01:23 -0400
Received: by bwz9 with SMTP id 9so2153861bwz.37
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 01:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear interrupt only when the status buffer is fully drained,
Make sure to clear interrupt when work_done == work_limit
 and the buffer is drained.
---
 drivers/net/sky2.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7681d28..ca1e9e5 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2524,9 +2524,6 @@ static int sky2_status_intr(struct sky2_hw *hw,
int to_do, u16 idx)
 		}
 	} while (hw->st_idx != idx);

-	/* Fully processed status ring so clear irq */
-	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-
 exit_loop:
 	sky2_rx_done(hw, 0, total_packets[0], total_bytes[0]);
 	sky2_rx_done(hw, 1, total_packets[1], total_bytes[1]);
@@ -2779,9 +2776,16 @@ static int sky2_poll(struct napi_struct *napi,
int work_limit)
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);

-	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
+	idx = sky2_read16(hw, STAT_PUT_IDX);
+	while (idx != hw->st_idx) {
 		work_done += sky2_status_intr(hw, work_limit - work_done, idx);

+		/* If we fully processed the status ring, clear the irq */
+		idx = sky2_read16(hw, STAT_PUT_IDX);
+		if (idx == hw->st_idx) {
+			sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+			break;
+		}
 		if (work_done >= work_limit)
 			goto done;
 	}
-- 
1.5.6.5
