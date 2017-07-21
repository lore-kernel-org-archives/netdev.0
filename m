From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] rxrpc: Expose UAPI definitions to userspace
Date: Fri, 21 Jul 2017 19:29:49 +0100
Message-ID: <150066178969.18902.18414855274319475080.stgit@warthog.procyon.org.uk>
References: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move UAPI definitions from the internal header and place them in a UAPI
header file so that userspace can make use of them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/rxrpc.h      |   79 -------------------------------------------
 include/uapi/linux/rxrpc.h |   80 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 79 deletions(-)
 delete mode 100644 include/linux/rxrpc.h
 create mode 100644 include/uapi/linux/rxrpc.h

diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
deleted file mode 100644
index 7343f71783dc..000000000000
--- a/include/linux/rxrpc.h
+++ /dev/null
@@ -1,79 +0,0 @@
-/* AF_RXRPC parameters
- *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef _LINUX_RXRPC_H
-#define _LINUX_RXRPC_H
-
-#include <linux/in.h>
-#include <linux/in6.h>
-
-/*
- * RxRPC socket address
- */
-struct sockaddr_rxrpc {
-	sa_family_t	srx_family;	/* address family */
-	u16		srx_service;	/* service desired */
-	u16		transport_type;	/* type of transport socket (SOCK_DGRAM) */
-	u16		transport_len;	/* length of transport address */
-	union {
-		sa_family_t family;		/* transport address family */
-		struct sockaddr_in sin;		/* IPv4 transport address */
-		struct sockaddr_in6 sin6;	/* IPv6 transport address */
-	} transport;
-};
-
-/*
- * RxRPC socket options
- */
-#define RXRPC_SECURITY_KEY		1	/* [clnt] set client security key */
-#define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
-#define RXRPC_EXCLUSIVE_CONNECTION	3	/* Deprecated; use RXRPC_EXCLUSIVE_CALL instead */
-#define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
-#define RXRPC_UPGRADEABLE_SERVICE	5	/* Upgrade service[0] -> service[1] */
-#define RXRPC_SUPPORTED_CMSG		6	/* Get highest supported control message type */
-
-/*
- * RxRPC control messages
- * - If neither abort or accept are specified, the message is a data message.
- * - terminal messages mean that a user call ID tag can be recycled
- * - s/r/- indicate whether these are applicable to sendmsg() and/or recvmsg()
- */
-enum rxrpc_cmsg_type {
-	RXRPC_USER_CALL_ID	= 1,	/* sr: user call ID specifier */
-	RXRPC_ABORT		= 2,	/* sr: abort request / notification [terminal] */
-	RXRPC_ACK		= 3,	/* -r: [Service] RPC op final ACK received [terminal] */
-	RXRPC_NET_ERROR		= 5,	/* -r: network error received [terminal] */
-	RXRPC_BUSY		= 6,	/* -r: server busy received [terminal] */
-	RXRPC_LOCAL_ERROR	= 7,	/* -r: local error generated [terminal] */
-	RXRPC_NEW_CALL		= 8,	/* -r: [Service] new incoming call notification */
-	RXRPC_ACCEPT		= 9,	/* s-: [Service] accept request */
-	RXRPC_EXCLUSIVE_CALL	= 10,	/* s-: Call should be on exclusive connection */
-	RXRPC_UPGRADE_SERVICE	= 11,	/* s-: Request service upgrade for client call */
-	RXRPC_TX_LENGTH		= 12,	/* s-: Total length of Tx data */
-	RXRPC__SUPPORTED
-};
-
-/*
- * RxRPC security levels
- */
-#define RXRPC_SECURITY_PLAIN	0	/* plain secure-checksummed packets only */
-#define RXRPC_SECURITY_AUTH	1	/* authenticated packets */
-#define RXRPC_SECURITY_ENCRYPT	2	/* encrypted packets */
-
-/*
- * RxRPC security indices
- */
-#define RXRPC_SECURITY_NONE	0	/* no security protocol */
-#define RXRPC_SECURITY_RXKAD	2	/* kaserver or kerberos 4 */
-#define RXRPC_SECURITY_RXGK	4	/* gssapi-based */
-#define RXRPC_SECURITY_RXK5	5	/* kerberos 5 */
-
-#endif /* _LINUX_RXRPC_H */
diff --git a/include/uapi/linux/rxrpc.h b/include/uapi/linux/rxrpc.h
new file mode 100644
index 000000000000..08e2fb9c70ae
--- /dev/null
+++ b/include/uapi/linux/rxrpc.h
@@ -0,0 +1,80 @@
+/* Types and definitions for AF_RXRPC.
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_RXRPC_H
+#define _UAPI_LINUX_RXRPC_H
+
+#include <linux/types.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+
+/*
+ * RxRPC socket address
+ */
+struct sockaddr_rxrpc {
+	sa_family_t	srx_family;	/* address family */
+	u16		srx_service;	/* service desired */
+	u16		transport_type;	/* type of transport socket (SOCK_DGRAM) */
+	u16		transport_len;	/* length of transport address */
+	union {
+		sa_family_t family;		/* transport address family */
+		struct sockaddr_in sin;		/* IPv4 transport address */
+		struct sockaddr_in6 sin6;	/* IPv6 transport address */
+	} transport;
+};
+
+/*
+ * RxRPC socket options
+ */
+#define RXRPC_SECURITY_KEY		1	/* [clnt] set client security key */
+#define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
+#define RXRPC_EXCLUSIVE_CONNECTION	3	/* Deprecated; use RXRPC_EXCLUSIVE_CALL instead */
+#define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */
+#define RXRPC_UPGRADEABLE_SERVICE	5	/* Upgrade service[0] -> service[1] */
+#define RXRPC_SUPPORTED_CMSG		6	/* Get highest supported control message type */
+
+/*
+ * RxRPC control messages
+ * - If neither abort or accept are specified, the message is a data message.
+ * - terminal messages mean that a user call ID tag can be recycled
+ * - s/r/- indicate whether these are applicable to sendmsg() and/or recvmsg()
+ */
+enum rxrpc_cmsg_type {
+	RXRPC_USER_CALL_ID	= 1,	/* sr: user call ID specifier */
+	RXRPC_ABORT		= 2,	/* sr: abort request / notification [terminal] */
+	RXRPC_ACK		= 3,	/* -r: [Service] RPC op final ACK received [terminal] */
+	RXRPC_NET_ERROR		= 5,	/* -r: network error received [terminal] */
+	RXRPC_BUSY		= 6,	/* -r: server busy received [terminal] */
+	RXRPC_LOCAL_ERROR	= 7,	/* -r: local error generated [terminal] */
+	RXRPC_NEW_CALL		= 8,	/* -r: [Service] new incoming call notification */
+	RXRPC_ACCEPT		= 9,	/* s-: [Service] accept request */
+	RXRPC_EXCLUSIVE_CALL	= 10,	/* s-: Call should be on exclusive connection */
+	RXRPC_UPGRADE_SERVICE	= 11,	/* s-: Request service upgrade for client call */
+	RXRPC_TX_LENGTH		= 12,	/* s-: Total length of Tx data */
+	RXRPC__SUPPORTED
+};
+
+/*
+ * RxRPC security levels
+ */
+#define RXRPC_SECURITY_PLAIN	0	/* plain secure-checksummed packets only */
+#define RXRPC_SECURITY_AUTH	1	/* authenticated packets */
+#define RXRPC_SECURITY_ENCRYPT	2	/* encrypted packets */
+
+/*
+ * RxRPC security indices
+ */
+#define RXRPC_SECURITY_NONE	0	/* no security protocol */
+#define RXRPC_SECURITY_RXKAD	2	/* kaserver or kerberos 4 */
+#define RXRPC_SECURITY_RXGK	4	/* gssapi-based */
+#define RXRPC_SECURITY_RXK5	5	/* kerberos 5 */
+
+#endif /* _UAPI_LINUX_RXRPC_H */
