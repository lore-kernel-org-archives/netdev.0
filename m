From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 13/26] rtl8180: reduce stack size for KASAN
Date: Thu,  2 Mar 2017 17:38:21 +0100
Message-ID: <20170302163834.2273519-14-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
To: kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170302163834.2273519-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When CONFIG_KASAN is set, we see overly large stack frames from inlining
functions with local variables:

drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c: In function 'rtl8225se_rf_init':
drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c:431:1: warning: the frame size of 4384 bytes is larger than 3072 bytes [-Wframe-larger-than=]

This marks them noinline_for_kasan.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c b/drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c
index fde89866fa8d..1efa098a2e32 100644
--- a/drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c
+++ b/drivers/net/wireless/realtek/rtl818x/rtl8180/rtl8225se.c
@@ -174,14 +174,14 @@ static void rtl8187se_three_wire_io(struct ieee80211_hw *dev, u8 *data,
 	} while (0);
 }
 
-static u32 rtl8187se_rf_readreg(struct ieee80211_hw *dev, u8 addr)
+static noinline_for_kasan u32 rtl8187se_rf_readreg(struct ieee80211_hw *dev, u8 addr)
 {
 	u32 dataread = addr & 0x0F;
 	rtl8187se_three_wire_io(dev, (u8 *)&dataread, 16, 0);
 	return dataread;
 }
 
-static void rtl8187se_rf_writereg(struct ieee80211_hw *dev, u8 addr, u32 data)
+static noinline_for_kasan void rtl8187se_rf_writereg(struct ieee80211_hw *dev, u8 addr, u32 data)
 {
 	u32 outdata = (data << 4) | (u32)(addr & 0x0F);
 	rtl8187se_three_wire_io(dev, (u8 *)&outdata, 16, 1);
-- 
2.9.0
