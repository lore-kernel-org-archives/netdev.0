From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH 2/8] connector: Provide the sender's credentials to the callback
Date: Fri,  2 Oct 2009 14:40:05 +0200
Message-ID: <1254487211-11810-3-git-send-email-philipp.reisner@linbit.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-2-git-send-email-philipp.reisner@linbit.com>
Cc: dm-devel@redhat.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev-devel@lists.sourceforge.net,
	Philipp Reisner <philipp.reisner@linbit.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757728AbZJBMl5@vger.kernel.org>
In-Reply-To: <1254487211-11810-2-git-send-email-philipp.reisner@linbit.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
---
 Documentation/connector/cn_test.c      |    2 +-
 Documentation/connector/connector.txt  |    8 ++++----
 drivers/connector/cn_queue.c           |    7 ++++---
 drivers/connector/connector.c          |    4 ++--
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/staging/dst/dcore.c            |    2 +-
 drivers/staging/pohmelfs/config.c      |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 drivers/w1/w1_netlink.c                |    2 +-
 include/linux/connector.h              |    6 +++---
 10 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/Documentation/connector/cn_test.c b/Documentation/connector/cn_test.c
index 1711adc..b07add3 100644
--- a/Documentation/connector/cn_test.c
+++ b/Documentation/connector/cn_test.c
@@ -34,7 +34,7 @@ static char cn_test_name[] = "cn_test";
 static struct sock *nls;
 static struct timer_list cn_test_timer;
 
-static void cn_test_callback(struct cn_msg *msg)
+static void cn_test_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	pr_info("%s: %lu: idx=%x, val=%x, seq=%u, ack=%u, len=%d: %s.\n",
 	        __func__, jiffies, msg->id.idx, msg->id.val,
diff --git a/Documentation/connector/connector.txt b/Documentation/connector/connector.txt
index 81e6bf6..78c9466 100644
--- a/Documentation/connector/connector.txt
+++ b/Documentation/connector/connector.txt
@@ -23,7 +23,7 @@ handling, etc...  The Connector driver allows any kernelspace agents to use
 netlink based networking for inter-process communication in a significantly
 easier way:
 
-int cn_add_callback(struct cb_id *id, char *name, void (*callback) (void *));
+int cn_add_callback(struct cb_id *id, char *name, void (*callback) (struct cn_msg *, struct netlink_skb_parms *));
 void cn_netlink_send(struct cn_msg *msg, u32 __group, int gfp_mask);
 
 struct cb_id
@@ -53,15 +53,15 @@ struct cn_msg
 Connector interfaces.
 /*****************************************/
 
-int cn_add_callback(struct cb_id *id, char *name, void (*callback) (void *));
+int cn_add_callback(struct cb_id *id, char *name, void (*callback) (struct cn_msg *, struct netlink_skb_parms *));
 
  Registers new callback with connector core.
 
  struct cb_id *id		- unique connector's user identifier.
 				  It must be registered in connector.h for legal in-kernel users.
  char *name			- connector's callback symbolic name.
- void (*callback) (void *)	- connector's callback.
-				  Argument must be dereferenced to struct cn_msg *.
+ void (*callback) (struct cn..)	- connector's callback.
+				  cn_msg and the sender's credentials
 
 
 void cn_del_callback(struct cb_id *id);
diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index b4cfac9..163c3e3 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -79,8 +79,9 @@ void cn_queue_wrapper(struct work_struct *work)
 		container_of(work, struct cn_callback_entry, work);
 	struct cn_callback_data *d = &cbq->data;
 	struct cn_msg *msg = NLMSG_DATA(nlmsg_hdr(d->skb));
+	struct netlink_skb_parms *nsp = &NETLINK_CB(d->skb);
 
-	d->callback(msg);
+	d->callback(msg, nsp);
 
 	d->destruct_data(d->ddata);
 	d->ddata = NULL;
@@ -90,7 +91,7 @@ void cn_queue_wrapper(struct work_struct *work)
 
 static struct cn_callback_entry *
 cn_queue_alloc_callback_entry(char *name, struct cb_id *id,
-			      void (*callback)(struct cn_msg *))
+			      void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq;
 
@@ -124,7 +125,7 @@ int cn_cb_equal(struct cb_id *i1, struct cb_id *i2)
 }
 
 int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id,
-			  void (*callback)(struct cn_msg *))
+			  void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq, *__cbq;
 	int found = 0;
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index fc9887f..e59f0ab 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -269,7 +269,7 @@ static void cn_notify(struct cb_id *id, u32 notify_event)
  * May sleep.
  */
 int cn_add_callback(struct cb_id *id, char *name,
-		    void (*callback)(struct cn_msg *))
+		    void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
 {
 	int err;
 	struct cn_dev *dev = &cdev;
@@ -351,7 +351,7 @@ static int cn_ctl_msg_equals(struct cn_ctl_msg *m1, struct cn_ctl_msg *m2)
  *
  * Used for notification of a request's processing.
  */
-static void cn_callback(struct cn_msg *msg)
+static void cn_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct cn_ctl_msg *ctl;
 	struct cn_ctl_entry *ent;
diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index ba0edad..556131f 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -129,7 +129,7 @@ static int fill_pkg(struct cn_msg *msg, struct dm_ulog_request *tfr)
  * This is the connector callback that delivers data
  * that was sent from userspace.
  */
-static void cn_ulog_callback(void *data)
+static void cn_ulog_callback(void *data, struct netlink_skb_parms *nsp)
 {
 	struct cn_msg *msg = (struct cn_msg *)data;
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
diff --git a/drivers/staging/dst/dcore.c b/drivers/staging/dst/dcore.c
index ac85773..3943c91 100644
--- a/drivers/staging/dst/dcore.c
+++ b/drivers/staging/dst/dcore.c
@@ -847,7 +847,7 @@ static dst_command_func dst_commands[] = {
 /*
  * Configuration parser.
  */
-static void cn_dst_callback(struct cn_msg *msg)
+static void cn_dst_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct dst_ctl *ctl;
 	int err;
diff --git a/drivers/staging/pohmelfs/config.c b/drivers/staging/pohmelfs/config.c
index 90f962e..c9162b3 100644
--- a/drivers/staging/pohmelfs/config.c
+++ b/drivers/staging/pohmelfs/config.c
@@ -527,7 +527,7 @@ out_unlock:
 	return err;
 }
 
-static void pohmelfs_cn_callback(struct cn_msg *msg)
+static void pohmelfs_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	int err;
 
diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
index e98baf6..aa7cd95 100644
--- a/drivers/video/uvesafb.c
+++ b/drivers/video/uvesafb.c
@@ -67,7 +67,7 @@ static DEFINE_MUTEX(uvfb_lock);
  * find the kernel part of the task struct, copy the registers and
  * the buffer contents and then complete the task.
  */
-static void uvesafb_cn_callback(struct cn_msg *msg)
+static void uvesafb_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct uvesafb_task *utask;
 	struct uvesafb_ktask *task;
diff --git a/drivers/w1/w1_netlink.c b/drivers/w1/w1_netlink.c
index 52ccb3d..45c126f 100644
--- a/drivers/w1/w1_netlink.c
+++ b/drivers/w1/w1_netlink.c
@@ -306,7 +306,7 @@ static int w1_netlink_send_error(struct cn_msg *rcmsg, struct w1_netlink_msg *rm
 	return error;
 }
 
-static void w1_cn_callback(struct cn_msg *msg)
+static void w1_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct w1_netlink_msg *m = (struct w1_netlink_msg *)(msg + 1);
 	struct w1_netlink_cmd *cmd;
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 05a7a14..545728e 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -136,7 +136,7 @@ struct cn_callback_data {
 	void *ddata;
 
 	struct sk_buff *skb;
-	void (*callback) (struct cn_msg *);
+	void (*callback) (struct cn_msg *, struct netlink_skb_parms *);
 
 	void *free;
 };
@@ -167,11 +167,11 @@ struct cn_dev {
 	struct cn_queue_dev *cbdev;
 };
 
-int cn_add_callback(struct cb_id *, char *, void (*callback) (struct cn_msg *));
+int cn_add_callback(struct cb_id *, char *, void (*callback) (struct cn_msg *, struct netlink_skb_parms *));
 void cn_del_callback(struct cb_id *);
 int cn_netlink_send(struct cn_msg *, u32, gfp_t);
 
-int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id, void (*callback)(struct cn_msg *));
+int cn_queue_add_callback(struct cn_queue_dev *dev, char *name, struct cb_id *id, void (*callback)(struct cn_msg *, struct netlink_skb_parms *));
 void cn_queue_del_callback(struct cn_queue_dev *dev, struct cb_id *id);
 
 int queue_cn_work(struct cn_callback_entry *cbq, struct work_struct *work);
-- 
1.6.0.4
