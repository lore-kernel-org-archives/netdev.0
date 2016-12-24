From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/6] firmware: Add request_firmware_prefer_user() function
Date: Sat, 24 Dec 2016 17:52:56 +0100
Message-ID: <1482598381-16513-2-git-send-email-pali.rohar@gmail.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482598381-16513-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This function works pretty much like request_firmware(), but it prefer
usermode helper. If usermode helper fails then it fallback to direct
access. Useful for dynamic or model specific firmware data.

Signed-off-by: Pali Rohár <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/base/firmware_class.c |   45 +++++++++++++++++++++++++++++++++++++++--
 include/linux/firmware.h      |    9 +++++++++
 2 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_class.c
index 22d1760..6a8c261 100644
--- a/drivers/base/firmware_class.c
+++ b/drivers/base/firmware_class.c
@@ -119,6 +119,11 @@ static inline long firmware_loading_timeout(void)
 #endif
 #define FW_OPT_NO_WARN	(1U << 3)
 #define FW_OPT_NOCACHE	(1U << 4)
+#ifdef CONFIG_FW_LOADER_USER_HELPER
+#define FW_OPT_PREFER_USER	(1U << 5)
+#else
+#define FW_OPT_PREFER_USER	0
+#endif
 
 struct firmware_cache {
 	/* firmware_buf instance will be added into the below list */
@@ -1169,13 +1174,26 @@ static int assign_firmware_buf(struct firmware *fw, struct device *device,
 		}
 	}
 
-	ret = fw_get_filesystem_firmware(device, fw->priv);
+	if (opt_flags & FW_OPT_PREFER_USER) {
+		ret = fw_load_from_user_helper(fw, name, device, opt_flags, timeout);
+		if (ret && !(opt_flags & FW_OPT_NO_WARN)) {
+			dev_warn(device,
+				 "User helper firmware load for %s failed with error %d\n",
+				 name, ret);
+			dev_warn(device, "Falling back to direct firmware load\n");
+		}
+	} else {
+		ret = -EINVAL;
+	}
+
+	if (ret)
+		ret = fw_get_filesystem_firmware(device, fw->priv);
 	if (ret) {
 		if (!(opt_flags & FW_OPT_NO_WARN))
 			dev_warn(device,
 				 "Direct firmware load for %s failed with error %d\n",
 				 name, ret);
-		if (opt_flags & FW_OPT_USERHELPER) {
+		if ((opt_flags & FW_OPT_USERHELPER) && !(opt_flags & FW_OPT_PREFER_USER)) {
 			dev_warn(device, "Falling back to user helper\n");
 			ret = fw_load_from_user_helper(fw, name, device,
 						       opt_flags, timeout);
@@ -1287,6 +1305,29 @@ int request_firmware_direct(const struct firmware **firmware_p,
 EXPORT_SYMBOL(request_firmware_into_buf);
 
 /**
+ * request_firmware_prefer_user: - prefer usermode helper for loading firmware
+ * @firmware_p: pointer to firmware image
+ * @name: name of firmware file
+ * @device: device for which firmware is being loaded
+ *
+ * This function works pretty much like request_firmware(), but it prefer
+ * usermode helper. If usermode helper fails then it fallback to direct access.
+ * Useful for dynamic or model specific firmware data.
+ **/
+int request_firmware_prefer_user(const struct firmware **firmware_p,
+			    const char *name, struct device *device)
+{
+	int ret;
+
+	__module_get(THIS_MODULE);
+	ret = _request_firmware(firmware_p, name, device, NULL, 0,
+				FW_OPT_UEVENT | FW_OPT_PREFER_USER);
+	module_put(THIS_MODULE);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
+
+/**
  * release_firmware: - release the resource associated with a firmware image
  * @fw: firmware resource to release
  **/
diff --git a/include/linux/firmware.h b/include/linux/firmware.h
index b1f9f0c..01f7a85 100644
--- a/include/linux/firmware.h
+++ b/include/linux/firmware.h
@@ -47,6 +47,8 @@ int request_firmware_nowait(
 	void (*cont)(const struct firmware *fw, void *context));
 int request_firmware_direct(const struct firmware **fw, const char *name,
 			    struct device *device);
+int request_firmware_prefer_user(const struct firmware **fw, const char *name,
+				 struct device *device);
 int request_firmware_into_buf(const struct firmware **firmware_p,
 	const char *name, struct device *device, void *buf, size_t size);
 
@@ -77,6 +79,13 @@ static inline int request_firmware_direct(const struct firmware **fw,
 	return -EINVAL;
 }
 
+static inline int request_firmware_prefer_user(const struct firmware **fw,
+					       const char *name,
+					       struct device *device)
+{
+	return -EINVAL;
+}
+
 static inline int request_firmware_into_buf(const struct firmware **firmware_p,
 	const char *name, struct device *device, void *buf, size_t size)
 {
-- 
1.7.9.5
