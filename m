From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 1/9] Platform: OLPC: add a stub to drivers/platform/ for the
 OLPC EC driver
Date: Wed, 18 Jul 2012 21:26:42 -0700
Message-ID: <20120718212642.3b53b54d@dev.queued.net>
References: <20120718182144.2d7b0b50@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Fox <pgf@laptop.org>, Daniel Drake <dsd@laptop.org>,
	"Richard A. Smith" <richard@laptop.org>,
	linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Matthew Garrett <mjg@redhat.com>,
	Anton Vorontsov <cbou@mail.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Chris Ball <cjb@laptop.org>,
	Jon Nettleton <jon.nettleton@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lunge.queued.net ([173.255.254.236]:50112 "EHLO
	lunge.queued.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2GSE07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 00:26:59 -0400
In-Reply-To: <20120718182144.2d7b0b50@dev.queued.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The OLPC EC driver has outgrown arch/x86/platform/.  It's time to both
share common code amongst different architectures, as well as move it out
of arch/x86/.  The XO-1.75 is ARM-based, and the EC driver shares a lot of
code with the x86 code.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 arch/x86/include/asm/olpc.h     |   19 +++----------------
 arch/x86/platform/olpc/olpc.c   |    4 ++--
 drivers/platform/Makefile       |    1 +
 drivers/platform/olpc/olpc-ec.c |   16 ++++++++++++++++
 include/linux/olpc-ec.h         |   29 +++++++++++++++++++++++++++++
 5 files changed, 51 insertions(+), 18 deletions(-)
 create mode 100644 drivers/platform/olpc/olpc-ec.c
 create mode 100644 include/linux/olpc-ec.h

diff --git a/arch/x86/include/asm/olpc.h b/arch/x86/include/asm/olpc.h
index 87bdbca..513e999 100644
--- a/arch/x86/include/asm/olpc.h
+++ b/arch/x86/include/asm/olpc.h
@@ -4,6 +4,7 @@
 #define _ASM_X86_OLPC_H
 
 #include <asm/geode.h>
+#include <linux/olpc-ec.h>
 
 struct olpc_platform_t {
 	int flags;
@@ -102,22 +103,8 @@ extern int pci_olpc_init(void);
 
 /* EC related functions */
 
-extern int olpc_ec_cmd(unsigned char cmd, unsigned char *inbuf, size_t inlen,
-		unsigned char *outbuf, size_t outlen);
-
-/* EC commands */
-
-#define EC_FIRMWARE_REV			0x08
-#define EC_WRITE_SCI_MASK		0x1b
-#define EC_WAKE_UP_WLAN			0x24
-#define EC_WLAN_LEAVE_RESET		0x25
-#define EC_READ_EB_MODE			0x2a
-#define EC_SET_SCI_INHIBIT		0x32
-#define EC_SET_SCI_INHIBIT_RELEASE	0x34
-#define EC_WLAN_ENTER_RESET		0x35
-#define EC_WRITE_EXT_SCI_MASK		0x38
-#define EC_SCI_QUERY			0x84
-#define EC_EXT_SCI_QUERY		0x85
+extern int olpc_ec_cmd_x86(unsigned char cmd, unsigned char *inbuf,
+		size_t inlen, unsigned char *outbuf, size_t outlen);
 
 /* SCI source values */
 
diff --git a/arch/x86/platform/olpc/olpc.c b/arch/x86/platform/olpc/olpc.c
index a4bee53..796e199 100644
--- a/arch/x86/platform/olpc/olpc.c
+++ b/arch/x86/platform/olpc/olpc.c
@@ -125,7 +125,7 @@ static int __wait_on_obf(unsigned int line, unsigned int port, int desired)
  * <http://wiki.laptop.org/go/Ec_specification>.  Unfortunately, while
  * OpenFirmware's source is available, the EC's is not.
  */
-int olpc_ec_cmd(unsigned char cmd, unsigned char *inbuf, size_t inlen,
+int olpc_ec_cmd_x86(unsigned char cmd, unsigned char *inbuf, size_t inlen,
 		unsigned char *outbuf,  size_t outlen)
 {
 	unsigned long flags;
@@ -201,7 +201,7 @@ err:
 	spin_unlock_irqrestore(&ec_lock, flags);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(olpc_ec_cmd);
+EXPORT_SYMBOL_GPL(olpc_ec_cmd_x86);
 
 void olpc_ec_wakeup_set(u16 value)
 {
diff --git a/drivers/platform/Makefile b/drivers/platform/Makefile
index 782953a..b17c16c 100644
--- a/drivers/platform/Makefile
+++ b/drivers/platform/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_X86)		+= x86/
+obj-$(CONFIG_OLPC)		+= olpc/
diff --git a/drivers/platform/olpc/olpc-ec.c b/drivers/platform/olpc/olpc-ec.c
new file mode 100644
index 0000000..4202603
--- /dev/null
+++ b/drivers/platform/olpc/olpc-ec.c
@@ -0,0 +1,16 @@
+/*
+ * Generic driver for the OLPC Embedded Controller.
+ *
+ * Copyright (C) 2011-2012 One Laptop per Child Foundation.
+ *
+ * Licensed under the GPL v2 or later.
+ */
+#include <linux/module.h>
+#include <asm/olpc.h>
+
+int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen)
+{
+	/* Currently a stub; this will be expanded upon later. */
+	return olpc_ec_cmd_x86(cmd, inbuf, inlen, outbuf, outlen);
+}
+EXPORT_SYMBOL_GPL(olpc_ec_cmd);
diff --git a/include/linux/olpc-ec.h b/include/linux/olpc-ec.h
new file mode 100644
index 0000000..6d4e426
--- /dev/null
+++ b/include/linux/olpc-ec.h
@@ -0,0 +1,29 @@
+#ifndef _LINUX_OLPC_EC_H
+#define _LINUX_OLPC_EC_H
+
+/* XO-1 EC commands */
+#define EC_FIRMWARE_REV			0x08
+#define EC_WRITE_SCI_MASK		0x1b
+#define EC_WAKE_UP_WLAN			0x24
+#define EC_WLAN_LEAVE_RESET		0x25
+#define EC_READ_EB_MODE			0x2a
+#define EC_SET_SCI_INHIBIT		0x32
+#define EC_SET_SCI_INHIBIT_RELEASE	0x34
+#define EC_WLAN_ENTER_RESET		0x35
+#define EC_WRITE_EXT_SCI_MASK		0x38
+#define EC_SCI_QUERY			0x84
+#define EC_EXT_SCI_QUERY		0x85
+
+#ifdef CONFIG_OLPC
+
+extern int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf,
+		size_t outlen);
+
+#else
+
+static inline int olpc_ec_cmd(u8 cmd, u8 *inbuf, size_t inlen, u8 *outbuf,
+		size_t outlen) { return -ENODEV; }
+
+#endif /* CONFIG_OLPC */
+
+#endif /* _LINUX_OLPC_EC_H */
-- 
1.7.2.5
