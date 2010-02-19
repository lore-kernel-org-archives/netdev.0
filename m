From: Florian Westphal <fwestphal@astaro.com>
Subject: [PATCH 5/5] net: sock_aio_write: set CMSG_MSG_COMPAT flag if is_compat_task
Date: Fri, 19 Feb 2010 13:41:47 +0100
Message-ID: <1266583307-3049-6-git-send-email-fwestphal@astaro.com>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Cc: johannes@sipsolutions.net, Florian Westphal <fwestphal@astaro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48625 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753489Ab0BSMls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:41:48 -0500
In-Reply-To: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

some programs (e.g. pluto ike daemon), send netlink data to the
kernel via write().

So far, the CMSG_MSG_COMPAT flag is not set in this case, which
results in the kernel interpreting the netlink data the wrong way.

An alternative solution is to switch userspace to sendmsg() when
using netlink sockets.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 no changes since v1.

 net/socket.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 769c386..e6a6a67 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -837,6 +837,10 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_iov = (struct iovec *)iov;
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
+#ifdef CONFIG_COMPAT
+	if (is_compat_task())
+		msg->msg_flags |= MSG_CMSG_COMPAT;
+#endif
 	if (sock->type == SOCK_SEQPACKET)
 		msg->msg_flags |= MSG_EOR;
 
-- 
1.6.3.3

