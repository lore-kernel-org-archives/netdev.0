From: Anton Blanchard <anton@samba.org>
Subject: recvmsg compat code
Date: Fri, 14 Mar 2003 06:24:57 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030313192457.GA3279@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, akpm@digeo.com, bcrl@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

The recent clean up of the duplicated recvmsg code (which I was happy to
see go in) broke my sshd.

It turns out compat handling of fd passing is broken. We were looking
for the MSG_CMSG_COMPAT flag in msg->msg_flags. I was just about to pass
down flags into the two problem functions, however put_cmsg is called
from a bunch of places.

Any thoughts?

Anton

===== net/core/scm.c 1.6 vs edited =====
--- 1.6/net/core/scm.c	Fri Mar  7 06:06:44 2003
+++ edited/net/core/scm.c	Fri Mar 14 06:18:03 2003
@@ -165,14 +165,15 @@
 	return err;
 }
 
-int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
+int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data,
+	     unsigned int flags)
 {
 	struct cmsghdr *cm = (struct cmsghdr*)msg->msg_control;
 	struct cmsghdr cmhdr;
 	int cmlen = CMSG_LEN(len);
 	int err;
 
-	if (MSG_CMSG_COMPAT & msg->msg_flags)
+	if (MSG_CMSG_COMPAT & flags)
 		return put_cmsg_compat(msg, level, type, len, data);
 
 	if (cm==NULL || msg->msg_controllen < sizeof(*cm)) {
@@ -200,7 +201,8 @@
 	return err;
 }
 
-void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
+void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm,
+		    unsigned long flags)
 {
 	struct cmsghdr *cm = (struct cmsghdr*)msg->msg_control;
 
@@ -210,7 +212,7 @@
 	int *cmfptr;
 	int err = 0, i;
 
-	if (MSG_CMSG_COMPAT & msg->msg_flags)
+	if (MSG_CMSG_COMPAT & flags)
 		return scm_detach_fds_compat(msg, scm);
 
 	if (msg->msg_controllen > sizeof(struct cmsghdr))
