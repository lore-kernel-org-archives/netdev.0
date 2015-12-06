From: Peter Wu <peter@lekensteyn.nl>
Subject: [PATCH] rtlwifi: fix gigantic memleak in rtl_usb
Date: Sun,  6 Dec 2015 18:57:57 +0100
Message-ID: <1449424677-3140-1-git-send-email-peter@lekensteyn.nl>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lekensteyn.nl ([178.21.112.251]:49180 "EHLO lekensteyn.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbbLFR6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 12:58:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free skb for received frames with a wrong checksum.

While using the rtl8192cu driver in monitor mode, somehow 5G of memory
was permanently lost (observable via the Available column in `free -m`).

Test scenario:

    ip link set down wlan1
    iw wlan1 set type monitor
    ip link set up wlan1
    iw wlan1 set channel 11

Then stream a video on a smartphone on channel 11. Without this patch
the memory usage grows linearly with the number of received packets:

    grep MemAvailable /proc/meminfo
    ip -s link show dev wlan1

Signed-off-by: Peter Wu <peter@lekensteyn.nl>
---
Hi,

This issue has existed since the introduction of this driver in v2.6.x,
using kmemleak I was about to figure out the source. There is also a
_rtl_usb_rx_process_agg that has similarly looking code, but that one is
unaffected. The pci code already frees the skb and is unaffected too.

Tested with kernel v4.3, this patch is simply rebased on v4.4-rc3 (due
to changed paths).

Kind regards,
Peter
---
 drivers/net/wireless/realtek/rtlwifi/usb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
index 2721cf8..aac1ed3 100644
--- a/drivers/net/wireless/realtek/rtlwifi/usb.c
+++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
@@ -531,6 +531,8 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 			ieee80211_rx(hw, skb);
 		else
 			dev_kfree_skb_any(skb);
+	} else {
+		dev_kfree_skb_any(skb);
 	}
 }
 
-- 
2.6.3
