From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Sat, 24 Dec 2016 17:52:57 +0100
Message-ID: <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482598381-16513-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

NVS calibration data for wl1251 are model specific. Every one device with
wl1251 chip has different and calibrated in factory.

Not all wl1251 chips have own EEPROM where are calibration data stored. And
in that case there is no "standard" place. Every device has stored them on
different place (some in rootfs file, some in dedicated nand partition,
some in another proprietary structure).

Kernel wl1251 driver cannot support every one different storage decided by
device manufacture so it will use request_firmware_prefer_user() call for
loading NVS calibration data and userspace helper will be responsible to
prepare correct data.

In case userspace helper fails request_firmware_prefer_user() still try to
load data file directly from VFS as fallback mechanism.

On Nokia N900 device which has wl1251 chip, NVS calibration data are stored
in CAL nand partition. CAL is proprietary Nokia key/value format for nand
devices.

With this patch it is finally possible to load correct model specific NVS
calibration data for Nokia N900.

Signed-off-by: Pali Rohár <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/Kconfig |    1 +
 drivers/net/wireless/ti/wl1251/main.c  |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl1251/Kconfig b/drivers/net/wireless/ti/wl1251/Kconfig
index 7142ccf..affe154 100644
--- a/drivers/net/wireless/ti/wl1251/Kconfig
+++ b/drivers/net/wireless/ti/wl1251/Kconfig
@@ -2,6 +2,7 @@ config WL1251
 	tristate "TI wl1251 driver support"
 	depends on MAC80211
 	select FW_LOADER
+	select FW_LOADER_USER_HELPER
 	select CRC7
 	---help---
 	  This will enable TI wl1251 driver support. The drivers make
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 208f062..24f8866 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -110,7 +110,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
 	struct device *dev = wiphy_dev(wl->hw->wiphy);
 	int ret;
 
-	ret = request_firmware(&fw, WL1251_NVS_NAME, dev);
+	ret = request_firmware_prefer_user(&fw, WL1251_NVS_NAME, dev);
 
 	if (ret < 0) {
 		wl1251_error("could not get nvs file: %d", ret);
-- 
1.7.9.5
