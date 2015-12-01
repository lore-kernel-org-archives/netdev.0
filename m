From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v4 2/4] net: diag: Add the ability to destroy a socket from userspace.
Date: Tue,  1 Dec 2015 16:04:24 +0900
Message-ID: <1448953466-132321-2-git-send-email-lorenzo@google.com>
References: <1448953466-132321-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34603 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbbLAHEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 02:04:42 -0500
Received: by padhx2 with SMTP id hx2so212379246pad.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 23:04:42 -0800 (PST)
In-Reply-To: <1448953466-132321-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows a privileged userspace process, such as a connection
manager or system administration tool, to close sockets belonging
to other apps when the network they were established on has
disconnected. It is needed on laptops and mobile hosts to ensure
that network switches / disconnects do not result in applications
being blocked for long periods of time (minutes) in read or
connect calls on TCP sockets that will never succeed because the
IP address they are bound to is no longer on the system. Closing
the sockets causes these calls to fail fast and allows the apps
to reconnect on another network.

For many years Android kernels have supported this via an
out-of-tree SIOCKILLADDR ioctl that is called on every
RTM_DELADDR event, but this solution is cleaner, more robust and
more flexible: the connection manager can iterate over all
connections on the deleted IP address and close all of them. It
can also be used to close all sockets opened by a given app
process, for example if the user has restricted that app from
using the network.

This patch adds a SOCK_DESTROY operation and a destroy function
pointer to sock_diag_handler. It does not include any
implementation code.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/sock_diag.h      |  1 +
 include/uapi/linux/sock_diag.h |  1 +
 net/core/sock_diag.c           | 11 ++++++++---
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index fddebc6..e15e8e2 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -15,6 +15,7 @@ struct sock_diag_handler {
 	__u8 family;
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
 	int (*get_info)(struct sk_buff *skb, struct sock *sk);
+	int (*destroy)(struct sk_buff *skb, struct nlmsghdr *nlh);
 };
 
 int sock_diag_register(const struct sock_diag_handler *h);
diff --git a/include/uapi/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
index 49230d3..bae2d80 100644
--- a/include/uapi/linux/sock_diag.h
+++ b/include/uapi/linux/sock_diag.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 #define SOCK_DIAG_BY_FAMILY 20
+#define SOCK_DESTROY 21
 
 struct sock_diag_req {
 	__u8	sdiag_family;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 0c1d58d..64e3d81 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -214,7 +214,7 @@ void sock_diag_unregister(const struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
-static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
 	struct sock_diag_req *req = nlmsg_data(nlh);
@@ -234,8 +234,12 @@ static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	hndl = sock_diag_handlers[req->sdiag_family];
 	if (hndl == NULL)
 		err = -ENOENT;
-	else
+	else if (nlh->nlmsg_type == SOCK_DIAG_BY_FAMILY)
 		err = hndl->dump(skb, nlh);
+	else if (nlh->nlmsg_type == SOCK_DESTROY && hndl->destroy)
+		err = hndl->destroy(skb, nlh);
+	else
+		err = -EOPNOTSUPP;
 	mutex_unlock(&sock_diag_table_mutex);
 
 	return err;
@@ -261,7 +265,8 @@ static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		return ret;
 	case SOCK_DIAG_BY_FAMILY:
-		return __sock_diag_rcv_msg(skb, nlh);
+	case SOCK_DESTROY:
+		return __sock_diag_cmd(skb, nlh);
 	default:
 		return -EINVAL;
 	}
-- 
2.6.0.rc2.230.g3dd15c0
