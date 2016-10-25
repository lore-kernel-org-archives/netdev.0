From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next] net: add an ioctl to get a socket network namespace
Date: Mon, 24 Oct 2016 18:29:13 -0700
Message-ID: <1477358953-3547-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Each socket operates in a network namespace where it has been created,
so if we want to dump and restore a socket, we have to know its network
namespace.

We have a socket_diag to get information about sockets, it doesn't
report sockets which are not bound or connected.

This patch introduces a new socket ioctl, which is called SIOCGSKNS
and used to get a file descriptor for a socket network namespace.

A task must have CAP_NET_ADMIN in a target network namespace to
use this ioctl.

Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 fs/nsfs.c                    |  2 +-
 include/linux/proc_fs.h      |  4 ++++
 include/uapi/linux/sockios.h |  1 +
 net/socket.c                 | 13 +++++++++++++
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index 8718af8..8c9fb29 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -118,7 +118,7 @@ void *ns_get_path(struct path *path, struct task_struct *task,
 	return ret;
 }
 
-static int open_related_ns(struct ns_common *ns,
+int open_related_ns(struct ns_common *ns,
 		   struct ns_common *(*get_ns)(struct ns_common *ns))
 {
 	struct path path = {};
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index b97bf2e..368c7ad 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -82,4 +82,8 @@ static inline struct proc_dir_entry *proc_net_mkdir(
 	return proc_mkdir_data(name, 0, parent, net);
 }
 
+struct ns_common;
+int open_related_ns(struct ns_common *ns,
+		   struct ns_common *(*get_ns)(struct ns_common *ns));
+
 #endif /* _LINUX_PROC_FS_H */
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 8e7890b..83cc54c 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -84,6 +84,7 @@
 #define SIOCWANDEV	0x894A		/* get/set netdev parameters	*/
 
 #define SIOCOUTQNSD	0x894B		/* output queue size (not sent only) */
+#define SIOCGSKNS	0x894C		/* get socket network namespace */
 
 /* ARP cache control calls. */
 		    /*  0x8950 - 0x8952  * obsolete calls, don't re-use */
diff --git a/net/socket.c b/net/socket.c
index 5a9bf5e..970a7ea 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -877,6 +877,11 @@ static long sock_do_ioctl(struct net *net, struct socket *sock,
  *	what to do with it - that's up to the protocol still.
  */
 
+static struct ns_common *get_net_ns(struct ns_common *ns)
+{
+	return &get_net(container_of(ns, struct net, ns))->ns;
+}
+
 static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 {
 	struct socket *sock;
@@ -945,6 +950,13 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 				err = dlci_ioctl_hook(cmd, argp);
 			mutex_unlock(&dlci_ioctl_mutex);
 			break;
+		case SIOCGSKNS:
+			err = -EPERM;
+			if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+				break;
+
+			err = open_related_ns(&net->ns, get_net_ns);
+			break;
 		default:
 			err = sock_do_ioctl(net, sock, cmd, arg);
 			break;
@@ -3093,6 +3105,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCSIFVLAN:
 	case SIOCADDDLCI:
 	case SIOCDELDLCI:
+	case SIOCGSKNS:
 		return sock_ioctl(file, cmd, arg);
 
 	case SIOCGIFFLAGS:
-- 
2.7.4
