From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: firmware_check() encodes the firmware version
	in i2400m->fw_version
Date: Sun,  1 Mar 2009 01:42:49 -0800
Message-ID: <1235900574-15319-3-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-2-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <1235900574-15319-2-git-send-email-inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Upcoming modifications will need to test for the running firmware
version before activating a feature or not. This is helpful to
implement backward compatibility with older firmware versions.

Modify i2400m_firmware_check() to encode in i2400m->fw_version the
major and minor version numbers of the firmware interface.

As well, move the call to be done as the very first operation once we
have communication with the device during probe() [in
__i2400m_dev_start()]. This is needed so any operation that is
executed afterwards can determine which fw version it is talking to.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   12 +++++++-----
 drivers/net/wimax/i2400m/driver.c  |    5 +++++
 drivers/net/wimax/i2400m/i2400m.h  |    4 ++++
 3 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index ac8fb6d..c8b3a68 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -52,7 +52,6 @@
  *
  * i2400m_dev_initalize()       Called by i2400m_dev_start()
  *   i2400m_set_init_config()
- *   i2400m_firmware_check()
  *   i2400m_cmd_get_state()
  * i2400m_dev_shutdown()        Called by i2400m_dev_stop()
  *   i2400m->bus_reset()
@@ -959,6 +958,10 @@ enum {
  * Long function, but quite simple; first chunk launches the command
  * and double checks the reply for the right TLV. Then we process the
  * TLV (where the meat is).
+ *
+ * Once we process the TLV that gives us the firmware's interface
+ * version, we encode it and save it in i2400m->fw_version for future
+ * reference.
  */
 int i2400m_firmware_check(struct i2400m *i2400m)
 {
@@ -1018,9 +1021,11 @@ int i2400m_firmware_check(struct i2400m *i2400m)
 	if (minor < I2400M_HDIv_MINOR_2 && minor > I2400M_HDIv_MINOR)
 		dev_warn(dev, "untested minor fw version %u.%u.%u\n",
 			 major, minor, branch);
-error_bad_major:
+	/* Yes, we ignore the branch -- we don't have to track it */
+	i2400m->fw_version = major << 16 | minor;
 	dev_info(dev, "firmware interface version %u.%u.%u\n",
 		 major, minor, branch);
+error_bad_major:
 error_no_tlv:
 error_cmd_failed:
 	kfree_skb(ack_skb);
@@ -1251,9 +1256,6 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	result = i2400m_set_init_config(i2400m, args, argc);
 	if (result < 0)
 		goto error;
-	result = i2400m_firmware_check(i2400m);	/* fw versions ok? */
-	if (result < 0)
-		goto error;
 	/*
 	 * Update state: Here it just calls a get state; parsing the
 	 * result (System State TLV and RF Status TLV [done in the rx
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index e80a0b6..69a816e 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -48,6 +48,7 @@
  *       i2400m_dev_bootstrap()
  *       i2400m_tx_setup()
  *       i2400m->bus_dev_start()
+ *       i2400m_firmware_check()
  *       i2400m_check_mac_addr()
  *   wimax_dev_add()
  *
@@ -404,6 +405,9 @@ retry:
 		dev_err(dev, "cannot create workqueue\n");
 		goto error_create_workqueue;
 	}
+	result = i2400m_firmware_check(i2400m);	/* fw versions ok? */
+	if (result < 0)
+		goto error_fw_check;
 	/* At this point is ok to send commands to the device */
 	result = i2400m_check_mac_addr(i2400m);
 	if (result < 0)
@@ -421,6 +425,7 @@ retry:
 
 error_dev_initialize:
 error_check_mac_addr:
+error_fw_check:
 	destroy_workqueue(i2400m->work_queue);
 error_create_workqueue:
 	i2400m->bus_dev_stop(i2400m);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index ad71ad1..5008cdb 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -366,6 +366,9 @@ struct i2400m_reset_ctx;
  *     module unloads, as we don't keep each dentry.
  *
  * @fw_name: name of the firmware image that is currently being used.
+ *
+ * @fw_version: version of the firmware interface, Major.minor,
+ *     encoded in the high word and low word (major << 16 | minor).
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -424,6 +427,7 @@ struct i2400m {
 
 	struct dentry *debugfs_dentry;
 	const char *fw_name;		/* name of the current firmware image */
+	unsigned long fw_version;	/* version of the firmware interface */
 };
 
 
-- 
1.5.6.5
