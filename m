From: Bandan Das <bsd@redhat.com>
Subject: [PATCH] vhost: use kthread_run macro
Date: Tue, 14 Apr 2015 17:32:34 -0400
Message-ID: <jpgiocywg3x.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Code Cleanup, kthread_run is a convenient wrapper
around kthread_create() that even wakes up the process
for us. Use it and remove no longer needed temp
task_struct variable.

Signed-off-by: Bandan Das <bsd@redhat.com>
---
 drivers/vhost/vhost.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ee2826..9ac66f7 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -366,7 +366,6 @@ EXPORT_SYMBOL_GPL(vhost_dev_has_owner);
 /* Caller should have device mutex */
 long vhost_dev_set_owner(struct vhost_dev *dev)
 {
-	struct task_struct *worker;
 	int err;
 
 	/* Is there an owner already? */
@@ -377,15 +376,12 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
-	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
-	if (IS_ERR(worker)) {
-		err = PTR_ERR(worker);
+	dev->worker = kthread_run(vhost_worker, dev, "vhost-%d", current->pid);
+	if (IS_ERR(dev->worker)) {
+		err = PTR_ERR(dev->worker);
 		goto err_worker;
 	}
 
-	dev->worker = worker;
-	wake_up_process(worker);	/* avoid contributing to loadavg */
-
 	err = vhost_attach_cgroups(dev);
 	if (err)
 		goto err_cgroup;
@@ -396,7 +392,7 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 
 	return 0;
 err_cgroup:
-	kthread_stop(worker);
+	kthread_stop(dev->worker);
 	dev->worker = NULL;
 err_worker:
 	if (dev->mm)
-- 
2.1.0

