From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/9] bnxt_en: Improve the delay logic for firmware response.
Date: Sat, 14 May 2016 20:29:44 -0400
Message-ID: <1463272188-30025-6-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35761 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003AbcEOAaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:03 -0400
Received: by mail-pf0-f170.google.com with SMTP id 77so54527293pfv.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:03 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code has 2 problems:

1. The maximum wait time is not long enough.  It is about 60% of the
duration specified by the firmware.  It is calling usleep_range(600, 800)
for every 1 msec we are supposed to wait.

2. The granularity of the delay is too coarse.  Many simple firmware
commands finish in 25 usec or less.

We fix these 2 issues by multiplying the original 1 msec loop counter by
40 and calling usleep_range(25, 40) for each iteration.

There is also a second delay loop to wait for the last DMA word to
complete.  This delay loop should be a very short 5 usec wait.

This change results in much faster bring-up/down time:

Before the patch:

time ip link set p4p1 up

real    0m0.120s
user    0m0.001s
sys     0m0.009s

After the patch:

time ip link set p4p1 up

real    0m0.030s
user    0m0.000s
sys     0m0.010s

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ba0c3e5..d33b20f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2718,7 +2718,7 @@ void bnxt_hwrm_cmd_hdr_init(struct bnxt *bp, void *request, u16 req_type,
 static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 				 int timeout, bool silent)
 {
-	int i, intr_process, rc;
+	int i, intr_process, rc, tmo_count;
 	struct input *req = msg;
 	u32 *data = msg;
 	__le32 *resp_len, *valid;
@@ -2747,11 +2747,12 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 		timeout = DFLT_HWRM_CMD_TIMEOUT;
 
 	i = 0;
+	tmo_count = timeout * 40;
 	if (intr_process) {
 		/* Wait until hwrm response cmpl interrupt is processed */
 		while (bp->hwrm_intr_seq_id != HWRM_SEQ_ID_INVALID &&
-		       i++ < timeout) {
-			usleep_range(600, 800);
+		       i++ < tmo_count) {
+			usleep_range(25, 40);
 		}
 
 		if (bp->hwrm_intr_seq_id != HWRM_SEQ_ID_INVALID) {
@@ -2762,15 +2763,15 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 	} else {
 		/* Check if response len is updated */
 		resp_len = bp->hwrm_cmd_resp_addr + HWRM_RESP_LEN_OFFSET;
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < tmo_count; i++) {
 			len = (le32_to_cpu(*resp_len) & HWRM_RESP_LEN_MASK) >>
 			      HWRM_RESP_LEN_SFT;
 			if (len)
 				break;
-			usleep_range(600, 800);
+			usleep_range(25, 40);
 		}
 
-		if (i >= timeout) {
+		if (i >= tmo_count) {
 			netdev_err(bp->dev, "Error (timeout: %d) msg {0x%x 0x%x} len:%d\n",
 				   timeout, le16_to_cpu(req->req_type),
 				   le16_to_cpu(req->seq_id), *resp_len);
@@ -2779,13 +2780,13 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 
 		/* Last word of resp contains valid bit */
 		valid = bp->hwrm_cmd_resp_addr + len - 4;
-		for (i = 0; i < timeout; i++) {
+		for (i = 0; i < 5; i++) {
 			if (le32_to_cpu(*valid) & HWRM_RESP_VALID_MASK)
 				break;
-			usleep_range(600, 800);
+			udelay(1);
 		}
 
-		if (i >= timeout) {
+		if (i >= 5) {
 			netdev_err(bp->dev, "Error (timeout: %d) msg {0x%x 0x%x} len:%d v:%d\n",
 				   timeout, le16_to_cpu(req->req_type),
 				   le16_to_cpu(req->seq_id), len, *valid);
-- 
1.8.3.1
