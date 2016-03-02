From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 2/7] bnx2x: fix sending VF->PF messages on big-endian
Date: Wed,  2 Mar 2016 13:47:06 +0100
Message-ID: <1456922831-15071-3-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:20 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VF is sending a message to the PF, it needs to trigger the PF
to tell it the message is ready.
The trigger did not work on ppc64. No interrupt appeared in the PF.

The bug is due to confusion about the layout of struct trigger_vf_zone.
In bnx2x_send_msg2pf() the trigger is written using writeb(), not
writel(), so the attempt to define the struct with a reversed layout on
big-endian is counter-productive.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 90a4dba..47b13ed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -5114,15 +5114,9 @@ struct vf_pf_channel_zone_trigger {
  * zone that triggers the in-bound interrupt
  */
 struct trigger_vf_zone {
-#if defined(__BIG_ENDIAN)
-	u16 reserved1;
-	u8 reserved0;
-	struct vf_pf_channel_zone_trigger vf_pf_channel;
-#elif defined(__LITTLE_ENDIAN)
 	struct vf_pf_channel_zone_trigger vf_pf_channel;
 	u8 reserved0;
 	u16 reserved1;
-#endif
 	u32 reserved2;
 };
 
-- 
2.5.0
