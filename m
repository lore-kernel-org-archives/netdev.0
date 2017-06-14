From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 03/11] tty: kbd: reduce stack size with KASAN
Date: Wed, 14 Jun 2017 23:15:38 +0200
Message-ID: <20170614211556.2062728-4-arnd@arndb.de>
References: <20170614211556.2062728-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As reported by kernelci, some functions in the VT code use significant
amounts of kernel stack when local variables get inlined into the caller
multiple times:

drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

Annotating those functions as noinline_if_stackbloat prevents the inlining
and reduces the overall stack usage in this driver.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/tty/vt/keyboard.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/vt/keyboard.c b/drivers/tty/vt/keyboard.c
index f4166263bb3a..c0d111444a0e 100644
--- a/drivers/tty/vt/keyboard.c
+++ b/drivers/tty/vt/keyboard.c
@@ -301,13 +301,13 @@ int kbd_rate(struct kbd_repeat *rpt)
 /*
  * Helper Functions.
  */
-static void put_queue(struct vc_data *vc, int ch)
+static noinline_if_stackbloat void put_queue(struct vc_data *vc, int ch)
 {
 	tty_insert_flip_char(&vc->port, ch, 0);
 	tty_schedule_flip(&vc->port);
 }
 
-static void puts_queue(struct vc_data *vc, char *cp)
+static noinline_if_stackbloat void puts_queue(struct vc_data *vc, char *cp)
 {
 	while (*cp) {
 		tty_insert_flip_char(&vc->port, *cp, 0);
@@ -555,7 +555,7 @@ static void fn_inc_console(struct vc_data *vc)
 	set_console(i);
 }
 
-static void fn_send_intr(struct vc_data *vc)
+static noinline_if_stackbloat void fn_send_intr(struct vc_data *vc)
 {
 	tty_insert_flip_char(&vc->port, 0, TTY_BREAK);
 	tty_schedule_flip(&vc->port);
-- 
2.9.0
