From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 12/15] wimax/i2400m: fix reboot echo/ack barker deadlock
Date: Wed,  4 Nov 2009 13:39:53 -0800
Message-ID: <923d708fed9d47c7b4d67694500d766337663e29.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932719AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m based devices can get in a sort of a deadlock some times;
when they boot, they send a reboot "barker" (a magic number) and then
the driver has to echo that same barker to ack reception
(echo/ack). Then the device does a final ack by sending an ACK barker.

The first time this happens, we don't know ahead of time with barker
the device is going to send, as different device models and SKUs will
send different barker depending on the EEPROM programming.

If the device has sent the barker before the driver has been able to
read it, the driver looses, as it doesn't know which barker it has to
echo/ack back. With older devices, we tried a couple of combinations
and that always worked; but now, with adding support for more, in
which we have an unlimited number of new barkers, that is not an
option.

So we rework said case so that when the device gets stuck, we just
cycle through all the known types until one forces the device to send
an ack. Otherwise, the driver gives up and aborts.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |   63 +++++++++++++++++++++++++++++++++--------
 include/linux/wimax/i2400m.h  |    2 +-
 2 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 55fe011..eef236d 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -812,7 +812,7 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
  *
  * @i2400m: device descriptor
  * @flags:
- *      I2400M_BRI_SOFT: a reboot notification has been seen
+ *      I2400M_BRI_SOFT: a reboot barker has been seen
  *          already, so don't wait for it.
  *
  *      I2400M_BRI_NO_REBOOT: Don't send a reboot command, but wait
@@ -829,8 +829,9 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
  * main phases to this:
  *
  * a. (1) send a reboot command and (2) get a reboot barker
- * b. (1) ack the reboot sending a reboot barker and (2) getting an
- *        ack barker in return
+ *
+ * b. (1) echo/ack the reboot sending the reboot barker back and (2)
+ *        getting an ack barker in return
  *
  * We want to skip (a) in some cases [soft]. The state machine is
  * horrible, but it is basically: on each phase, send what has to be
@@ -838,6 +839,16 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
  * have to backtrack and retry, so we keep a max tries counter for
  * that.
  *
+ * It sucks because we don't know ahead of time which is going to be
+ * the reboot barker (the device might send different ones depending
+ * on its EEPROM config) and once the device reboots and waits for the
+ * echo/ack reboot barker being sent back, it doesn't understand
+ * anything else. So we can be left at the point where we don't know
+ * what to send to it -- cold reset and bus reset seem to have little
+ * effect. So the function iterates (in this case) through all the
+ * known barkers and tries them all until an ACK is
+ * received. Otherwise, it gives up.
+ *
  * If we get a timeout after sending a warm reset, we do it again.
  */
 int i2400m_bootrom_init(struct i2400m *i2400m, enum i2400m_bri flags)
@@ -848,6 +859,7 @@ int i2400m_bootrom_init(struct i2400m *i2400m, enum i2400m_bri flags)
 	struct i2400m_bootrom_header ack;
 	int count = i2400m->bus_bm_retries;
 	int ack_timeout_cnt = 1;
+	unsigned i;
 
 	BUILD_BUG_ON(sizeof(*cmd) != sizeof(i2400m_barker_db[0].data));
 	BUILD_BUG_ON(sizeof(ack) != sizeof(i2400m_ACK_BARKER));
@@ -858,6 +870,7 @@ int i2400m_bootrom_init(struct i2400m *i2400m, enum i2400m_bri flags)
 	if (flags & I2400M_BRI_SOFT)
 		goto do_reboot_ack;
 do_reboot:
+	ack_timeout_cnt = 1;
 	if (--count < 0)
 		goto error_timeout;
 	d_printf(4, dev, "device reboot: reboot command [%d # left]\n",
@@ -869,22 +882,47 @@ do_reboot:
 	flags &= ~I2400M_BRI_NO_REBOOT;
 	switch (result) {
 	case -ERESTARTSYS:
+		/*
+		 * at this point, i2400m_bm_cmd(), through
+		 * __i2400m_bm_ack_process(), has updated
+		 * i2400m->barker and we are good to go.
+		 */
 		d_printf(4, dev, "device reboot: got reboot barker\n");
 		break;
 	case -EISCONN:	/* we don't know how it got here...but we follow it */
 		d_printf(4, dev, "device reboot: got ack barker - whatever\n");
 		goto do_reboot;
-	case -ETIMEDOUT:	/* device has timed out, we might be in boot
-				 * mode already and expecting an ack, let's try
-				 * that */
-		if (i2400m->barker == NULL) {
-			dev_info(dev, "warm reset timed out, unknown barker "
-				 "type, rebooting\n");
-			goto do_reboot;
-		} else {
-			dev_info(dev, "warm reset timed out, trying an ack\n");
+	case -ETIMEDOUT:
+		/*
+		 * Device has timed out, we might be in boot mode
+		 * already and expecting an ack; if we don't know what
+		 * the barker is, we just send them all. Cold reset
+		 * and bus reset don't work. Beats me.
+		 */
+		if (i2400m->barker != NULL) {
+			dev_err(dev, "device boot: reboot barker timed out, "
+				"trying (set) %08x echo/ack\n",
+				le32_to_cpu(i2400m->barker->data[0]));
 			goto do_reboot_ack;
 		}
+		for (i = 0; i < i2400m_barker_db_used; i++) {
+			struct i2400m_barker_db *barker = &i2400m_barker_db[i];
+			memcpy(cmd, barker->data, sizeof(barker->data));
+			result = i2400m_bm_cmd(i2400m, cmd, sizeof(*cmd),
+					       &ack, sizeof(ack),
+					       I2400M_BM_CMD_RAW);
+			if (result == -EISCONN) {
+				dev_warn(dev, "device boot: got ack barker "
+					 "after sending echo/ack barker "
+					 "#%d/%08x; rebooting j.i.c.\n",
+					 i, le32_to_cpu(barker->data[0]));
+				flags &= ~I2400M_BRI_NO_REBOOT;
+				goto do_reboot;
+			}
+		}
+		dev_err(dev, "device boot: tried all the echo/acks, could "
+			"not get device to respond; giving up");
+		result = -ESHUTDOWN;
 	case -EPROTO:
 	case -ESHUTDOWN:	/* dev is gone */
 	case -EINTR:		/* user cancelled */
@@ -892,6 +930,7 @@ do_reboot:
 	default:
 		dev_err(dev, "device reboot: error %d while waiting "
 			"for reboot barker - rebooting\n", result);
+		d_dump(1, dev, &ack, result);
 		goto do_reboot;
 	}
 	/* At this point we ack back with 4 REBOOT barkers and expect
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index d6e2a35..fd5af05 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -138,7 +138,7 @@ struct i2400m_bcf_hdr {
 	__le32 module_id;
 	__le32 module_vendor;
 	__le32 date;		/* BCD YYYMMDD */
-	__le32 size;
+	__le32 size;            /* in dwords */
 	__le32 key_size;	/* in dwords */
 	__le32 modulus_size;	/* in dwords */
 	__le32 exponent_size;	/* in dwords */
-- 
1.6.2.5

