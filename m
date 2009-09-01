From: David Ward <david.ward@ll.mit.edu>
Subject: [RFC] iproute2: gracefully exit from rtnl_listen()
Date: Tue,  1 Sep 2009 17:41:26 -0400
Message-ID: <1251841286-32463-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from LLMAIL1.LL.MIT.EDU ([129.55.12.41]:38359 "EHLO ll.mit.edu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752595AbZIAWYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 18:24:24 -0400
Received: (from smtp@localhost)
	by ll.mit.edu (8.12.10/8.8.8) id n81Lm05i008814
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2009 17:48:00 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_listen() (in iproute2's libnetlink) allows a userspace application to
monitor an RTNETLINK multicast group, so that the application can react to
changes in the kernel's routing table, neighbor cache, etc. as they occur.
(This is in contrast with using RTNETLINK to solicit the kernel for a full
copy of the routing table or neighbor cache at a specific point in time.)

However rtnl_listen() creates an infinite loop, which does not break in the
absence of errors, so there does not seem to be any way to gracefully exit
from it. Existing applications that call rtnl_listen(), such as rtmon, break
from this loop by terminating the entire application. There should be some
mechanism for stopping rtnl_listen() and continuing program execution.

If you assume that rtnl_listen() will only need to be stopped because the
application has received a signal (such as SIGINT), then the application's
signal handler can call rtnl_close() to close the RTNETLINK socket.
Afterwards, with this patch, rtnl_listen() can detect that the socket was
closed during the interrupt and exit.

I am offering this as a starting point for consideration, but I feel that
this is at best a poor solution. What is a better way to fix rtnl_listen()
(and similar libnetlink functions for consistency)?
---
 lib/libnetlink.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..afb5b23 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -196,8 +196,11 @@ int rtnl_dump_filter(struct rtnl_handle *rth,
 		status = recvmsg(rth->fd, &msg, 0);
 
 		if (status < 0) {
-			if (errno == EINTR || errno == EAGAIN)
+			if (errno == EINTR || errno == EAGAIN) {
+				if (rth->fd < 0)
+					return 0;
 				continue;
+			}
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
 			return -1;
@@ -300,8 +303,11 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 		status = recvmsg(rtnl->fd, &msg, 0);
 
 		if (status < 0) {
-			if (errno == EINTR || errno == EAGAIN)
+			if (errno == EINTR || errno == EAGAIN) {
+				if (rtnl->fd < 0)
+					return 0;
 				continue;
+			}
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
 			return -1;
@@ -405,8 +411,11 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		status = recvmsg(rtnl->fd, &msg, 0);
 
 		if (status < 0) {
-			if (errno == EINTR || errno == EAGAIN)
+			if (errno == EINTR || errno == EAGAIN) {
+				if (rtnl->fd < 0)
+					return 0;
 				continue;
+			}
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
 			return -1;
-- 
1.5.5.6

