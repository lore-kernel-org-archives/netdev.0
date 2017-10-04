From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/13] timer: Remove init_timer_on_stack() in favor of timer_setup_on_stack()
Date: Wed,  4 Oct 2017 16:26:57 -0700
Message-ID: <1507159627-127660-4-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Michael Reed <mdr@sgi.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        linux-pm@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
        linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Remove uses of init_timer_on_stack() with open-coded function and data
assignments that could be expressed using timer_setup_on_stack(). Several
were removed from the stack entirely since there was a one-to-one mapping
of parent structure to timer, those are switched to using timer_setup()
instead. All related callbacks were adjusted to use from_timer().

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Cc: Ursula Braun <ubraun@linux.vnet.ibm.com>
Cc: Michael Reed <mdr@sgi.com>
Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-pm@vger.kernel.org
Cc: linux1394-devel@lists.sourceforge.net
Cc: linux-s390@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/base/power/main.c           |  8 +++-----
 drivers/firewire/core-transaction.c | 10 +++++-----
 drivers/parport/ieee1284.c          | 21 +++++++--------------
 drivers/s390/char/tape.h            |  1 +
 drivers/s390/char/tape_std.c        | 18 ++++++------------
 drivers/s390/net/lcs.c              | 16 ++++++----------
 drivers/s390/net/lcs.h              |  1 +
 drivers/scsi/qla1280.c              | 14 +++++---------
 drivers/scsi/qla1280.h              |  1 +
 include/linux/parport.h             |  1 +
 include/linux/timer.h               |  2 --
 11 files changed, 36 insertions(+), 57 deletions(-)

diff --git a/drivers/base/power/main.c b/drivers/base/power/main.c
index 770b1539a083..ae47b2ec84b4 100644
--- a/drivers/base/power/main.c
+++ b/drivers/base/power/main.c
@@ -478,9 +478,9 @@ struct dpm_watchdog {
  * There's not much we can do here to recover so panic() to
  * capture a crash-dump in pstore.
  */
-static void dpm_watchdog_handler(unsigned long data)
+static void dpm_watchdog_handler(struct timer_list *t)
 {
-	struct dpm_watchdog *wd = (void *)data;
+	struct dpm_watchdog *wd = from_timer(wd, t, timer);
 
 	dev_emerg(wd->dev, "**** DPM device timeout ****\n");
 	show_stack(wd->tsk, NULL);
@@ -500,11 +500,9 @@ static void dpm_watchdog_set(struct dpm_watchdog *wd, struct device *dev)
 	wd->dev = dev;
 	wd->tsk = current;
 
-	init_timer_on_stack(timer);
+	timer_setup_on_stack(timer, dpm_watchdog_handler, 0);
 	/* use same timeout value for both suspend and resume */
 	timer->expires = jiffies + HZ * CONFIG_DPM_WATCHDOG_TIMEOUT;
-	timer->function = dpm_watchdog_handler;
-	timer->data = (unsigned long)wd;
 	add_timer(timer);
 }
 
diff --git a/drivers/firewire/core-transaction.c b/drivers/firewire/core-transaction.c
index d6a09b9cd8cc..4372f9e4b0da 100644
--- a/drivers/firewire/core-transaction.c
+++ b/drivers/firewire/core-transaction.c
@@ -137,9 +137,9 @@ int fw_cancel_transaction(struct fw_card *card,
 }
 EXPORT_SYMBOL(fw_cancel_transaction);
 
-static void split_transaction_timeout_callback(unsigned long data)
+static void split_transaction_timeout_callback(struct timer_list *timer)
 {
-	struct fw_transaction *t = (struct fw_transaction *)data;
+	struct fw_transaction *t = from_timer(t, timer, split_timeout_timer);
 	struct fw_card *card = t->card;
 	unsigned long flags;
 
@@ -373,8 +373,8 @@ void fw_send_request(struct fw_card *card, struct fw_transaction *t, int tcode,
 	t->tlabel = tlabel;
 	t->card = card;
 	t->is_split_transaction = false;
-	setup_timer(&t->split_timeout_timer,
-		    split_transaction_timeout_callback, (unsigned long)t);
+	timer_setup(&t->split_timeout_timer,
+		    split_transaction_timeout_callback, 0);
 	t->callback = callback;
 	t->callback_data = callback_data;
 
@@ -423,7 +423,7 @@ int fw_run_transaction(struct fw_card *card, int tcode, int destination_id,
 	struct transaction_callback_data d;
 	struct fw_transaction t;
 
-	init_timer_on_stack(&t.split_timeout_timer);
+	timer_setup_on_stack(&t.split_timeout_timer, NULL, 0);
 	init_completion(&d.done);
 	d.payload = payload;
 	fw_send_request(card, &t, tcode, destination_id, generation, speed,
diff --git a/drivers/parport/ieee1284.c b/drivers/parport/ieee1284.c
index 74cc6dd982d2..2d1a5c737c6e 100644
--- a/drivers/parport/ieee1284.c
+++ b/drivers/parport/ieee1284.c
@@ -44,10 +44,11 @@ static void parport_ieee1284_wakeup (struct parport *port)
 	up (&port->physport->ieee1284.irq);
 }
 
-static struct parport *port_from_cookie[PARPORT_MAX];
-static void timeout_waiting_on_port (unsigned long cookie)
+static void timeout_waiting_on_port (struct timer_list *t)
 {
-	parport_ieee1284_wakeup (port_from_cookie[cookie % PARPORT_MAX]);
+	struct parport *port = from_timer(port, t, timer);
+
+	parport_ieee1284_wakeup (port);
 }
 
 /**
@@ -69,27 +70,19 @@ static void timeout_waiting_on_port (unsigned long cookie)
 int parport_wait_event (struct parport *port, signed long timeout)
 {
 	int ret;
-	struct timer_list timer;
 
 	if (!port->physport->cad->timeout)
 		/* Zero timeout is special, and we can't down() the
 		   semaphore. */
 		return 1;
 
-	init_timer_on_stack(&timer);
-	timer.expires = jiffies + timeout;
-	timer.function = timeout_waiting_on_port;
-	port_from_cookie[port->number % PARPORT_MAX] = port;
-	timer.data = port->number;
-
-	add_timer (&timer);
+	timer_setup(&port->timer, timeout_waiting_on_port, 0);
+	mod_timer(&port->timer, jiffies + timeout);
 	ret = down_interruptible (&port->physport->ieee1284.irq);
-	if (!del_timer_sync(&timer) && !ret)
+	if (!del_timer_sync(&port->timer) && !ret)
 		/* Timed out. */
 		ret = 1;
 
-	destroy_timer_on_stack(&timer);
-
 	return ret;
 }
 
diff --git a/drivers/s390/char/tape.h b/drivers/s390/char/tape.h
index ea664dd4f56d..52fbcd9c3cf8 100644
--- a/drivers/s390/char/tape.h
+++ b/drivers/s390/char/tape.h
@@ -128,6 +128,7 @@ struct tape_request {
 	int options;			/* options for execution. */
 	int retries;			/* retry counter for error recovery. */
 	int rescnt;			/* residual count from devstat. */
+	struct timer_list timer;	/* timer for std_assign_timeout(). */
 
 	/* Callback for delivering final status. */
 	void (*callback)(struct tape_request *, void *);
diff --git a/drivers/s390/char/tape_std.c b/drivers/s390/char/tape_std.c
index 3478e19ae194..cd204abdc0bc 100644
--- a/drivers/s390/char/tape_std.c
+++ b/drivers/s390/char/tape_std.c
@@ -32,14 +32,12 @@
  * tape_std_assign
  */
 static void
-tape_std_assign_timeout(unsigned long data)
+tape_std_assign_timeout(struct timer_list *t)
 {
-	struct tape_request *	request;
-	struct tape_device *	device;
+	struct tape_request *	request = from_timer(request, t, timer);
+	struct tape_device *	device = request->device;
 	int rc;
 
-	request = (struct tape_request *) data;
-	device = request->device;
 	BUG_ON(!device);
 
 	DBF_EVENT(3, "%08x: Assignment timeout. Device busy.\n",
@@ -70,16 +68,12 @@ tape_std_assign(struct tape_device *device)
 	 * to another host (actually this shouldn't happen but it does).
 	 * So we set up a timeout for this call.
 	 */
-	init_timer_on_stack(&timeout);
-	timeout.function = tape_std_assign_timeout;
-	timeout.data     = (unsigned long) request;
-	timeout.expires  = jiffies + 2 * HZ;
-	add_timer(&timeout);
+	timer_setup(&request->timer, tape_std_assign_timeout, 0);
+	mod_timer(&timeout, jiffies + 2 * HZ);
 
 	rc = tape_do_io_interruptible(device, request);
 
-	del_timer_sync(&timeout);
-	destroy_timer_on_stack(&timeout);
+	del_timer_sync(&request->timer);
 
 	if (rc != 0) {
 		DBF_EVENT(3, "%08x: assign failed - device might be busy\n",
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index d01b5c2a7760..21bba406d5be 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -834,9 +834,10 @@ lcs_notify_lancmd_waiters(struct lcs_card *card, struct lcs_cmd *cmd)
  * Emit buffer of a lan command.
  */
 static void
-lcs_lancmd_timeout(unsigned long data)
+lcs_lancmd_timeout(struct timer_list *t)
 {
-	struct lcs_reply *reply, *list_reply, *r;
+	struct lcs_reply *reply = from_timer(reply, t, timer);
+	struct lcs_reply *list_reply, *r;
 	unsigned long flags;
 
 	LCS_DBF_TEXT(4, trace, "timeout");
@@ -864,7 +865,6 @@ lcs_send_lancmd(struct lcs_card *card, struct lcs_buffer *buffer,
 {
 	struct lcs_reply *reply;
 	struct lcs_cmd *cmd;
-	struct timer_list timer;
 	unsigned long flags;
 	int rc;
 
@@ -885,14 +885,10 @@ lcs_send_lancmd(struct lcs_card *card, struct lcs_buffer *buffer,
 	rc = lcs_ready_buffer(&card->write, buffer);
 	if (rc)
 		return rc;
-	init_timer_on_stack(&timer);
-	timer.function = lcs_lancmd_timeout;
-	timer.data = (unsigned long) reply;
-	timer.expires = jiffies + HZ*card->lancmd_timeout;
-	add_timer(&timer);
+	timer_setup(&reply->timer, lcs_lancmd_timeout, 0);
+	mod_timer(&reply->timer, jiffies + HZ * card->lancmd_timeout);
 	wait_event(reply->wait_q, reply->received);
-	del_timer_sync(&timer);
-	destroy_timer_on_stack(&timer);
+	del_timer_sync(&reply->timer);
 	LCS_DBF_TEXT_(4, trace, "rc:%d",reply->rc);
 	rc = reply->rc;
 	lcs_put_reply(reply);
diff --git a/drivers/s390/net/lcs.h b/drivers/s390/net/lcs.h
index 150fcb4cebc3..d44fb8d9378f 100644
--- a/drivers/s390/net/lcs.h
+++ b/drivers/s390/net/lcs.h
@@ -275,6 +275,7 @@ struct lcs_reply {
 	void (*callback)(struct lcs_card *, struct lcs_cmd *);
 	wait_queue_head_t wait_q;
 	struct lcs_card *card;
+	struct timer_list timer;
 	int received;
 	int rc;
 };
diff --git a/drivers/scsi/qla1280.c b/drivers/scsi/qla1280.c
index 8a29fb09db14..390775d5c918 100644
--- a/drivers/scsi/qla1280.c
+++ b/drivers/scsi/qla1280.c
@@ -758,9 +758,9 @@ enum action {
 };
 
 
-static void qla1280_mailbox_timeout(unsigned long __data)
+static void qla1280_mailbox_timeout(struct timer_list *t)
 {
-	struct scsi_qla_host *ha = (struct scsi_qla_host *)__data;
+	struct scsi_qla_host *ha = from_timer(ha, t, mailbox_timer);
 	struct device_reg __iomem *reg;
 	reg = ha->iobase;
 
@@ -2465,7 +2465,6 @@ qla1280_mailbox_command(struct scsi_qla_host *ha, uint8_t mr, uint16_t *mb)
 	uint16_t __iomem *mptr;
 	uint16_t data;
 	DECLARE_COMPLETION_ONSTACK(wait);
-	struct timer_list timer;
 
 	ENTER("qla1280_mailbox_command");
 
@@ -2494,18 +2493,15 @@ qla1280_mailbox_command(struct scsi_qla_host *ha, uint8_t mr, uint16_t *mb)
 	/* Issue set host interrupt command. */
 
 	/* set up a timer just in case we're really jammed */
-	init_timer_on_stack(&timer);
-	timer.expires = jiffies + 20*HZ;
-	timer.data = (unsigned long)ha;
-	timer.function = qla1280_mailbox_timeout;
-	add_timer(&timer);
+	timer_setup(&ha->mailbox_timer, qla1280_mailbox_timeout, 0);
+	mod_timer(&ha->mailbox_timer, jiffies + 20 * HZ);
 
 	spin_unlock_irq(ha->host->host_lock);
 	WRT_REG_WORD(&reg->host_cmd, HC_SET_HOST_INT);
 	data = qla1280_debounce_register(&reg->istatus);
 
 	wait_for_completion(&wait);
-	del_timer_sync(&timer);
+	del_timer_sync(&ha->mailbox_timer);
 
 	spin_lock_irq(ha->host->host_lock);
 
diff --git a/drivers/scsi/qla1280.h b/drivers/scsi/qla1280.h
index 834884b9eed5..1522aca2c8c8 100644
--- a/drivers/scsi/qla1280.h
+++ b/drivers/scsi/qla1280.h
@@ -1055,6 +1055,7 @@ struct scsi_qla_host {
 	struct list_head done_q;	/* Done queue */
 
 	struct completion *mailbox_wait;
+	struct timer_list mailbox_timer;
 
 	volatile struct {
 		uint32_t online:1;			/* 0 */
diff --git a/include/linux/parport.h b/include/linux/parport.h
index 58e3c64c6b49..397607a0c0eb 100644
--- a/include/linux/parport.h
+++ b/include/linux/parport.h
@@ -225,6 +225,7 @@ struct parport {
 	struct pardevice *waittail;
 
 	struct list_head list;
+	struct timer_list timer;
 	unsigned int flags;
 
 	void *sysctl_table;
diff --git a/include/linux/timer.h b/include/linux/timer.h
index d11e819a86e2..b10c4bdc6fbd 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -132,8 +132,6 @@ static inline void init_timer_on_stack_key(struct timer_list *timer,
 	__init_timer((timer), TIMER_PINNED)
 #define init_timer_deferrable(timer)					\
 	__init_timer((timer), TIMER_DEFERRABLE)
-#define init_timer_on_stack(timer)					\
-	__init_timer_on_stack((timer), 0)
 
 #define __setup_timer(_timer, _fn, _data, _flags)			\
 	do {								\
-- 
2.7.4
