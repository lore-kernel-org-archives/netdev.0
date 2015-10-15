From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/2] overflow-arith: begin to add support for overflow builtin functions
Date: Thu, 15 Oct 2015 14:07:04 +0200
Message-ID: <1444910825-25021-1-git-send-email-hannes@stressinduktion.org>
Cc: dvyukov@google.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:60902 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752933AbbJOMHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 08:07:12 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D356E21074
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:07:11 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea of the overflow-arith.h header is to collect overflow checking
functions in one central place.

If gcc compiler supports the __builtin_overflow_* builtins we use them
because they might give better performance, otherwise the code falls
back to normal overflow checking functions.

The builtin_overflow functions are supported by gcc-5 and clang. The
matter of supporting clang is to just provide a corresponding
CC_HAVE_BUILTIN_OVERFLOW, because the specific overflow checking builtins
don't differ between gcc and clang.

I just provide overflow_usub function here as I intend this to get merged
into net, more functions will definitely follow as they are needed.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/compiler-gcc.h   |  4 ++++
 include/linux/overflow-arith.h | 18 ++++++++++++++++++
 2 files changed, 22 insertions(+)
 create mode 100644 include/linux/overflow-arith.h

diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index dfaa7b3..82c159e 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -237,6 +237,10 @@
 #define KASAN_ABI_VERSION 3
 #endif
 
+#if GCC_VERSION >= 50000
+#define CC_HAVE_BUILTIN_OVERFLOW
+#endif
+
 #endif	/* gcc version >= 40000 specific checks */
 
 #if !defined(__noclone)
diff --git a/include/linux/overflow-arith.h b/include/linux/overflow-arith.h
new file mode 100644
index 0000000..e12ccf8
--- /dev/null
+++ b/include/linux/overflow-arith.h
@@ -0,0 +1,18 @@
+#pragma once
+
+#include <linux/kernel.h>
+
+#ifdef CC_HAVE_BUILTIN_OVERFLOW
+
+#define overflow_usub __builtin_usub_overflow
+
+#else
+
+static inline bool overflow_usub(unsigned int a, unsigned int b,
+				 unsigned int *res)
+{
+	*res = a - b;
+	return *res > a ? true : false;
+}
+
+#endif
-- 
2.4.3
