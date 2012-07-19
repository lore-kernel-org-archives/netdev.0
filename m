From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH RESEND 8/9] Platform: OLPC: move global variables into priv
 struct
Date: Wed, 18 Jul 2012 21:44:23 -0700
Message-ID: <20120718214423.0224a3fa@dev.queued.net>
References: <20120718213713.232e4161@dev.queued.net>
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
In-Reply-To: <20120718213713.232e4161@dev.queued.net>
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

Populate olpc_ec_priv with variables that were previously global.  This
makes things a tad bit clearer, IMO.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 drivers/platform/olpc/olpc-ec.c |   48 ++++++++++++++++++++++----------------
 1 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/platform/olpc/olpc-ec.c b/drivers/platform/olpc/olpc-ec.c
index 1a15a79..0f9f859 100644
--- a/drivers/platform/olpc/olpc-ec.c
+++ b/drivers/platform/olpc/olpc-ec.c
@@ -31,6 +31,12 @@ struct ec_cmd_desc {
 
 struct olpc_ec_priv {
 	struct olpc_ec_driver *drv;
+	struct work_struct worker;
+	struct mutex cmd_lock;
+
+	/* Pending EC commands */
+	struct list_head cmd_q;
+	spinlock_t cmd_q_lock;
 
 	struct dentry *dbgfs_dir;
 
@@ -46,16 +52,9 @@ struct olpc_ec_priv {
 	bool suspended;
 };
 
-static void olpc_ec_worker(struct work_struct *w);
-
-static DECLARE_WORK(ec_worker, olpc_ec_worker);
-static LIST_HEAD(ec_cmd_q);
-static DEFINE_SPINLOCK(ec_cmd_q_lock);
-
 static struct olpc_ec_driver *ec_driver;
 static struct olpc_ec_priv *ec_priv;
 static void *ec_cb_arg;
-static DEFINE_MUTEX(ec_cb_lock);
 
 void olpc_ec_driver_register(struct olpc_ec_driver *drv, void *arg)
 {
@@ -66,49 +65,51 @@ EXPORT_SYMBOL_GPL(olpc_ec_driver_register);
 
 static void olpc_ec_worker(struct work_struct *w)
 {
+	struct olpc_ec_priv *ec = container_of(w, struct olpc_ec_priv, worker);
 	struct ec_cmd_desc *desc = NULL;
 	unsigned long flags;
 
 	/* Grab the first pending command from the queue */
-	spin_lock_irqsave(&ec_cmd_q_lock, flags);
-	if (!list_empty(&ec_cmd_q)) {
-		desc = list_first_entry(&ec_cmd_q, struct ec_cmd_desc, node);
+	spin_lock_irqsave(&ec->cmd_q_lock, flags);
+	if (!list_empty(&ec->cmd_q)) {
+		desc = list_first_entry(&ec->cmd_q, struct ec_cmd_desc, node);
 		list_del(&desc->node);
 	}
-	spin_unlock_irqrestore(&ec_cmd_q_lock, flags);
+	spin_unlock_irqrestore(&ec->cmd_q_lock, flags);
 
 	/* Do we actually have anything to do? */
 	if (!desc)
 		return;
 
 	/* Protect the EC hw with a mutex; only run one cmd at a time */
-	mutex_lock(&ec_cb_lock);
+	mutex_lock(&ec->cmd_lock);
 	desc->err = ec_driver->ec_cmd(desc->cmd, desc->inbuf, desc->inlen,
 			desc->outbuf, desc->outlen, ec_cb_arg);
-	mutex_unlock(&ec_cb_lock);
+	mutex_unlock(&ec->cmd_lock);
 
 	/* Finished, wake up olpc_ec_cmd() */
 	complete(&desc->finished);
 
 	/* Run the worker thread again in case there are more cmds pending */
-	schedule_work(&ec_worker);
+	schedule_work(&ec->worker);
 }
 
 /*
  * Throw a cmd descripter onto the list.  We now have SMP OLPC machines, so
  * locking is pretty critical.
  */
-static void queue_ec_descriptor(struct ec_cmd_desc *desc)
+static void queue_ec_descriptor(struct ec_cmd_desc *desc,
+		struct olpc_ec_priv *ec)
 {
 	unsigned long flags;
 
 	INIT_LIST_HEAD(&desc->node);
 
-	spin_lock_irqsave(&ec_cmd_q_lock, flags);
-	list_add_tail(&desc->node, &ec_cmd_q);
-	spin_unlock_irqrestore(&ec_cmd_q_lock, flags);
+	spin_lock_irqsave(&ec->cmd_q_lock, flags);
+	list_add_tail(&desc->node, &ec->cmd_q);
+	spin_unlock_irqrestore(&ec->cmd_q_lock, flags);
 
-	schedule_work(&ec_worker);
+	schedule_work(&ec->worker);
 }
 
 int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen)
@@ -137,7 +138,7 @@ int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen)
 	desc.err = 0;
 	init_completion(&desc.finished);
 
-	queue_ec_descriptor(&desc);
+	queue_ec_descriptor(&desc, ec);
 
 	/* Timeouts must be handled in the platform-specific EC hook */
 	wait_for_completion(&desc.finished);
@@ -266,7 +267,14 @@ static int olpc_ec_probe(struct platform_device *pdev)
 	ec = kzalloc(sizeof(*ec), GFP_KERNEL);
 	if (!ec)
 		return -ENOMEM;
+
 	ec->drv = ec_driver;
+	INIT_WORK(&ec->worker, olpc_ec_worker);
+	mutex_init(&ec->cmd_lock);
+
+	INIT_LIST_HEAD(&ec->cmd_q);
+	spin_lock_init(&ec->cmd_q_lock);
+
 	ec_priv = ec;
 	platform_set_drvdata(pdev, ec);
 
-- 
1.7.2.5
