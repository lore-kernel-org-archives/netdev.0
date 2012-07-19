From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 5/9] Platform: OLPC: add a suspended flag to the EC driver
Date: Wed, 18 Jul 2012 21:28:24 -0700
Message-ID: <20120718212824.70ee6466@dev.queued.net>
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

A problem we've noticed on XO-1.75 is when we suspend in the middle of
an EC command.  Don't allow that.

In the process, create a private object for the generic EC driver to
use; we have a framework for passing around a struct, use that rather
than a proliferation of global variables.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 drivers/platform/olpc/olpc-ec.c |   46
++++++++++++++++++++++++++++++++++++++- 1 files changed, 45
insertions(+), 1 deletions(-)

diff --git a/drivers/platform/olpc/olpc-ec.c
b/drivers/platform/olpc/olpc-ec.c index d00523c..cfba41f 100644
--- a/drivers/platform/olpc/olpc-ec.c
+++ b/drivers/platform/olpc/olpc-ec.c
@@ -9,6 +9,7 @@
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/platform_device.h>
+#include <linux/slab.h>
 #include <linux/workqueue.h>
 #include <linux/module.h>
 #include <linux/list.h>
@@ -27,6 +28,21 @@ struct ec_cmd_desc {
 	void *priv;
 };
 
+struct olpc_ec_priv {
+	struct olpc_ec_driver *drv;
+
+	/*
+	 * Running an EC command while suspending means we don't
always finish
+	 * the command before the machine suspends.  This means that
the EC
+	 * is expecting the command protocol to finish, but we after a
period
+	 * of time (while the OS is asleep) the EC times out and
restarts its
+	 * idle loop.  Meanwhile, the OS wakes up, thinks it's still
in the
+	 * middle of the command protocol, starts throwing random
things at
+	 * the EC... and everyone's uphappy.
+	 */
+	bool suspended;
+};
+
 static void olpc_ec_worker(struct work_struct *w);
 
 static DECLARE_WORK(ec_worker, olpc_ec_worker);
@@ -34,6 +50,7 @@ static LIST_HEAD(ec_cmd_q);
 static DEFINE_SPINLOCK(ec_cmd_q_lock);
 
 static struct olpc_ec_driver *ec_driver;
+static struct olpc_ec_priv *ec_priv;
 static void *ec_cb_arg;
 static DEFINE_MUTEX(ec_cb_lock);
 
@@ -93,6 +110,7 @@ static void queue_ec_descriptor(struct ec_cmd_desc
*desc) 
 int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf, size_t
outlen) {
+	struct olpc_ec_priv *ec = ec_priv;
 	struct ec_cmd_desc desc;
 
 	/* XXX: this will be removed in later patches */
@@ -104,6 +122,13 @@ int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen,
u8 *outbuf, size_t outlen) if (WARN_ON(!ec_driver
|| !ec_driver->ec_cmd)) return -ENODEV;
 
+	if (!ec)
+		return -ENOMEM;
+
+	/* Suspending in the middle of a command hoses things really
badly */
+	if (WARN_ON(ec->suspended))
+		return -EBUSY;
+
 	might_sleep();
 
 	desc.cmd = cmd;
@@ -126,11 +151,19 @@ EXPORT_SYMBOL_GPL(olpc_ec_cmd);
 
 static int olpc_ec_probe(struct platform_device *pdev)
 {
+	struct olpc_ec_priv *ec;
 	int err;
 
 	if (!ec_driver)
 		return -ENODEV;
 
+	ec = kzalloc(sizeof(*ec), GFP_KERNEL);
+	if (!ec)
+		return -ENOMEM;
+	ec->drv = ec_driver;
+	ec_priv = ec;
+	platform_set_drvdata(pdev, ec);
+
 	err = ec_driver->probe ? ec_driver->probe(pdev) : 0;
 
 	return err;
@@ -139,12 +172,23 @@ static int olpc_ec_probe(struct platform_device
*pdev) static int olpc_ec_suspend(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
-	return ec_driver->suspend ? ec_driver->suspend(pdev) : 0;
+	struct olpc_ec_priv *ec = platform_get_drvdata(pdev);
+	int err = 0;
+
+	if (ec_driver->suspend)
+		err = ec_driver->suspend(pdev);
+	if (!err)
+		ec->suspended = true;
+
+	return err;
 }
 
 static int olpc_ec_resume(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
+	struct olpc_ec_priv *ec = platform_get_drvdata(pdev);
+
+	ec->suspended = false;
 	return ec_driver->resume ? ec_driver->resume(pdev) : 0;
 }
 
-- 
1.7.2.5
