From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 3/9] Platform: OLPC: allow EC cmd to be overridden, and
 create a workqueue to call it
Date: Wed, 18 Jul 2012 21:28:18 -0700
Message-ID: <20120718212818.5ed01c8a@dev.queued.net>
References: <20120718182144.2d7b0b50@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Daniel Drake <dsd@laptop.org>,
 libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
 netdev@vger.kernel.org, Jon Nettleton <jon.nettleton@gmail.com>,
 x86@kernel.org, linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, "Richard A.
 Smith" <richard@laptop.org>, Paul Fox <pgf@laptop.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Anton Vorontsov <cbou@mail.ru>, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Chris Ball <cjb@laptop.org>,
 David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 "John W. Linville" <linville@tuxdriver.com>, Matthew Garrett <mjg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120718182144.2d7b0b50@dev.queued.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This provides a new API allows different OLPC architectures to override the
EC driver.  x86 and ARM OLPC machines use completely different EC backends.

The olpc_ec_cmd is synchronous, and waits for the workqueue to send the
command to the EC.  Multiple callers can run olpc_ec_cmd() at once, and
they will by serialized and sleep while only one executes on the EC at a time.

We don't provide an unregister function, as that doesn't make sense within
the context of OLPC machines - there's only ever 1 EC, it's critical to
functionality, and it certainly not hotpluggable.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 drivers/platform/olpc/olpc-ec.c |  112 ++++++++++++++++++++++++++++++++++++++-
 include/linux/olpc-ec.h         |    6 ++
 2 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/drivers/platform/olpc/olpc-ec.c b/drivers/platform/olpc/olpc-ec.c
index 4202603..44e6a4f 100644
--- a/drivers/platform/olpc/olpc-ec.c
+++ b/drivers/platform/olpc/olpc-ec.c
@@ -5,12 +5,120 @@
  *
  * Licensed under the GPL v2 or later.
  */
+#include <linux/completion.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
 #include <linux/module.h>
+#include <linux/list.h>
+#include <linux/olpc-ec.h>
 #include <asm/olpc.h>
 
+struct ec_cmd_desc {
+	u8 cmd;
+	u8 *inbuf, *outbuf;
+	size_t inlen, outlen;
+
+	int err;
+	struct completion finished;
+	struct list_head node;
+
+	void *priv;
+};
+
+static void olpc_ec_worker(struct work_struct *w);
+
+static DECLARE_WORK(ec_worker, olpc_ec_worker);
+static LIST_HEAD(ec_cmd_q);
+static DEFINE_SPINLOCK(ec_cmd_q_lock);
+
+static struct olpc_ec_driver *ec_driver;
+static void *ec_cb_arg;
+static DEFINE_MUTEX(ec_cb_lock);
+
+void olpc_ec_driver_register(struct olpc_ec_driver *drv, void *arg)
+{
+	ec_driver = drv;
+	ec_cb_arg = arg;
+}
+EXPORT_SYMBOL_GPL(olpc_ec_driver_register);
+
+static void olpc_ec_worker(struct work_struct *w)
+{
+	struct ec_cmd_desc *desc = NULL;
+	unsigned long flags;
+
+	/* Grab the first pending command from the queue */
+	spin_lock_irqsave(&ec_cmd_q_lock, flags);
+	if (!list_empty(&ec_cmd_q)) {
+		desc = list_first_entry(&ec_cmd_q, struct ec_cmd_desc, node);
+		list_del(&desc->node);
+	}
+	spin_unlock_irqrestore(&ec_cmd_q_lock, flags);
+
+	/* Do we actually have anything to do? */
+	if (!desc)
+		return;
+
+	/* Protect the EC hw with a mutex; only run one cmd at a time */
+	mutex_lock(&ec_cb_lock);
+	desc->err = ec_driver->ec_cmd(desc->cmd, desc->inbuf, desc->inlen,
+			desc->outbuf, desc->outlen, ec_cb_arg);
+	mutex_unlock(&ec_cb_lock);
+
+	/* Finished, wake up olpc_ec_cmd() */
+	complete(&desc->finished);
+
+	/* Run the worker thread again in case there are more cmds pending */
+	schedule_work(&ec_worker);
+}
+
+/*
+ * Throw a cmd descripter onto the list.  We now have SMP OLPC machines, so
+ * locking is pretty critical.
+ */
+static void queue_ec_descriptor(struct ec_cmd_desc *desc)
+{
+	unsigned long flags;
+
+	INIT_LIST_HEAD(&desc->node);
+
+	spin_lock_irqsave(&ec_cmd_q_lock, flags);
+	list_add_tail(&desc->node, &ec_cmd_q);
+	spin_unlock_irqrestore(&ec_cmd_q_lock, flags);
+
+	schedule_work(&ec_worker);
+}
+
 int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen)
 {
-	/* Currently a stub; this will be expanded upon later. */
-	return olpc_ec_cmd_x86(cmd, inbuf, inlen, outbuf, outlen);
+	struct ec_cmd_desc desc;
+
+	/* XXX: this will be removed in later patches */
+	/* Are we using old-style callers? */
+	if (!ec_driver || !ec_driver->ec_cmd)
+		return olpc_ec_cmd_x86(cmd, inbuf, inlen, outbuf, outlen);
+
+	/* Ensure a driver and ec hook have been registered */
+	if (WARN_ON(!ec_driver || !ec_driver->ec_cmd))
+		return -ENODEV;
+
+	might_sleep();
+
+	desc.cmd = cmd;
+	desc.inbuf = inbuf;
+	desc.outbuf = outbuf;
+	desc.inlen = inlen;
+	desc.outlen = outlen;
+	desc.err = 0;
+	init_completion(&desc.finished);
+
+	queue_ec_descriptor(&desc);
+
+	/* Timeouts must be handled in the platform-specific EC hook */
+	wait_for_completion(&desc.finished);
+
+	/* The worker thread dequeues the cmd; no need to do anything here */
+	return desc.err;
 }
 EXPORT_SYMBOL_GPL(olpc_ec_cmd);
diff --git a/include/linux/olpc-ec.h b/include/linux/olpc-ec.h
index 6d4e426..231e96f 100644
--- a/include/linux/olpc-ec.h
+++ b/include/linux/olpc-ec.h
@@ -14,8 +14,14 @@
 #define EC_SCI_QUERY			0x84
 #define EC_EXT_SCI_QUERY		0x85
 
+struct olpc_ec_driver {
+	int (*ec_cmd)(u8, u8 *, size_t, u8 *, size_t, void *);
+};
+
 #ifdef CONFIG_OLPC
 
+extern void olpc_ec_driver_register(struct olpc_ec_driver *drv, void *arg);
+
 extern int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf,
 		size_t outlen);
 
-- 
1.7.2.5
