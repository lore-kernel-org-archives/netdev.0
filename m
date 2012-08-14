From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v3 3/6] cgroup: Update classid for fd pass in SCM_RIGHTS datagramm
Date: Tue, 14 Aug 2012 15:02:20 +0200
Message-ID: <1344949343-26090-5-git-send-email-wagi@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344949343-26090-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

A socket fd passed in a SCM_RIGHTS datagram was not getting
updated with the new tasks cgrp classid. This leaves IO on
the socket tagged with the old tasks classid.

To fix this add a check in the scm recvmsg path to update the
sock cgrp classid with the new tasks value.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 net/core/scm.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 8f6ccfd..221080f 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -35,7 +35,7 @@
 #include <net/sock.h>
 #include <net/compat.h>
 #include <net/scm.h>
-
+#include <net/cls_cgroup.h>
 
 /*
  *	Only allow a user to send credentials, that they could set with
@@ -249,6 +249,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 	struct file **fp = scm->fp->fp;
 	int __user *cmfptr;
 	int err = 0, i;
+	__u32 classid = task_cls_classid(current);
 
 	if (MSG_CMSG_COMPAT & msg->msg_flags) {
 		scm_detach_fds_compat(msg, scm);
@@ -265,6 +266,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 	for (i=0, cmfptr=(__force int __user *)CMSG_DATA(cm); i<fdmax;
 	     i++, cmfptr++)
 	{
+		struct socket *sock;
 		int new_fd;
 		err = security_file_receive(fp[i]);
 		if (err)
@@ -282,6 +284,9 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		/* Bump the usage count and install the file. */
 		get_file(fp[i]);
 		fd_install(new_fd, fp[i]);
+		sock = sock_from_file(fp[i], &err);
+		if (sock)
+			sock->sk->sk_classid = classid;
 	}
 
 	if (i > 0)
-- 
1.7.12.rc1.16.g05a20c8
