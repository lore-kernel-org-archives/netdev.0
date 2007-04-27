From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] AF_RXRPC/AFS: Arch-specific fixes
Date: Fri, 27 Apr 2007 15:31:40 +0100
Message-ID: <20070427143140.23545.37397.stgit@warthog.cambridge.redhat.com>
References: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbXD0Obs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 10:31:48 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3REVlM8030705
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 10:31:47 -0400
In-Reply-To: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes for various arch compilation problems:

 (*) Missing module exports.

 (*) Variable name collision when rxkad and af_rxrpc both built in
     (rxrpc_debug).

 (*) Large constant representation problem (AFS_UUID_TO_UNIX_TIME).

 (*) Configuration dependencies.

 (*) printk() format warnings.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 arch/ia64/lib/csum_partial_copy.c |    2 ++
 fs/Kconfig                        |    1 +
 fs/afs/internal.h                 |    2 +-
 fs/afs/rxrpc.c                    |    2 +-
 fs/afs/use-rtnetlink.c            |    2 +-
 net/rxrpc/Kconfig                 |    5 +++++
 net/rxrpc/rxkad.c                 |    1 +
 7 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/lib/csum_partial_copy.c b/arch/ia64/lib/csum_partial_copy.c
index 503dfe6..118daf5 100644
--- a/arch/ia64/lib/csum_partial_copy.c
+++ b/arch/ia64/lib/csum_partial_copy.c
@@ -128,6 +128,8 @@ csum_partial_copy_from_user(const void __user *src, void *dst,
 	return (__force __wsum)result;
 }
 
+EXPORT_SYMBOL(csum_partial_copy_from_user);
+
 __wsum
 csum_partial_copy_nocheck(const void *src, void *dst, int len, __wsum sum)
 {
diff --git a/fs/Kconfig b/fs/Kconfig
index e33c089..a42f767 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -2020,6 +2020,7 @@ config AFS_FS
 	tristate "Andrew File System support (AFS) (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
 	select AF_RXRPC
+	select KEYS
 	help
 	  If you say Y here, you will get an experimental Andrew File System
 	  driver. It currently only supports unsecured read-only AFS access.
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 6dd3197..34665f7 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -367,7 +367,7 @@ struct afs_uuid {
 	u32		time_low;			/* low part of timestamp */
 	u16		time_mid;			/* mid part of timestamp */
 	u16		time_hi_and_version;		/* high part of timestamp and version  */
-#define AFS_UUID_TO_UNIX_TIME	0x01b21dd213814000
+#define AFS_UUID_TO_UNIX_TIME	0x01b21dd213814000ULL
 #define AFS_UUID_TIMEHI_MASK	0x0fff
 #define AFS_UUID_VERSION_TIME	0x1000	/* time-based UUID */
 #define AFS_UUID_VERSION_NAME	0x3000	/* name-based UUID */
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index e7b0473..222c1a3 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -772,7 +772,7 @@ int afs_extract_data(struct afs_call *call, struct sk_buff *skb,
 
 	if (call->offset < count) {
 		if (last) {
-			_leave(" = -EBADMSG [%d < %lu]", call->offset, count);
+			_leave(" = -EBADMSG [%d < %zu]", call->offset, count);
 			return -EBADMSG;
 		}
 		_leave(" = -EAGAIN");
diff --git a/fs/afs/use-rtnetlink.c b/fs/afs/use-rtnetlink.c
index 82f0daa..f8991c7 100644
--- a/fs/afs/use-rtnetlink.c
+++ b/fs/afs/use-rtnetlink.c
@@ -243,7 +243,7 @@ static int afs_read_rtm(struct afs_rtm_desc *desc)
 		desc->datalen = kernel_recvmsg(desc->nlsock, &msg, iov, 1,
 					       desc->datamax, 0);
 		if (desc->datalen < 0) {
-			_leave(" = %ld [recv]", desc->datalen);
+			_leave(" = %zd [recv]", desc->datalen);
 			return desc->datalen;
 		}
 
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index d72380e..8750f6d 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -30,6 +30,11 @@ config AF_RXRPC_DEBUG
 config RXKAD
 	tristate "RxRPC Kerberos security"
 	depends on AF_RXRPC && KEYS
+	select CRYPTO
+	select CRYPTO_MANAGER
+	select CRYPTO_BLKCIPHER
+	select CRYPTO_PCBC
+	select CRYPTO_FCRYPT
 	help
 	  Provide kerberos 4 and AFS kaserver security handling for AF_RXRPC
 	  through the use of the key retention service.
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 1eaf529..5ec7051 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -18,6 +18,7 @@
 #include <linux/ctype.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
+#define rxrpc_debug rxkad_debug
 #include "ar-internal.h"
 
 #define RXKAD_VERSION			2

