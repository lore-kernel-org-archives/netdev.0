From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 03/13] wimax/i2400m: clean up & add a payload argument to i2400m_schedule_work()
Date: Wed,  4 Nov 2009 13:39:54 -0800
Message-ID: <b0fbcb2a0b54ee201fa8af61fdebe14c050f18fe.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20716 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932732AbZKDVmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:05 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forthcoming commits use having a payload argument added to
i2400m_schedule_work(), which then becomes nearly identical to
i2400m_queue_work().

This patch thus cleans up both's implementation, making it share
common helpers and adding the payload argument to
i2400m_schedule_work().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   52 +++++++++++++++++++++++-------------
 drivers/net/wimax/i2400m/i2400m.h |    6 +++-
 2 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 73f45ea..5803a2b 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -107,6 +107,24 @@ MODULE_PARM_DESC(barkers,
 		 "signal; values are appended to a list--setting one value "
 		 "as zero cleans the existing list and starts a new one.");
 
+static
+struct i2400m_work *__i2400m_work_setup(
+	struct i2400m *i2400m, void (*fn)(struct work_struct *),
+	gfp_t gfp_flags, const void *pl, size_t pl_size)
+{
+	struct i2400m_work *iw;
+
+	iw = kzalloc(sizeof(*iw) + pl_size, gfp_flags);
+	if (iw == NULL)
+		return NULL;
+	iw->i2400m = i2400m_get(i2400m);
+	iw->pl_size = pl_size;
+	memcpy(iw->pl, pl, pl_size);
+	INIT_WORK(&iw->ws, fn);
+	return iw;
+}
+
+
 /**
  * i2400m_queue_work - schedule work on a i2400m's queue
  *
@@ -166,14 +184,12 @@ int i2400m_queue_work(struct i2400m *i2400m,
 
 	BUG_ON(i2400m->work_queue == NULL);
 	result = -ENOMEM;
-	iw = kzalloc(sizeof(*iw) + pl_size, gfp_flags);
-	if (iw == NULL)
-		goto error_kzalloc;
-	iw->i2400m = i2400m_get(i2400m);
-	memcpy(iw->pl, pl, pl_size);
-	INIT_WORK(&iw->ws, fn);
-	result = queue_work(i2400m->work_queue, &iw->ws);
-error_kzalloc:
+	iw = __i2400m_work_setup(i2400m, fn, gfp_flags, pl, pl_size);
+	if (iw != NULL) {
+		result = queue_work(i2400m->work_queue, &iw->ws);
+		if (WARN_ON(result == 0))
+			result = -ENXIO;
+	}
 	return result;
 }
 EXPORT_SYMBOL_GPL(i2400m_queue_work);
@@ -192,21 +208,19 @@ EXPORT_SYMBOL_GPL(i2400m_queue_work);
  * it should not happen.
  */
 int i2400m_schedule_work(struct i2400m *i2400m,
-			 void (*fn)(struct work_struct *), gfp_t gfp_flags)
+			 void (*fn)(struct work_struct *), gfp_t gfp_flags,
+			 const void *pl, size_t pl_size)
 {
 	int result;
 	struct i2400m_work *iw;
 
 	result = -ENOMEM;
-	iw = kzalloc(sizeof(*iw), gfp_flags);
-	if (iw == NULL)
-		goto error_kzalloc;
-	iw->i2400m = i2400m_get(i2400m);
-	INIT_WORK(&iw->ws, fn);
-	result = schedule_work(&iw->ws);
-	if (result == 0)
-		result = -ENXIO;
-error_kzalloc:
+	iw = __i2400m_work_setup(i2400m, fn, gfp_flags, pl, pl_size);
+	if (iw != NULL) {
+		result = schedule_work(&iw->ws);
+		if (WARN_ON(result == 0))
+			result = -ENXIO;
+	}
 	return result;
 }
 
@@ -630,7 +644,7 @@ int i2400m_dev_reset_handle(struct i2400m *i2400m)
 	i2400m->boot_mode = 1;
 	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
 	return i2400m_schedule_work(i2400m, __i2400m_dev_reset_handle,
-				    GFP_ATOMIC);
+				    GFP_ATOMIC, NULL, 0);
 }
 EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 5ac2cce..700f87b 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -695,8 +695,6 @@ extern void i2400m_dev_shutdown(struct i2400m *);
 
 extern struct attribute_group i2400m_dev_attr_group;
 
-extern int i2400m_schedule_work(struct i2400m *,
-				void (*)(struct work_struct *), gfp_t);
 
 /* HDI message's payload description handling */
 
@@ -778,10 +776,14 @@ struct device *i2400m_dev(struct i2400m *i2400m)
 struct i2400m_work {
 	struct work_struct ws;
 	struct i2400m *i2400m;
+	size_t pl_size;
 	u8 pl[0];
 };
 extern int i2400m_queue_work(struct i2400m *,
 			     void (*)(struct work_struct *), gfp_t,
+			     const void *, size_t);
+extern int i2400m_schedule_work(struct i2400m *,
+				void (*)(struct work_struct *), gfp_t,
 				const void *, size_t);
 
 extern int i2400m_msg_check_status(const struct i2400m_l3l4_hdr *,
-- 
1.6.2.5

