From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 13/31] timer: Remove meaningless .data/.function assignments
Date: Wed, 20 Sep 2017 16:27:37 -0700
Message-ID: <1505950075-50223-14-git-send-email-keescook@chromium.org>
References: <1505950075-50223-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Kees Cook <keescook@chromium.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 Jens Axboe <axboe@fb.com>, Ganesh Krishna <ganesh.krishna@microchip.com>,
 netdev@vger.kernel.org, Aditya Shankar <aditya.shankar@microchip.com>,
 Krzysztof Halasa <khc@pm.waw.pl>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1505950075-50223-1-git-send-email-keescook@chromium.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Several timer users needlessly reset their .function/.data fields during
their timer callback, but nothing else changes them. Some users do not
use their .data field at all. Each instance is removed here.

Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: Aditya Shankar <aditya.shankar@microchip.com>
Cc: Ganesh Krishna <ganesh.krishna@microchip.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jens Axboe <axboe@fb.com>
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: devel@driverdev.osuosl.org
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org> # for staging
Acked-by: Krzysztof Halasa <khc@pm.waw.pl> # for wan/hdlc*
Acked-by: Jens Axboe <axboe@kernel.dk> # for amiflop
---
 drivers/block/amiflop.c                           | 3 +--
 drivers/net/wan/hdlc_cisco.c                      | 2 --
 drivers/net/wan/hdlc_fr.c                         | 2 --
 drivers/staging/wilc1000/wilc_wfi_cfgoperations.c | 4 +---
 4 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/block/amiflop.c b/drivers/block/amiflop.c
index c4b1cba27178..6680d75bc857 100644
--- a/drivers/block/amiflop.c
+++ b/drivers/block/amiflop.c
@@ -323,7 +323,7 @@ static void fd_deselect (int drive)
 
 }
 
-static void motor_on_callback(unsigned long nr)
+static void motor_on_callback(unsigned long ignored)
 {
 	if (!(ciaa.pra & DSKRDY) || --on_attempts == 0) {
 		complete_all(&motor_on_completion);
@@ -344,7 +344,6 @@ static int fd_motor_on(int nr)
 		fd_select(nr);
 
 		reinit_completion(&motor_on_completion);
-		motor_on_timer.data = nr;
 		mod_timer(&motor_on_timer, jiffies + HZ/2);
 
 		on_attempts = 10;
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index c696d42f4502..6c98d85f2773 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -276,8 +276,6 @@ static void cisco_timer(unsigned long arg)
 	spin_unlock(&st->lock);
 
 	st->timer.expires = jiffies + st->settings.interval * HZ;
-	st->timer.function = cisco_timer;
-	st->timer.data = arg;
 	add_timer(&st->timer);
 }
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index de42faca076a..7da2424c28a4 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -644,8 +644,6 @@ static void fr_timer(unsigned long arg)
 			state(hdlc)->settings.t391 * HZ;
 	}
 
-	state(hdlc)->timer.function = fr_timer;
-	state(hdlc)->timer.data = arg;
 	add_timer(&state(hdlc)->timer);
 }
 
diff --git a/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c b/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c
index ac5aaafa461c..60f088babf27 100644
--- a/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c
+++ b/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c
@@ -266,7 +266,7 @@ static void update_scan_time(void)
 		last_scanned_shadow[i].time_scan = jiffies;
 }
 
-static void remove_network_from_shadow(unsigned long arg)
+static void remove_network_from_shadow(unsigned long unused)
 {
 	unsigned long now = jiffies;
 	int i, j;
@@ -287,7 +287,6 @@ static void remove_network_from_shadow(unsigned long arg)
 	}
 
 	if (last_scanned_cnt != 0) {
-		hAgingTimer.data = arg;
 		mod_timer(&hAgingTimer, jiffies + msecs_to_jiffies(AGING_TIME));
 	}
 }
@@ -304,7 +303,6 @@ static int is_network_in_shadow(struct network_info *pstrNetworkInfo,
 	int i;
 
 	if (last_scanned_cnt == 0) {
-		hAgingTimer.data = (unsigned long)user_void;
 		mod_timer(&hAgingTimer, jiffies + msecs_to_jiffies(AGING_TIME));
 		state = -1;
 	} else {
-- 
2.7.4
