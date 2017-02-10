From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] afs: Move UUID struct to linux/uuid.h
Date: Fri, 10 Feb 2017 16:46:18 +0000
Message-ID: <148674517884.6350.9783675457789471861.stgit@warthog.procyon.org.uk>
References: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148674517199.6350.17724845267620917182.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the afs_uuid struct to linux/uuid.h, rename it to uuid_v1 and change
the u16/u32 fields to __be16/__be32 instead so that the structure can be
cast to a 16-octet network-order buffer.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de
---

 fs/afs/cmservice.c   |   28 ++++++++++++++--------------
 fs/afs/internal.h    |   27 ++-------------------------
 fs/afs/main.c        |   25 +++++++++++++------------
 include/linux/uuid.h |   24 ++++++++++++++++++++++++
 4 files changed, 53 insertions(+), 51 deletions(-)

diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index e349a3316303..2edbdcbf6432 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -351,7 +351,7 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call)
 {
 	struct sockaddr_rxrpc srx;
 	struct afs_server *server;
-	struct afs_uuid *r;
+	struct uuid_v1 *r;
 	unsigned loop;
 	__be32 *b;
 	int ret;
@@ -381,15 +381,15 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call)
 		}
 
 		_debug("unmarshall UUID");
-		call->request = kmalloc(sizeof(struct afs_uuid), GFP_KERNEL);
+		call->request = kmalloc(sizeof(struct uuid_v1), GFP_KERNEL);
 		if (!call->request)
 			return -ENOMEM;
 
 		b = call->buffer;
 		r = call->request;
-		r->time_low			= ntohl(b[0]);
-		r->time_mid			= ntohl(b[1]);
-		r->time_hi_and_version		= ntohl(b[2]);
+		r->time_low			= b[0];
+		r->time_mid			= htons(ntohl(b[1]));
+		r->time_hi_and_version		= htons(ntohl(b[2]));
 		r->clock_seq_hi_and_reserved 	= ntohl(b[3]);
 		r->clock_seq_low		= ntohl(b[4]);
 
@@ -454,7 +454,7 @@ static int afs_deliver_cb_probe(struct afs_call *call)
 static void SRXAFSCB_ProbeUuid(struct work_struct *work)
 {
 	struct afs_call *call = container_of(work, struct afs_call, work);
-	struct afs_uuid *r = call->request;
+	struct uuid_v1 *r = call->request;
 
 	struct {
 		__be32	match;
@@ -477,7 +477,7 @@ static void SRXAFSCB_ProbeUuid(struct work_struct *work)
  */
 static int afs_deliver_cb_probe_uuid(struct afs_call *call)
 {
-	struct afs_uuid *r;
+	struct uuid_v1 *r;
 	unsigned loop;
 	__be32 *b;
 	int ret;
@@ -503,15 +503,15 @@ static int afs_deliver_cb_probe_uuid(struct afs_call *call)
 		}
 
 		_debug("unmarshall UUID");
-		call->request = kmalloc(sizeof(struct afs_uuid), GFP_KERNEL);
+		call->request = kmalloc(sizeof(struct uuid_v1), GFP_KERNEL);
 		if (!call->request)
 			return -ENOMEM;
 
 		b = call->buffer;
 		r = call->request;
-		r->time_low			= ntohl(b[0]);
-		r->time_mid			= ntohl(b[1]);
-		r->time_hi_and_version		= ntohl(b[2]);
+		r->time_low			= b[0];
+		r->time_mid			= htons(ntohl(b[1]));
+		r->time_hi_and_version		= htons(ntohl(b[2]));
 		r->clock_seq_hi_and_reserved 	= ntohl(b[3]);
 		r->clock_seq_low		= ntohl(b[4]);
 
@@ -569,9 +569,9 @@ static void SRXAFSCB_TellMeAboutYourself(struct work_struct *work)
 	memset(&reply, 0, sizeof(reply));
 	reply.ia.nifs = htonl(nifs);
 
-	reply.ia.uuid[0] = htonl(afs_uuid.time_low);
-	reply.ia.uuid[1] = htonl(afs_uuid.time_mid);
-	reply.ia.uuid[2] = htonl(afs_uuid.time_hi_and_version);
+	reply.ia.uuid[0] = afs_uuid.time_low;
+	reply.ia.uuid[1] = htonl(ntohs(afs_uuid.time_mid));
+	reply.ia.uuid[2] = htonl(ntohs(afs_uuid.time_hi_and_version));
 	reply.ia.uuid[3] = htonl((s8) afs_uuid.clock_seq_hi_and_reserved);
 	reply.ia.uuid[4] = htonl((s8) afs_uuid.clock_seq_low);
 	for (loop = 0; loop < 6; loop++)
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 65504e218d35..79061fa17168 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -19,6 +19,7 @@
 #include <linux/sched.h>
 #include <linux/fscache.h>
 #include <linux/backing-dev.h>
+#include <linux/uuid.h>
 #include <net/af_rxrpc.h>
 
 #include "afs.h"
@@ -407,30 +408,6 @@ struct afs_interface {
 	unsigned	mtu;		/* MTU of interface */
 };
 
-/*
- * UUID definition [internet draft]
- * - the timestamp is a 60-bit value, split 32/16/12, and goes in 100ns
- *   increments since midnight 15th October 1582
- *   - add AFS_UUID_TO_UNIX_TIME to convert unix time in 100ns units to UUID
- *     time
- * - the clock sequence is a 14-bit counter to avoid duplicate times
- */
-struct afs_uuid {
-	u32		time_low;			/* low part of timestamp */
-	u16		time_mid;			/* mid part of timestamp */
-	u16		time_hi_and_version;		/* high part of timestamp and version  */
-#define AFS_UUID_TO_UNIX_TIME	0x01b21dd213814000ULL
-#define AFS_UUID_TIMEHI_MASK	0x0fff
-#define AFS_UUID_VERSION_TIME	0x1000	/* time-based UUID */
-#define AFS_UUID_VERSION_NAME	0x3000	/* name-based UUID */
-#define AFS_UUID_VERSION_RANDOM	0x4000	/* (pseudo-)random generated UUID */
-	u8		clock_seq_hi_and_reserved;	/* clock seq hi and variant */
-#define AFS_UUID_CLOCKHI_MASK	0x3f
-#define AFS_UUID_VARIANT_STD	0x80
-	u8		clock_seq_low;			/* clock seq low */
-	u8		node[6];			/* spatially unique node ID (MAC addr) */
-};
-
 /*****************************************************************************/
 /*
  * cache.c
@@ -565,7 +542,7 @@ extern int afs_drop_inode(struct inode *);
  * main.c
  */
 extern struct workqueue_struct *afs_wq;
-extern struct afs_uuid afs_uuid;
+extern struct uuid_v1 afs_uuid;
 
 /*
  * misc.c
diff --git a/fs/afs/main.c b/fs/afs/main.c
index f8188feb03ad..a07c14df3fd1 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -31,7 +31,7 @@ static char *rootcell;
 module_param(rootcell, charp, 0);
 MODULE_PARM_DESC(rootcell, "root AFS cell name and VL server IP addr list");
 
-struct afs_uuid afs_uuid;
+struct uuid_v1 afs_uuid;
 struct workqueue_struct *afs_wq;
 
 /*
@@ -41,7 +41,7 @@ static int __init afs_get_client_UUID(void)
 {
 	struct timespec ts;
 	u64 uuidtime;
-	u16 clockseq;
+	u16 clockseq, hi_v;
 	int ret;
 
 	/* read the MAC address of one of the external interfaces and construct
@@ -53,22 +53,23 @@ static int __init afs_get_client_UUID(void)
 	getnstimeofday(&ts);
 	uuidtime = (u64) ts.tv_sec * 1000 * 1000 * 10;
 	uuidtime += ts.tv_nsec / 100;
-	uuidtime += AFS_UUID_TO_UNIX_TIME;
-	afs_uuid.time_low = uuidtime;
-	afs_uuid.time_mid = uuidtime >> 32;
-	afs_uuid.time_hi_and_version = (uuidtime >> 48) & AFS_UUID_TIMEHI_MASK;
-	afs_uuid.time_hi_and_version |= AFS_UUID_VERSION_TIME;
+	uuidtime += UUID_TO_UNIX_TIME;
+	afs_uuid.time_low = htonl(uuidtime);
+	afs_uuid.time_mid = htons(uuidtime >> 32);
+	hi_v = (uuidtime >> 48) & UUID_TIMEHI_MASK;
+	hi_v |= UUID_VERSION_TIME;
+	afs_uuid.time_hi_and_version = htons(hi_v);
 
 	get_random_bytes(&clockseq, 2);
 	afs_uuid.clock_seq_low = clockseq;
 	afs_uuid.clock_seq_hi_and_reserved =
-		(clockseq >> 8) & AFS_UUID_CLOCKHI_MASK;
-	afs_uuid.clock_seq_hi_and_reserved |= AFS_UUID_VARIANT_STD;
+		(clockseq >> 8) & UUID_CLOCKHI_MASK;
+	afs_uuid.clock_seq_hi_and_reserved |= UUID_VARIANT_STD;
 
 	_debug("AFS UUID: %08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
-	       afs_uuid.time_low,
-	       afs_uuid.time_mid,
-	       afs_uuid.time_hi_and_version,
+	       ntohl(afs_uuid.time_low),
+	       ntohs(afs_uuid.time_mid),
+	       ntohs(afs_uuid.time_hi_and_version),
 	       afs_uuid.clock_seq_hi_and_reserved,
 	       afs_uuid.clock_seq_low,
 	       afs_uuid.node[0], afs_uuid.node[1], afs_uuid.node[2],
diff --git a/include/linux/uuid.h b/include/linux/uuid.h
index 2d095fc60204..4dff73a89758 100644
--- a/include/linux/uuid.h
+++ b/include/linux/uuid.h
@@ -19,6 +19,30 @@
 #include <uapi/linux/uuid.h>
 
 /*
+ * V1 (time-based) UUID definition [RFC 4122].
+ * - the timestamp is a 60-bit value, split 32/16/12, and goes in 100ns
+ *   increments since midnight 15th October 1582
+ *   - add AFS_UUID_TO_UNIX_TIME to convert unix time in 100ns units to UUID
+ *     time
+ * - the clock sequence is a 14-bit counter to avoid duplicate times
+ */
+struct uuid_v1 {
+	__be32		time_low;			/* low part of timestamp */
+	__be16		time_mid;			/* mid part of timestamp */
+	__be16		time_hi_and_version;		/* high part of timestamp and version  */
+#define UUID_TO_UNIX_TIME	0x01b21dd213814000ULL
+#define UUID_TIMEHI_MASK	0x0fff
+#define UUID_VERSION_TIME	0x1000	/* time-based UUID */
+#define UUID_VERSION_NAME	0x3000	/* name-based UUID */
+#define UUID_VERSION_RANDOM	0x4000	/* (pseudo-)random generated UUID */
+	u8		clock_seq_hi_and_reserved;	/* clock seq hi and variant */
+#define UUID_CLOCKHI_MASK	0x3f
+#define UUID_VARIANT_STD	0x80
+	u8		clock_seq_low;			/* clock seq low */
+	u8		node[6];			/* spatially unique node ID (MAC addr) */
+};
+
+/*
  * The length of a UUID string ("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
  * not including trailing NUL.
  */
