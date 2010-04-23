From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] [RFC] Add sock_create_kern_net()
Date: Fri, 23 Apr 2010 07:55:37 -0700
Message-ID: <1272034539-19899-3-git-send-email-danms@us.ibm.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272034539-19899-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This helper allows kernel routines to create a socket in a given netns,
instead of forcing it to the initial or current one.

I know this seems like it's violating the netns boundary.  The intended
use (as in the following patches) is specifically when talking to RTNETLINK
in another netns for the purposes of creating or examining resources there.
It is expected that this will be used for that sort of transient socket
creation only.  In other words:

  s = sock_create_kern_net(AF_NETLINK, ..., other_netns, ...);
  rtnl_talk(s);
  close(s);

If this is acceptable, I will actually be able to clean up and simplify
other bits of the net checkpoint code to make better use of RTNL for
examining and restoring resources.

Perhaps we should assert that family == AF_NETLINK (or maybe just
printk(KERN_WARN) if it is not) to prevent abuse of this call?

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/net.h |    2 ++
 net/socket.c        |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 9548e45..9cfc899 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -235,6 +235,8 @@ extern int	     sock_create(int family, int type, int proto,
 				 struct socket **res);
 extern int	     sock_create_kern(int family, int type, int proto,
 				      struct socket **res);
+extern int	     sock_create_kern_net(int family, int type, int protocol,
+				      struct net *net, struct socket **res);
 extern int	     sock_create_lite(int family, int type, int proto,
 				      struct socket **res); 
 extern void	     sock_release(struct socket *sock);
diff --git a/net/socket.c b/net/socket.c
index 3253c04..95c94a7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1294,6 +1294,12 @@ int sock_create_kern(int family, int type, int protocol, struct socket **res)
 	return __sock_create(&init_net, family, type, protocol, res, 1);
 }
 
+int sock_create_kern_net(int family, int type, int protocol,
+			 struct net *net, struct socket **res)
+{
+	return __sock_create(net, family, type, protocol, res, 1);
+}
+
 SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 {
 	int retval;
-- 
1.6.2.5
