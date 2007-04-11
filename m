From: David Howells <dhowells@redhat.com>
Subject: [PATCH 6/8] AFS: AF_RXRPC key changes
Date: Wed, 11 Apr 2007 20:10:27 +0100
Message-ID: <20070411191027.15499.8147.stgit@warthog.cambridge.redhat.com>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make two changes to the AF_RXRPC key handling to make it easier for AFS to
use:

 (1) Export key_type_rxrpc so that AFS can request keys of this type.

 (2) Make it possible to have keys that represent "no security".  These are
     created by instantiating the keys with no data.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 include/keys/rxrpc-type.h |   22 ++++++++++++++++++++++
 net/rxrpc/af_rxrpc.c      |    2 ++
 net/rxrpc/ar-key.c        |   10 +++++++++-
 net/rxrpc/ar-output.c     |    6 +++++-
 4 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
new file mode 100644
index 0000000..e2ee73a
--- /dev/null
+++ b/include/keys/rxrpc-type.h
@@ -0,0 +1,22 @@
+/* RxRPC key type
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _KEYS_RXRPC_TYPE_H
+#define _KEYS_RXRPC_TYPE_H
+
+#include <linux/key.h>
+
+/*
+ * key type for AF_RXRPC keys
+ */
+extern struct key_type key_type_rxrpc;
+
+#endif /* _KEYS_USER_TYPE_H */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 115ad19..9e37e4f 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -299,6 +299,8 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 
 	if (!key)
 		key = rx->key;
+	if (key && !key->payload.data)
+		key = NULL; /* a no-security key */
 
 	bundle = rxrpc_get_bundle(rx, trans, key, service_id, gfp);
 	if (IS_ERR(bundle)) {
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 869a96c..7e049ff 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -19,6 +19,7 @@
 #include <linux/crypto.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
+#include <keys/rxrpc-type.h>
 #include <keys/user-type.h>
 #include "ar-internal.h"
 
@@ -40,6 +41,8 @@ struct key_type key_type_rxrpc = {
 	.describe	= rxrpc_describe,
 };
 
+EXPORT_SYMBOL(key_type_rxrpc);
+
 /*
  * rxrpc server defined keys take "<serviceId>:<securityIndex>" as the
  * description and an 8-byte decryption key as the payload
@@ -63,6 +66,8 @@ struct key_type key_type_rxrpc_s = {
  *	12	4	kvno
  *	16	8	session key
  *	24	[len]	ticket
+ *
+ * if no data is provided, then a no-security key is made
  */
 static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 {
@@ -74,6 +79,10 @@ static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 
 	_enter("{%x},,%zu", key_serial(key), datalen);
 
+	/* handle a no-security key */
+	if (!data && datalen == 0)
+		return 0;
+
 	/* get the key interface version number */
 	ret = -EINVAL;
 	if (datalen <= 4 || !data)
@@ -287,7 +296,6 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 		struct rxkad_key tsec;
 	} data;
 
-
 	_enter("");
 
 	key = key_alloc(&key_type_rxrpc, "x", 0, 0, current, 0,
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index ed7f3f4..d2d0baa 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -132,6 +132,7 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
+	struct key *key;
 	__be16 service_id;
 	u32 abort_code = 0;
 	int ret;
@@ -153,7 +154,10 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 				(struct sockaddr_rxrpc *) msg->msg_name;
 			service_id = htons(srx->srx_service);
 		}
-		bundle = rxrpc_get_bundle(rx, trans, rx->key, service_id,
+		key = rx->key;
+		if (key && !rx->key->payload.data)
+			key = NULL;
+		bundle = rxrpc_get_bundle(rx, trans, key, service_id,
 					  GFP_KERNEL);
 		if (IS_ERR(bundle))
 			return PTR_ERR(bundle);

