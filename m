From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/15] igb: fix a few items where weren't
	correctly setup for mbx timeout
Date: Mon, 05 Oct 2009 09:34:05 -0700
Message-ID: <20091005163404.32487.88572.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:60603
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753957AbZJEQgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:36:16 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The mailbox timeout routines need to be updated as they were not correctly
handling the case of a mailbox timeout and could cause issues with long
delays when used.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mbx.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index ef645f6..c474cdb 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -143,12 +143,16 @@ static s32 igb_poll_for_msg(struct e1000_hw *hw, u16 mbx_id)
 	if (!countdown || !mbx->ops.check_for_msg)
 		goto out;
 
-	while (mbx->ops.check_for_msg(hw, mbx_id)) {
+	while (countdown && mbx->ops.check_for_msg(hw, mbx_id)) {
 		countdown--;
 		if (!countdown)
 			break;
 		udelay(mbx->usec_delay);
 	}
+
+	/* if we failed, all future posted messages fail until reset */
+	if (!countdown)
+		mbx->timeout = 0;
 out:
 	return countdown ? 0 : -E1000_ERR_MBX;
 }
@@ -168,12 +172,16 @@ static s32 igb_poll_for_ack(struct e1000_hw *hw, u16 mbx_id)
 	if (!countdown || !mbx->ops.check_for_ack)
 		goto out;
 
-	while (mbx->ops.check_for_ack(hw, mbx_id)) {
+	while (countdown && mbx->ops.check_for_ack(hw, mbx_id)) {
 		countdown--;
 		if (!countdown)
 			break;
 		udelay(mbx->usec_delay);
 	}
+
+	/* if we failed, all future posted messages fail until reset */
+	if (!countdown)
+		mbx->timeout = 0;
 out:
 	return countdown ? 0 : -E1000_ERR_MBX;
 }
@@ -217,12 +225,13 @@ out:
 static s32 igb_write_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
-	s32 ret_val = 0;
+	s32 ret_val = -E1000_ERR_MBX;
 
-	if (!mbx->ops.write)
+	/* exit if either we can't write or there isn't a defined timeout */
+	if (!mbx->ops.write || !mbx->timeout)
 		goto out;
 
-	/* send msg*/
+	/* send msg */
 	ret_val = mbx->ops.write(hw, msg, size, mbx_id);
 
 	/* if msg sent wait until we receive an ack */

