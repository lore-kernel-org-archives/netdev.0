From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 3/3] nfc: trf7970a: Prevent repeated polling from crashing the kernel
Date: Tue, 20 Dec 2016 11:16:32 -0500
Message-ID: <1482250592-4268-3-git-send-email-glansberry@gmail.com>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Jaret Cantu <jaret.cantu@timesys.com>,
        Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:35219 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757561AbcLTQQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 11:16:45 -0500
Received: by mail-qt0-f177.google.com with SMTP id c47so181136026qtc.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 08:16:44 -0800 (PST)
In-Reply-To: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaret Cantu <jaret.cantu@timesys.com>

Repeated polling attempts cause a NULL dereference error to occur.
This is because the state of the trf7970a is currently reading but
another request has been made to send a command before it has finished.

The solution is to properly kill the waiting reading (workqueue)
before failing on the send.
---
 drivers/nfc/trf7970a.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index 8a88195..5916737 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -1496,6 +1496,10 @@ static int trf7970a_send_cmd(struct nfc_digital_dev *ddev,
 			(trf->state != TRF7970A_ST_IDLE_RX_BLOCKED)) {
 		dev_err(trf->dev, "%s - Bogus state: %d\n", __func__,
 				trf->state);
+		if (trf->state == TRF7970A_ST_WAIT_FOR_RX_DATA ||
+		    trf->state == TRF7970A_ST_WAIT_FOR_RX_DATA_CONT)
+			trf->ignore_timeout =
+				!cancel_delayed_work(&trf->timeout_work);
 		ret = -EIO;
 		goto out_err;
 	}
-- 
Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
