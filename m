From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] rtlwifi: Standardize RT_PRINT_DATA macro and uses
Date: Thu, 05 Jan 2012 08:29:07 -0800
Message-ID: <1325780947.22154.14.camel@joe2Laptop>
References: <cover.1325734202.git.joe@perches.com>
	 <e7d4163a9897f33145d8a07be54f507ab68e0243.1325734203.git.joe@perches.com>
	 <20120105114314.GD2222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105114314.GD2222@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 12:43 +0100, Stanislaw Gruszka wrote:
> Hi Joe

Morning Stanislaw.

> On Wed, Jan 04, 2012 at 07:40:40PM -0800, Joe Perches wrote:
> >  	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
> 
> Since you are working on it, can you also get rid of this DBG_*
> parameter, if rtlwifi maintainers are ok with that? It is additional
> console loglvevel, standard kernel loglevel should be used.

Not quite, all of the RT_PRINT_DATA are emitted at KERN_DEBUG.
These DBG_*s are just a normal debug verbosity level. 

It does seem odd though to have a DBG_EMERG and not always
emit it.

What might also be useful for any embedded use is to add
CONFIG_RTLWIFI_DEBUG to conditionally remove all of the
debug logging code to reduce the largish object size.

This reduces the object size by about 1/3 (250KB)
when CONFIG_RTLWIFI_DEBUG is not set.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 368722	  55333	  94224	 518279	  7e887	drivers/net/wireless/rtlwifi/built-in.o.new
 586904	  55333	 127216	 769453	  bbdad	drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>

---

 drivers/net/wireless/rtlwifi/Kconfig |    5 +++++
 drivers/net/wireless/rtlwifi/debug.h |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index d6c42e6..44b9c0a 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -49,6 +49,11 @@ config RTLWIFI
 	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
 	default m
 
+config RTLWIFI_DEBUG
+	tristate "Additional debugging output"
+	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
+	default y
+
 config RTL8192C_COMMON
 	tristate
 	depends on RTL8192CE || RTL8192CU
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index b024c23..fd5600c 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -156,6 +156,8 @@ enum dbgp_flag_e {
 	DBGP_TYPE_MAX
 };
 
+#ifdef CONFIG_RTLWIFI_DEBUG
+
 #define RT_ASSERT(_exp, fmt, ...)					\
 do {									\
 	if (!(_exp)) {							\
@@ -195,5 +197,37 @@ do {									\
 	}								\
 } while (0)
 
+#else
+
+struct rtl_priv;
+
+__printf(2, 3)
+static inline void RT_ASSERT(int exp, const char *fmt, ...)
+{
+}
+
+__printf(4, 5)
+static inline void RT_TRACE(struct rtl_priv *rtlpriv,
+			    int comp, int level,
+			    const char *fmt, ...)
+{
+}
+
+__printf(4, 5)
+static inline void RTPRINT(struct rtl_priv *rtlpriv,
+			   int dbgtype, int dbgflag,
+			   const char *fmt, ...)
+{
+}
+
+static inline void RT_PRINT_DATA(struct rtl_priv *rtlpriv,
+				 int comp, int level,
+				 const char *titlestring,
+				 const void *hexdata, size_t hexdatalen)
+{
+}
+
+#endif
+
 void rtl_dbgp_flag_init(struct ieee80211_hw *hw);
 #endif
