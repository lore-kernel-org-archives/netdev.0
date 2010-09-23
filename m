From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 8/8] net: Implement socketat.
Date: Thu, 23 Sep 2010 01:51:59 -0700
Message-ID: <m1bp7oq1u8.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
        Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
        linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ocborgq7.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org> (Eric W. Biederman's message
	of "Thu, 23 Sep 2010 01:45:04 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


Add a system call for creating sockets in a specified network namespace.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/socket.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 2270b94..1116f3c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1269,7 +1269,7 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 }
 EXPORT_SYMBOL(sock_create_kern);
 
-SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
+static int do_socket(struct net *net, int family, int type, int protocol)
 {
 	int retval;
 	struct socket *sock;
@@ -1289,7 +1289,7 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
 		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
-	retval = sock_create(family, type, protocol, &sock);
+	retval = __sock_create(net, family, type, protocol, &sock, 0);
 	if (retval < 0)
 		goto out;
 
@@ -1306,6 +1306,28 @@ out_release:
 	return retval;
 }
 
+SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
+{
+	return do_socket(current->nsproxy->net_ns, family, type, protocol);
+}
+
+SYSCALL_DEFINE4(socketat, int, fd, int, family, int, type, int, protocol)
+{
+	struct net *net;
+	int retval;
+
+	if (fd == -1) {
+		net = get_net(current->nsproxy->net_ns);
+	} else {
+		net = get_net_ns_by_fd(fd);
+		if (IS_ERR(net))
+			return  PTR_ERR(net);
+	}
+	retval = do_socket(net, family, type, protocol);
+	put_net(net);
+	return retval;
+}
+
 /*
  *	Create a pair of connected sockets.
  */
-- 
1.6.5.2.143.g8cc62
