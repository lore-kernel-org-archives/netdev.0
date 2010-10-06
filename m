From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/2] vhost: put mm after thread stop
Date: Wed, 6 Oct 2010 15:34:38 +0200
Message-ID: <81ac3f9b6277cad646ec19815259a5376cdfd636.1286372006.git.mst@redhat.com>
References: <cover.1286372004.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, kvm@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org, avi@redhat.com,
	anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1286372004.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

makes it possible to batch use/unuse mm

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 677d112..8b9d474 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -207,7 +207,7 @@ static int vhost_worker(void *data)
 		if (work) {
 			__set_current_state(TASK_RUNNING);
 			work->fn(work);
-			if (n++) {
+			if (dev->nvqs <= ++n) {
 				__set_current_state(TASK_RUNNING);
 				schedule();
 				n = 0;
@@ -409,15 +409,14 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	/* No one will access memory at this point */
 	kfree(dev->memory);
 	dev->memory = NULL;
-	if (dev->mm)
-		mmput(dev->mm);
-	dev->mm = NULL;
-
 	WARN_ON(!list_empty(&dev->work_list));
 	if (dev->worker) {
 		kthread_stop(dev->worker);
 		dev->worker = NULL;
 	}
+	if (dev->mm)
+		mmput(dev->mm);
+	dev->mm = NULL;
 }
 
 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
-- 
1.7.3-rc1

