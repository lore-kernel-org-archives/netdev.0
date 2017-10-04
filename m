From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/13] timer: Remove last user of TIMER_INITIALIZER
Date: Wed,  4 Oct 2017 16:27:01 -0700
Message-ID: <1507159627-127660-8-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mark Gross <mark.gross@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        "Martin K. Petersen" <martin.pet
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drops the last user of TIMER_INITIALIZER and adapts timer.h to use the
internal version.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mark Gross <mark.gross@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/char/tlclk.c  | 12 +++++-------
 include/linux/timer.h |  2 +-
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/char/tlclk.c b/drivers/char/tlclk.c
index 6210bff46341..8eeb4190207d 100644
--- a/drivers/char/tlclk.c
+++ b/drivers/char/tlclk.c
@@ -184,9 +184,8 @@ static unsigned int telclk_interrupt;
 static int int_events;		/* Event that generate a interrupt */
 static int got_event;		/* if events processing have been done */
 
-static void switchover_timeout(unsigned long data);
-static struct timer_list switchover_timer =
-	TIMER_INITIALIZER(switchover_timeout , 0, 0);
+static void switchover_timeout(struct timer_list *t);
+static struct timer_list switchover_timer;
 static unsigned long tlclk_timer_data;
 
 static struct tlclk_alarms *alarm_events;
@@ -805,7 +804,7 @@ static int __init tlclk_init(void)
 		goto out3;
 	}
 
-	init_timer(&switchover_timer);
+	timer_setup(&switchover_timer, switchover_timeout, 0);
 
 	ret = misc_register(&tlclk_miscdev);
 	if (ret < 0) {
@@ -855,9 +854,9 @@ static void __exit tlclk_cleanup(void)
 
 }
 
-static void switchover_timeout(unsigned long data)
+static void switchover_timeout(struct timer_list *unused)
 {
-	unsigned long flags = *(unsigned long *) data;
+	unsigned long flags = tlclk_timer_data;
 
 	if ((flags & 1)) {
 		if ((inb(TLCLK_REG1) & 0x08) != (flags & 0x08))
@@ -922,7 +921,6 @@ static irqreturn_t tlclk_interrupt(int irq, void *dev_id)
 		/* TIMEOUT in ~10ms */
 		switchover_timer.expires = jiffies + msecs_to_jiffies(10);
 		tlclk_timer_data = inb(TLCLK_REG1);
-		switchover_timer.data = (unsigned long) &tlclk_timer_data;
 		mod_timer(&switchover_timer, switchover_timer.expires);
 	} else {
 		got_event = 1;
diff --git a/include/linux/timer.h b/include/linux/timer.h
index 10cc45ca5803..4f7476e4a727 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -87,7 +87,7 @@ struct timer_list {
 
 #define DEFINE_TIMER(_name, _function, _expires, _data)		\
 	struct timer_list _name =				\
-		TIMER_INITIALIZER(_function, _expires, _data)
+		__TIMER_INITIALIZER(_function, _expires, _data, 0)
 
 void init_timer_key(struct timer_list *timer, unsigned int flags,
 		    const char *name, struct lock_class_key *key);
-- 
2.7.4
