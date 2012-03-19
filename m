From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 2/3] ath5k: Introduce _ath5k_printk to reduce code/text
Date: Sun, 18 Mar 2012 17:30:53 -0700
Message-ID: <b157e2d1a746733d1814b9726f326d52d36da2fc.1332116921.git.joe@perches.com>
References: <cover.1332116921.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Bob Copeland <me@bobcopeland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1332116921.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macros can be converted to functions to reduce overall object size.

Convert the ATH5K_PRINTK macro to use _ath5k_printk.

Allyesconfig size is reduced ~10%

$ size drivers/net/wireless/ath/ath5k/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 211557	   2032	  40672	 254261	  3e135	drivers/net/wireless/ath/ath5k/built-in.o.new
 235412	   2032	  47296	 284740	  45844	drivers/net/wireless/ath/ath5k/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath5k/ath5k.h |    9 +++++----
 drivers/net/wireless/ath/ath5k/base.c  |   20 ++++++++++++++++++++
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 954c373..55ef93d 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -79,11 +79,12 @@
 #define ATH5K_PRINTF(fmt, ...)						\
 	pr_warn("%s: " fmt, __func__, ##__VA_ARGS__)
 
+void __printf(3, 4)
+_ath5k_printk(const struct ath5k_hw *ah, const char *level,
+	      const char *fmt, ...);
+
 #define ATH5K_PRINTK(_sc, _level, _fmt, ...)				\
-	printk(_level pr_fmt("%s%s" _fmt),				\
-	       ((_sc) && (_sc)->hw) ? wiphy_name((_sc)->hw->wiphy) : "", \
-	       ((_sc) && (_sc)->hw) ? ": " : "",			\
-	       ##__VA_ARGS__)
+	_ath5k_printk(_sc, _level, _fmt, ##__VA_ARGS__)
 
 #define ATH5K_PRINTK_LIMIT(_sc, _level, _fmt, ...)			\
 do {									\
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index a9c0503..3007bba 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -3040,3 +3040,23 @@ ath5k_set_beacon_filter(struct ieee80211_hw *hw, bool enable)
 	ath5k_hw_set_rx_filter(ah, rfilt);
 	ah->filter_flags = rfilt;
 }
+
+void _ath5k_printk(const struct ath5k_hw *ah, const char *level,
+		   const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	if (ah && ah->hw)
+		printk("%s" pr_fmt("%s: %pV"),
+		       level, wiphy_name(ah->hw->wiphy), &vaf);
+	else
+		printk("%s" pr_fmt("%pV"), level, &vaf);
+
+	va_end(args);
+}
-- 
1.7.8.111.gad25c.dirty
