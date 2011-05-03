From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 2/4] Cleanup defines and header includes to address
	several issues
Date: Tue, 03 May 2011 09:12:16 -0700
Message-ID: <20110503161216.29251.49320.stgit@gitlad.jf.intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57529 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab1ECQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 12:12:18 -0400
In-Reply-To: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to address several issues.  First it moves the check
for ethtool-config.h into ethtool-util.h the reason for this change is so
that any references to ethtool-util.h outside of ethtool.c will use the
correct defines for the endian types.

In addition I have pulled several headers that will be common to both
ethtool.c and rxclass.c into the ethtool-util.h header file.  I am also
centralizing several macros that will be needed across multiple files when
I implement the network flow classifier rules.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-util.h |   17 +++++++++++++++--
 ethtool.c      |   17 +----------------
 2 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/ethtool-util.h b/ethtool-util.h
index f053028..6a4f3f4 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -3,8 +3,13 @@
 #ifndef ETHTOOL_UTIL_H__
 #define ETHTOOL_UTIL_H__
 
+#ifdef HAVE_CONFIG_H
+#include "ethtool-config.h"
+#endif
 #include <sys/types.h>
 #include <endian.h>
+#include <sys/ioctl.h>
+#include <net/if.h>
 
 /* ethtool.h expects these to be defined by <linux/types.h> */
 #ifndef HAVE_BE_TYPES
@@ -12,14 +17,14 @@ typedef __uint16_t __be16;
 typedef __uint32_t __be32;
 #endif
 
-#include "ethtool-copy.h"
-
 typedef unsigned long long u64;
 typedef __uint32_t u32;
 typedef __uint16_t u16;
 typedef __uint8_t u8;
 typedef __int32_t s32;
 
+#include "ethtool-copy.h"
+
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
 {
@@ -40,6 +45,14 @@ static inline u32 cpu_to_be32(u32 value)
 }
 #endif
 
+#ifndef ARRAY_SIZE
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#ifndef SIOCETHTOOL
+#define SIOCETHTOOL     0x8946
+#endif
+
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,
diff --git a/ethtool.c b/ethtool.c
index 9ad7000..24d4e4f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -21,19 +21,12 @@
  *   * show settings for all devices
  */
 
-#ifdef HAVE_CONFIG_H
-#  include "ethtool-config.h"
-#endif
-
-#include <sys/types.h>
+#include "ethtool-util.h"
 #include <string.h>
 #include <stdlib.h>
-#include <sys/types.h>
-#include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <stdio.h>
 #include <errno.h>
-#include <net/if.h>
 #include <sys/utsname.h>
 #include <limits.h>
 #include <ctype.h>
@@ -43,18 +36,10 @@
 #include <arpa/inet.h>
 
 #include <linux/sockios.h>
-#include "ethtool-util.h"
 
-
-#ifndef SIOCETHTOOL
-#define SIOCETHTOOL     0x8946
-#endif
 #ifndef MAX_ADDR_LEN
 #define MAX_ADDR_LEN	32
 #endif
-#ifndef ARRAY_SIZE
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
-#endif
 
 #ifndef HAVE_NETIF_MSG
 enum {

