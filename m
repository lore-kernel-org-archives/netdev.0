From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 3/3] nfc: trf7970a: Prevent repeated polling from crashing the kernel
Date: Thu, 15 Dec 2016 17:30:44 -0500
Message-ID: <1481841044-4314-3-git-send-email-glansberry@gmail.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Jaret Cantu <jaret.cantu@timesys.com>,
        Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaret Cantu <jaret.cantu@timesys.com>

Repeated polling attempts cause a NULL dereference error to occur.
This is because the curent state of the trf7970a is reading but
a request has been made to send a command.

The solution is to properly kill the waiting reading (workqueue)
before failing on the send.
---
 drivers/nfc/trf7970a.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index b4c37ab..f96a321 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -1493,6 +1493,10 @@ static int trf7970a_send_cmd(struct nfc_digital_dev *ddev,
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
