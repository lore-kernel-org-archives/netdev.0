From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 v4.2-rc1] printk: make extended printk support conditional
 on netconsole
Date: Fri, 3 Jul 2015 12:22:51 -0400
Message-ID: <20150703162251.GB5273@mtj.duckdns.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
 <20150629161355.GS15805@mtj.duckdns.org>
 <20150629233140.GA7711@mtj.duckdns.org>
 <20150702162141.GC30677@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmladek@suse.cz, "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150702162141.GC30677@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

6fe29354befe ("printk: implement support for extended console
drivers") implemented extended printk support for extended netconsole.
The code added was miniscule but it added static 8k buffer
unconditionally unnecessarily bloating the kernel for cases where
extended netconsole is not used.

This patch introduces CONFIG_PRINTK_CON_EXTENDED which is selected by
CONFIG_NETCONSOLE.  If the config option is not set, extended printk
support is compiled out along with the static buffer.

Verified 8k reduction in vmlinux bss when !CONFIG_NETCONSOLE.

v2: Added a warning for cases where CON_EXTENDED is requested while
    CONFIG_PRINTK_CON_EXTENDED is disabled as suggested by Petr.

v3: Moved ext console enable info messages into the inc function.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-and-suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Reviewed-by: Petr Mladek <pmladek@suse.com>
---
 drivers/net/Kconfig    |    1 +
 init/Kconfig           |    3 +++
 kernel/printk/printk.c |   38 ++++++++++++++++++++++++++++++++++----
 3 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 019fcef..39587f1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -195,6 +195,7 @@ config GENEVE
 
 config NETCONSOLE
 	tristate "Network console logging support"
+	select PRINTK_CON_EXTENDED
 	---help---
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
diff --git a/init/Kconfig b/init/Kconfig
index bcc41bd..cd281ab 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1438,6 +1438,9 @@ config PRINTK
 	  very difficult to diagnose system problems, saying N here is
 	  strongly discouraged.
 
+config PRINTK_CON_EXTENDED
+	bool
+
 config BUG
 	bool "BUG() support" if EXPERT
 	default y
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index cf8c242..841ea4d 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -84,6 +84,10 @@ static struct lockdep_map console_lock_dep_map = {
 };
 #endif
 
+#ifdef CONFIG_PRINTK_CON_EXTENDED
+
+#define CONSOLE_EXT_LOG_BUF_LEN		CONSOLE_EXT_LOG_MAX
+
 /*
  * Number of registered extended console drivers.
  *
@@ -96,6 +100,33 @@ static struct lockdep_map console_lock_dep_map = {
  */
 static int nr_ext_console_drivers;
 
+static void inc_nr_ext_console_drivers(void)
+{
+	if (!nr_ext_console_drivers++)
+		pr_info("printk: continuation disabled due to ext consoles, expect more fragments in /dev/kmsg\n");
+}
+
+static void dec_nr_ext_console_drivers(void)
+{
+	nr_ext_console_drivers--;
+}
+
+#else	/* CONFIG_PRINTK_CON_EXTENDED */
+
+#define CONSOLE_EXT_LOG_BUF_LEN		0
+#define nr_ext_console_drivers		0
+
+static void inc_nr_ext_console_drivers(void)
+{
+	WARN_ONCE(true, "printk: CON_EXTENDED requested when !CONFIG_PRINTK_CON_EXTENDED\n");
+}
+
+static void dec_nr_ext_console_drivers(void)
+{
+}
+
+#endif	/* CONFIG_PRINTK_CON_EXTENDED */
+
 /*
  * Helper macros to handle lockdep when locking/unlocking console_sem. We use
  * macros instead of functions so that _RET_IP_ contains useful information.
@@ -2224,7 +2255,7 @@ static void console_cont_flush(char *text, size_t size)
  */
 void console_unlock(void)
 {
-	static char ext_text[CONSOLE_EXT_LOG_MAX];
+	static char ext_text[CONSOLE_EXT_LOG_BUF_LEN];
 	static char text[LOG_LINE_MAX + PREFIX_MAX];
 	static u64 seen_seq;
 	unsigned long flags;
@@ -2562,8 +2593,7 @@ void register_console(struct console *newcon)
 	}
 
 	if (newcon->flags & CON_EXTENDED)
-		if (!nr_ext_console_drivers++)
-			pr_info("printk: continuation disabled due to ext consoles, expect more fragments in /dev/kmsg\n");
+		inc_nr_ext_console_drivers();
 
 	if (newcon->flags & CON_PRINTBUFFER) {
 		/*
@@ -2638,7 +2668,7 @@ int unregister_console(struct console *console)
 	}
 
 	if (!res && (console->flags & CON_EXTENDED))
-		nr_ext_console_drivers--;
+		dec_nr_ext_console_drivers();
 
 	/*
 	 * If this isn't the last console and it has CON_CONSDEV set, we
