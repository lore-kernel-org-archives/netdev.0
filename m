From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 17/17] tipc: remove
	tipc_snprintf
Date: Mon, 9 Feb 2015 09:50:19 +0100
Message-ID: <1423471819-23112-18-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

tipc_snprintf() was heavily utilized by the old netlink API which no
longer exists (now netlink compat).

In this patch we swap tipc_snprintf() to the identical scnprintf() in
the only remaining occurrence.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Makefile |  2 +-
 net/tipc/bearer.c |  6 +++---
 net/tipc/core.h   |  2 --
 net/tipc/log.c    | 54 ------------------------------------------------------
 4 files changed, 4 insertions(+), 60 deletions(-)
 delete mode 100644 net/tipc/log.c

diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 6864b9d..599b1a5 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_TIPC) := tipc.o
 tipc-y	+= addr.o bcast.o bearer.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
-	   netlink.o netlink_compat.o node.o socket.o log.o eth_media.o \
+	   netlink.o netlink_compat.o node.o socket.o eth_media.o \
 	   server.o socket.o
 
 tipc-$(CONFIG_TIPC_MEDIA_IB)	+= ib_media.o
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 858c5a6..48852c2 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -111,13 +111,13 @@ void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a)
 	m_ptr = media_find_id(a->media_id);
 
 	if (m_ptr && !m_ptr->addr2str(a, addr_str, sizeof(addr_str)))
-		ret = tipc_snprintf(buf, len, "%s(%s)", m_ptr->name, addr_str);
+		ret = scnprintf(buf, len, "%s(%s)", m_ptr->name, addr_str);
 	else {
 		u32 i;
 
-		ret = tipc_snprintf(buf, len, "UNKNOWN(%u)", a->media_id);
+		ret = scnprintf(buf, len, "UNKNOWN(%u)", a->media_id);
 		for (i = 0; i < sizeof(a->value); i++)
-			ret += tipc_snprintf(buf - ret, len + ret,
+			ret += scnprintf(buf - ret, len + ret,
 					    "-%02x", a->value[i]);
 	}
 }
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 451c346..3dc68c7 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -70,8 +70,6 @@
 
 #define TIPC_MOD_VER "2.0.0"
 
-int tipc_snprintf(char *buf, int len, const char *fmt, ...);
-
 extern int tipc_net_id __read_mostly;
 extern int sysctl_tipc_rmem[3] __read_mostly;
 extern int sysctl_tipc_named_timeout __read_mostly;
diff --git a/net/tipc/log.c b/net/tipc/log.c
deleted file mode 100644
index b186af0..0000000
--- a/net/tipc/log.c
+++ /dev/null
@@ -1,54 +0,0 @@
-/*
- * net/tipc/log.c: TIPC print buffer routines for debugging
- *
- * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-
-/**
- * tipc_snprintf - append formatted output to print buffer
- * @buf: pointer to print buffer
- * @len: buffer length
- * @fmt: formatted info to be printed
- */
-int tipc_snprintf(char *buf, int len, const char *fmt, ...)
-{
-	int i;
-	va_list args;
-
-	va_start(args, fmt);
-	i = vscnprintf(buf, len, fmt, args);
-	va_end(args);
-	return i;
-}
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
