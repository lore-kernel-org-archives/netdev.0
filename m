From: Mathy Vanhoef <vanhoefm@gmail.com>
Subject: [PATCH] brcmfmac: kill URB when request timed out
Date: Wed, 12 Nov 2014 21:33:34 -0500
Message-ID: <5464187E.5060208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: brudley@broadcom.com, arend@broadcom.com, frankyl@broadcom.com,
	meuleman@broadcom.com, John Linville <linville@tuxdriver.com>,
	pieterpg@broadcom.com, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kill the submitted URB in brcmf_usb_dl_cmd if the request timed out. This
assures the URB is never submitted twice. It also prevents a possible
use-after-free of the URB transfer buffer if a timeout occurs.

Signed-off-by: Mathy Vanhoef <vanhoefm@gmail.com>
---
For a discussion about this patch and the underlying problem, see the mails
with as subject "[PATCH] brcmfmac: unlink URB when request timed out".

 drivers/net/wireless/brcm80211/brcmfmac/usb.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
index 5265aa7..4572def 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -738,10 +738,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
 		goto finalize;
 	}
 
-	if (!brcmf_usb_ioctl_resp_wait(devinfo))
+	if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
+		usb_kill_urb(devinfo->ctl_urb);
 		ret = -ETIMEDOUT;
-	else
+	} else {
 		memcpy(buffer, tmpbuf, buflen);
+	}
 
 finalize:
 	kfree(tmpbuf);
-- 
1.7.10.4
