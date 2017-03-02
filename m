From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 04/26] tty: kbd: reduce stack size with KASAN
Date: Thu,  2 Mar 2017 17:38:12 +0100
Message-ID: <20170302163834.2273519-5-arnd@arndb.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As reported by kernelci, some functions in the VT code use significant
amounts of kernel stack when local variables get inlined into the caller
multiple times:

drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

Annotating those functions as noinline_for_kasan prevents the inlining
and reduces the overall stack usage in this driver.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/tty/vt/keyboard.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
index 397e1509fe51..f8a183c1639f 100644
--- a/drivers/tty/vt/keyboard.c
+++ b/drivers/tty/vt/keyboard.c
@@ -300,13 +300,13 @@ int kbd_rate(struct kbd_repeat *rpt)
 /*
  * Helper Functions.
  */
-static void put_queue(struct vc_data *vc, int ch)
+static noinline_for_kasan void put_queue(struct vc_data *vc, int ch)
 {
 	tty_insert_flip_char(&vc->port, ch, 0);
 	tty_schedule_flip(&vc->port);
 }
 
-static void puts_queue(struct vc_data *vc, char *cp)
+static noinline_for_kasan void puts_queue(struct vc_data *vc, char *cp)
 {
 	while (*cp) {
 		tty_insert_flip_char(&vc->port, *cp, 0);
@@ -554,7 +554,7 @@ static void fn_inc_console(struct vc_data *vc)
 	set_console(i);
 }
 
-static void fn_send_intr(struct vc_data *vc)
+static noinline_for_kasan void fn_send_intr(struct vc_data *vc)
 {
 	tty_insert_flip_char(&vc->port, 0, TTY_BREAK);
 	tty_schedule_flip(&vc->port);
-- 
2.9.0
