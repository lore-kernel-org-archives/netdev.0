From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 1/3] bluetooth: Add logging functions bt_info and bt_err
Date: Thu, 16 Feb 2012 23:32:42 -0800
Message-ID: <5c5e8180081e57e6098139fadd9275073048f448.1329461203.git.joe@perches.com>
References: <cover.1329461202.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1329461202.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use specific logging functions instead of a generic
bt_printk function can save some text.

Remove now unused bt_printk function.
Add compatibility BT_INFO and BT_ERR macros.

(compiled x86 and defconfig with bluetooth and all bluetooth drivers)

$ size net/bluetooth/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 381662	  20072	 100416	 502150	  7a986	net/bluetooth/built-in.o.allyesconfig.new
 382463	  20072	 100400	 502935	  7ac97	net/bluetooth/built-in.o.allyesconfig.old
 126635	   1388	    132	 128155	  1f49b	net/bluetooth/built-in.o.defconfig.new
 127175	   1388	    132	 128695	  1f6b7	net/bluetooth/built-in.o.defconfig.old

$ size drivers/bluetooth/built-in.o*
 127575	   8976	  29476	 166027	  2888b	drivers/bluetooth/built-in.o.allyesconfig.new
 129512	   8976	  29516	 168004	  29044	drivers/bluetooth/built-in.o.allyesconfig.old
  52998	   3292	    156	  56446	   dc7e	drivers/bluetooth/built-in.o.defconfig.new
  54358	   3292	    156	  57806	   e1ce	drivers/bluetooth/built-in.o.defconfig.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/bluetooth/bluetooth.h |   14 ++++++++------
 net/bluetooth/lib.c               |   27 ++++++++++++++++++++++++---
 2 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 4a82ca0..9f5f2c1 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -109,12 +109,14 @@ struct bt_power {
  */
 #define BT_CHANNEL_POLICY_AMP_PREFERRED		2
 
-__printf(2, 3)
-int bt_printk(const char *level, const char *fmt, ...);
-
-#define BT_INFO(fmt, arg...)   bt_printk(KERN_INFO, pr_fmt(fmt), ##arg)
-#define BT_ERR(fmt, arg...)    bt_printk(KERN_ERR, pr_fmt(fmt), ##arg)
-#define BT_DBG(fmt, arg...)    pr_debug(fmt "\n", ##arg)
+__printf(1, 2)
+int bt_info(const char *fmt, ...);
+__printf(1, 2)
+int bt_err(const char *fmt, ...);
+
+#define BT_INFO(fmt, ...)	bt_info(fmt "\n", ##__VA_ARGS__)
+#define BT_ERR(fmt, ...)	bt_err(fmt "\n", ##__VA_ARGS__)
+#define BT_DBG(fmt, ...)	pr_debug(fmt "\n", ##__VA_ARGS__)
 
 /* Connection and socket states */
 enum {
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index 86a6bed..5066288 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -24,6 +24,8 @@
 
 /* Bluetooth kernel library. */
 
+#define pr_fmt(fmt) "Bluetooth: " fmt
+
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -151,7 +153,26 @@ int bt_to_errno(__u16 code)
 }
 EXPORT_SYMBOL(bt_to_errno);
 
-int bt_printk(const char *level, const char *format, ...)
+int bt_info(const char *format, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, format);
+
+	vaf.fmt = format;
+	vaf.va = &args;
+
+	r = pr_info("%pV", &vaf);
+
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(bt_info);
+
+int bt_err(const char *format, ...)
 {
 	struct va_format vaf;
 	va_list args;
@@ -162,10 +183,10 @@ int bt_printk(const char *level, const char *format, ...)
 	vaf.fmt = format;
 	vaf.va = &args;
 
-	r = printk("%sBluetooth: %pV\n", level, &vaf);
+	r = pr_err("%pV", &vaf);
 
 	va_end(args);
 
 	return r;
 }
-EXPORT_SYMBOL(bt_printk);
+EXPORT_SYMBOL(bt_err);
-- 
1.7.8.111.gad25c.dirty
