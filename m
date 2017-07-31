From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V5 2/2] brcmfmac: don't warn user about NVRAM if fallback to the platform one succeeds
Date: Mon, 31 Jul 2017 17:09:45 +0200
Message-ID: <20170731150945.8925-2-zajec5@gmail.com>
References: <20170731150945.8925-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Daniel Wagner <wagi@monom.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>, yi1.li@linux.intel.com,
        atull@kernel.org, Moritz Fischer <moritz.fischer@ettus.com>,
        pmladek@suse.com, Johannes Berg <johannes.berg@intel.com>,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        Kalle Valo <kvalo@codeaurora.org>, luto@kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Howells <dhowells@redhat.com>, pjones@redhat.com,
        Hans de Goede <hdegoede@redhat.com>, alan@linux.intel.com,
        tytso@mit.edu, lkml <linux-kernel@vger.kernel.org>,
        Franky Lin <franky.li
To: "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35137 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752291AbdGaPLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 11:11:24 -0400
In-Reply-To: <20170731150945.8925-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

Failing to load NVRAM *file* isn't critical if we manage to get platform
NVRAM in the fallback path. It means warnings like:
[   10.801506] brcmfmac 0000:01:00.0: Direct firmware load for brcm/brcmfmac43602-pcie.txt failed with error -2
are unnecessary & disturbing for people with *platform* NVRAM as they
are not expected to have NVRAM file. This is a very common case for
Broadcom home routers.

Instead of printing warning immediately within the firmware subsystem
let's try our fallback code first. If that fails as well, then it's a
right moment to print an error.

This should reduce amount of false reports from users seeing this
warning while having wireless working perfectly fine with the platform
NVRAM.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V2: Update commit message as it wasn't clear enough (thanks Andy) & add extra
    messages to the firmware.c.
V3: Set FW_OPT_UEVENT to don't change behavior
V4: Switch to the new request_firmware_async syntax
V5: Rebase, update commit message, resend after drvdata discussion
---
 .../wireless/broadcom/brcm80211/brcmfmac/firmware.c    | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
index d231042f19d6..524442b3870f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c
@@ -462,8 +462,14 @@ static void brcmf_fw_request_nvram_done(const struct firmware *fw, void *ctx)
 		raw_nvram = false;
 	} else {
 		data = bcm47xx_nvram_get_contents(&data_len);
-		if (!data && !(fwctx->flags & BRCMF_FW_REQ_NV_OPTIONAL))
-			goto fail;
+		if (!data) {
+			brcmf_dbg(TRACE, "Failed to get platform NVRAM\n");
+			if (!(fwctx->flags & BRCMF_FW_REQ_NV_OPTIONAL)) {
+				brcmf_err("Loading NVRAM from %s and using platform one both failed\n",
+					  fwctx->nvram_name);
+				goto fail;
+			}
+		}
 		raw_nvram = true;
 	}
 
@@ -491,6 +497,9 @@ static void brcmf_fw_request_nvram_done(const struct firmware *fw, void *ctx)
 static void brcmf_fw_request_code_done(const struct firmware *fw, void *ctx)
 {
 	struct brcmf_fw *fwctx = ctx;
+	struct firmware_opts fw_opts = {
+		.optional = true,
+	};
 	int ret = 0;
 
 	brcmf_dbg(TRACE, "enter: dev=%s\n", dev_name(fwctx->dev));
@@ -503,9 +512,8 @@ static void brcmf_fw_request_code_done(const struct firmware *fw, void *ctx)
 		goto done;
 
 	fwctx->code = fw;
-	ret = request_firmware_nowait(THIS_MODULE, true, fwctx->nvram_name,
-				      fwctx->dev, GFP_KERNEL, fwctx,
-				      brcmf_fw_request_nvram_done);
+	ret = request_firmware_async(fwctx->nvram_name, &fw_opts, fwctx->dev,
+				     fwctx, brcmf_fw_request_nvram_done);
 
 	/* pass NULL to nvram callback for bcm47xx fallback */
 	if (ret)
-- 
2.11.0
