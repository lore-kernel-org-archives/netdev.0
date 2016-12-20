From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] nfc: trf7970a: Prevent repeated polling from crashing the kernel
Date: Tue, 20 Dec 2016 11:10:49 -0500
Message-ID: <1482250250-4192-6-git-send-email-glansberry@gmail.com>
References: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org, Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>,
        Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482250250-4192-1-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>

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
Signed-off-by: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
