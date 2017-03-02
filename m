From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 12/26] wl3501_cs: reduce stack size for KASAN
Date: Thu,  2 Mar 2017 17:38:20 +0100
Message-ID: <20170302163834.2273519-13-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inlining functions with local variables can lead to excessive stack usage
with KASAN:

drivers/net/wireless/wl3501_cs.c: In function 'wl3501_rx_interrupt':
drivers/net/wireless/wl3501_cs.c:1103:1: error: the frame size of 2232 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]

Marking a few functions as noinline_for_kasan avoids the problem

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/wl3501_cs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index acec0d9ec422..15dd8e31d373 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -242,8 +242,8 @@ static int wl3501_get_flash_mac_addr(struct wl3501_card *this)
  *
  * Move 'size' bytes from PC to card. (Shouldn't be interrupted)
  */
-static void wl3501_set_to_wla(struct wl3501_card *this, u16 dest, void *src,
-			      int size)
+static noinline_for_kasan void wl3501_set_to_wla(struct wl3501_card *this,
+						 u16 dest, void *src, int size)
 {
 	/* switch to SRAM Page 0 */
 	wl3501_switch_page(this, (dest & 0x8000) ? WL3501_BSS_SPAGE1 :
@@ -264,8 +264,8 @@ static void wl3501_set_to_wla(struct wl3501_card *this, u16 dest, void *src,
  *
  * Move 'size' bytes from card to PC. (Shouldn't be interrupted)
  */
-static void wl3501_get_from_wla(struct wl3501_card *this, u16 src, void *dest,
-				int size)
+static noinline_for_kasan void wl3501_get_from_wla(struct wl3501_card *this,
+						u16 src, void *dest, int size)
 {
 	/* switch to SRAM Page 0 */
 	wl3501_switch_page(this, (src & 0x8000) ? WL3501_BSS_SPAGE1 :
@@ -1037,7 +1037,7 @@ static inline void wl3501_auth_confirm_interrupt(struct wl3501_card *this,
 		wl3501_mgmt_resync(this);
 }
 
-static inline void wl3501_rx_interrupt(struct net_device *dev)
+static noinline_for_kasan void wl3501_rx_interrupt(struct net_device *dev)
 {
 	int morepkts;
 	u16 addr;
-- 
2.9.0
