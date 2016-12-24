From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Sat, 24 Dec 2016 17:53:01 +0100
Message-ID: <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org,
        =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
To: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:35755 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755530AbcLXRCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2016 12:02:20 -0500
In-Reply-To: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case there is no valid MAC address kernel generates random one. This
patch propagate this generated MAC address back to NVS data which will be
uploaded to wl1251 chip. So HW would have same MAC address as linux kernel
uses.

Signed-off-by: Pali Rohár <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 1454ba2..895ae05 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1555,6 +1555,24 @@ static int wl1251_read_nvs_mac(struct wl1251 *wl)
 	return 0;
 }
 
+static int wl1251_write_nvs_mac(struct wl1251 *wl)
+{
+	int i;
+
+	if (wl->nvs_len < 0x24)
+		return -ENODATA;
+
+	/* length is 2 and data address is 0x546c (mask is 0xfffe) */
+	if (wl->nvs[0x19] != 2 || wl->nvs[0x1a] != 0x6d || wl->nvs[0x1b] != 0x54)
+		return -EINVAL;
+
+	/* MAC is stored in reverse order */
+	for (i = 0; i < ETH_ALEN; i++)
+		wl->nvs[0x1c + i] = wl->mac_addr[ETH_ALEN - i - 1];
+
+	return 0;
+}
+
 static int wl1251_register_hw(struct wl1251 *wl)
 {
 	int ret;
@@ -1620,6 +1638,8 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
 		static const u8 nokia_oui[3] = {0x00, 0x1f, 0xdf};
 		memcpy(wl->mac_addr, nokia_oui, 3);
 		get_random_bytes(wl->mac_addr + 3, 3);
+		if (!wl->use_eeprom)
+			wl1251_write_nvs_mac(wl);
 		wl1251_warning("MAC address in eeprom or nvs data is not valid");
 		wl1251_warning("Setting random MAC address: %pM", wl->mac_addr);
 	}
-- 
1.7.9.5
