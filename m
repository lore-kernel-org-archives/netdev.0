From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH] net: core: move mac_pton() to lib/net_utils.c
Date: Tue,  4 Jun 2013 19:46:26 +0300
Message-ID: <1370364386-5034-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we have at least one user of this function outside of CONFIG_NET
scope, we have to provide this function independently. The proposed
solution is to move it under lib/net_utils.c with corresponding
configuration variable and select wherever it is needed.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/misc/Kconfig     |  1 +
 drivers/net/netconsole.c |  1 +
 include/linux/if_ether.h |  1 -
 include/linux/kernel.h   |  2 ++
 lib/Kconfig              |  3 +++
 lib/Makefile             |  2 ++
 lib/net_utils.c          | 26 ++++++++++++++++++++++++++
 net/Kconfig              |  1 +
 net/core/netpoll.c       |  1 +
 net/core/utils.c         | 22 ----------------------
 10 files changed, 37 insertions(+), 23 deletions(-)
 create mode 100644 lib/net_utils.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index c002d86..80889d5 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -480,6 +480,7 @@ config BMP085_SPI
 
 config PCH_PHUB
 	tristate "Intel EG20T PCH/LAPIS Semicon IOH(ML7213/ML7223/ML7831) PHUB"
+	select GENERIC_NET_UTILS
 	depends on PCI
 	help
 	  This driver is for PCH(Platform controller Hub) PHUB(Packet Hub) of
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index c96a7a7..2cf3ed8 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -40,6 +40,7 @@
 #include <linux/slab.h>
 #include <linux/console.h>
 #include <linux/moduleparam.h>
+#include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/netpoll.h>
 #include <linux/inet.h>
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 12b4d55..d556973 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -30,7 +30,6 @@ static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
 
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 
-int mac_pton(const char *s, u8 *mac);
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
 #endif	/* _LINUX_IF_ETHER_H */
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index bd95d1f..cf23b15 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -450,6 +450,8 @@ static inline char * __deprecated pack_hex_byte(char *buf, u8 byte)
 extern int hex_to_bin(char ch);
 extern int __must_check hex2bin(u8 *dst, const char *src, size_t count);
 
+int mac_pton(const char *s, u8 *mac);
+
 /*
  * General tracing related utility functions - trace_printk(),
  * tracing_on/tracing_off and tracing_start()/tracing_stop
diff --git a/lib/Kconfig b/lib/Kconfig
index c2ce4fd..1464562 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -22,6 +22,9 @@ config GENERIC_STRNCPY_FROM_USER
 config GENERIC_STRNLEN_USER
 	bool
 
+config GENERIC_NET_UTILS
+	bool
+
 config GENERIC_FIND_FIRST_BIT
 	bool
 
diff --git a/lib/Makefile b/lib/Makefile
index af911db..c676cf4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -141,6 +141,8 @@ obj-$(CONFIG_DDR) += jedec_ddr_data.o
 obj-$(CONFIG_GENERIC_STRNCPY_FROM_USER) += strncpy_from_user.o
 obj-$(CONFIG_GENERIC_STRNLEN_USER) += strnlen_user.o
 
+obj-$(CONFIG_GENERIC_NET_UTILS) += net_utils.o
+
 obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
 
 libfdt_files = fdt.o fdt_ro.o fdt_wip.o fdt_rw.o fdt_sw.o fdt_strerror.o
diff --git a/lib/net_utils.c b/lib/net_utils.c
new file mode 100644
index 0000000..2e3c52c
--- /dev/null
+++ b/lib/net_utils.c
@@ -0,0 +1,26 @@
+#include <linux/string.h>
+#include <linux/if_ether.h>
+#include <linux/ctype.h>
+#include <linux/kernel.h>
+
+int mac_pton(const char *s, u8 *mac)
+{
+	int i;
+
+	/* XX:XX:XX:XX:XX:XX */
+	if (strlen(s) < 3 * ETH_ALEN - 1)
+		return 0;
+
+	/* Don't dirty result unless string is valid MAC. */
+	for (i = 0; i < ETH_ALEN; i++) {
+		if (!isxdigit(s[i * 3]) || !isxdigit(s[i * 3 + 1]))
+			return 0;
+		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
+			return 0;
+	}
+	for (i = 0; i < ETH_ALEN; i++) {
+		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
+	}
+	return 1;
+}
+EXPORT_SYMBOL(mac_pton);
diff --git a/net/Kconfig b/net/Kconfig
index 523e43e..2273655 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -5,6 +5,7 @@
 menuconfig NET
 	bool "Networking support"
 	select NLATTR
+	select GENERIC_NET_UTILS
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 688517c..b9bb88b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -12,6 +12,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/moduleparam.h>
+#include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/string.h>
diff --git a/net/core/utils.c b/net/core/utils.c
index 3c7f5b5..aa88e23 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -338,25 +338,3 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 				  csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
-
-int mac_pton(const char *s, u8 *mac)
-{
-	int i;
-
-	/* XX:XX:XX:XX:XX:XX */
-	if (strlen(s) < 3 * ETH_ALEN - 1)
-		return 0;
-
-	/* Don't dirty result unless string is valid MAC. */
-	for (i = 0; i < ETH_ALEN; i++) {
-		if (!isxdigit(s[i * 3]) || !isxdigit(s[i * 3 + 1]))
-			return 0;
-		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
-			return 0;
-	}
-	for (i = 0; i < ETH_ALEN; i++) {
-		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
-	}
-	return 1;
-}
-EXPORT_SYMBOL(mac_pton);
-- 
1.8.3.101.g727a46b
