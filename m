From: Thiago Farina <tfransosi@gmail.com>
Subject: [PATCH] net/9p/protocol.c: Remove duplicated macros.
Date: Sat,  4 Dec 2010 23:22:46 -0200
Message-ID: <3300e3823b702d35658175ff6379a4f77fa9a5b0.1291512089.git.tfransosi@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Sripathi Kodi <sripathik@in.ibm.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the macros already provided by kernel.h file.

Signed-off-by: Thiago Farina <tfransosi@gmail.com>
---
 net/9p/protocol.c |   33 +++++++++------------------------
 1 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 45c15f4..798beac 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -27,31 +27,16 @@
 
 #include <linux/module.h>
 #include <linux/errno.h>
+#include <linux/kernel.h>
 #include <linux/uaccess.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/stddef.h>
 #include <linux/types.h>
 #include <net/9p/9p.h>
 #include <net/9p/client.h>
 #include "protocol.h"
 
-#ifndef MIN
-#define MIN(a, b) (((a) < (b)) ? (a) : (b))
-#endif
-
-#ifndef MAX
-#define MAX(a, b) (((a) > (b)) ? (a) : (b))
-#endif
-
-#ifndef offset_of
-#define offset_of(type, memb) \
-	((unsigned long)(&((type *)0)->memb))
-#endif
-#ifndef container_of
-#define container_of(obj, type, memb) \
-	((type *)(((char *)obj) - offset_of(type, memb)))
-#endif
-
 static int
 p9pdu_writef(struct p9_fcall *pdu, int proto_version, const char *fmt, ...);
 
@@ -104,7 +89,7 @@ EXPORT_SYMBOL(p9stat_free);
 
 static size_t pdu_read(struct p9_fcall *pdu, void *data, size_t size)
 {
-	size_t len = MIN(pdu->size - pdu->offset, size);
+	size_t len = min(pdu->size - pdu->offset, size);
 	memcpy(data, &pdu->sdata[pdu->offset], len);
 	pdu->offset += len;
 	return size - len;
@@ -112,7 +97,7 @@ static size_t pdu_read(struct p9_fcall *pdu, void *data, size_t size)
 
 static size_t pdu_write(struct p9_fcall *pdu, const void *data, size_t size)
 {
-	size_t len = MIN(pdu->capacity - pdu->size, size);
+	size_t len = min(pdu->capacity - pdu->size, size);
 	memcpy(&pdu->sdata[pdu->size], data, len);
 	pdu->size += len;
 	return size - len;
@@ -121,7 +106,7 @@ static size_t pdu_write(struct p9_fcall *pdu, const void *data, size_t size)
 static size_t
 pdu_write_u(struct p9_fcall *pdu, const char __user *udata, size_t size)
 {
-	size_t len = MIN(pdu->capacity - pdu->size, size);
+	size_t len = min(pdu->capacity - pdu->size, size);
 	if (copy_from_user(&pdu->sdata[pdu->size], udata, len))
 		len = 0;
 
@@ -201,7 +186,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				if (errcode)
 					break;
 
-				size = MAX(len, 0);
+				size = max_t(int16_t, len, 0);
 
 				*sptr = kmalloc(size + 1, GFP_KERNEL);
 				if (*sptr == NULL) {
@@ -256,8 +241,8 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				    p9pdu_readf(pdu, proto_version, "d", count);
 				if (!errcode) {
 					*count =
-					    MIN(*count,
-						pdu->size - pdu->offset);
+					    min_t(int32_t, *count,
+						  pdu->size - pdu->offset);
 					*data = &pdu->sdata[pdu->offset];
 				}
 			}
@@ -421,7 +406,7 @@ p9pdu_vwritef(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				const char *sptr = va_arg(ap, const char *);
 				int16_t len = 0;
 				if (sptr)
-					len = MIN(strlen(sptr), USHRT_MAX);
+					len = min_t(int16_t, strlen(sptr), USHRT_MAX);
 
 				errcode = p9pdu_writef(pdu, proto_version,
 								"w", len);
-- 
1.7.3.2.343.g7d43d
