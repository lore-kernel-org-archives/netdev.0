From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH] net: net_cls: fd passed in SCM_RIGHTS datagram not set correctly
Date: Mon, 21 Jan 2013 10:38:22 +0100
Message-ID: <1358761102-7765-1-git-send-email-wagi@monom.org>
Cc: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Commit 6a328d8c6f03501657ad580f6f98bf9a42583ff7 changed the update
logic for the socket but it does not update the SCM_RIGHTS update
as well. This patch is based on the net_prio fix commit

48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8

    net: netprio: fd passed in SCM_RIGHTS datagram not set correctly

    A socket fd passed in a SCM_RIGHTS datagram was not getting
    updated with the new tasks cgrp prioidx. This leaves IO on
    the socket tagged with the old tasks priority.

    To fix this add a check in the scm recvmsg path to update the
    sock cgrp prioidx with the new tasks value.

Let's apply the same fix for net_cls.

Reported-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 net/core/scm.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 57fb1ee..905dcc6 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -35,6 +35,7 @@
 #include <net/sock.h>
 #include <net/compat.h>
 #include <net/scm.h>
+#include <net/cls_cgroup.h>
 
 
 /*
@@ -302,8 +303,10 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		}
 		/* Bump the usage count and install the file. */
 		sock = sock_from_file(fp[i], &err);
-		if (sock)
+		if (sock) {
 			sock_update_netprioidx(sock->sk, current);
+			sock_update_classid(sock->sk, current);
+		}
 		fd_install(new_fd, get_file(fp[i]));
 	}
 
-- 
1.8.0.rc0
