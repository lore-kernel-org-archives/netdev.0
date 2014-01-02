From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, RFC 19/30] isdn: pcbit: fix interruptible_sleep_on race
Date: Thu,  2 Jan 2014 13:07:43 +0100
Message-ID: <1388664474-1710039-20-git-send-email-arnd@arndb.de>
References: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

interruptible_sleep_on is racy and going away. In case of pcbit,
the driver would run into a timeout if the card is initialized
before we start waiting for it. This uses wait_event to fix the
race. In order to do this, the state machine handling for the
timeout case has to get trivially reorganized so we actually know
whether the timeout has occorred or not.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/pcbit/drv.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/pcbit/drv.c b/drivers/isdn/pcbit/drv.c
index 1eaf622..f02cc50 100644
--- a/drivers/isdn/pcbit/drv.c
+++ b/drivers/isdn/pcbit/drv.c
@@ -796,6 +796,7 @@ static void set_running_timeout(unsigned long ptr)
 #endif
 	dev = (struct pcbit_dev *) ptr;
 
+	dev->l2_state = L2_DOWN;
 	wake_up_interruptible(&dev->set_running_wq);
 }
 
@@ -818,7 +819,8 @@ static int set_protocol_running(struct pcbit_dev *dev)
 
 	add_timer(&dev->set_running_timer);
 
-	interruptible_sleep_on(&dev->set_running_wq);
+	wait_event(dev->set_running_wq, dev->l2_state == L2_RUNNING ||
+					dev->l2_state == L2_DOWN);
 
 	del_timer(&dev->set_running_timer);
 
@@ -842,8 +844,6 @@ static int set_protocol_running(struct pcbit_dev *dev)
 		printk(KERN_DEBUG "pcbit: initialization failed\n");
 		printk(KERN_DEBUG "pcbit: firmware not loaded\n");
 
-		dev->l2_state = L2_DOWN;
-
 #ifdef DEBUG
 		printk(KERN_DEBUG "Bank3 = %02x\n",
 		       readb(dev->sh_mem + BANK3));
-- 
1.8.3.2
