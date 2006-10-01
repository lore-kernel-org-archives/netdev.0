From: akpm@osdl.org
Subject: [patch 1/2] bluetooth: guard bt_proto with rwlock
Date: Sat, 30 Sep 2006 20:43:16 -0700
Message-ID: <200610010343.k913hGh6007183@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jet@gyve.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4584 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751824AbWJADnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 23:43:32 -0400
To: arcel@holtmann.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masatake YAMATO <jet@gyve.org>

I found that bt_proto manipulated in bt_sock_register is not guarded
from race condition.

Look at net/bluetooth/af_bluetooth.c:

    static struct net_proto_family *bt_proto[BT_MAX_PROTO];

    int bt_sock_register(int proto, struct net_proto_family *ops)
    {
	    if (proto < 0 || proto >= BT_MAX_PROTO)
		    return -EINVAL;

	    if (bt_proto[proto])
		    return -EEXIST;

	    bt_proto[proto] = ops;
	    return 0;
    }

Here bt_proto[proto] is set.

In other hand,

    static int bt_sock_create(struct socket *sock, int proto)
    {
	    int err = 0;

	    if (proto < 0 || proto >= BT_MAX_PROTO)
		    return -EINVAL;

    #if defined(CONFIG_KMOD)
	    if (!bt_proto[proto]) {
		    request_module("bt-proto-%d", proto);
	    }
    #endif
	    err = -EPROTONOSUPPORT;
	    if (bt_proto[proto] && try_module_get(bt_proto[proto]->owner)) {
		    err = bt_proto[proto]->create(sock, proto);
		    module_put(bt_proto[proto]->owner);
	    }
	    return err;
    }

bt_proto[proto] is referred.

So I wrote a patch which guards bt_proto with rwlock.

Signed-off-by: Masatake YAMATO <jet@gyve.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/bluetooth/af_bluetooth.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff -puN net/bluetooth/af_bluetooth.c~bluetooth-guard-bt_proto-with-rwlock net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c~bluetooth-guard-bt_proto-with-rwlock
+++ a/net/bluetooth/af_bluetooth.c
@@ -26,6 +26,7 @@
 
 #include <linux/module.h>
 
+#include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/errno.h>
@@ -53,30 +54,44 @@
 /* Bluetooth sockets */
 #define BT_MAX_PROTO	8
 static struct net_proto_family *bt_proto[BT_MAX_PROTO];
+static DEFINE_RWLOCK(bt_proto_rwlock);
 
 int bt_sock_register(int proto, struct net_proto_family *ops)
 {
+	int err;
+
 	if (proto < 0 || proto >= BT_MAX_PROTO)
 		return -EINVAL;
 
-	if (bt_proto[proto])
-		return -EEXIST;
+	err = -EEXIST;
 
-	bt_proto[proto] = ops;
-	return 0;
+	write_lock(&bt_proto_rwlock);
+	if (bt_proto[proto] == NULL) {
+		err = 0;
+		bt_proto[proto] = ops;
+	}
+	write_unlock(&bt_proto_rwlock);
+
+	return err;
 }
 EXPORT_SYMBOL(bt_sock_register);
 
 int bt_sock_unregister(int proto)
 {
+	int err;
+
 	if (proto < 0 || proto >= BT_MAX_PROTO)
 		return -EINVAL;
 
-	if (!bt_proto[proto])
-		return -ENOENT;
+	err = -ENOENT;
+	write_lock(&bt_proto_rwlock);
+	if (bt_proto[proto]) {
+		err = 0;
+		bt_proto[proto] = NULL;
+	}
+	write_unlock(&bt_proto_rwlock);
 
-	bt_proto[proto] = NULL;
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL(bt_sock_unregister);
 
@@ -93,10 +108,12 @@ static int bt_sock_create(struct socket 
 	}
 #endif
 	err = -EPROTONOSUPPORT;
+	read_lock(&bt_proto_rwlock);
 	if (bt_proto[proto] && try_module_get(bt_proto[proto]->owner)) {
 		err = bt_proto[proto]->create(sock, proto);
 		module_put(bt_proto[proto]->owner);
 	}
+	read_unlock(&bt_proto_rwlock);
 	return err; 
 }
 
_
