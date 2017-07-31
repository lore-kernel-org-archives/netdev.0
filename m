From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V5 1/2] firmware: add more flexible request_firmware_async function
Date: Mon, 31 Jul 2017 17:09:44 +0200
Message-ID: <20170731150945.8925-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Daniel Wagner <wagi@monom.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>, yi1.li@linux.intel.com,
        atull@kernel.org, Moritz Fischer <moritz.fischer@ettus.com>,
        pmladek@suse.com, Johannes Berg <johannes.berg@intel.com>,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        Kalle Valo <kvalo@codeaurora.org>, luto@kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Howells <dhowells@redhat.com>, pjones@redhat.com,
        Hans de Goede <hdegoede@redhat.com>, alan@linux.intel.com,
        tytso@mit.edu, lkml <linux-kernel@vger.kernel.org>,
        Franky Lin <franky.li
To: "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

So far we got only one function for loading firmware asynchronously:
request_firmware_nowait. It didn't allow much customization of firmware
loading process - there is only one bool uevent argument. Moreover this
bool also controls user helper in an unclear way.

Some drivers need more flexible helper providing more options. This
includes control over uevent or warning for the missing firmware. Of
course this list may grow up in the future.

To handle this easily this patch adds a generic request_firmware_async
function. It takes struct with options as an argument which will allow
extending it in the future without massive changes.

This is a really cheap change (no new independent API) which works
nicely with the existing code. The old request_firmware_nowait is kept
as a simple helper calling new helper.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V3: Don't expose all FW_OPT_* flags.
    As Luis noted we want a struct so add struct firmware_opts for real
    flexibility.
    Thank you Luis for your review!
V5: Rebase, update commit message, resend after drvdata discussion
---
 drivers/base/firmware_class.c | 43 ++++++++++++++++++++++++++++++++++---------
 include/linux/firmware.h      | 15 ++++++++++++++-
 2 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_class.c
index b9f907eedbf7..cde85b05e4cb 100644
--- a/drivers/base/firmware_class.c
+++ b/drivers/base/firmware_class.c
@@ -1375,7 +1375,7 @@ static void request_firmware_work_func(struct work_struct *work)
 	_request_firmware(&fw, fw_work->name, fw_work->device, NULL, 0,
 			  fw_work->opt_flags);
 	fw_work->cont(fw, fw_work->context);
-	put_device(fw_work->device); /* taken in request_firmware_nowait() */
+	put_device(fw_work->device); /* taken in __request_firmware_nowait() */
 
 	module_put(fw_work->module);
 	kfree_const(fw_work->name);
@@ -1383,10 +1383,9 @@ static void request_firmware_work_func(struct work_struct *work)
 }
 
 /**
- * request_firmware_nowait - asynchronous version of request_firmware
+ * __request_firmware_nowait - asynchronous version of request_firmware
  * @module: module requesting the firmware
- * @uevent: sends uevent to copy the firmware image if this flag
- *	is non-zero else the firmware copy must be done manually.
+ * @opt_flags: flags that control firmware loading process, see FW_OPT_*
  * @name: name of firmware file
  * @device: device for which firmware is being loaded
  * @gfp: allocation flags
@@ -1405,9 +1404,9 @@ static void request_firmware_work_func(struct work_struct *work)
  *
  *		- can't sleep at all if @gfp is GFP_ATOMIC.
  **/
-int
-request_firmware_nowait(
-	struct module *module, bool uevent,
+static int
+__request_firmware_nowait(
+	struct module *module, unsigned int opt_flags,
 	const char *name, struct device *device, gfp_t gfp, void *context,
 	void (*cont)(const struct firmware *fw, void *context))
 {
@@ -1426,8 +1425,7 @@ request_firmware_nowait(
 	fw_work->device = device;
 	fw_work->context = context;
 	fw_work->cont = cont;
-	fw_work->opt_flags = FW_OPT_NOWAIT | FW_OPT_FALLBACK |
-		(uevent ? FW_OPT_UEVENT : FW_OPT_USERHELPER);
+	fw_work->opt_flags = FW_OPT_NOWAIT | opt_flags;
 
 	if (!try_module_get(module)) {
 		kfree_const(fw_work->name);
@@ -1440,8 +1438,35 @@ request_firmware_nowait(
 	schedule_work(&fw_work->work);
 	return 0;
 }
+
+int request_firmware_nowait(struct module *module, bool uevent,
+			    const char *name, struct device *device, gfp_t gfp,
+			    void *context,
+			    void (*cont)(const struct firmware *fw, void *context))
+{
+	unsigned int opt_flags = FW_OPT_FALLBACK |
+		(uevent ? FW_OPT_UEVENT : FW_OPT_USERHELPER);
+
+	return __request_firmware_nowait(module, opt_flags, name, device, gfp,
+					 context, cont);
+}
 EXPORT_SYMBOL(request_firmware_nowait);
 
+int __request_firmware_async(struct module *module, const char *name,
+			     struct firmware_opts *fw_opts, struct device *dev,
+			     void *context,
+			     void (*cont)(const struct firmware *fw, void *context))
+{
+	unsigned int opt_flags = FW_OPT_UEVENT;
+
+	if (fw_opts->optional)
+		opt_flags |= FW_OPT_NO_WARN;
+
+	return __request_firmware_nowait(module, opt_flags, name, dev,
+					 GFP_KERNEL, context, cont);
+}
+EXPORT_SYMBOL(__request_firmware_async);
+
 #ifdef CONFIG_PM_SLEEP
 static ASYNC_DOMAIN_EXCLUSIVE(fw_cache_domain);
 
diff --git a/include/linux/firmware.h b/include/linux/firmware.h
index b1f9f0ccb8ac..a32b6e67462d 100644
--- a/include/linux/firmware.h
+++ b/include/linux/firmware.h
@@ -82,6 +82,19 @@ static inline int request_firmware_into_buf(const struct firmware **firmware_p,
 {
 	return -EINVAL;
 }
-
 #endif
+
+struct firmware_opts {
+	bool optional;
+};
+
+int __request_firmware_async(struct module *module, const char *name,
+			     struct firmware_opts *fw_opts, struct device *dev,
+			     void *context,
+			     void (*cont)(const struct firmware *fw, void *context));
+
+#define request_firmware_async(name, fw_opts, dev, context, cont)	\
+	__request_firmware_async(THIS_MODULE, name, fw_opts, dev,	\
+				 context, cont)
+
 #endif
-- 
2.11.0
