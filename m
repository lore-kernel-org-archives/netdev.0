From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] net: recvmmsg: Strip MSG_WAITFORONE when calling recvmsg
Date: Tue, 17 May 2011 08:59:24 +1000
Message-ID: <20110517085924.3a47b8e2@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59921 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab1EPW73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 18:59:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


recvmmsg fails on a raw socket with EINVAL. The reason for this is
packet_recvmsg checks the incoming flags:

        err = -EINVAL;
        if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE))
                goto out;

This patch strips out MSG_WAITFORONE when calling recvmmsg which
fixes the issue.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable@kernel.org [2.6.34+]
---

We could also add MSG_WAITFORONE to the raw socket recvmsg check, or
just remove the check completely. Thoughts?

Index: linux-net/net/socket.c
===================================================================
--- linux-net.orig/net/socket.c	2011-05-09 08:59:22.757767314 +1000
+++ linux-net/net/socket.c	2011-05-16 17:14:52.501268819 +1000
@@ -2232,14 +2232,16 @@ int __sys_recvmmsg(int fd, struct mmsghd
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
 			err = __sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags & ~MSG_WAITFORONE,
+					    datagrams);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
 			++compat_entry;
 		} else {
 			err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
-					    &msg_sys, flags, datagrams);
+					    &msg_sys, flags & ~MSG_WAITFORONE,
+					    datagrams);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
