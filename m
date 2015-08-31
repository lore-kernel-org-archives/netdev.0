From: Joe Perches <joe@perches.com>
Subject: [PATCH] mwifiex: Make mwifiex_dbg a function, reduce object size
Date: Mon, 31 Aug 2015 10:46:45 -0700
Message-ID: <1441043205.3276.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mwifiex_dbg macro has two tests that could be consolidated
into a function reducing overall object size ~10KB (~4%).

So convert the macro into a function.

$ size drivers/net/wireless/mwifiex/built-in.o* (x86-64 defconfig)
   text	   data	    bss	    dec	    hex	filename
 233102	   8628	   4809	 246539	  3c30b	drivers/net/wireless/mwifiex/built-in.o.new
 243949	   8628	   4809	 257386	  3ed6a	drivers/net/wireless/mwifiex/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/mwifiex/main.c | 20 ++++++++++++++++++++
 drivers/net/wireless/mwifiex/main.h | 17 ++++++++---------
 2 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 278dc94..4fa8ca3 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -1447,6 +1447,26 @@ exit_sem_err:
 }
 EXPORT_SYMBOL_GPL(mwifiex_remove_card);
 
+void _mwifiex_dbg(const struct mwifiex_adapter *adapter, int mask,
+		  const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if (!adapter->dev || !(adapter->debug_mask & mask))
+		return;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	dev_info(adapter->dev, "%pV", &vaf);
+
+	va_end(args);
+}
+EXPORT_SYMBOL_GPL(_mwifiex_dbg);
+
 /*
  * This function initializes the module.
  *
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwifiex/main.h
index 6b95121..96663214 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -48,6 +48,9 @@
 
 extern const char driver_version[];
 
+struct mwifiex_adapter;
+struct mwifiex_private;
+
 enum {
 	MWIFIEX_ASYNC_CMD,
 	MWIFIEX_SYNC_CMD
@@ -180,12 +183,11 @@ enum MWIFIEX_DEBUG_LEVEL {
 					MWIFIEX_DBG_FATAL | \
 					MWIFIEX_DBG_ERROR)
 
-#define mwifiex_dbg(adapter, dbg_mask, fmt, args...)		\
-do {								\
-	if ((adapter)->debug_mask & MWIFIEX_DBG_##dbg_mask)	\
-		if ((adapter)->dev)				\
-			dev_info((adapter)->dev, fmt, ## args);	\
-} while (0)
+__printf(3, 4)
+void _mwifiex_dbg(const struct mwifiex_adapter *adapter, int mask,
+		  const char *fmt, ...);
+#define mwifiex_dbg(adapter, mask, fmt, ...)				\
+	_mwifiex_dbg(adapter, MWIFIEX_DBG_##mask, fmt, ##__VA_ARGS__)
 
 #define DEBUG_DUMP_DATA_MAX_LEN		128
 #define mwifiex_dbg_dump(adapter, dbg_mask, str, buf, len)	\
@@ -506,9 +508,6 @@ enum mwifiex_iface_work_flags {
 	MWIFIEX_IFACE_WORK_CARD_RESET,
 };
 
-struct mwifiex_adapter;
-struct mwifiex_private;
-
 struct mwifiex_private {
 	struct mwifiex_adapter *adapter;
 	u8 bss_type;
