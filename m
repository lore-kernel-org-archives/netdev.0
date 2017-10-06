From: Ivan Delalande <colona@arista.com>
Subject: [PATCH iproute2 1/2] utils: add print_escape_buf to format and print arbitrary bytes
Date: Fri,  6 Oct 2017 16:48:19 -0700
Message-ID: <20171006234820.27567-1-colona@arista.com>
Cc: netdev@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:33745 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751980AbdJFX6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:58:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep it as simple as possible for now: just escape anything that is not
isprint-able, is among the "escape" parameter or '\' as an octal escape
sequence. This should be pretty easy to extend if any other user needs
something more complex in the future.

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/utils.h |  2 ++
 lib/utils.c     | 15 +++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/utils.h b/include/utils.h
index 76addb32..3d91c50d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -195,6 +195,8 @@ static inline void __jiffies_to_tv(struct timeval *tv, unsigned long jiffies)
 	tv->tv_usec = tvusec - 1000000 * tv->tv_sec;
 }
 
+void print_escape_buf(const __u8 *buf, size_t len, const char *escape);
+
 int print_timestamp(FILE *fp);
 void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 
diff --git a/lib/utils.c b/lib/utils.c
index 0cf99619..a494190e 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -31,6 +31,7 @@
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
+#include <ctype.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -1047,6 +1048,20 @@ int addr64_n2a(__u64 addr, char *buff, size_t len)
 	return written;
 }
 
+/* Print buffer and escape bytes that are !isprint or among 'escape' */
+void print_escape_buf(const __u8 *buf, size_t len, const char *escape)
+{
+	size_t i;
+
+	for (i = 0; i < len; ++i) {
+		if (isprint(buf[i]) && buf[i] != '\\' &&
+		    !strchr(escape, buf[i]))
+			printf("%c", buf[i]);
+		else
+			printf("\\%03o", buf[i]);
+	}
+}
+
 int print_timestamp(FILE *fp)
 {
 	struct timeval tv;
-- 
2.14.2
