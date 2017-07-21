From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net/socket: fix type in assignment and trim long line
Date: Fri, 21 Jul 2017 18:49:45 +0200
Message-ID: <5226dfcbd13df441445da0caccae5867fdc80c4c.1500655551.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Al Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57918 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754665AbdGUQvi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 12:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit ffb07550c76f ("copy_msghdr_from_user(): get rid of
field-by-field copyin") introduce a new sparse warning:

net/socket.c:1919:27: warning: incorrect type in assignment (different address spaces)
net/socket.c:1919:27:    expected void *msg_control
net/socket.c:1919:27:    got void [noderef] <asn:1>*[addressable] msg_control

and a line above 80 chars, let's fix them

Fixes: ffb07550c76f ("copy_msghdr_from_user(): get rid of field-by-field copyin")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
I noticed only because I had a very similar commit pending;
replacing the field-by-field copyin with a single copy_from_user()
gives measurable performance improvements - more than 10% under
UDP flood if using recvmsg() to sink the traffic
---
 net/socket.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index bf21226..ad22df1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1916,7 +1916,7 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 	if (copy_from_user(&msg, umsg, sizeof(*umsg)))
 		return -EFAULT;
 
-	kmsg->msg_control = msg.msg_control;
+	kmsg->msg_control = (void __force *)msg.msg_control;
 	kmsg->msg_controllen = msg.msg_controllen;
 	kmsg->msg_flags = msg.msg_flags;
 
@@ -1935,7 +1935,8 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 
 	if (msg.msg_name && kmsg->msg_namelen) {
 		if (!save_addr) {
-			err = move_addr_to_kernel(msg.msg_name, kmsg->msg_namelen,
+			err = move_addr_to_kernel(msg.msg_name,
+						  kmsg->msg_namelen,
 						  kmsg->msg_name);
 			if (err < 0)
 				return err;
-- 
2.9.4
